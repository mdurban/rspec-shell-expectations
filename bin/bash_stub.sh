#!/usr/bin/env bash
function json-encode {
  echo -n ".${1}." |
    awk '
      BEGIN {RS=""}
      {
        gsub(/\\/, "\\\\")
        gsub(/\"/, "\\\"")
        gsub(/\t/, "\\t")
        gsub(/\r/, "\\r")
        gsub(/\b/, "\\b")
        gsub(/\n/, "\\n")
        print substr($0, 2, length($0)-2)
      }
    '
}

function json-decode {
  echo -n "${1}" |
    awk '
      {
        gsub(/\\"/, "\"")
        print $0
      }
    '
}

function create-call-log {
  command_name=${1}; shift
  command_port=${1}; shift
  raw_stdin=$([[ -t 0 ]] && echo -n '' || cat -; ret=$?; echo .; exit "$ret")

  argument_list=( "${@}" )
  command=$(
    echo "\"command\":\"${command_name}\","
  )
  stdin=$(
    echo "\"stdin\":\"$(json-encode "${raw_stdin%.}")\","
  )
  arguments=$(
    for index in "${!argument_list[@]}"; do
      arg="${argument_list[${index}]}"
      echo "\"args.${index}\":\"$(json-encode "${arg}")\","
    done
  )

  echo "{"
  echo "${command}"
  [[ -n "${arguments}" ]] && echo "${stdin}" || echo "${stdin%,}"
  [[ -n "${arguments}" ]] && echo "${arguments%,}"
  echo "}"
}

function send-to-server {
  echo -n "${2}" | nc localhost ${1}
}

function extract-number-properties {
  echo -n "${1}" | sed -En "s/^\"${2}\":([0-9]+),?$/\1/gp"
}

function extract-string-properties {
  echo -n "${1}" | sed -En "s/^\"${2}\":\"(.*)\",?$/\1/gp"
}

function print-output {
  local type=${1}
  local target=${2}
  local content=${3}

  case ${type} in
    stdout)
      echo -en "${content}"
      ;;
    stderr)
      echo -en "${content}" >&2
      ;;
    file)
      if [[ -n "${target}" ]]; then
          echo -en "${content}" > "${target}"
      fi
      ;;
  esac
}
function main {
  client_message=$(create-call-log "${@}")
  server_message=$(send-to-server "${2}" "${client_message}")
  IFS=$'\n'
  target_list=( $(extract-string-properties "${server_message}" "outputs\..*\.target") )
  type_list=( $(extract-string-properties "${server_message}" "outputs\..*\.type") )
  content_list=( $(extract-string-properties "${server_message}" "outputs\..*\.content") )
  exit_code=$(extract-number-properties "${server_message}" "exitcode")

  for index in "${!target_list[@]}"; do
    target=${target_list[${index}]}
    type=${type_list[${index}]}
    content=$(json-decode "${content_list[${index}]}")
    print-output "${type}" "${target}" "${content}"
  done

  exit ${exit_code}
}

[[ ${0} == ${BASH_SOURCE} ]] && main "${@}"
