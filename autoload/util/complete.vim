""""
"" global functions
""""
let s:cmd_dict = {}


"{{{
" \brief	init command tab-completion
"
" \param	dict	the dictionary containing completion
" 					information
function util#complete#init(dict)
	let s:cmd_dict = deepcopy(a:dict)
endfunction
"}}}

"{{{
" \brief	tab-completion lookup function
"
" \param	arg		argument at cursor
" \param	line	command line
" \param	pos		offset into line
function util#complete#lookup(arg, line, pos)
	" create argument list based on a:line[0 .. a:pos - 1]
	let l:argv = split(tolower(strpart(a:line, 0, a:pos)))
	let l:argc = len(l:argv)

	" initialise dictionary pointer
	let l:dict = s:cmd_dict

	" iterate over arguments (l:argv) checking dictionary for completion
	let l:i = 0
	while l:i < l:argc
		if has_key(l:dict, l:argv[l:i])
			" l:dict contains key l:argv[i], hence cycle to next dictionary
			let l:dict = l:dict[l:argv[l:i]]
		else
			" key l:argv[i] is not present in l:dict

			if l:i == l:argc - 1 && a:line[a:pos - 1] != ' '
				" l:argv[i] is the last argument, since there is no entry in
				" l:dict and a:line[a:pos - 1] is not a blank, the current
				" argument is incomplete, hence break the loop and return
				" content of current dictionary l:dict
				break

			elseif has_key(l:dict, "__nested__")
				" l:dict contains an entry '__nested__', i.e. its completion
				" is computed via a function
				" completion will only continue if a second stage nest is
				" present, i.e. '__nested1__' is defined as a dictionary
				"
				if !has_key(l:dict, "__nested1__")
					" no subsequent completion for this argument
					return ""
				endif

				" get subsequent dictionary
				let l:subnest = l:dict["__nested1__"]

				" get completion for current argument
				exec "let l:str = " . l:dict["__nested__"] . "(\"" . l:argv[l:i] . "\")"

				" generate intermediate dictionary containing all results for
				" the current completion level as key and the subsequent nest,
				" as value
				let l:sargv = split(l:str, '\n')
				let l:sargc = len(l:sargv)

				let l:dict = {}
				for l:j in range(0, l:sargc - 1)
					let l:dict[l:sargv[l:j]] = l:subnest
				endfor

				" for next iteration with same element of l:argv[] but on the
				" intermediate dictionary
				continue

			else
				" no entry found for argument, while argument also not being
				" incomplete, this indicated an invalid argument
				" incomplete ar
				return ""
			endif
		endif

		let l:i += 1
	endwhile

	let l:user = ""

	if has_key(l:dict, "__nested__")
		" call used-defined function to compute the completion string
		exec "let l:user = " . l:dict["__nested__"] . "(\"" . a:arg . "\")"
	endif

	" create string of keys in l:dict, removing '__nested__'
	return substitute(join(sort(keys(l:dict)), "\n"), "__nested1*__\n*", "", "g") . l:user
endfunction
"}}}

"{{{
" \brief	helper function to complete file names
"
" \param	subcmd	current argument supplied in command line
function util#complete#file(subcmd)
	" get list of files
	exec "let l:files = glob(\"" . a:subcmd . "*\", 0, 1)"

	" append '/' to directories
	let l:i = 0
	for l:file in l:files
		if isdirectory(l:file) != 0
			let l:files[l:i] .= "/"
		endif

		let l:i += 1
	endfor

	return join(sort(l:files), "\n")
endfunction
"}}}
