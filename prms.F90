module prms

    use doubleprecision

    real(kind = dp), parameter :: pi      = 4._dp*atan(1._dp)
    real(kind = dp), parameter :: rk(2,2) = reshape( &
        [0.75_dp, (1._dp/3._dp), (0.25_dp), (2._dp/3._dp)], shape(rk))

    real, parameter :: g=1.4_dp     !ratio of specific heats
    integer :: n                    !number of spatial grid points
    integer :: l                    !length of computational domain
    real :: tend                    !dimensionless end time of simulation
    real :: cfl                     !courant nymber
    real :: beta                    !exponent of dissipation coefficient
    real :: amp                     !amplitude of initial condition
    integer :: outfile              !how often to output files and print timesteps
    character(len = 20) :: ft       !time marching scheme
    character(len = 20) :: fflux    !flux functions
    character(len = 20) :: enable_viscosity !flag for added viscosity
    
    integer :: nt, nsteps, nfor
    real(kind = dp) :: h, hi, t, dt
    real :: maxwavespeed        !typically called alpha .. = abs(v) + c
    real :: eps                 !dissipation coefficeint 

contains

subroutine getprms
    integer :: i

    open(1,file='Input/weno.in')
    read(1,*) n;                print*, 'Nx=',n
    read(1,*) L;                print*, 'L=', L
    read(1,*) tend;             print*, 'Tend=', Tend
    read(1,*) cfl;              print*, 'CFL=', CFL
    read(1,*) beta;             print*, 'beta=', beta
    read(1,*) amp;              print*, 'amp=', amp
    read(1,*) outfile;          print*, 'Output frequency=', outfile
    read(1,*) FT;               print*, 'FT', FT
    read(1,*) FFlux;            print*, 'Flux', FFlux
    read(1,*) enable_viscosity; print*, 'Viscosity enabled:', enable_viscosity
    close(1)

    maxwavespeed = 1+sqrt(1/amp) !for entropy wave of speed 1

    h = L / real(n)
    hi = 1.d0 / h

    eps = 0.01*h**beta !h**(beta-1.)
    
    if ( (FFlux.eq.'AV') .or. ((enable_viscosity.eq.'True') .and. (eps>0.00001)) ) then
        dt = minval( (/ cfl*h/(maxwavespeed*eps), cfl*h/maxwavespeed /) )
    else 
        dt = cfl * h/maxwavespeed
    end if

    nsteps = int(tend / dt)
    dt = tend / real(nsteps, dp)
    
    print '(" Number of time steps = ", I7, " with dt = ", F16.12)', nsteps, dt
    
end subroutine getprms

end module prms
