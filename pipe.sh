#! /bin/bash -

pipe () {
  local -A __pipe_sh=(
          [name]="$FUNCNAME"
    [invocation]="$FUNCNAME"
      [funcname]="$FUNCNAME"
  )

  if (( ${#BASH_SOURCE[@]} > 1 )) && [[ "${BASH_SOURCE[0]}" == "${BASH_SOURCE[1]}" ]] ; then
          __pipe_sh[name]="${BASH_SOURCE[0]##*/}"
    __pipe_sh[invocation]="source ${__pipe_sh[name]}"
  fi

  local __pipe_sh_usage=(
    "usage: ${__pipe_sh[invocation]} [--] PIPEFD"
    "       ${__pipe_sh[invocation]} [--] READER WRITER"
  )
  local __pipe_sh_help=(
    "${__pipe_sh_usage[@]}"
    "Create pipe in bash. Option --man shows manual page."
  )

  local -A __pipe_sh_rsvd_id=(
    [__pipe_sh]=1
    [__pipe_sh_usage]=1
    [__pipe_sh_help]=1
    [__pipe_sh_rsvd_id]=1
  )

  __pipe.which () {
    command which -- "${1:?}" || {
      printf '%s: unmet dependency - %s\n' "'$1;" >&2
      return 1
    }
  }
  __pipe.roff () {
    local grep_bin envsubst_bin tail_bin
    grep_bin="$(__pipe.which grep)" || return
    tail_bin="$(__pipe.which tail)" || return
    envsubst_bin="$(__pipe.which envsubst)" || return

    local src="${BASH_SOURCE##*/}"
    export PIPE_SH_TITLE="${src^^}"
    export PIPE_SH_NAME="$src"
    export PIPE_SH_FUNCNAME="${__pipe_sh[funcname]}"

    local end_of_bash
    end_of_bash="$( "$grep_bin" -n -- '^#END_OF_BASH$' "$BASH_SOURCE" )" || return
    local roff_start="$(( ${end_of_bash%:*} + 1 ))"
    "$envsubst_bin" '${PIPE_SH_TITLE} ${PIPE_SH_NAME} ${PIPE_SH_FUNCNAME}' < <( "$tail_bin" -n +"$roff_start" -- "$BASH_SOURCE" )
  }
  __pipe.man () {
    local man_bin
    man_bin="$(__pipe.which man)" || return
    __pipe.roff | "$man_bin" -l -
  }
  __pipe.check-name () {
    local name
    for name in "$@" ; do
      local id="${name%'['*}"
      if [[ ! "$id" =~ ^[_a-zA-Z]+[_a-zA-Z0-9]*$ ]] ; then
        echo "${__pipe_sh[invocation]}: invalid identifier - '$id'" >&2
        return 64
      fi
      eval "attr=\"\${${id}@a}\""
      if [[ "${attr}" != "${attr/r/}" ]] ; then
        echo "${__pipe_sh[invocation]}: readonly varaible - '$id'" >&2
        return 64
      fi
      if [[ -v __pipe_sh_rsvd_id["$id"] ]] ; then
        echo "${__pipe_sh[invocation]}: reserved identifier - '$id'" >&2
        return 64
      fi
      ( unset -v -- "$name" ) 2>/dev/null || {
        echo "${__pipe_sh[invocation]}: invalid identifier - '$name'" >&2
        return 64
      }
    done
  }
  __pipe_sh[private_funcs]='__pipe.which __pipe.roff __pipe.man __pipe.check-name __pipe.impl'

  __pipe.impl () {
    while (( $# )) ; do
      case "$1" in
      [^-]* ) break ;;
      --    ) shift ; break ;;
      -[h]* | --help )
        printf '%s\n' "${__pipe_sh_help[@]}"
        return
        ;;
      --roff )
        __pipe.roff
        return
        ;;
      --man )
        __pipe.man
        return
        ;;
      --*   )
        : "${1%%=*}"
        echo "${__pipe_sh[invocation]}: bad option - '${_}'" >&2
        return 64
        ;;
      -*    )
        : "${1:0:2}"
        echo "${__pipe_sh[invocation]}: bad option - '${_}'" >&2
        return 64
        ;;
      esac
    done

    case "$#" in
    1 )
      __pipe.check-name "${1}[0]" "${1}[1]" || return
      set -- "${1}[0]" "${1}[1]"
      ;;
    2 )
      __pipe.check-name "${1}" "${2}" || return
      ;;
    0 )
      printf '%s\n' "${__pipe_sh[invocation]}: missing required argument" "${__pipe_sh_usage[@]}" 1>&2
      return 64
      ;;
    * )
      printf '%s\n' "${__pipe_sh[invocation]}: too many arguments" "${__pipe_sh_usage[@]}" 1>&2
      return 64
      ;;
    esac

    __pipe_sh[tail_bin]="$(__pipe.which tail)" || return

    exec {__pipe_sh[reader]}< <(
      "${__pipe_sh[tail_bin]}" -F /dev/null >/dev/null
    ) || {
      echo "${__pipe_sh[invocation]}: failed to create donor process" 1>&2
      return 1
    }
    exec {__pipe_sh[writer]}>"/proc/$!/fd/1" || {
      exec {__pipe_sh[reader]}<&-
      echo "${__pipe_sh[invocation]}: failed to dup stdout of donor process" 1>&2
      return 1
    }
    kill -- "$!"

    declare -g -- "${@%'['*}"
    eval "${1}=${__pipe_sh[reader]@Q} && ${2}=${__pipe_sh[writer]@Q}"
  }

  __pipe_sh[status]=0
  __pipe.impl "$@" || __pipe_sh[status]="$?"
  unset -f -- ${__pipe_sh[private_funcs]}
  return "${__pipe_sh[status]}"
}

