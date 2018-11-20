#include "fintrf.h"

#if 0

!     fengdemo.F
!     .F file need to be preprocessed to generate .for equivalent

#endif

!     fengdemo.f
!
!     This is a simple program that illustrates how to call the MATLAB
!     Engine functions from a FORTRAN program.
!
! Copyright 1984-2018 The MathWorks, Inc.
!======================================================================


program main
use, intrinsic :: iso_fortran_env, only: dp=>real64

implicit none

mwPointer engOpen, engGetVariable, mxCreateDoubleMatrix
#if MX_HAS_INTERLEAVED_COMPLEX
mwPointer mxGetDoubles
#else
mwPointer mxGetPr
#endif
mwPointer :: ep, T, D 
mwSize, parameter :: M=1, N=10
real(dp) ::  dist(N)
integer :: engPutVariable, engEvalString, engClose
integer :: temp, status
mwSize :: i
real(dp), parameter :: time(N)=[ 1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
character(2) :: argv

ep = engOpen('matlab ')

if (ep == 0) error stop 'Cannot start MATLAB engine'

T = mxCreateDoubleMatrix(M, N, 0)
#if MX_HAS_INTERLEAVED_COMPLEX
call mxCopyReal8ToPtr(time, mxGetDoubles(T), N)
#else
call mxCopyReal8ToPtr(time, mxGetPr(T), N)
#endif


!     Place the variable T into the MATLAB workspace

status = engPutVariable(ep, 'T', T)

if (status /= 0) error stop 'engPutVariable failed'



!     Evaluate a function of time, distance = (1/2)g.*t.^2
!     (g is the acceleration due to gravity)

if (engEvalString(ep, 'D = .5.*(-9.8).*T.^2;') /= 0) error stop 'engEvalString failed'


call get_command_argument(1, argv, status=status)
if (status==0) then
  if (argv=='-v') call plot(ep, T, D)
endif

D = engGetVariable(ep, 'D')
#if MX_HAS_INTERLEAVED_COMPLEX
call mxCopyPtrToReal8(mxGetDoubles(D), dist, N)
#else
call mxCopyPtrToReal8(mxGetPr(D), dist, N)
#endif
print *, 'MATLAB computed the following distances:'
print *, '  time(s)  distance(m)'
do i=1,size(time)
 print '(2G10.3)', time(i), dist(i)
enddo


call mxDestroyArray(T)
call mxDestroyArray(D)
status = engClose(ep)

if (status /= 0) error stop 'engClose failed'

contains

subroutine plot(ep, T, D)

mwPointer, intent(in) :: ep, T, D

if (engEvalString(ep, 'plot(T,D);') /= 0) error stop 'engEvalString failed'

if (engEvalString(ep, 'title(''Position vs. Time'')') /= 0) error stop 'engEvalString failed'

if (engEvalString(ep, 'xlabel(''Time (seconds)'')') /= 0) error stop 'engEvalString failed'

if (engEvalString(ep, 'ylabel(''Position (meters)'')') /= 0) error stop 'engEvalString failed'

! read from console to make sure that we pause long enough to be able to see the plot

print *, 'Type 0 <return> to Exit'
print *, 'Type 1 <return> to continue'

read(*,*) temp

if (temp==0) then
  if (engClose(ep) /= 0) error stop 'engClose failed'
  stop 
endif

if (engEvalString(ep, 'close;') /= 0) error stop 'engEvalString failed'

end subroutine plot

end program


