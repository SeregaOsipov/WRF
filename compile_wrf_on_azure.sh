#!/bin/bash
#SBATCH --job-name=compile_wrf_chem
#SBATCH --partition=n1
#SBATCH --nodes=1
#SBATCH --ntasks=1
#SBATCH --cpus-per-task=32
#SBATCH --mem=440000M
#SBATCH --time=02:00:00
#SBATCH --output=/shared/home/sosipov/Models/WRF/slurm_compile_wrf_%j.out
#SBATCH --error=/shared/home/sosipov/Models/WRF/slurm_compile_wrf_%j.err
# ==============================================================================
# WRF-Chem (v4.6.1-middle-east, em_real + KPP) Build Script for Azure HPC Cluster
#
# Recommended usage (Slurm n1 partition, ~440 GiB RAM, full parallel build):
#   sbatch /shared/home/sosipov/Models/WRF/compile_wrf_on_azure.sh
#
# Why n1 partition instead of login node or serial partition:
#   - Login node (8 cores, 31 GiB RAM) and serial partition (16 cores, 58 GiB RAM)
#     cannot fit the concurrent peak RSS (~110 GB) of the 7 auto-generated
#     external/RSL_LITE/*_domain_em_*.f90 files under `ifx -O3 -ip` (10-25.5 GB each),
#     nor high-concurrency builds of inc/allocs_0..31.f90 (~49 GB at -j 16).
#   - The n1 partition provides 120 cores and 443,596 MiB (~433 GiB) RAM per node,
#     allowing unrestricted parallel compilation with full `-O3 -ip` optimization.
# ==============================================================================

set -eo pipefail

echo "============================================================"
echo "Host / Node    : $(hostname)"
echo "Slurm Job ID   : ${SLURM_JOB_ID:-interactive}"
echo "Partition      : ${SLURM_JOB_PARTITION:-none}"
echo "Allocated CPUs : ${SLURM_CPUS_PER_TASK:-$(nproc)}"
echo "Allocated Mem  : ${SLURM_MEM_PER_NODE:-system-default} MB"
echo "Start Time     : $(date)"
echo "============================================================"

# 1. Load Intel oneAPI (2024.2 LLVM: icx/icpx/ifx/mpiicx/mpiifx) & WRF-Chem env
source "${HOME}/.commonrc"
gogowrfchem

cd "${WRF_DIR:-/shared/home/sosipov/Models/WRF}"

# 2. Ensure csh/tcsh shebangs resolve user-space csh (${PREFIX}/bin/csh)
for f in clean compile chem/KPP/clean_kpp chem/KPP/compile_wkc chem/KPP/kpp/kpp-2.1/kpp_compile \
         chem/KPP/util/create_inc_files.csh chem/KPP/util/wkc/linker.csh \
         chem/KPP/util/write_decomp/write_decom.csh external/esmf_time_f90/testall.csh \
         external/fftpack/77to90.csh external/io_grib1/diffwrf; do
    if [ -f "$f" ]; then
        sed -i '1s|^#!/bin/csh -f|#!/usr/bin/env -S csh -f|; 1s|^#!/bin/csh|#!/usr/bin/env csh|' "$f"
    fi
done

# 3. Configure WRF if configure.wrf is not already present:
#    Option 78: INTEL (ifx/icx) : oneAPI LLVM (dmpar)
#    Nesting 1: basic
if [ ! -f configure.wrf ]; then
    ./configure <<EOF
78
1
EOF
fi

# 4. Apply Intel oneAPI LLVM (ifx/icx) adjustments to configure.wrf:
#    - Use mpiifx / mpiicx wrappers (mpif90/mpicc default to classic ifort/icc)
#    - Replace deprecated -no-ip with -fno-ip in FCNOOPT
#    - Place -ip in FCOPTIM (-O3 -ip) instead of FCBASEOPTS_NO_G so FCBASEOPTS
#      does not re-enable -ip after $(FCNOOPT) on module_configure.f90
#    - Add C89 compatibility flags for icx (Clang 19)
CONFIGURE_FILE=./configure.wrf
C89_COMPAT_FLAGS="-Wno-implicit-function-declaration -Wno-implicit-int -Wno-return-type -Wno-incompatible-function-pointer-types"

sed -i 's|^DM_FC.*|DM_FC           =       mpiifx|' "${CONFIGURE_FILE}"
sed -i 's|^DM_CC.*|DM_CC           =       mpiicx|' "${CONFIGURE_FILE}"
sed -i 's|-no-ip|-fno-ip|g' "${CONFIGURE_FILE}"
sed -i 's|^FCOPTIM.*|FCOPTIM         =       -O3 -ip|' "${CONFIGURE_FILE}"
sed -i 's|^FCBASEOPTS_NO_G =       -ip |FCBASEOPTS_NO_G =       |' "${CONFIGURE_FILE}"
if ! grep -q "Wno-implicit-function-declaration" "${CONFIGURE_FILE}"; then
    sed -i "/^CFLAGS_LOCAL/s/-O3/-O3 ${C89_COMPAT_FLAGS}/" "${CONFIGURE_FILE}"
fi

# 5. KPP / WKC adjustments for Berkeley YACC (/usr/bin/byacc -d) and LLVM icx C89 compatibility
sed -i 's/-ll //' chem/KPP/kpp/kpp-2.1/src/Makefile
sed -i 's|^#  YACC=.*|YACC=/usr/bin/byacc -d|; s|^YACC=.*|YACC=/usr/bin/byacc -d|' chem/KPP/configure_kpp
sed -i "0,/^CC_FLAGS=.*/s|^CC_FLAGS=.*|CC_FLAGS=\"-O0 ${C89_COMPAT_FLAGS}\"|" chem/KPP/configure_kpp
sed -i "s|^CFLAGS =.*|CFLAGS = ${C89_COMPAT_FLAGS}|" chem/KPP/util/wkc/Makefile
sed -i "s|^DEBUG =.*|DEBUG = -g ${C89_COMPAT_FLAGS}|" chem/KPP/util/wkc/Makefile.tuv
sed -i "s|^CFLAGS = \$(CC_TOOLS_CFLAGS).*|CFLAGS = \$(CC_TOOLS_CFLAGS) ${C89_COMPAT_FLAGS}|" tools/Makefile

# 6. Compile WRF-Chem (em_real)
NJOBS="${WRF_JOBS:-${SLURM_CPUS_PER_TASK:-$(nproc)}}"
echo "Compiling WRF-Chem (em_real) with -j ${NJOBS}..."
time ./compile -j "${NJOBS}" em_real 2>&1 | tee compile_em_real.log

# 7. Verify generated executables
ls -lh main/*.exe
echo "============================================================"
echo "Finished at    : $(date)"
echo "============================================================"
