.486
.model flat, stdcall
option casemap :none
include windows.inc
include kernel32.inc
include masm32.inc
include user32.inc
includelib kernel32.lib
includelib masm32.lib
includelib user32.lib 
            
sportsmenStats struct
	day 		   dd ?
	mounth 		   dd ?
	year 		   dd ?
	weight 		   dq ?
sportsmenStats ends

.data
	array		   sportsmenStats <1, 2, 2010, 78.4>, <4, 5, 2001, 85.4>, <8, 9, 2005, 74.2>
	slashN             dw 10      
	zero 		   dd 0
	template           db "%2.2s (day), %2.2s (mounth), %4.4s (year), %3.4s (weigth)", 0     
	srcArrrMsg 	   db "Arr: ", 0
	arrAfterSByWeight  db "After sort by weight: ", 0
	arrAfterSByDate    db "After soet by date: ", 0  
	
.data?     
	inputHandle        dd ?
	outputHandle       dd ?
	numberOfChars      dd ?  
	inputBuffer	   dd ?
	numberRes 	   dd ? 
	
	tempDay 	   dd ? 
	tempMonth 	   dd ?
	tempYear 	   dd ?
	tempWeight	   dd ?
	
	answer             db 1000 dup (?)
	
.code    

sportsmenStatsCompareByWeight:
	mov EAX, [ ESP + 4 ]
	fld qword ptr [ EAX + 12]
	mov EAX, [ ESP + 8 ]
	fcomp qword ptr [ EAX + 12]
	fstsw AX
	sahf
	
	ja greatByWeight
	jb lessByWeight
		mov EAX, 0
		jmp returnByWeight
	greatByWeight:
		mov EAX, 1
		jmp returnByWeight
	lessByWeight:
		mov EAX, -1
	returnByWeight:
ret 8      


sportsmenStatsCompareByDate:
	mov EAX, [ ESP + 4 ]
	fld dword ptr [ EAX + 8 ]
	mov EAX, [ ESP + 8 ]
	fcomp dword ptr [ EAX + 8 ]
	fstsw AX
	sahf 
	ja greatByWeight
	jb lessByWeight          
	
	mov EAX, [ ESP + 4 ]
	fld dword ptr [ EAX + 4 ]
	mov EAX, [ ESP + 8 ]
	fcomp dword ptr [ EAX + 4 ]
	fstsw AX
	sahf 
	ja greatByWeight
	jb lessByWeight          
	
	mov EAX, [ ESP + 4 ]
	fld dword ptr [ EAX ]
	mov EAX, [ ESP + 8 ]
	fcomp dword ptr [ EAX ]
	fstsw AX
	sahf 
	ja greatByWeight
	jb lessByWeight
	
		mov EAX, 0
		jmp returnByDate
	greatByDate:
		mov EAX, 1
		jmp returnByDate
	lessByDate:
		mov EAX, -1
	returnByDate:
ret 8          
               

selectionSort:    
	mov EBX, [ ESP + 4 ]
	mov EBP, [ ESP + 8 ]
	mov EDX, [ ESP + 12 ] 
 
	beginCycleSort:
		cmp EBP, 1
		je endCycleSort              
		     
		
		mov ESI, EBX
                mov EDI, EBP 
		
		beginCycleMax:
			cmp EDI, 0
			je endCycleMax   
		
			push ESI
			push EBX
			call EDX
		
			cmp EAX, 0
			jng skipMax
				mov ESI, EBX
			skipMax:
			add EBX, 20
			dec EDI
			jmp beginCycleMax
		endCycleMax:    
	      
	 
  		mov EDI, EBP
  		
		beginCycle:
			cmp EDI, 0
			je endCycle
                        sub EBX, 20
                        dec EDI
			jmp beginCycle
		endCycle:   
		
		push [ EBX ] 
		push [ ESI ]
		pop dword ptr [ EBX ]
		pop dword ptr [ ESI ]   
		
		push [ EBX + 4 ] 
		push [ ESI + 4 ]
		pop dword ptr [ EBX + 4 ]
		pop dword ptr [ ESI + 4 ]       
		
		push [ EBX + 8 ] 
		push [ ESI + 8 ]
		pop dword ptr [ EBX + 8 ]
		pop dword ptr [ ESI + 8 ]
	        
		fld qword ptr [ ESI + 12 ]
		fld qword ptr [ EBX + 12 ]
       		fstp qword ptr [ ESI + 12 ]
		fstp qword ptr [ EBX + 12 ]
		   
		add EBX, 20   
		dec EBP
		
		jmp beginCycleSort
	endCycleSort:
