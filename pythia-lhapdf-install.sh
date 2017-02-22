#!/bin/bash
#
# test instalation of lhapdf and pythia8201 in home directory of the user
# change user_name accordingly
PYDIR="$HOME/pythia-test"
#
##################
# install lhapdf #
##################
mkdir -p $PYDIR/lhapdf/share/LHAPDF 
cd $PYDIR/lhapdf
wget http://www.hepforge.org/archive/lhapdf/LHAPDF-6.1.4.tar.gz
tar xzf LHAPDF-6.1.4.tar.gz && cd "$_"
./configure --prefix=$PYDIR/lhapdf/
wget http://www.hepforge.org/archive/lhapdf/pdfsets/6.1/CT10nlo.tar.gz -O- | tar xz -C $PYDIR/lhapdf/share/LHAPDF
make -j6
make install
##################
# install pythia #
##################	
cd $PYDIR
wget http://home.thep.lu.se/~torbjorn/pythia8/pythia8201.tgz
tar xvfz pythia8201.tgz
cd pythia8201
# various options for configuring
# a) lib and include are searched for headers and libraries; libraries are shared (?); installation point is given	 
./configure --with-lhapdf6=$PYDIR/lhapdf --with-hepmc2=/opt/rivet --enable-shared --prefix=$PYDIR/pythia8201
# c) link only to libraries 
# ./configure --with-lhapdf6-lib=$PYDIR/lhapdf/lib --with-hepmc2-lib=/opt/rivet/lib
# b) lib and include are searched for headers and libraries
# ./configure --with-lhapdf6=$PYDIR/lhapdf --with-hepmc2=/opt/rivet
# compile on 6 cores
make -j6
make install
#########################
# test pythia on main89 #
#########################
cd ./share/Pythia8/examples
# 1st try to compile and run main89 with writing to stdout
make main89 
./main89 main89unlop.cmnd main89.hepmc
# fix main89unlops.cmnd - first rename main89unlops.cmnd
mv main89unlops.cmnd main89unlopsOLD.cmnd
# then change LHAPDF5:CT10 to LHAPDF6:CT10nlo and remove .gz extensions from .lhe.gz in main89unlopOLD.cmnd
sed -e 's/LHAPDF5:CT10/LHAPDF6:CT10nlo/' -e 's/.lhe.gz/.lhe/' main89unlopsOLD.cmnd > main89unlops.cmnd
# fianlly unzip lhe event files
gunzip *.gz
# compile and run main89 writing to stdout
make main89 
./main89 main89unlop.cmnd main89.hepmc
# or writing to .out file
# ./main89 main89unlop.cmnd main89.hepmc > main89.out

