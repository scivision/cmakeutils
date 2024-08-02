# Build MPI

This mini-project is to build MPI-3 library OpenMPI for those systems not having MPI for the desired compiler.

```sh
cmake -Bbuild --install-prefix $HOME/my_mpi

cmake --build build
```

## MPICH

```sh
cmake -Dmpich=yes
```

builds MPICH instead of the default OpenMPI.

Note that MPICH does [not yet work with Clang](https://releases.llvm.org/11.0.0/tools/flang/docs/RuntimeDescriptor.html#interoperability-requirements)
This is particularly relevant for macOS, where Clang is the default compiler.

A successful MPICH configure step ends like:

```
config.status: executing gen_binding_f90 commands
  [ /scripts/mpi/build/MPI-prefix/src/MPI/maint/gen_binding_f90.py -f-logical-size=4 -ignore-tkr=gcc ]
  --> [src/binding/fortran/use_mpi/mpi_base.f90]
  --> [src/binding/fortran/use_mpi/mpi_constants.f90]
  --> [src/binding/fortran/use_mpi/mpi_sizeofs.f90]
config.status: executing gen_binding_f08 commands
  [ /scripts/mpi/build/MPI-prefix/src/MPI/maint/gen_binding_f08.py -fint-size=4 -aint-size=8 -count-size=8 -cint-size=4 ]
  --> [src/binding/fortran/use_mpi_f08/wrappers_c/f08_cdesc.c]
  --> [src/binding/fortran/use_mpi_f08/wrappers_c/cdesc_proto.h]
  --> [src/binding/fortran/use_mpi_f08/wrappers_f/f08ts.f90]
  --> [src/binding/fortran/use_mpi_f08/wrappers_f/pf08ts.f90]
  --> [src/binding/fortran/use_mpi_f08/mpi_c_interface_cdesc.f90]
  --> [src/binding/fortran/use_mpi_f08/mpi_c_interface_nobuf.f90]
  --> [src/binding/fortran/use_mpi_f08/mpi_f08.f90]
  --> [src/binding/fortran/use_mpi_f08/pmpi_f08.f90]
  --> [src/binding/fortran/use_mpi_f08/mpi_f08_types.f90]
*****************************************************
***
*** device configuration: ch3:nemesis
*** nemesis networks: tcp
***
*****************************************************
Configuration completed.
```

and the internal MPICH header confdef.h must have `#define HAVE_F08_BINDING 1`
