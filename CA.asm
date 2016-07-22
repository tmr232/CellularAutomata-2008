;=====================================================================
;Interesting Rules:
;1E
;5A
;6E
;7E
;=====================================================================

;=====================================================================
;The data segment
;=====================================================================
dseg	segment
	;Text Messages:
;=====================================================================
;The intro message shows as the main screen
;=====================================================================
	intro	db "##### #### #    #    #  # #    #### ###" ,0dh,0ah
			db "#     #    #    #    #  # #    #  # #  #" ,0dh,0ah
			db "#     #### #    #    #  # #    #### ###" ,0dh,0ah
			db "#     #    #    #    #  # #    #  # #  #" ,0dh,0ah
			db "##### #### #### #### #### #### #  # #  #" ,0dh,0ah
			db 0dh,0ah
			db "#### #  # ##### #### ## ## #### ##### ####" ,0dh,0ah
			db "#  # #  #   #   #  # # # # #  #   #   #  #" ,0dh,0ah
			db "#### #  #   #   #  # # # # ####   #   ####" ,0dh,0ah
			db "#  # #  #   #   #  # #   # #  #   #   #  #" ,0dh,0ah
			db "#  # ####   #   #### #   # #  #   #   #  #" ,0dh,0ah
			db	0dh,0ah
			db	"Press 1 for help, 2 to start, else -> quit.$"
;=====================================================================
;The about message is the first help screen
;=====================================================================
	about	db	"What is Cellular Automata?",0dh,0ah,0dh,0ah
			db	"Cellular Automata (CA) is a collection of 'colored'",0dh,0ah
			db	"cells on a grid of specified shape that evolves through",0dh,0ah
			db	"a number of discrete time steps according to a set of",0dh,0ah
			db	"rules based on the states of neighboring cells. The",0dh,0ah
			db	"rules are then applied iteratively for as many time",0dh,0ah
			db	"steps as desired.",0dh,0ah,0dh,0ah
			db	"-Wolfram Mathworld.$"
;=====================================================================
;The howto is the second help screen
;=====================================================================
	howTo	db	"To experiment with this program, choose the option 'start'.",0dh,0ah
			db	"Then enter a rule number and colors.",0dh,0ah
			db	"The rule is a hexadecimal number, it's binary representation is"
			db	"used by the",0dh,0ah,"program as the CA's set of rules.",0dh,0ah
			db	"To produce interesting patterns, the first row is always set with a"
			db	" single live",0dh,0ah,"point at it's center."
			db 	0dh,0ah
			db 	0dh,0ah
			db	"Rule:	|	Cell Status:",0dh,0ah
			db	"0	|	|0|0|0|",0dh,0ah
			db	"1	|	|0|0|1|",0dh,0ah
			db	"2	|	|0|1|0|",0dh,0ah
			db	"3	|	|0|1|1|",0dh,0ah
			db	"4	|	|1|0|0|",0dh,0ah
			db	"5	|	|1|0|1|",0dh,0ah
			db	"6	|	|1|1|0|",0dh,0ah
			db	"7	|	|1|1|1|",0dh,0ah
			db 	0dh,0ah
			db	"The binary code of the entered code is inversed and used as "
			db	"the truth rule,",0dh,0ah,"indexed as drawn above. There are 2^8 = FF possible"
			db	"rules generating various",0dh,0ah,"patterns."
			db 	0dh,0ah
			db	"Colors are selected from the FF VGA pallete."
			db 	"$"
;=====================================================================
;The example is the third help screen
;=====================================================================
	example	db	"Here's is an example of the rule application:" ,0dh,0ah
			db	"Rule Number: 1E	Binary Representation: 00011110",0dh,0ah
			db	"Rule Interpretation: 01111000",0dh,0ah
			db	"   |  #| # | ##|#  |# #|## |###",0dh,0ah
			db	"   | # | # | # | # |   |   |",0dh,0ah,0dh,0ah
			db	"And for a more interesting exemple:",0dh,0ah
			db	"#",0dh,0ah
			db	"##",0dh,0ah
			db	"# #",0dh,0ah
			db	"#  #",0dh,0ah
			db	"#####",0dh,0ah
			db	"#    #",0dh,0ah
			db	"##  ###",0dh,0ah
			db	"# ###  #",0dh,0ah
			db	"#    ####$"
;=====================================================================
;The rulemsg shows when a user is asked for the CA rule
	ruleMsg	db	"Please Enter a Rule Number (0 - FF):$"
;The bgmsg shows when asking for a background color
	bgMsg	db	"Please Enter a Background-Color Number (0 - FF):$"
;the fgmsg shows when asking for a foreground color
	fgMsg	db	"Please Enter a Foreground-Color Number (0 - FF):$"
