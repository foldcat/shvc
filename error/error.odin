/*
   Copyright 2026 Shiver Contributors

   Licensed under the Apache License, Version 2.0 (the "License");
   you may not use this file except in compliance with the License.
   You may obtain a copy of the License at

       http://www.apache.org/licenses/LICENSE-2.0

   Unless required by applicable law or agreed to in writing, software
   distributed under the License is distributed on an "AS IS" BASIS,
   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
   See the License for the specific language governing permissions and
   limitations under the License.
*/

package error

import "../parser/tokens"
import "base:runtime"
import "core:fmt"
import "core:os"
import "core:terminal/ansi"

RED_START :: ansi.CSI + ansi.FG_RED + ansi.SGR
GRAY_START :: ansi.CSI + ansi.FG_BRIGHT_BLACK + ansi.SGR
ANSI_RESET :: ansi.CSI + ansi.RESET + ansi.SGR

print_error :: proc(
	source: string,
	span: tokens.Span,
	error_name: string,
	error_description: string,
	should_panic: bool,
) {
	fmt.println(RED_START, "An error occured: ", error_name, ANSI_RESET, sep = "")
	fmt.println(RED_START, "Description: ", error_description, ANSI_RESET, sep = "")

	if len(source) == 0 do return

	// validation
	if span.start < 0 || span.start > len(source) {
		panic("span.start out of range")
	}
	if span.end < 0 || span.end > len(source) {
		panic("span.end out of range")
	}
	if span.end < span.start {
		panic("span.end cannot be less than span.start")
	}

	// if we point exactly to eof on a blank trailing line
	// step back by 1 so we capture the line with actual code
	target_pos := span.start
	if target_pos == len(source) && target_pos > 0 && source[target_pos - 1] == '\n' {
		target_pos -= 1
	}

	// walk to target pos
	line_no := 1
	c_start := 0
	p_start := -1

	for i := 0; i < target_pos; i += 1 {
		if source[i] == '\n' {
			p_start = c_start
			line_no += 1
			c_start = i + 1
		}
	}
	column := target_pos - c_start
	p_end := p_start != -1 ? c_start - 1 : -1

	// walk forward from target pos
	// scan from target_pos to find the true end of the current line
	// prevents multi line spans from bleeding int ocurrent line print
	c_end := target_pos
	for c_end < len(source) && source[c_end] != '\n' {
		c_end += 1
	}

	n_start, n_end := -1, -1
	if c_end < len(source) { 	// stopped at a newline so a next line probably exists
		n_start = c_end + 1
		n_end = n_start
		for n_end < len(source) && source[n_end] != '\n' {
			n_end += 1
		}
	}

	// find the padding width for line numbers
	max_ln := n_start != -1 ? line_no + 1 : line_no
	digits := 0
	for t := max_ln; t > 0; t /= 10 {
		digits += 1
	}
	if digits == 0 do digits = 1

	// previous line
	if p_start != -1 {
		fmt.printf(
			"%s%*d | %s%s\n",
			GRAY_START,
			digits,
			line_no - 1,
			ANSI_RESET,
			source[p_start:p_end],
		)
	}

	// current line (the one with error)
	fmt.printf("%s%*d | %s%s\n", GRAY_START, digits, line_no, ANSI_RESET, source[c_start:c_end])

	// print ^ here
	fmt.printf("%*s   ", digits, "")
	current_line_str := source[c_start:c_end]
	for i in 0 ..< column {
		if i < len(current_line_str) && current_line_str[i] == '\t' {
			fmt.print("\t")
		} else {
			fmt.print(" ")
		}
	}

	// clamp the ^ length so it wont extend past the current line boundary
	actual_end := min(span.end, c_end)
	span_width := max(1, actual_end - span.start)
	for _ in 0 ..< span_width {
		fmt.print("^")
	}
	fmt.println(RED_START, " here", ANSI_RESET, sep = "")

	// the next line
	if n_start != -1 {
		fmt.printf(
			"%s%*d | %s%s\n",
			GRAY_START,
			digits,
			line_no + 1,
			ANSI_RESET,
			source[n_start:n_end],
		)
	}

	if should_panic {
		os.exit(1)
	}
}
