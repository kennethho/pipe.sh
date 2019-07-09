# pipe.sh
pipe for bash

<pre>
<strong>NAME</strong>
       <strong>pipe.sh</strong> - create pipe in <strong>bash</strong>(1)

<strong>SYNOPSIS</strong>
       <strong>source</strong> <strong>pipe.sh</strong>
       <strong>pipe</strong> <em>PIPEFD</em>
       <strong>pipe</strong> <em>READFD</em> <em>WRITEFD</em>

<strong>DESCRIPTION</strong>
       <strong>pipe</strong> is a <strong>bash</strong>(1) function that creates anonymous pipe, it is like
       <strong>pipe</strong>(2) for <strong>bash</strong>(1). As with <strong>pipe</strong>(2), <em>PIPEFD</em> is user-supplied name
       of an array that is used to return two file descriptors referring
       to the ends of the pipe. Where the read end is stored at index <strong>0</strong>,
       and the write end at index <strong>1</strong>. Alternatively, user can supply two
       names to return ends of the pipe.

<strong>EXAMPLE</strong>
       $ ### in a bash prompt ###
       $ <strong>source pipe.sh</strong>
       $ <strong>pipe r w</strong>
       $ <strong>echo hello >&${w}</strong>
       $ <strong>exec {w}>&-</strong>
       $ <strong>cat <&${r}</strong>   #### output follows ###
       hello
</pre>