;The invMsg shows whenever a user enters invalid input
	invMsg	db	"Invalid Input, Please Enter a Hex Number:$"
;the clkAny shows when the user needs to click to get to the next screen
	clkAny	db	"Click any key to continue...$"
;nLine is the code for writing a new line
	nLine	db	0dh,0ah,'$'
;=====================================================================
;Mode Variables - these store information  about the different screen modes
		;text
	textMode	db	3h
	;tWidth
	tHeight		dw	50
		;graphics
	graphicsMode	db	13h
	gScrWidth	dw	320
	gScrHeight	dw	200
	gMemory		dw	0A000h
	
	;Drawing Variables:
	gFGColor	db	0fh
	gBGColor	db	0
	
	;Cellular Automata Variables:
	rule	db	8	dup(?)
	;Temporary Variables:
	tempStr	db	3,4 dup(?)
dseg	ends

;=====================================================================
;The stack segment:
;=====================================================================
sseg	segment	stack
	dw	100h	dup(?)
sseg	ends

;=====================================================================
;The code segment
;=====================================================================
cseg	segment
	assume cs:cseg,ds:dseg,ss:sseg
	
;=====================================================================
;This function sets the cursor in the beginning of the next line.
;Input: None
;Output: None
;Requires: the new line text
;=====================================================================
NewLine	proc
	push ax dx
	mov ah,9h
	mov dx,offset nLine
	int 21h
	pop dx ax
	ret
NewLine	endp

;=====================================================================
;This function clears the screen.
;Input: None
;Output: None
;Requires: the hight of the screen
;=====================================================================
ClrScr	proc
	push cx dx ax bx
	mov cx,tHeight
clrscrLoop:
	call NewLine
	loop clrscrLoop
	
	;move cursor to top left corner
	xor bh, bh		;Page number - 0
	xor dx, dx		;dl<---Column=0  ,  dh<---Line=0
	mov ah, 2
	int 10h
	
	pop bx ax dx cx
	ret
ClrScr	endp

;=====================================================================
;This function writes a string to the screen.
;Input: The offset of the string
;Output: None
;Usage: Push the offset of the string into the stack, and call the function.
;Example:
;	push offset someStringName
;	call Write
;=====================================================================
Write	proc
	push bp
	mov bp,sp
	push ax dx
	mov ah,9h
	mov dx,ss:[bp+4]
	int 21h
	pop dx ax bp
	ret 2
Write	endp

;=====================================================================
;This function gets a string from the user.
;Input: The offset of the string
;Output: The user's string is put into the given string location
;Usage: Push the offset of the string and call the function.
;Example:
;	push offset someTargetStringName
;	call GetS
;=====================================================================
GetS	proc
	push bp
	mov bp,sp
	push ax dx
	mov dx,ss:[bp+4]
	mov ah,0ah
	int 21h
	pop dx ax bp
	ret 2
GetS	endp
	
;=====================================================================
;This function gets a hexadecimal number from the user.
;Input: None
;Output: The hexadecimal number is the first cell in the stack
;Exceptions: If the input is NOT a hexadecimal number, set the carry flag to 1.
;Usage: Call the function.
;Warning: Erases the top word of the stack
;Example:
;	push ax		;protect the stack
;	call GetWord	;call the function
;	pop ax		;get the user input
;=====================================================================
GetWord proc
	push bp
	mov bp,sp
	push ax
	push si
	push cx
	push bx
	
	mov ch,0
	mov si,ss:[bp+4]
	mov cl,byte ptr ds:[si+1]
	inc si
	mov ax,0
	
getWordLoop:
	inc si ; start loop
	mov bl,byte ptr ds:[si]
	
	cmp bl,'0' ; if:number
	jb checkCase
	cmp bl,'9'
	ja checkCase
	jmp digit
	
checkCase:
	cmp bl,'a' ; if:small letter
	jb upperCase
	cmp bl,'f'
	ja upperCase
	jmp lowerCase
upperCase:

	cmp bl,'A' ; checks if num,else quits
	jb NotNum
	cmp bl,'F'
	ja NotNum
	
	sub bl,'A'; big letter
	add bl,0ah
	push cx
	mov cx,4
	rol ax,cl
	pop cx
	add al,bl
	jmp wordLoop
digit:
	sub bl,'0';number
	push cx
	mov cx,4
	rol ax,cl
	pop cx
	add al,bl
	jmp wordLoop
lowerCase:
	sub bl,'a'; small letter
	add bl,0ah
	push cx
	mov cx,4
	rol ax,cl
	pop cx
	add al,bl
wordLoop:
	loop getWordLoop
	mov ss:[bp+4],ax
	pop bx
	pop cx
	pop si
	pop ax
	pop bp
	clc
	ret
