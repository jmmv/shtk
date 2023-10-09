<h1>Getting started</h1>

<p>shtk is a tool and a library. The tool, <a href="shtk.1.html">shtk(1)</a>, provides the mechanisms to "compile" an shtk script into a runnable script. The library, <a href="shtk.3.html">shtk(3)</a>, provides a collection of shell modules with different functionality.</p>

<p>Here is the typical "Hello, world!" program built with shtk. Start by creating a source file, say <tt>hello.sh</tt> with the following contents:</p>

<pre>
shtk_import cli

main() {
    shtk_cli_info "Hello, world!"
}
</pre>

<p>Now, build and run it:</p>

<pre>
$ shtk build hello.sh
$ ./hello
hello: I: Hello, world!
</pre>

<p>You can also write test programs with shtk. A simple integration test for our <tt>hello.sh</tt> sample program, which we store as <tt>hello_test.sh</tt>, would look like this:</p>

<pre>
shtk_import unittest

shtk_unittest_add_test hello_prints_hello_world_to_stderr
hello_prints_hello_world_to_stderr_test() {
    assert_command -e inline:"hello: I: Hello, world!\n" ../hello
}
</pre>

<p>You can build and run the test just like the original program, but specifying a different entry point:</p>

<pre>
$ shtk build -m shtk_unittest_main hello_test.sh
$ ./hello_test
hello_test: I: Testing hello_prints_hello_world_to_stderr...
Running checked command: ../hello
hello_test: I: Testing hello_prints_hello_world_to_stderr... PASSED
hello_test: I: Ran 1 tests; ALL PASSED
</pre>

<h1>Reference manual</h1>

<p>The manual pages below correspond to shtk @SHTK_VERSION@.</p>
