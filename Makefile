# $HeadURL$
# $Id$
FFLAGS= -g -O3 -I.
programs=weno3.x weno5.x
common=doublePrecision.o prms.o conv.o assorted.o fluxes.o numflux.o rhside.o ic.o viscous.o

all: $(programs)

main3.o: FFLAGS += -DWENOORDER=3
main3.o: main.F90
	$(FC) $(FFLAGS) -c -o $@ $<

weno3.x: main3.o reconstruct3.o $(common)
	$(LD) -o $@ $^

main5.o: FFLAGS += -DWENOORDER=5
main5.o: main.F90
	$(FC) $(FFLAGS) -c -o $@ $<

weno5.x: main5.o reconstruct5.o $(common)
	$(LD) -o $@ $^

# Module dependencies
assorted.F90:         doublePrecision.mod prms.mod
numflux.F90:          doublePrecision.mod prms.mod
fluxes.F90:           doublePrecision.mod prms.mod
main.F90:             doublePrecision.mod prms.mod conv.mod
ic.F90:               doublePrecision.mod prms.mod conv.mod
reconstruct3.F90:     doublePrecision.mod prms.mod
reconstruct5.F90:     doublePrecision.mod prms.mod
rhside.F90:           doublePrecision.mod prms.mod
viscous.F90:          doublePrecision.mod prms.mod

clean:
	@rm -fv  *.mod *.o *.x *__genmod.f90 *__genmod.mod

# FC=gfortran-13
LD=${FC} 
RANLIB=touch
AR=ar r

.PHONY: clean docs

.SUFFIXES:
.SUFFIXES: .f .o
.SUFFIXES: .F90 .o
.SUFFIXES: .F90 .mod

.f.o:
	$(FC) $(FFLAGS) -c $<

.F90.o:
	$(FC) $(FFLAGS) -c $<

.F90.mod:
	$(FC) $(FFLAGS) -c $<
