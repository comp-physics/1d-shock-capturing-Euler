!> Compute the Lax-Friedrichs flux
!! \f$\hat{f}^{\mbox{LF}}\left(u^{-},u^{+}\right)\f$ given values of
!! \f$u\f$.  See section 3.1 of Shu's 2009 SIAM Review paper
!! or section 2 of Liu, Sher, and Chan's 1994 JCP paper for more details.

subroutine numflux (fp, fm, uc, f)

    use doubleprecision
    use prms

    implicit none

    real(kind = dp), intent(in)  :: uc(3,0:n), f(3,0:n)
    real(kind = dp), intent(out) :: fp(3,0:n), fm(3,0:n)
    real(kind = dp)              :: alpha
    integer :: i
    
    if (FFlux .eq. 'GLF') then
        alpha = maxwavespeed  !maxval(abs(u))
        fp    = 0.5_dp * (f + alpha*uc)
        fm    = 0.5_dp * (f - alpha*uc)
    else if( FFLUX .eq. 'LLF') then
        do i = 0,n
            alpha   = 1+sqrt(1./uc(1,i))
            fp(:,i) = 0.5_dp * (f(:,i) + alpha*uc(:,i))
            fm(:,i) = 0.5_dp * (f(:,i) - alpha*uc(:,i))
        end do
    else if (FFlux .eq. 'AV') then
        alpha = eps+maxwavespeed
        fp    = 0.5_dp * (f + alpha*uc)
        fm    = 0.5_dp * (f - alpha*uc)
    end if 

end subroutine numflux
