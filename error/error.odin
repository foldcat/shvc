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

	if span.start < 0 || span.start > len(source) {
		panic("span.start out of range")
	}

	// if we point exactly to eof on a blank trailing line
	// step back by 1 so we capture the line with actual code
	target_pos := span.start
	if target_pos == len(source) && target_pos > 0 && source[target_pos - 1] == '\n' {
		target_pos -= 1
	}

	// find target line number and column pos
	line_no := 1
	line_start := 0
	for i := 0; i < target_pos; i += 1 {
		if source[i] == '\n' {
			line_no += 1
			line_start = i + 1
		}
	}
	column := target_pos - line_start

	// extract the boundaries for previous, current & next line
	curr := 0
	idx := 1
	p_start, p_end := -1, -1
	c_start, c_end := -1, -1
	n_start, n_end := -1, -1

	for curr <= len(source) {
		line_end := curr
		for line_end < len(source) && source[line_end] != '\n' {
			line_end += 1
		}

		if idx == line_no - 1 {
			p_start, p_end = curr, line_end
		} else if idx == line_no {
			c_start, c_end = curr, line_end
		} else if idx == line_no + 1 {
			n_start, n_end = curr, line_end
			break // dont need to scan further
		}

		curr = line_end + 1
		idx += 1
		if curr > len(source) do break
	}

	// find the padding width for line numbers
	max_ln := line_no
	if n_start != -1 do max_ln = line_no + 1
	digits := 0
	for t := max_ln; t > 0; t /= 10 {
		digits += 1
	}
	if digits == 0 do digits = 1

	// render

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
	if c_start != -1 {
		fmt.printf(
			"%s%*d | %s%s\n",
			GRAY_START,
			digits,
			line_no,
			ANSI_RESET,
			source[c_start:c_end],
		)
	}

	// print ^ here
	if c_start != -1 {
		fmt.printf("%*s   ", digits, "")

		current_line_str := source[c_start:c_end]
		for i in 0 ..< column {
			// use tabs if it is tab to prevent alignment issues
			if i < len(current_line_str) && current_line_str[i] == '\t' {
				fmt.print("\t")
			} else {
				fmt.print(" ")
			}
		}
		fmt.println(RED_START, "^ here", ANSI_RESET, sep = "")
	}

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
