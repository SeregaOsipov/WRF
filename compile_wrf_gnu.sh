#!/bin/sh

source /project/k10066/osipovs/.commonrc
gogowrfchem_gnu

sleep 1

# GET SOURCES
#rm -rf $DIR
#git clone --branch $WRF_VERSION https://github.com/wrf-model/WRF.git $DIR
#cd $DIR

./configure <<EOF
34
1
EOF

# This changes are implmented in the arch/configure.defaults
# See configure.defaults.gnu.shaheen

## CPE WRAPPERS
# sed -i 's/gcc/cc/' configure.wrf
# sed -i 's/mpicc/cc/' configure.wrf
# sed -i 's/gfortran/ftn/' configure.wrf
# sed -i 's/mpif90/ftn/' configure.wrf

## MANUAL MODIFICATIONS : works for gcc 12 (and 13)
CONFIGURE_FILE=./configure.wrf
# sed -i 's/^DM_CC.*/DM_CC           =       cc/' $CONFIGURE_FILE                                         # Update DM_CC to use "cc" compiler and remove "-cc=$(SCC)" from the configuration
# sed -i '/^FCOPTIM/s/=\( *\)/=\1-fallow-argument-mismatch /' $CONFIGURE_FILE                             # Add "-fallow-argument-mismatch" to FCOPTIM to allow argument mismatches
# sed -i '/^FCNOOPT/s/=\( *\)/=\1-fallow-argument-mismatch -fallow-invalid-boz  /' $CONFIGURE_FILE        # Add flags to FCNOOPT to allow argument mismatches and invalid boz constants
# sed -i '/^FCBASEOPTS_NO_G/s/=\( *\)/=\1-fallow-argument-mismatch -fallow-invalid-boz /' $CONFIGURE_FILE # Add flags to FCBASEOPTS_NO_G to allow argument mismatches and invalid boz constants
# KPP
sed -i 's/-ll //' chem/KPP/kpp/kpp-2.1/src/Makefile                                                     # Remove the linking to the libl library (-ll) from the Makefile
sed -i 's|^YACC=.*|YACC="/usr/bin/yacc -d"|' chem/KPP/configure_kpp                                     # Replace the YACC definition with /usr/bin/yacc -d in the configure_kpp file


## Compilation
time ./compile -j 16 em_real 2>&1 | tee compile_em_real.log
