project('Octave test', 'cpp',
  default_options : ['cpp_std=c++11'])

cxx = meson.get_compiler('cpp')

octexe = find_program('octave', required : true)
path = '''"runtests('.')"'''
test('Octave .m', octexe, args : ['-q', '--eval', path])


# FUTURE: need to add components option to meson itself
#oct = dependency('Octave', components : []'Development'])

# Meson < 0.50
liboct = cxx.find_library('octave', required : true)
octconf = find_program('octave-config')
octinc = run_command(octconf, ['-p', 'OCTINCLUDEDIR']).stdout().strip()
octinc = include_directories(octinc)
oct = declare_dependency(dependencies: liboct, include_directories : octinc)

octcpp = executable('octdemo', 'octdemo.cpp',
  dependencies: oct)
test('Octave C++', octcpp)
