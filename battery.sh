T=3
L=10
CFLs=( 0.45 )

Ns=( 512 1024 2000 4000 8000 16000 32000 48000 )
#Ns=( 128 256 512 1024 2048 4096 8192 )
#Ns=( 128 256 512 1024 2048 4096 8192 16384 32768 )
amp=3
Beta=0.95 #for artifical viscosity

enable_adjoint='True' #{True,False}
enable_viscosity='True' #{True,False}
ForTime=RK3
BackTime=RK3

forflux=GLF     #{LLF,GLF,AV}
backflux=GLF    #{GLF,AV}

rm -rf ./out/* ./O/*

for N in "${Ns[@]}"; do
for CFL in "${CFLs[@]}"; do
    case='weno-'$T'T-'$N'N-'$CFL'CFL'
    echo Case $case
    cat ./Input/weno.temp   | sed -e s/XXN/$N/ -e s/XXBETA/$Beta/ -e s/XXCFL/$CFL/ -e s/XXT/$T/ -e s/XXAMP/$amp/ -e s/XXL/$L/ -e s/XXFT/$ForTime/ -e s/XXBT/$BackTime/ -e s/XXFFLUX/$forflux/ -e s/XXAFLUX/$backflux/ -e s/XXADJ/$enable_adjoint/ -e s/XXVISC/$enable_viscosity/ > ./Input/weno.in
    rm -rf ./D/* 
    #./weno3.x  > './out/'$case'_3.out'
    ./weno5.x  > './out/'$case'_5.out'

    cp ./D/final* './O/adjfin_'$case'.csv'
    #cat ./D/l1err.out >> ./O/l1err.out
    #mv ./D/l1err.out './O/l1err_'$case'.dat'
done
done
