function(download_check msg ret log)

list(GET ret 0 stat)
if(NOT stat EQUAL 0)
    list(GET ret 1 err)
    message(FATAL_ERROR "${msg} download failed: ${stat} ${err} ${log}")
endif()

endfunction(download_check)


function(github_latest_release username project vervar)

# https://docs.github.com/en/rest/releases/releases?apiVersion=2022-11-28#get-the-latest-release
set(url "https://api.github.com/repos/${username}/${project}/releases/latest")

set(fn ${CMAKE_CURRENT_BINARY_DIR}/${username}_${project}_latest_release.json)

if(NOT EXISTS ${fn})
    message(STATUS "Get latest Github release for ${username}/${project} from ${url} => ${fn}")

    file(DOWNLOAD ${url} ${fn}
    HTTPHEADER "Accept: application/vnd.github+json"
    HTTPHEADER "X-GitHub-Api-Version: 2022-11-28"
    STATUS ret LOG log
    )
    download_check("GitHub ${project} latest release" "${ret}" "${log}")
endif()

file(READ ${fn} json)

# must put json in quote to avoid CMake syntax error from semicolon in JSON string
string(JSON tag GET "${json}" "tag_name")

# assumes project version is vMAJOR.MINOR.PATCH
if(tag MATCHES "v[0-9]+\\.[0-9]+\\.[0-9]+")
  string(SUBSTRING ${tag} 1 -1 _gh_project_version)
endif()

if(NOT DEFINED _gh_project_version)
  message(FATAL_ERROR "failed to find latest ${project} version in ${fn} from ${url}")
endif()

set(${vervar} ${_gh_project_version} PARENT_SCOPE)

endfunction(github_latest_release)
