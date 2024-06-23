subroutine output (u, x, str, lt)

  use doubleprecision
  use prms

  implicit none

  integer, intent(in) :: lt
  real(kind = dp), intent(in) :: u(0:n)
  real(kind = dp), intent(in) :: x(0:n)
  character(len = *), intent(in) :: str
  character(len=30) :: fn
  character(len=80) :: header
  integer :: i, iter

  if ( n.gt.1000) then
      iter=10
    else
      iter=1
  end if

  if ( ( mod(lt,outfile).eq.0 ) .or. (lt .eq. nsteps) ) then
    write(fn,"('D/',A,I10.10,'.csv')") str,lt
    !write(header,"('ZONE STRANDID=1, SOLUTIONTIME=',I4.4 )") lt
    write(header,"('xdat,   udat')") 
    open  (2, file = fn)
    write(2,*) header
    do i = 0,n,iter
        write (2,*) x(i),',',u(i)
        !write (2,"(f10.5,a,f10.5)") x(i),',',u(i)
    end do
    close (2)
  end if

  if (lt .eq. -1) then
    write(fn,"('D/final_',A,'csv')") str
    open  (2, file = fn)
    write(header,"('ColumnX   ColumnY')") 
    write(2,*) header
    do i = 0,n,iter
        write (2,*) x(i),u(i)
        !write (2,"(2f10.5)") x(i),u(i)
    end do
    close (2)
  end if

end subroutine output
