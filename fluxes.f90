subroutine fluxes (ff, up)

  use doubleprecision
  use prms

  implicit none
  real(kind = dp), intent(in)  :: up(3,0:n)
  real(kind = dp), intent(out) :: ff(3,0:n)
  real(kind = dp)              :: alpha
  integer :: i

  ff(1,:) = up(1,:)*up(2,:)
  ff(2,:) = up(1,:)*up(2,:)*up(2,:) + up(3,:)
  ff(3,:) = up(2,:)*( up(3,:)*g/(g-1.) + 0.5*up(1,:)*up(2,:)*up(2,:))

end subroutine fluxes
