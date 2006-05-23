" GPL Notice:
"
"    This program is free software; you can redistribute it and/or modify
"    it under the terms of the GNU General Public License as published by
"    the Free Software Foundation; either version 2 of the License, or
"    (at your option) any later version.
"
"    This program is distributed in the hope that it will be useful,
"    but WITHOUT ANY WARRANTY; without even the implied warranty of
"    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
"    GNU Library General Public License for more details.
"
"    You should have received a copy of the GNU General Public License
"    along with this program; if not, write to the Free Software
"    Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA 02111-1307, USA.
"
"
" Name:
"
"    autoproto.vim 
"
"
" Copyright:
" 
"    Jochen Baier, 2006 (email@Jochen-Baier.de)
"
"
" Based on:
"
"    cream-pop.vim
"    CursorHold example
"
" Version: 0.03
" Last Modified: May 23, 2006
"
"
" The "autoproto" plugin displays the function parameter/prototypes
" in the preview window if you type a left parenthesis behind
" a function name.
" With this plugin it is not necessary to memorize large parameter lists.
" You do not need to leave insert mode. Typing is almost not affected.
"
"
" Supported Languages: C
"
" Installation: 
"
" * Drop autoproto.vim into your plugin directory 
"
" * The script need a tag file to work:
"  - for your project: ":!ctags -R ." (or use the gvim button)
"  - for library functions: 
"    run: "ctags -R -f ~/.vim/systags --c-kinds=+p /usr/include /usr/local/include"
"    put  "set tags+=~/.vim/systags" in your .vimrc file.
"
" * Open some *.c file and write for example: "XCreateWindow ("
"   (or "XCreateWindow(").
"   If the tag exist it will be shown in the preview window.
"   Note: only *.c files are supported ! The file must exist.
"   
"

function! Debug (...)

 "remove for debug
  return
 
  let i  = 1
  let msg= ""
  while i <= a:0
   exe "let msg=msg.a:".i
   if i < a:0
    let msg=msg." "
   endif
   let i=i+1
  endwhile

  call Decho (msg)

endfunction

function! Rm_leading_spaces (string)
  
  let first_letter=0

  while 1==1

    if a:string[first_letter] != " "
      break
    else
     let first_letter=first_letter + 1
    endif

   if first_letter >= strlen(a:string)
    call Debug ("leading spaces problem -> skip")
    return 0
   endif

  endwhile 

  return strpart(a:string, first_letter) 
 
endfunction

function Rm_trailing_spaces (string)

  let line=a:string
  let string_len = strlen (line)
  let last_letter=string_len - 1
  let space_count = 0
  
  while 1==1

    if line[last_letter] != " "
      break
    else
      let last_letter=last_letter  - 1
      let space_count = space_count + 1
      call Debug ("space_count: " . space_count) 

      if space_count > 1
        call Debug ("too many trailing spaces -> skip")
        return 0
      endif

    endif

    if last_letter <= 1
      call Debug ("trailing spaces problem -> skip")
      return 0
    endif

  endwhile                              

  return strpart(line, 0, last_letter + 1)          

endfunction    

function! Get_last_word(...)

  call Debug ("function: Get_last_word")

  let line=getline (".")
  let line_len=strlen (line)
  call Debug ("line: <" . line . ">")
   
  if line_len < 1
    call Debug ("line too short -> skip")
    return 0
  endif

  if line_len == 1
    if line == " "
      call Debug ("line is only one blank --> skip")
      return
    endif
  endif
  

  let line=Rm_trailing_spaces (line)

  if line == "0"
      return 0
  endif

  call Debug ("after remove trailing spaces: <" .  line. ">" )

  let line=Rm_leading_spaces(line) 
  if line == "0"
    return 0
  endif  


  "could be inside a comment
  if strpart(line, 0, 2) == "/*"
    call Debug ("large comment found")
    return 0
  endif

  if strpart(line, 0, 2) == "//"
    call Debug ("line comment found")
    return 0
  endif


  "semicolon ?
  let semi=strridx (line, ";")
  if semi != -1
    let line=strpart(line, semi+1)
    call Debug("after last semi: <" . line . ">")      
  endif   

  let line=Rm_leading_spaces(line)   
  call Debug("line after leading_spaces after semi: <" . line . ">")
  if line == "0"
    return 0
  endif

  call Debug ("cleand line: <" . line . ">")
 

  "could be a new function definition...  

  if strridx (line, "=") == -1

  if strpart(line, 0, 6) == "static"
    call Debug ("static found")
    return 0
  endif

  if strpart(line, 0, 4) == "void"
    call Debug ("void found")
    return 0
  endif

  if strpart(line, 0, 6) == "extern"
    call Debug ("extern found")
    return 0
  endif

  if strpart(line, 0, 8) == "volatile"
    call Debug ("volatile found")
    return 0
  endif    
 
  if strpart(line, 0, 6) == "inline"
    call Debug ("inline found")
    return 0
  endif

  if strpart(line, 0, 6) == "struct"
    call Debug ("inline found")
    return 0
  endif    

  if strpart(line, 0, 8) == "unsigned"
    call Debug ("unsigned found")
    return 0
  endif 

  if strpart(line, 0, 3) == "int"
    call Debug ("int found")
    return 0
  endif

  if strpart(line, 0, 4) == "long"
    call Debug ("long found")
    return 0
  endif

  if strpart(line, 0, 5) == "fload"
    call Debug ("fload found")
    return 0
  endif

  if strpart(line, 0, 4) == "char"
    call Debug ("char found")
    return 0
  endif 

  endif

  "comma ?
 let comma=strridx (line, ",")
 if comma != -1
   let line=strpart(line, comma+1)
   call Debug("after comma: <" . line . ">")      
 endif   

 let line=Rm_leading_spaces(line) 
 if line == "0"
   return 0
 endif      

 "could be inside a string
  if stridx (line, "\"")  != -1
    call Debug("probably inside a string")
    return 0
  endif    

  "last space
  let last_blank=  strridx(line, " ")
  if last_blank != -1
    call Debug ("last_blank found")
    let line = strpart(line, last_blank + 1)
  endif   

  call Debug ("last_string:<" . line . ">") 

  if strlen (line) == 0
    call Debug ("last_string zero length -> skip")
    return 0
  endif


  "signs..
  let start_pos = -1
  let tmp= strridx(line, "!")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif

  let tmp= strridx(line, "=")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif

  let tmp= strridx(line, "{")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif

  let tmp= strridx(line, "+")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif

  let tmp= strridx(line, "-")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif

  let tmp= strridx(line, ">")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif
            
  let tmp= strridx(line, "<")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif
            
  let tmp= strridx(line, ":")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif
            
  let tmp= strridx(line, "?")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif


  let tmp= strridx(line, ")")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif
            
  let tmp= strridx(line, "(")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif

  let tmp= strridx(line, "&")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif    

  let tmp= strridx(line, "|")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif 

  let tmp= strridx(line, "/")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif

  let tmp= strridx(line, "%")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif

  let tmp= strridx(line, "~")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif

  let tmp= strridx(line, "\"")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif 

  let tmp= strridx(line, "*")
  if tmp != -1
    if tmp > start_pos
      let start_pos=tmp
    endif
  endif      

  if start_pos >= (strlen (line)-1)
        call Debug("start_pos >= strlen")
        return 0
  endif

  call Debug ("start_pos: " . start_pos)
            
  let line = strpart(line, start_pos+1) 
  call  Debug("last word:<". line . ">")

  let word_len =strlen (line)
  call Debug ("word len:" . word_len)

  if word_len == 0
   call Debug ("zero length word ->skip")
   return 0
  endif

  while 1==1

    if line == "if"
      return 0
    endif

    if line == "for"
      return 0
    endif  

    if line == "while"
      return 0
    endif
   
    if line == "switch"
      return 0
    endif 

    if line == "sizeof"
      return 0
    endif  

    if line == "int"
      return 0
    endif
  
    if line == "long"
      return 0
    endif
  
    if line == "float"
      return 0
    endif
  
    if line == "char"
      return 0
    endif 

    if line == "return"
      return 0
    endif   

    break  
  endwhile

 return line

endfunction

function! Open_bracket (...)

  let last_word = Get_last_word()

  if last_word == "0"
    call Debug ("tag is 0 -> skip")
    return
  endif

  if strlen (last_word) < 1
    call Debug ("tag has zero length -> skip")
    return
  endif

  call Debug ("tag is:<" . last_word . ">") 

  silent! wincmd P
  if &previewwindow
    match none
    wincmd p
  endif

  try
    exe "ptag " . last_word
  catch
    call Debug ("ptag failed !")
    return
  endtry

  silent! wincmd P		
  if &previewwindow	
 
	  if has("folding")
	    silent! .foldopen
	  endif

    let cur_pos=winline()
    if cur_pos <= 1 
      let cur_pos = 0
    else
      let cur_pos=cur_pos -1
    endif

	  call search("$", "b")
	  let w = substitute(last_word, '\\', '\\\\', "")
	  call search('\<\V' . last_word . '\>')
    hi previewWord term=bold ctermbg=green guibg=green
    exe 'match previewWord "\%' . line(".") . 'l\%' . col(".") . 'c\k*"'

    if cur_pos != 0
      execute "normal " . cur_pos . "\<C-e>"
    endif

    wincmd p 

  endif

endfunction

function! Map_comma (...)

  inoremap <silent> <buffer> ( <C-o>:call Open_bracket()<CR>(

endfunction                                   

autocmd BufRead *.c call Map_comma()
