#! /bin/bash -

pipe () {
  local -A __pipe_rsvd_id=(
    [__pipe_rsvd_id]=1
        [__pipe_funcname]=1
         [__pipe_usage]=1
           [__pipe_doc]=1
             [__pipe_x]=1
  )
  local -- "${!__pipe_rsvd_id[@]}"

  local __pipe_funcname="$FUNCNAME"
  local __pipe_usage=(
    #"usage: ${__pipe_funcname} [--] <pipefd>"
    #"       ${__pipe_funcname} [--] <rdfd> <wrfd>"
    "usage: source ${BASH_SOURCE##*/}"
    "       ${__pipe_funcname} [--] PIPEFD"
    "       ${__pipe_funcname} [--] READFD WRITEFD"
  )
  local __pipe_doc=(
    "${__pipe_usage[@]}"
    "Create anonymous pipe in bash, like pipe(2) for bash. Option --man for more detail."
  )

  __pipe-man () {
    cat <<'__EOF__' | man -l -
.
.TH "pipe.sh" "1" "July 2019" "" ""
.
.SH "NAME"
\fBpipe.sh\fR \- create pipe in \fBbash\fR(1)
.
.SH "SYNOPSIS"
\fBsource pipe.sh\fR
.SY pipe
.I PIPEFD
.YS
.SY pipe
.I READFD
.I WRITEFD
.YS
.
.SH "DESCRIPTION"
\fBpipe\fR is a \fBbash\fR(1) function that creates anonymous pipe, it is like \fBpipe\fR(2) for \fBbash\fR(1)\. As with \fBpipe\fR(2), \fIPIPEFD\fR is user-supplied name of an array that is used to return two file descriptors referring to the ends of the pipe\. Where the read end is stored at index \fB0\fR, and the write end at index \fB1\fR\. Alternatively, user can supply two names to return ends of the pipe.
.
.SH "EXAMPLE"
.
.
.nf

$ ### in a bash prompt ###
$ source pipe.sh
$ pipe r w
$ echo hello >&${w}
$ exec {w}>&-
$ cat <&${r}   #### output follows ###
hello
.fi
__EOF__
  }
  __pipe-is-reserved () {
    local name
    for name ; do
      if [[ -v __pipe_rsvd_id["$name"] ]] || [[ -v __pipe_rsvd_id["${name%'['*}"] ]] ; then
        return 0
      fi
    done
    return 1
  }
  __pipe-check-name () {
    local name
    for name in "$@" ; do
      local id="${name%'['*}"
      if [[ ! "$id" =~ ^[_a-zA-Z]+[_a-zA-Z0-9]*$ ]] ; then
        echo "${__pipe_funcname}: invalid identifier - '$id'" >&2
        return 64
      fi
      eval "attr=\"\${${id}@a}\""
      if [[ "${attr}" != "${attr/r/}" ]] ; then
        echo "${__pipe_funcname}: readonly varaible - '$id'" >&2
        return 64
      fi
      if [[ -v __pipe_rsvd_id["$id"] ]] ; then
        echo "${__pipe_funcname}: reserved identifier - '$id'" >&2
        return 64
      fi
      ( unset -v -- "$name" ) 2>/dev/null || {
        echo "${__pipe_funcname}: invalid identifier - '$name'" >&2
        return 64
      }
    done
  }

  __pipe-impl () {
    while (( $# )) ; do
      case "$1" in
      [^-]* ) break ;;
      --    ) shift ; break ;;
      -[h]* | --help )
        printf '%s\n' "${__pipe_doc[@]}"
        return
        ;;
      --man )
        __pipe-man
        return
        ;;
      --*   )
        : "${1%%=*}"
        echo "${__pipe_funcname}: bad option - '${_}'" >&2
        return 64
        ;;
      -*    )
        : "${1:0:2}"
        echo "${__pipe_funcname}: bad option - '${_}'" >&2
        return 64
        ;;
      esac
    done

    case "$#" in
    1 )
      __pipe-check-name "${1}[0]" "${1}[1]" || return
      set -- "${1}[0]" "${1}[1]"
      ;;
    2 )
      __pipe-check-name "${1}" "${2}" || return
      ;;
    0 )
      printf '%s\n' "${__pipe_funcname}: missing required argument" "${__pipe_usage[@]}" 1>&2
      return 64
      ;;
    * )
      printf '%s\n' "${__pipe_funcname}: too many arguments" "${__pipe_usage[@]}" 1>&2
      return 64
      ;;
    esac

    local __pipe_x
    exec {__pipe_x[0]}< <(
      tail -F /dev/null >/dev/null
    ) || {
      echo "${__pipe_funcname}: failed to create donor process" 1>&2
      return 1
    }
    exec {__pipe_x[1]}>"/proc/$!/fd/1" || {
      exec {__pipe_x[0]}<&-
      echo "${__pipe_funcname}: failed to dup stdout of donor process" 1>&2
      return 1
    }
    kill -- "$!"

    declare -g -- "${@%'['*}"
    eval "${1}=${__pipe_x[0]@Q} && ${2}=${__pipe_x[1]@Q}"
  }

  local __pipe_x=0
  __pipe-impl "$@" || __pipe_x="$?"
  unset -f -- __pipe-impl __pipe-is-reserved __pipe-check-name __pipe-man
  return "$__pipe_x"
}

[[ "$0" != "$BASH_SOURCE" ]] || {
  case "${1:-}" in
  -h* | --help )
    pipe --help
    exit
    ;;
  --man )
    pipe --man
    exit
    ;;
  esac
  printf '%s\n' "${BASH_SOURCE##*/}: not sourced"
  pipe --help >&2
  exit 64
}