[[ "$0" != "$BASH_SOURCE" ]] || {
  case "${1:-}" in
  -h* | --help ) ;&
  --roff ) ;&
  --man )
    pipe "$1"
    exit
    ;;
  esac
  printf '%s\n' "${BASH_SOURCE##*/}: must be sourced"
  pipe --help >&2
  exit 64
}

if (( $# )) ; then
  pipe "$@" || return
fi
return


# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #

#END_OF_BASH
.TH "${PIPE_SH_TITLE}" "7" "July 2019" "0.1" ""
.
.SH "NAME"
${PIPE_SH_NAME} \(em create pipe in \fBbash\fR(1)
.
.SH "SYNOPSIS"
.nf
\fBsource\fR \fB${PIPE_SH_NAME}\fR [ \fB\-\-help\fR | \fB\-\-roff\fR | \fB\-\-man\fR ]
\fBsource\fR \fB${PIPE_SH_NAME}\fR [\fB--\fR] \fIPIPEFD\fR
\fBsource\fR \fB${PIPE_SH_NAME}\fR [\fB--\fR] \fIREADER\fR \fIWRITER\fR
.fi
.
.SH "DESCRIPTION"
.PP
Resembling \fBpipe\fR(2), \fB${PIPE_SH_NAME}\fR creates pipe. Argument \fIPIPEFD\fR is user-supplied name of an array that is used to return two file descriptors referring to the ends of created pipe, the read end at index \fB0\fR and the write end at index \fB1\fR\. Alternatively, two names (argument \fIREADER\fR and \fIWRITER\fR) can be supplied to return the ends of the pipe\.
.PP
Once \fB${PIPE_SH_NAME}\fR is sourced, an interface in the form of a \fBbash\fR function that avoids redundant sourcing, \fB${PIPE_SH_FUNCNAME}\fR, is made available in the sourcing shell and subsequent subshells.
.
.SH OPTIONS
.IP "\fB\-h\fR, \fB\-\-help\fR" 4
Output a brief help message.
.IP "\fB\-\-roff\fR" 4
Output manual page source. The option depends on \fBgrep\fR(1), \fBtail\fR(1) and \fBenvsubst\fR(1).
.IP "\fB\-\-man\fR" 4
Show manual page. The option depends on option \fB\-\-roff\fR and \fBman\fR(1).
.
.SH "EXAMPLE"
.
.nf
$ # in a bash prompt
$ \fBsource\fR \fB${PIPE_SH_NAME}\fR
$ \fB${PIPE_SH_FUNCNAME}\fR \fBr\fR \fBw\fR
$ \fBecho\fB \fIhello\fB >&${w}\fR
$ \fBexec\fR \fB{w}>&\-\fR # so the next command, cat, would eventually get EOF and exit
$ \fBcat\fR \fB<&${r}\fR
hello
$
.fi
.SH "NOTES"
.PP
Other than one command to \fBtail\fR(1), pipe creation in \fB${PIPE_SH_NAME}\fR in made is pure \fBbash\fR.
.
.SH "REPORTING BUGS"
https://github.com/kennethho/pipe.sh/issues
.SH "SEE ALSO"
.nf
\fBpipe\fR(7), \fBpipe\fR(2) and \fBbash\fR(1)
.fi
