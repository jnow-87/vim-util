""""
"" global functions
""""

"{{{
" \brief	push an entry to the tag stack
"
" \param	tag_name	name of the tag
" \param	buf_nr		vim buffer number
" \param	position	file position as returned by getpos()
function util#tagstack#push(tag_name, buf_nr, position)
	let l:dict = {
	\	"bufnr": a:buf_nr,
	\	"from": a:position,
	\	"tagname": a:tag_name,
	\ }

	call settagstack(win_getid(), { "items": [ l:dict ] }, "a")
endfunction
"}}}

"{{{
" \brief	push the cursor position in the current file to the tag stack
function util#tagstack#push_cursor()
	call util#tagstack#push(expand("<cword>"), bufnr(), getpos("."))
endfunction
"}}}