NotNum:
	pop bx
	pop cx
	pop si
	pop ax
	pop bp
	stc
	ret
GetWord endp
	

;=====================================================================
;This function converts a number to a CA Rule
;Input: the Hexadecimal number, the offset of the rule array
;Stack Order:
	;ss:[bp+6]	->	push rule number
	;ss:[bp+4]	->	push offset rule array
	
;Output: the CA Rule in the rule array
;Code Example:
	;push ruleNumber
	;push offsetRuleArray
	;call NumToRule
	
;Use of Registers:
	;cx	->	Used as a loop counter, gets the rule's length
	;bx	->	Pointer to the rule array
	;ax	->	The rule number
	
;Function Example:
	;Number = 30d = 11110b
	;Rule = 0,1,1,1,1,0,0,0
;=====================================================================
NumToRule	proc
		push bp
		mov bp,sp
		push ax bx cx
		mov cx,8				;cs = rule length
		mov bx,ss:[bp+4]		;bx = offset rule array
		mov ax,ss:[bp+6]		;ax = rule number
movLoop:
		shr ax,1				;cf = next rule
		mov byte ptr ds:[bx],0	;in order to avoid errors, each rule cell
								;is set to 0 before adding the rule to it.
		adc byte ptr ds:[bx],0	;rule[bx] = cf
		inc bx					;bx++
		loop movLoop
		pop cx bx ax bp
		ret 4
NumToRule endp

;=====================================================================
;This function draws the CA patterns onto the screen memory.
;Input: background color, foreground color, screen memory adress, screen height (px),
	;screen width (px), offset from the beginning of screen memory, offset of the CA Rule
;Stack ordering:
	;push gFGColor,gBGColor	->ss:[bp+14]
	;push screenMem	-> ss:[bp+12]
	;push height		-> ss:[bp+10]
	;push width		-> ss:[bp+8]
	;push offset array	-> ss:[bp+6] (offset from screenMem[0])
	;push offset rule	-> ss:[bp+4]

;Output: draws and pattern to the screen, returns nothing.
;Algorithm explanation:
	;for each cell in the array, from the second row forth, check the
	;three closest neighbours from the row above ([cell-width-1],[cell-width],[cell-width+1])
	;and generate a number from it (binary number - first cell is 4, second is 2 and tthe third cell is 1).
	;Use this number as the index for the rule array to determine the new cell state.
	;Keep looping on all the rows and columns.
	;Edge cells are always dead.

;Code Example:
	;mov al, foregroundColor
	;mov ah, backgroundColor
	;push ax
	;push screenMem
	;push height
	;push width
	;push offsetFromScreenMem
	;push offset CARule
	;call Create1D
;=====================================================================
Create1D	proc
		push bp
		mov bp,sp
		push ax bx cx dx si di es
		mov ax,ss:[bp+12];ax = screenMem
		mov es,ax;es  = screenMem
		mov cx,ss:[bp+10];cx = height
		mov di,ss:[bp+6];di = offset array
		mov si,di
		add si,ss:[bp+8];si += width
		mov dx,ss:[bp+14];dl = gFGColor , dh = gBGColor
rowLoop:
		push cx
		mov cx,ss:[bp+8];cx = width
colLoop:
		xor al,al
		cmp cx,ss:[bp+8];width
		;je nextCell
		je makeBG
		cmp cx,1
		;je nextCell
		je makeBG
		cmp byte ptr es:[di-1],dh
		je check2
		add al,4
check2:
		cmp byte ptr es:[di],dh
		je check3
		add al,2
check3:
		cmp byte ptr es:[di+1],dh
		je checkRule
		inc al
checkRule:
		xor bh,bh
		mov bl,al
		push di
		mov di,ss:[bp+4];offset rule
		mov al,ds:[di+bx];check the rule
		cmp al,0
		je setBG
		mov es:[si],dl
		jmp setFG
setBG:
		mov es:[si],dh
setFG:
		pop di
nextCell:
		inc di
		inc si
		loop colLoop
		pop cx
		loop rowLoop
		pop es di si dx cx bx ax bp
		ret 12
makeBG:
		mov es:[si],dh
		jmp nextCell
Create1D	endp

;=====================================================================
;This function sets one live (foreground) cell (pixel) in the middle of the first line (top line of the screen),
	;and sets all other cells in the row to dead (background).
;Input: width of the row, graphics memory adress, foreground color, background color
;Stack Order:
	;ss:[bp+8]	->	push gFGColor,gBGColor
	;ss:[bp+6]	->	push gMemory
	;ss:[bp+4]	->	push row width

