# WRF-Chem (`v4.6.1-middle-east`) Compilation Guide on Azure HPC Cluster

## 1. Quick Start (Slurm `n1` Partition)

Always submit WRF-Chem compilations to the **`n1` partition** (`443,596 MiB` / `~433 GiB` RAM, 120 AMD EPYC 7V73X cores per node) using [`compile_wrf_on_azure.sh`](file:///shared/home/sosipov/Models/WRF/compile_wrf_on_azure.sh):

```bash
cd /shared/home/sosipov/Models/WRF
sbatch compile_wrf_on_azure.sh
```

For a full clean rebuild while preserving [`configure.wrf`](file:///shared/home/sosipov/Models/WRF/configure.wrf):
```bash
source ~/.commonrc && gogowrfchem
cd /shared/home/sosipov/Models/WRF
cp configure.wrf configure.wrf.azure
./clean -a
cp configure.wrf.azure configure.wrf
sbatch compile_wrf_on_azure.sh
```

---

## 2. Why Compile on the `n1` Partition (Instead of Login Node or `serial`)

| Environment | CPUs | Memory Limit | Suitability for WRF-Chem (`ifx -O3 -ip`) |
| :--- | :--- | :--- | :--- |
| **Login Node** (`rccg-slurm-scheduler`) | 8 vCPUs | 31 GiB (0 Swap) | **Insufficient.** OOM-kills on `inc/allocs_*.f90` and `RSL_LITE/*_domain_em_*.f90`. |
| **Slurm `serial` Partition** | Max 16 CPUs | 59,136 MiB (~57.75 GiB) | **Insufficient for unthrottled parallel `-O3 -ip`.** Concurrent compilation of the 7 `RSL_LITE/*_domain_em_*.f90` files requires ~110 GB RAM (`OUT_OF_MEMORY` at 59,134 MiB unless serialized). |
| **Slurm `n1` Partition (Recommended)** | Up to 120 CPUs | **443,596 MiB (~433 GiB)** | **Ideal.** Easily accommodates all parallel memory spikes (~110 GB) with full `-O3 -ip` optimization and high `-j` parallelism. |

### Measured Memory & Timing Bottlenecks (`ifx 2024.2.1`, `-O3 -ip`)
1. **`external/RSL_LITE/*_domain_em_*.f90` (7 auto-generated nesting/halo files in `frame/`):**
   - Individual peak RSS under `ifx -O3 -ip`:
     - `interp_domain_em_part3.f90`: **25.5 GB** (~30s)
     - `feedback_domain_em_part1.f90`: **21.3 GB** (~29s)
     - `feedback_domain_em_part2.f90`: **19.3 GB** (~42s)
     - `force_domain_em_part2.f90`: **14.6 GB** (~26s)
     - `interp_domain_em_part2.f90`: **13.1 GB** (~23s)
     - `interp_domain_em_part1.f90`: **12.4 GB** (~22s)
     - `interp_domain_em_small.f90`: **4.4 GB** (~13s)
   - **Combined concurrent RSS:** **~110.6 GB** when all 7 run in parallel. On `n1` (~440 GB RAM), all 7 compile simultaneously in ~40 seconds without any Makefile serialization or `-O0` workarounds.
2. **`inc/allocs_0..31.f90` & `inc/deallocs_0..11.f90` (in `frame/`):**
   - Each process uses **3.7–6.8 GB RSS** under `-O3 -ip` (~49.5 GB total at `-j 16`).
3. **`frame/module_configure.f90` (193,188 lines; `inc/scalar_indices.inc` is 144,174 lines):**
   - Strict serial bottleneck in `frame/Makefile` (`module_domain.o` and `nl_get/set_0..7_routines.o` depend on `module_configure.mod`).
   - Takes ~15–18 minutes of single-core CPU time (`~1.9 GB` RSS) even with `FCNOOPT` (`-O0 -fno-inline -fno-ip`).

---

## 3. Environment & Toolchain Summary

Defined in [`/shared/home/sosipov/.commonrc`](file:///shared/home/sosipov/.commonrc):
- **`gogointelone`**: Loads Intel oneAPI Base & HPC Toolkits (`2024.2`) from `/shared/home/sosipov/.local/intel/oneapi/setvars.sh` and exports LLVM compilers (`CC=icx`, `CXX=icpx`, `FC=ifx`, `MPIFC=mpiifx`, `MPICC=mpiicx`, `MPICXX=mpiicpx`) and `/shared/home/sosipov/.local` library paths (`zlib 1.3.1`, `libpng 1.6.43`, `jasper 1.900.1`, `hdf5 1.14.3`, `netcdf-c 4.9.2`, `netcdf-fortran 4.6.1`, `tcsh 6.24.13`).
- **`gogowrfchem`**: Calls `gogointelone` and exports `NETCDF`, `HDF5`, `PHDF5`, `JASPERLIB`, `JASPERINC`, `WRF_DIR=/shared/home/sosipov/Models/WRF`, `WRF_EM_CORE=1`, `WRF_CHEM=1`, `WRF_KPP=1`, `WRFIO_NCD_LARGE_FILE_SUPPORT=1`, `FLEX_LIB_DIR=/usr/lib/x86_64-linux-gnu`, and `YACC="/usr/bin/byacc -d"`.

---

## 4. Required Intel oneAPI LLVM (`2024.2`) & KPP Fixes (Automated in [`compile_wrf_on_azure.sh`](file:///shared/home/sosipov/Models/WRF/compile_wrf_on_azure.sh))

1. **User-space `csh` Shebangs**: System `/bin/csh` is not installed on the cluster image; helper scripts are updated from `#!/bin/csh` to `#!/usr/bin/env csh` to resolve `/shared/home/sosipov/.local/bin/csh`.
2. **Intel MPI LLVM Wrappers**: `configure` option `78` (`INTEL (ifx/icx) : oneAPI LLVM`, `dmpar`) defaults to `mpif90`/`mpicc` (which invoke classic `ifort`/`icc`); replaced with `DM_FC = mpiifx` and `DM_CC = mpiicx`.
3. **`FCOPTIM` vs `FCNOOPT` Flag Ordering for `ifx`**:
   - Upstream `configure.defaults` puts `-ip` in `FCBASEOPTS_NO_G` and `-no-ip` in `FCNOOPT`. Because WRF's `noopt_exceptions` rules expand `$(FCNOOPT) $(FCBASEOPTS)`, trailing `-ip` overrides `-fno-ip` in LLVM `ifx`.
   - Moving `-ip` to `FCOPTIM = -O3 -ip` and using `FCNOOPT = -O0 -fno-inline -fno-ip` keeps `-O3 -ip` on all optimized files while properly disabling IPO on `noopt_exceptions` files (`module_configure.f90`, etc.).
4. **Clang 19 / `icx` C89 Compatibility for KPP & WKC**: Added `-Wno-implicit-function-declaration -Wno-implicit-int -Wno-return-type -Wno-incompatible-function-pointer-types` for KPP 2.1's legacy C89 code.
5. **Berkeley YACC for KPP**: Set `YACC=/usr/bin/byacc -d` in `chem/KPP/configure_kpp` (without quotes inside the `configure.kpp` Makefile heredoc) and removed `-ll` from `chem/KPP/kpp/kpp-2.1/src/Makefile`.