ret 12  

printArray:      
	mov EBX, [ ESP + 4 ]  
	mov ESI, [ ESP + 8 ]
                    
   	outputBegin:  
		cmp ESI, 0
		je endOutputBegin    
		
		push offset tempDay
		push [ EBX ]
		call dwtoa 
		
		push offset tempMonth
		push [ EBX + 4 ]
		call dwtoa
	        
	        push offset tempYear
		push [ EBX + 8 ]
		call dwtoa
	                                                                            
		push offset tempWeight  
		push [ EBX + 12 ] + 4
		push [ EBX + 12 ]
		call FloatToStr
	        
		push offset tempWeight
		push offset tempYear
		push offset tempMonth
		push offset tempDay
		push offset template
		push offset answer
		call wsprintf
		add ESP, 24
		 
		push offset answer
       		call lstrlen
       		push NULL
       		push offset numberOfChars
       		push EAX
		push offset answer
       		push outputHandle
		call WriteConsole  
		
		push NULL
		push offset numberOfChars
		push 1
		push offset slashN
		push outputHandle
		call WriteConsole 
		
		add EBX, 20
		dec ESI	   
			   
   		jmp outputBegin	
   	endOutputBegin:
ret 8

  
entryPoint:
	push STD_INPUT_HANDLE
	call GetStdHandle
	mov inputHandle, EAX
	push STD_OUTPUT_HANDLE
	call GetStdHandle
	mov outputHandle, EAX   	    
        
	push offset srcArrrMsg
       	call lstrlen
       	push NULL
       	push offset numberOfChars
       	push EAX
	push offset srcArrrMsg
       	push outputHandle
	call WriteConsole    
	
	push NULL
	push offset numberOfChars
	push 1
	push offset slashN
	push outputHandle
	call WriteConsole

        push 3               
        push offset array       
        call printArray  
        
	push NULL
	push offset numberOfChars
	push 1
	push offset slashN
	push outputHandle
	call WriteConsole 

        
        
        push offset arrAfterSByWeight
       	call lstrlen
       	push NULL
       	push offset numberOfChars
       	push EAX
	push offset arrAfterSByWeight
       	push outputHandle
	call WriteConsole
	
	push NULL
	push offset numberOfChars
	push 1
	push offset slashN
	push outputHandle
	call WriteConsole      
        
        push sportsmenStatsCompareByWeight          
        push 3 
        push offset array
        call selectionSort
        
        push 3               
        push offset array       
        call printArray  
        
	push NULL
	push offset numberOfChars
	push 1
	push offset slashN
	push outputHandle
	call WriteConsole 
	  
              
        
        push offset arrAfterSByDate    
       	call lstrlen
       	push NULL
       	push offset numberOfChars
       	push EAX
	push offset arrAfterSByDate    
       	push outputHandle
	call WriteConsole                         
        
	push NULL
	push offset numberOfChars
	push 1
	push offset slashN
	push outputHandle
	call WriteConsole    
        
        push sportsmenStatsCompareByDate
        push 3 
        push offset array
        call selectionSort             
        
        push 3               
        push offset array       
        call printArray     
        
        
        push NULL
	push offset numberOfChars
	push 1
	push offset inputBuffer
	push inputHandle
	call ReadConsole

	push 0
	call ExitProcess
END entryPoint  