""""
"" local functions
""""
"{{{
" parse the given mode for additional modifier
" modifier for mode:
" 	'nosilent'	do not create a <silent> mapping
"
" modifier for entry action:
" 	'noescape'	do not escape from current mode
"
" modifier for exit action:
" 	'noinsert'	do not fall back to insert mode
function s:get_param(mode)
	" get mode
	let mode = a:mode

	if stridx(mode, "nosilent") != -1
		let mode = substitute(mode, "nosilent", "", "g")
	else
		let mode .= "<silent>"
	endif

	" get entry action
	let entry = ""

	if stridx(mode, "noescape") != -1
		let mode = substitute(mode, "noescape", "", "g")
	else
		let entry .= "<right><esc>"
	endif

	" get exit action
	let exit = ""

	if stridx(mode, "noinsert") != -1
		let mode = substitute(mode, "noinsert", "", "g")
	else
		let exit .= "<insert>"
	endif

	return [ mode, entry, exit ]
endfunction
"}}}

""""
"" global functions
""""
"{{{
" create silent normal mode mapping
function util#map#n(lhs, rhs, mode="")
	let [ mode, entry, exit ] = s:get_param(a:mode)

	exec 'nnoremap ' . mode . ' ' . a:lhs . ' ' . a:rhs
endfunction
"}}}

"{{{
" create silent insert mode mapping
function util#map#i(lhs, rhs, mode="")
	let [ mode, entry, exit ] = s:get_param(a:mode)

	exec 'inoremap ' . mode . ' ' . a:lhs . ' ' . entry . a:rhs . exit
endfunction

"}}}

"{{{
" create silent visual mode mapping
function util#map#v(lhs, rhs, mode="")
	let [ mode, entry, exit ] = s:get_param(a:mode)

	exec 'vnoremap ' . mode . ' ' . a:lhs . ' ' . a:rhs
	exec 'snoremap ' . mode . ' ' . a:lhs . ' ' . a:rhs
endfunction
"}}}

"{{{
" create silent normal and insert mode mapping
function util#map#ni(lhs, rhs, mode="")
	call util#map#n(a:lhs, a:rhs, a:mode)
	call util#map#i(a:lhs, a:rhs, a:mode)
endfunction
"}}}

"{{{
" create silent normal and visual mode mapping
function util#map#nv(lhs, rhs, mode="")
	call util#map#n(a:lhs, a:rhs, a:mode)
	call util#map#v(a:lhs, a:rhs, a:mode)
endfunction
"}}}

"{{{
" create silent normal and visual mode mapping
function util#map#nvi(lhs, rhs, mode="")
	call util#map#n(a:lhs, a:rhs, a:mode)
	call util#map#v(a:lhs, a:rhs, a:mode)
	call util#map#i(a:lhs, a:rhs, a:mode)
endfunction
"}}}

"{{{
" \brief	escape the given key, e.g. <tab> to \<tab>
"
" \param	key		string containing the key to escape
function util#map#escape(key)
	execute "let l:ekey = \"" . escape(a:key, "<") . "\""
	return l:ekey
endfunction
"}}}
