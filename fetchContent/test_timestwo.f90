program test_timestwo
use multiplier, only : timestwo
implicit none

if (timestwo(3) /= 6) error stop

end program