# pipe.sh
pipe for bash

<pre>
<strong>NAME</strong>
       <strong>pipe.sh</strong> - create pipe in <strong>bash</strong>(1)

<strong>SYNOPSIS</strong>
       <strong>source</strong> <strong>pipe.sh</strong> [ <strong>--help</strong> | <strong>--roff</strong> | <strong>--man</strong> ]
       <strong>source</strong> <strong>pipe.sh</strong> [<strong>--</strong>] <em>PIPEFD</em>
       <strong>source</strong> <strong>pipe.sh</strong> [<strong>--</strong>] <em>READER WRITER</em>

<strong>DESCRIPTION</strong>
       Resembling <strong>pipe</strong>(2), <strong>pipe.sh</strong> creates pipe. Argument <em>PIPEFD</em> is user-
       supplied name of an array that is used to return two file
       descriptors referring to the ends of created pipe, the read end at
       index <strong>0</strong> and the write end at index <strong>1</strong>. Alternatively, two names (
       argument <em>READER</em> and <em>WRITER</em>) can be supplied to return the ends of
       the pipe.

       Once <strong>pipe.sh</strong> is sourced, an interface in the form of a <strong>bash</strong>
       function that avoids redundant sourcing, <strong>pipe</strong>, is made available in
       the sourcing shell and subsequent subshells.

<strong>OPTIONS</strong>
       <strong>-h</strong>, <strong>--help</strong>
           Output a brief help message.

       <strong>--roff</strong>
           Output manual page source. The option depends on <strong>grep</strong>(1), <strong>tail</strong>(1)
           and <strong>envsubst</strong>(1).

       <strong>--man</strong>
           Show manual page. The option depends on option <strong>--roff</strong> and <strong>man</strong>(1).

<strong>EXAMPLE</strong>
       $ # in a bash prompt
       $ <strong>source pipe.sh</strong>
       $ <strong>pipe r w</strong>
       $ <strong>echo hello >&${w}</strong>
       $ <strong>exec {w}>&-</strong> # so the next command, cat, would eventually get EOF and exit
       $ <strong>cat <&${r}</strong>
       hello
       $

<strong>NOTES</strong>
       Other than one command to <strong>tail</strong>(1), pipe creation in <strong>pipe.sh</strong> in made
       is pure <strong>bash</strong>.
       
<strong>REPORTING BUS</strong>
       <a href="https://github.com/kennethho/pipe.sh/issues">https://github.com/kennethho/pipe.sh/issues</a>

<strong>SEE ALSO</strong>
       <strong>pipe</strong>(7), <strong>pipe</strong>(2) and <strong>bash</strong>(1)
</pre>
