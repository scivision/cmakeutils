# Downloading and extracting data with CMake

A key question when downloading and extracting data with CMake is whether the data is needed at **configuration** time or **build** time.

* CMake configure:  `cmake -B build` gets ready to build the program.
* CMake build: `cmake --build build` compiles and links the program, making artifacts (binary executables and libraries)

If the downloaded files aren't needed until the compiled program runs (i.e. runtime) then downloading at build time is OK.
If the downloaded files are needed to make decisions on how the program is built, then downloading the files at configuration time is necessary.
Here are examples of each CMake file download and extraction method.

## file(DOWNLOAD)

CMake
[file(DOWNLOAD)](https://cmake.org/cmake/help/latest/command/file.html?highlight=file%20download#download)
method is the most "manual" but also the most flexible.
The code feels most like code used in other programming languages in general.
It downloads file at CMake configuration time.
The [CMakeLists.txt](./CMakeLists.txt) in this folder is an example of this method.

## FetchContent

Since CMake 3.11,
[FetchContent](https://cmake.org/cmake/help/latest/module/FetchContent.html)
makes files and even entire CMake projects and CMake targets available at configure time.
We frequently use FetchContent to tie together multiple CMake projects instead of the older ExternalProject.
With regard to downloading and extracting files, FetchContent can be used for that as well.
A distinction is that FetchContent will force-overwrite local changes to the files, while file(DOWNLOAD) can be more easily but inside an if() statement if this is not desired.

## ExternalData

CMake
[ExternalData](https://cmake.org/cmake/help/latest/module/ExternalData.html)
downloads files at build time, replacing files if necessary.
In our opinion ExternalData is for more advanced uses, and is not frequently necessary, especially with the characteristic of files only available at build time.