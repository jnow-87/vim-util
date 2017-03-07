""""
"" global functions
""""
"{{{
" \brief	focus given line in current buffer
"
" \param	line		line to focus, -1 if nothing should be done
" \param	foldopen	0: nothing
" 						1: open fold if the target line contains one
function util#window#focus_line(line, foldopen)
	if a:line != -1
		exec a:line

		if a:foldopen
			silent! foldopen
		endif
	endif
endfunction
"}}}

"{{{
" \brief	focus window in current tab
"
" \param	win			window number to focus
" \param	line		cf. 'util#window#focus_line()'
" \param	foldopen	cf. 'util#window#focus_line()'
"
" \return	0	on success
" 			-1	on negative window number
function util#window#focus_window(win, line, foldopen)
	if a:win == -1
		return -1
	endif

	exec a:win . "wincmd w"
	call util#window#focus_line(a:line, a:foldopen)

	return 0
endfunction
"}}}

"{{{
" \brief	focus given file, potentially switching to another tab or
" 			open a new one
"
" \param	file		filename to switch to
" \param	line		cf. 'util#window#focus_line()'
" \param	foldopen	cf. 'util#window#focus_line()'
"
" \return	0	buffer for the file found/switched in the current tab
"			1	filen opened or found in another tab
function util#window#focus_file(file, line, foldopen)
	let bnum = bufnr(a:file)

	if bnum != -1
		" buffer exists, try to switch to its window in the current tab
		if util#window#focus_window(bufwinnr(bnum), a:line, a:foldopen) == 0
			return 0
		endif

		" if buffer not found in current tab, check all tabs
		for i in range(1, tabpagenr('$'))
			if index(tabpagebuflist(i), bnum) != -1
				" switch tab and window once buffer found
				exec "tabnext " . i
				call util#window#focus_window(bufwinnr(bnum), a:line, a:foldopen)

				return 1
			endif
		endfor
	endif

	" open file in new tab
	exec "tabnew " . a:file
	call util#window#focus_line(a:line, a:foldopen)

	return 1
endfunction
"}}}

let s:win_width = {}

"{{{
" \brief	toggle window width maximisation
function util#window#expand()
	" generate name using buffername and tabpage number
	let name = bufname('%') . "_" . tabpagenr()

	if has_key(s:win_width, name)
		" if an original size is saved, restore it and remove the entry
		exec "vert resize " . s:win_width[name]
		call remove(s:win_width, name)
	else
		" if no original size is saved, store current size and maximise window
		let s:win_width[name] = winwidth(0)
		vert resize
	endif
endfunction
"}}}
