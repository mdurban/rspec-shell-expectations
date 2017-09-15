#!/usr/bin/env bash
function overridden_function {
  echo 'i was not overridden'
}

function /absolute/path/to/overridden_path_functions {
  echo 'i was not overridden'
}

function relative/path/to/overridden_path_functions {
  echo 'i was not overridden'
}

function overridden_command_function {
  overridden_command "${1}" "${2}"
  echo 'standard error output' >&2
}
