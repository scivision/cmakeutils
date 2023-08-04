# script to invoke Chromium-like web browser and convert HTML document to PDF
#
# Notes:
# * Firefox and Safari do not have a built-in command line print to PDF
# * there doesn't appear to be a way to print in landscape mode, default is portrait
# * ensure the HTML doc images are <= 100% width or they'll be cut off in the PDF

cmake_minimum_required(VERSION 3.20)

set(CMAKE_EXECUTE_PROCESS_COMMAND_ECHO "STDOUT")

if(NOT html)
  message(FATAL_ERROR "Usage:
  cmake -Dhtml=/path/to/index.html -P html2pdf.cmake"
  )
endif()

set(apple_path
"/Applications/Chromium.app/Contents/MacOS/"
"/Applications/Google Chrome.app/Contents/MacOS/"
"/Applications/Microsoft Edge.app/Contents/MacOS/"
)

# find web browser
find_program(browser
NAMES chromium-browser google-chrome msedge "Microsoft Edge"
NAMES_PER_DIR
PATHS ${apple_path}
)

if(NOT browser)
  message(FATAL_ERROR "Chromium-like browser not found")
endif()

cmake_path(REPLACE_EXTENSION html LAST_ONLY ".pdf" OUTPUT_VARIABLE pdf_file)

message(STATUS "${html} => ${pdf_file}")

# set browser options
# https://www.chromium.org/developers/how-tos/run-chromium-with-flags/
set(cmd ${browser} --headless --no-pdf-header-footer --print-to-pdf=${pdf_file} ${html})

execute_process(COMMAND ${cmd} RESULT_VARIABLE result)
if(result)
  message(FATAL_ERROR "Failed to convert ${html} to ${pdf_file}
  ${result}")
endif()
