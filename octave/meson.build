project('Octave test', 'cpp',
  meson_version: '>=0.50',
  default_options : ['cpp_std=c++11'])

oct = dependency('Octave', module_path : '../cmake/Modules',
  modules : 'Octave::Octave')  
# case matters, OCTAVE, octave do not work, only Octave

octcpp = executable('octdemo', 'octdemo.cpp',
  dependencies: oct)
test('Octave C++', octcpp)
