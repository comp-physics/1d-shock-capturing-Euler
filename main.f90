program main

    use doubleprecision
    use prms
    use conv
    use weno

    implicit none

    real(kind = dp), dimension(:), allocatable :: x 
    real(kind = dp), dimension(:,:), allocatable :: up, uc, frp, frm, fp, fm, f, ff
    real(kind = dp), dimension(:,:,:), allocatable :: urk, ucsol
    integer :: i

    call getprms

    allocate( x(0:n) )
    allocate( up(3,0:n), uc(3,0:n), frp(3,0:n), frm(3,0:n), f(3,0:n), fp(3,0:n), &
            fm(3,0:n), ff(3,0:n)  )
    allocate( urk(3,0:n,1:2), ucsol(0:nsteps,3,0:n) )

    call getic(x,uc,up,ucsol)

    do nt = 1,nsteps,1
        if (mod(nt,outfile).eq.0) print*, 'Timestep = ', nt

        if (FT.eq.'Euler') then
            call c_to_p(up,uc)
            call fluxes(ff,up)
            call numflux(fp, fm, uc, ff)
            call recon(fp,fm,f)
            call rhside(fp, f, n, hi)
            if (enable_viscosity.eq.'True') call viscosity(uc,fp)
            uc = uc + dt * fp
        else if (FT.eq.'RK3') then
            !substep 1
            call c_to_p(up,uc)
            call fluxes(ff,up)
            call numflux(fp, fm, uc, ff)
            call recon(fp,fm,f)
            call rhside(fp, f, n, hi)
            if (enable_viscosity.eq.'True') call viscosity(uc,fp)
            urk(:,:,1)= uc(:,:) + dt * fp(:,:)
            
            !substep 2
            call c_to_p(up,urk(:,:,1))
            call fluxes(ff,up)
            call numflux(fp, fm, urk(:,:,1), ff)
            call recon(fp,fm,f)
            call rhside(fp, f, n, hi)
            if (enable_viscosity.eq.'True') call viscosity(urk(:,:,1),fp)
            urk(:,:,2) = rk(1,1) * uc(:,:) + rk(1,2) * (urk(:,:,1) + dt * fp(:,:))

            !substep 3
            call c_to_p(up,urk(:,:,2))
            call fluxes(ff,up)
            call numflux(fp, fm, urk(:,:,2), ff)
            call recon(fp,fm,f)
            call rhside(fp, f, n, hi)
            if (enable_viscosity.eq.'True') call viscosity(urk(:,:,2),fp)
            uc(:,:) = rk(2,1) * uc(:,:) + rk(2,2) * (urk(:,:,2) + dt * fp(:,:))
        end if
        
        ucsol(nt,:,:) = uc(:,:)
        call output(uc(1,:),x,'rho.',nt)
    end do

    !print*, 'L1 Error = ', sum(    abs( uc(1,:) - 3*(exp(-( x(:)-tend)**2.)+1) )) / real(n)
    !print*, 'L0 Error = ', maxval( abs( uc(1,:) - 3*(exp(-( x(:)-tend)**2.)+1) ))
    !open(1,file='D/l1err.out')
    !    write(1,*) sum(    abs( uc(1,:) - 3*(exp(-( x(:)-tend)**2.)+1) ))/real(n)
    !close(1)

end program main
