""""
"" global functions
""""
"{{{
" \brief	create exec-mode abbreviation
"
" \param	abbrev		LHS
" \param	expansion	RHS
function util#abbrev#execabbrev(abbrev, expansion)
	exec 'cabbr ' . a:abbrev . ' <c-r>=getcmdpos() == 1 && getcmdtype() == ":" ? "' . a:expansion . '" : "' . a:abbrev . '"<CR>'
endfunction
"}}}