;Output: None
;Usage: used before Create1D to set the first generation.
;Example:
	;mov al, foregroundColor
	;mov ah, backgroundColor
	;push ax
	;push gMemory
	;push rowWidth
	;call SetTopRow
;=====================================================================
SetTopRow	proc	;used to set a single active pixel in the middle of the top row.
	push bp
	mov bp,sp
	push ax bx cx es
	mov cx,ss:[bp+4]	;cx = row width
	mov bx,0			;bx = top row pointer
	mov ax,ss:[bp+6]	;ax = gMemory
	mov es,ax
	mov ax,ss:[bp+8]	;al = gFGColor , ah = gBGColor
	
	add cx,2
	dec bx
	
topRowLoop:
	mov byte ptr es:[bx],ah
	inc bx
	loop topRowLoop
	mov bx,ss:[bp+4]	;bx = row width
	shr bx,1			;bx = bx/2 = middle of the row
	mov byte ptr es:[bx],al
	pop es cx bx ax bp
	ret 6
SetTopRow	endp
;=====================================================================
;Upon runtime, the program starts here.
;=====================================================================
Main:
	mov ax,dseg
	mov ds,ax

restart:;The program returns to here after viewing the help screens or drawing a pattern.
	;Clear the screen
	call ClrScr
	
	;print the intro message
	push offset intro
	call Write
	;wait for a key
	mov ah,7
	int 21h
	;if 1, show help
	cmp al,'1'
	je showHelp
	;if 2, start the cellular automata
	cmp al,'2'
	je midStart
	;else, quit
	xor al,al
	mov ah,4ch
	int 21h
midStart:
	jmp start
	;Show Help Code:

;=====================================================================
;This part of the code shows the help screens.
;=====================================================================
showHelp:
;Clear the screen
	call ClrScr
	;write the about text
	push offset about
	call Write
	
	call NewLine
	call NewLine
	
	push offset clkAny
	call Write
	
	mov ah,7
	int 21h
	
	call ClrScr
	;write the how-to text
	push offset howTo
	call Write
	
	call NewLine
	call NewLine
	
	push offset clkAny
	call Write
	
	
	mov ah,7
	int 21h
	
	call ClrScr
	;show the example
	push offset example
	call Write
	
	call NewLine
	call NewLine
	
	push offset clkAny
	call Write
	
	mov ah,7
	int 21h
	
	call ClrScr
	
	jmp restart

;=====================================================================
;this part of the code gets user input and draws the pattern
;=====================================================================
start:
	;call ClrScr
	call ClrScr
	;set new line
	call NewLine
	call NewLine
;=====================================================================
;get the rule number
	push offset ruleMsg
	call Write
	
AgainRule:
	
	push offset tempStr
	call Gets
	
	push offset tempStr
	call GetWord
	
	call NewLine
	jnc GoodRule	;if the input is a valid hex number, continue, 
	;else, ask the user for new info.
	push offset invMsg
	call Write
	
	jmp AgainRule
GoodRule:
	push offset rule
	call NumToRule
;Rule code gathered
;=====================================================================
;get the background color
	;set new line
	call NewLine
	;ask for a bg-color
	push offset bgMsg
	call Write

AgainBgC:
	
	push offset tempStr
	call Gets
	
	push offset tempStr
	call GetWord
	call NewLine
	
	jnc GoodBgC;if the input is a valid hex number, continue, 
	;else, ask the user for new info.
	
	push offset invMsg
	call Write
	
	jmp AgainBgC
GoodBgC:
	pop ax
	mov gBGColor,al
;background color gathered
;=====================================================================
;get the foreground color
	;set new line
	call NewLine
	;ask for fg-color
	push offset fgMsg
	call Write
	
AgainFgC:
	
	push offset tempStr
	call Gets
	
	push offset tempStr
	call GetWord
	call NewLine
	
	jnc GoodFgC;if the input is a valid hex number, continue, 
	;else, ask the user for new info.
	
	push offset invMsg
	call Write
	
	jmp AgainFgC
GoodFgC:
	
	pop ax
	mov gFGColor,al
;foreground color gathered
;=====================================================================
	;initialize the graphics mode
	xor ah,ah
	mov al,graphicsMode
	int 10h
	;initialize the first row (make single centered)
	mov al,gFGColor
	mov ah,gBGColor
	push ax
	push gMemory
	push gScrWidth
	call SetTopRow
	;draw the cellular automata pattern
	push ax
	push gMemory
	push gScrHeight
	push gScrWidth
	push 0
	push offset rule
	call Create1D
	;wait for a key
	mov ah,7
	int 21h
	;goto textmode
	mov al,textMode
	xor ah,ah
	int 10h
	;start the program all over again
	jmp restart

cseg	ends
end		Main
;=====================================================================
;EOF!!!
;=====================================================================