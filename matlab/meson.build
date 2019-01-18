# not yet working, may be a Meson bug
project('Matlab test', 'fortran')

mat = dependency('Matlab')  
  # case matters, MATLAB, matlab do not work, only Matlab

  
feng = executable('fengdemo', 'fengdemo.F90',
  dependencies: mat)
  
test('Matlab Feng', feng)
