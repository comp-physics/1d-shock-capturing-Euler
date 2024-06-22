module conv

    use doubleprecision
    use prms

contains

subroutine c_to_p(up,uc)

    implicit none

    real(kind = dp), intent(in)  :: uc(3,0:n)
    real(kind = dp), intent(out) :: up(3,0:n)

    up(1,:) = uc(1,:)
    up(2,:) = uc(2,:)/uc(1,:)
    up(3,:) = (g-1.)*(uc(3,:) - 0.5*(uc(2,:)**2.)/uc(1,:))

end subroutine c_to_p

subroutine p_to_c(up,uc)

    implicit none

    real(kind = dp), intent(in)  :: up(3,0:n)
    real(kind = dp), intent(out) :: uc(3,0:n)

    uc(1,:) = up(1,:)
    uc(2,:) = up(1,:)*up(2,:)
    uc(3,:) = up(3,:)/(g-1.) + 0.5*up(1,:)*(up(2,:)**2.)

end subroutine p_to_c

end module conv
