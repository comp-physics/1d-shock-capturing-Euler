!> Evaluate the right hand side of the inviscid equation's time evolution
!! \f$
!! \partial_{t} \bar{u}_j = -\frac{1}{h}\left[
!!   f\left(u\left(x_{j+1/2},t\right)\right)
!!   -
!!   f\left(u\left(x_{j+1/2},t\right)\right)
!! \right]\f$
!! assuming periodic boundary conditions.  See section 2 of Liu,
!! Osher, and Chan's 1994 JCP paper for more details.
!!
!! @param fout The evaluated right hand side
!! @param fin  The input data \f$f\left(u\left(x_{j+1/2}\right)\right)\f$
!!             for \f$j\in\left\{0,\dots,n\right\}\f$.  Usually
!!             this will be an approximation found through reconstruction.
!! @param n    Grid size
!! @param hi   \f$\frac{1}{h}\f$

subroutine rhside (fout, fin, n, hi)

  use doubleprecision

  implicit none

  integer :: i
  INTEGER, INTENT(IN) :: n
  REAL(KIND = dp), INTENT(IN) :: fin(3,0:n), hi
  REAL(KIND = dp), INTENT(OUT) :: fout(3,0:n)

  !periodic
  !fout(1:n) = -hi * (fin(1:n) - fin(0:n-1))
  !fout(0)   = fout(n)

  do i = 1,3
    fout(i,6:n-5) = -hi * (fin(i,6:n-5) - fin(i,5:n-6))
    fout(i,0:5) = 0.; fout(i,n-4:n) = 0.
  end do

END SUBROUTINE rhside
