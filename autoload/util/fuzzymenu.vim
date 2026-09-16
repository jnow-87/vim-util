""""
"" configuration variables
""""
"{{{

let g:fuzzymenu_search_sym = get(g:, "fuzzymenu_search_sym", "/")
"}}}

""""
"" local variables
"""""
"{{{
let s:menu_win_id = -1
let s:menu_text = []
let s:menu_text_filtered = []
let s:menu_dict = []
let s:menu_dict_filtered = []
let s:callback = ""
let s:user_query = ""
"}}}

""""
"" local functions
"""""
"{{{
" \brief	update the popup menu content based on the user query
function s:apply_query()
	let s:menu_text_filtered = []
	let s:menu_dict_filtered = []

	" match s:user_query against the original s:menu_text instead of
	" s:menu_text_filtered to correctly handle characters getting removed from
	" s:user_query
	for match in matchstrlist(s:menu_text, ".*" . s:user_query . ".*")
		let s:menu_text_filtered += [s:menu_text[l:match["idx"]]]
		let s:menu_dict_filtered += [s:menu_dict[l:match["idx"]]]
	endfor

	call popup_setoptions(s:menu_win_id, {"title": g:fuzzymenu_search_sym . " ". s:user_query})
	call popup_settext(s:menu_win_id, s:menu_text_filtered)
endfunction

" \brief	popup callback handler for handling user keyboard input
"
" \param	win_id	popup window id
" \param	key		key pressed
"
" \return	v:true to indicate that a key was handled and prevent it from
" 			being handled by vim
function s:menu_input_hdlr(win_id, key)
	let s:translate = {
	\	"\<tab>": "\<down>",
	\	"\<s-tab>": "\<up>",
	\ }

	" ignore '~' since it has a special meaning within regex and will cause
	" problems within s:apply_query()
	let s:translate["~"] = ""

	let l:key = get(s:translate, a:key, a:key)

	if l:key == "\<esc>"
		call popup_close(a:win_id, -1)

	elseif index(["\<cr>", "\<down>", "\<up>"], l:key) != -1
		call popup_filter_menu(a:win_id, l:key)

	elseif l:key == "\<backspace>"
		let s:user_query = s:user_query[0:-2]
		call s:apply_query()

	else
		let s:user_query .= l:key
		call s:apply_query()
	endif

	return v:true
endfunction

" \brief	popup callback handler for when the user closes the menu
" 			either by selecting an item dismissing the menu
"
" \param	win_id		popup window id
" \param	result		one-based index of the selected menu line
function s:menu_closed_hdlr(win_id, result)
	if a:result >= 1 && a:result <= len(s:menu_text)
		exec "call " . s:callback . "(s:menu_dict_filtered[a:result - 1])"
	endif
endfunction
"}}}

""""
"" global functions
"""""
"{{{
" \brief	open a popup menu which allows the user to fuzzy search its items
"
" \param	items		list of dicts containing at least the "text" key, which
" 						will be displaced to the user
"
" \param	callback	function to be called upon menu entry selection,
" 						prototype: 'foo(selected_entry)'
"
" 						the function is called if the user selects and
" 						entry from the menu, it is not called if the menu
" 						is closed without selecting anything
"						the function receives the selected entry from the
"						items dictionary
"
" \param	selected	one-based index of the menu item to highlight upon
" 						opening the menu
"}}}
function util#fuzzymenu#open(items, callback, selected=0)
	let l:args = {
	\	"line": "cursor+1",
	\	"col": "cursor-1",
	\	"mapping": v:false,
	\	"cursorline": v:true,
	\	"wrap": v:false,
	\	"filter": "s:menu_input_hdlr",
	\	"callback": "s:menu_closed_hdlr",
	\	"title": g:fuzzymenu_search_sym,
	\ }

	let s:callback = a:callback
	let s:user_query = ""
	let s:menu_dict = a:items
	let s:menu_text = []

	for item in a:items
		let s:menu_text += [item["text"]]
	endfor

	let s:menu_text_filtered = s:menu_text
	let s:menu_dict_filtered = s:menu_dict

	let s:menu_win_id = popup_create(s:menu_text, l:args)

	if a:selected != 0
		call win_execute(s:menu_win_id, "normal! " . (a:selected - 1) . "j")
	endif
endfunction
"}}}
