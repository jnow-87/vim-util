" get own script ID
nmap <c-f11><c-f12><c-f13> <sid>
let s:sid = "<SNR>" . maparg("<c-f11><c-f12><c-f13>", "n", 0, 1).sid . "_"
nunmap <c-f11><c-f12><c-f13>


""""
"" local variables
"""""
"{{{
let s:map_trigger = "<c-f11><c-f12>"

let s:callback = ""
let s:menu_entries = []
let s:omnifunc = ""
let s:pos = []
"}}}

""""
"" local functions
""""
"{{{
" \brief	handle omni-compeltion triggered within 'pmenu#open'
" 
" \param	findstart	argument accordin to 'help complete-functions'
" \param	base		argument accordin to 'help complete-functions'
"
" \return	list used for popup-menu
function Pemu_complete(findstart, base)
	" return current column
	if a:findstart == 1
		return col('.')
	endif

	" extend provided list
	for e in s:menu_entries
		let e.word = a:base	" avoid any insertions
		let e.dup = 1		" allow multiple entries with same 'word'
		let e.empty = 1		" add entry even it is an empty string
	endfor

	return s:menu_entries
endfunction
"}}}

"{{{
" \brief	function called once completion is finished
" 			cleanup temporary mappings and autocommands used to trigger the
" 			menu
function s:complete_done()
	" cleanup temporary autocommands and mappings
	autocmd! PMENU
	exec "nunmap " . s:map_trigger

	" reset omnifunc
	exec "set omnifunc=" . s:omnifunc

	" call user callback forwarding selection
	exec "call " . s:callback . "(v:completed_item)"

	let pos = getpos('.')

	" reset cursor column if still in the same buffer at the same line
	if pos[0] == s:pos[0] && pos[1] == s:pos[1] && pos[3] == s:pos[3]
		let pos[2] = s:pos[2]
		call setpos('.', pos)
	endif

	" reset local variables
	let s:callback = ""
	let s:menu_entries = []
	let s:pos = []
endfunction
"}}}

""""
"" global functions
""""
"{{{
" \brief	generate and trigger popup-menu
" 			function has to be invoked through an <expr> map or via <c-r>,
" 				nmap <expr> x util#pmenu#open(lst, "<sid>dummy", "n")
"				imap <expr> y util#pmenu#open(lst, "<sid>dummy", "i")
"				imap x <c-r>=util#pmenu#open(lst, "<sid>dummy", "i")<cr>
"
" \param	menu_entries	list of dictionaries containing desired menu
" 							entries, dictionary format according to 
" 							'help complete-items' (at least provide "abbr")
" \param	callback		function to be called upon menu entry selection,
" 							prototype: 'foo(select_dict)'
" 							result is provided as dictionary (cf. 'help complete-items')
" \param	mode			vim mode active when invoking 'pmenu#open':
" 								"n"	normal mode
" 								"i"	inset mode
" 								"v"	visual mode
" 								"s"	selection mode
" \param 	selected		menu entry to set the cursor to
"
" \return	string to trigger omni-completion
function util#pmenu#open(menu_entries, callback, mode, selected=0)
	let s:menu_entries = a:menu_entries
	let s:callback = a:callback

	if len(a:menu_entries) == 0 || a:callback == ""
		return "\<esc>"
	endif

	let s:pos = getpos('.')
	let s:omnifunc = &omnifunc
	set omnifunc=Pemu_complete

	augroup PMENU
	exec 'autocmd PMENU CompleteDone * call feedkeys("\<esc>' . escape(s:map_trigger, "<") . '")'
	augroup END

	call util#map#n(s:map_trigger, ":call " . s:sid . "complete_done()<cr>", "")

	let trigger = "\<c-x>\<c-o>"
	let trigger .= repeat("\<down>", a:selected)

	if stridx(a:mode, "i") == -1
		return "\<insert>". trigger
	endif

	return trigger
endfunction
"}}}
