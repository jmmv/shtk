// Copyright 2023 Julio Merino
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are
// met:
//
// * Redistributions of source code must retain the above copyright
//   notice, this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright
//   notice, this list of conditions and the following disclaimer in the
//   documentation and/or other materials provided with the distribution.
// * Neither the name of Google Inc. nor the names of its contributors
//   may be used to endorse or promote products derived from this software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
// "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
// LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
// A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
// OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
// SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
// LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
// DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
// THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
// (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
// OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

//
// Sample program that takes two int16 integers as arguments, adds them,
// and prints a message with the result.
//
// The goal of this program is to provide a success path and a variety of
// error paths to write integration tests for to demonstrate how shtk's
// unittest module can be used to validate any program.
//


#include <err.h>
#include <errno.h>
#include <inttypes.h>
#include <stdio.h>
#include <stdlib.h>

int16_t parse_int_arg(char* arg_name, char* arg_value) {
    char *endptr;
    errno = 0;
    long val = strtol(arg_value, &endptr, 10);

    if (errno != 0) {
        err(EXIT_FAILURE, "Invalid %s", arg_name);
    }

    if (endptr == arg_value || *endptr != '\0') {
        errx(EXIT_FAILURE, "Invalid %s: bad digits", arg_name);
    }

    if (val > INT16_MAX || val < INT16_MIN) {
        errx(EXIT_FAILURE, "Invalid %s: out of range", arg_name);
    }

    return (int16_t) val;
}

int main(int argc, char** argv) {
    if (argc != 3) {
        errx(EXIT_FAILURE, "Requires two integer arguments");
    }
    int16_t x1 = parse_int_arg("first operand", argv[1]);
    int16_t x2 = parse_int_arg("second operand", argv[2]);

    printf("The sum of %d and %d is %d\n", x1, x2, x1 + x2);

    return EXIT_SUCCESS;
}
