 ;*Dissassembler*
 ;*Kestutis Gimbutas, 4 kursas, 3 grupe, programu sistemos*         
          
          
.model small

bufdydis EQU 1            ;konstanta bufDydis (lygi 1) - skaitymo ir ra�ymo buferi� dyd�iai

.stack 100h   

.data         
      ilgis1 DB  2 dup (0)             ;pirmo  failko duomenu ilgis (simboliu skaicius)
	 ilgis22 DB  2 dup (0)
      duom1  DB  "TEST.COM", 0;30 dup (0)            ;duomen� failo pavadinimas, pasibaigiantis nuliniu simboliu (C sintakse - '\0')
      rez    DB  "rez.txt", 0;30 dup (0)            ;rezultat� failo pavadinimas, pasibaigiantis nuliniu simboliu
      skbuf1 DB  bufdydis dup (?)      ;skaitymo buferis pirmo failo
      r1buf  DB  bufdydis dup (?)      ;rasymo buferis
      r2buf  DB  bufdydis dup (?)      ;laikinas atminties buferis                                
      d1d    DW  ?                     ;vieta, skirta saugoti duomen� failo deskriptoriaus numer� ("handle")
      rd     DW  ?                     ;vieta, skirta saugoti rezultato failo deskriptoriaus numer�
      cikl   DB  2     
      nusk   DB  100 dup ('$')   
      count  DB  1        
      MOVas  DB "MOV", 0Dh, 0Ah, "$"
 neatpazinta DB "-", 0Dh, 0Ah, "$"
	klRa     DB "Ivyko klaida rasant i rezultato faila", 10,13, "$"
    klUzRa   DB "ivyko klaida uzdarant rezultato faila", 10,13, "$"	
    klUzSk1  DB "Ivyko klaida uzdarant pirma duomenu faila", 10,13, "$"  
      HELPas DB  " Si programa atidaro duomenu faila, sukuriu rezultato faila."
             DB  " Po to nuskaito duomenu faila i buferi ir buferi iraso i"
             DB  " i rezultato faila."
             DB  " Pastaba1: duomenu failo ilgis negali buti didesnis uz 255 "  
             DB  " Pastaba2: parametruose turi buti nurodyti 2 failu vardai, "
             DB  " sia seka: duomenu failas1, rezulatato failas $" 
        
       tmpW DW ?
       tmpB DB ?
      tmpsk DB 0h
      modrm DB 0h
        reg DB 0h
        arw DB 0h
       kabl DB ","
       plus DB "+"
       entr DB 0Dh, 0Ah
        c88 DB "Mov $"
        c89 DB "Mov $"
        c8A DB "Mov $"
        c8B DB "Mov $"
        c8C DB "Mov $"
        c8E DB "Mov $"
        ;c8F DB "Pop $"
        ;c9A DB "Call cs:$"
        cA0 DB "Mov Al, ds:$"
        cA1 DB "Mov AX, ds:$"
        cA2 DB "Mov ds:$"
        cA3 DB "Mov ds:$" 
        cB0 DB "Mov AL, $"
        cB1 DB "Mov CL, $"
        cB2 DB "Mov DL, $"
        cB3 DB "Mov BL, $"
        cB4 DB "Mov Ah, $"
        cB5 DB "Mov Ch, $"
        cB6 DB "Mov Dh, $"
        cB7 DB "Mov Bh, $"
        cB8 DB "Mov AX, $"
        cB9 DB "Mov CX, $"
        cBA DB "Mov DX, $"
        cBB DB "Mov BX, $"
        cBC DB "Mov SP, $"
        cBD DB "Mov BP, $"
        cBE DB "Mov SI, $"
        cBF DB "Mov DI, $"
             

             
.code                                  ; kodo segmento pradzia

pratimas22:      
                                                                                                                
             MOV  ax, @data            ; ds registro iniciavimas                                                                                                   
             MOV  ds, ax               ; ds rodytu i duomenu segmento pradzia                          
          
             JMP duom1atid
                                                                  
             mov si, 80h      
             xor cx, cx        
             mov cl, es:[si]
             mov count, cl      
             lea di, nusk      
             cmp cx, 0          
             jz help        
             inc si  

nextsim:
             mov al, es:[si]
             mov ds:[di], al
             inc si
             inc di
             loop nextsim
 
             xor cx, cx
             mov cl, count
             lea si, nusk  
             mov al, "/"   
             mov ah, "?" 

arslash:
             cmp ds:[si], al
             je arQmark 
             inc si
             loop arslash        
             jmp file 

arQmark:  
             inc si
             cmp ds:[si], ah
             je help

file:
             lea si, nusk 
             inc si        
             dec count
             lea di, duom1
             xor cx, cx
             mov cl, count
            
duom1fail:  
             mov al, ds:[si]
             mov ds:[di], al 
             cmp al, 20h
             je rezultfail
             inc si
             inc di
             loop duom1fail  
             JMP help

rezultfail:
             lea di, rez  
             inc si   
             dec cl
rezdirek:   
             mov al, ds:[si]
             cmp al, 20h
             je  nera
             mov ds:[di], al
             inc si
             inc di
             loop rezdirek
             JMP nera     
    
help:
             mov ah, 9h
             mov dx, offset helpas
             int 21h
             JMP pabaiga

nera:         

;*duomenu faulu atidarymas skaitymui*
             MOV  word ptr cikl, 0000h 
duom1atid:

             MOV  ah, 3Dh				      ;21h pertraukimo failo atidarymo funkcijos numeris
             MOV  al, 00				      ;00 - failas atidaromas skaitymui
           	 MOV  dx, offset duom1            ;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
             INT  21h                         ;failas atidaromas skaitymui
             JC   help                        ;jei atidarant fail� skaitymui �vyksta klaida, nustatomas carry flag
             MOV  d1d, ax	                  ;atmintyje i�sisaugom duomen� failo deskriptoriaus numeri           
           
;*rezultato failo sukurimas/atidarymas rasymui*

rez1atid:

             MOV  ah, 3Ch			          ;21h pertraukimo failo suk�rimo funkcijos numeris
             MOV  cx, 0		                  ;kuriamo failo atributai
             MOV  dx, offset rez              ;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
             INT  21h                         ;sukuriamas failas; jei failas jau egzistuoja, visa jo informacija i�trinama
             JC   help      ;jei kuriant fail� skaitymui �vyksta klaida, nustatomas carry flag
             MOV  rd, ax                      ;atmintyje i�sisaugom rezultato failo deskriptoriaus numer�

			 
Ciklas:            

pirmas:  

skaito1:
     
    CALL skaityk1baita                     
 
;_________________________________________________________________________	   
;di - pirmas failas



atpazinkkomanda:


	cmp al, 8Bh
	JE MOVa
    
    MOV DX, offset neatpazinta   
	CALL irasyk
    JMP ciklas
    
    
MOVa:
    MOV DX, offset c8B
    MOV arw, 1000b
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykreg 
    CALL rasykkableli    
    CALL rasykrm
    CALL rasykIsNaujEil      
    JMP ciklas

;_____________________________________________________________
;PROCEDUROS

skaityk1baita proc            
    mov al, 0
	mov bx, d1d
	mov cx, 0
	mov dx, 0
	mov ah, 42h
	int 21h ; seek... 
	mov bx, d1d
	mov dx, offset skbuf1
	mov cx, 1
	mov ah, 3fh
	int 21h ; read from file... 
    cmp ax, 0h
    JE  uzdarytiRasymui
    mov ah, 0h
    mov al, skbuf1
    mov di, ax
    ret
skaityk1baita endp
        
setmodrmIRreg proc
    push ax
    push ax
    push ax    
regas:
    pop ax
    SHL al, 02h
    SHR al, 05h
    mov reg, al    
modrmas:    
    pop ax
    SHR al, 06h
    SHL al, 03h
    mov tmpsk, al
    pop ax
    SHL al, 02h
    SHR al, 05h
    ADD al, tmpsk
    MOV modrm, al
    ret    
setmodrmIRreg endp
 
rasykrm proc
xor ax, ax      
add al, modrm  
mov bx, 2
mul bx
mov bx, ax
mov dx, offset tmpW
jmp cs:TblModRM[bx]    
TblModRM dw o00, o01, o02, o03, o04, o05, o06, o07

o00:
mov tmpW, "[B"
Call irasykZodi 
mov tmpW, "X]"
Call irasykZodi
push dx
mov dx, offset plus
CALL irasykBaita
pop dx
mov tmpW, "[S"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi 
ret
o01:
mov tmpW, "[B"
Call irasykZodi    
mov tmpW, "X]"
Call irasykZodi
push dx
mov dx, offset plus
CALL irasykBaita
pop dx 
mov tmpW, "[D"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi
ret 
o02:
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "P]"
Call irasykZodi
push dx
mov dx, offset plus
CALL irasykBaita
pop dx 
mov tmpW, "[S"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi
ret  
o03:
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "P]"
Call irasykZodi
push dx
mov dx, offset plus
CALL irasykBaita
pop dx 
mov tmpW, "[D"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi
ret  
o04:
mov tmpW, "[S"
Call irasykZodi
mov tmpW, "I]"
Call irasykZodi
ret  
o05:
mov tmpW, "[D"
Call irasykZodi
mov tmpW, "I]"
Call irasykZodi
ret  
o06:
mov tmpW, "ds" 
Call irasykZodi
mov tmpW, ":0"
Call irasykZodi
mov al, 00h
;Call Writeal
mov al, 00h
;Call Writeal
;mov tmpB, "h"
;Call Writebbb 
ret  
o07:
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "X]"
Call irasykZodi
ret  
rasykrm endp  
 
rasykreg proc
xor ax, ax      
mov al, reg
add al, arw
mov bx, 2
mul bx
mov bx, ax
mov dx, offset tmpW
jmp cs:TblReg[bx]    
TblReg dw r00, r01, r02, r03, r04, r05, r06, r07
       dw r10, r11, r12, r13, r14, r15, r16, r17 
r00:mov tmpW, "AL"
    Call irasykZodi 
    ret
r01:mov tmpW, "CL"
    Call irasykZodi
    ret 
r02:mov tmpW, "DL"
    Call irasykZodi
    ret  
r03:mov tmpW, "BL"
    Call irasykZodi
    ret  
r04:mov tmpW, "AH"
    Call irasykZodi
    ret  
r05:mov tmpW, "CH"
    Call irasykZodi
    ret  
r06:mov tmpW, "DH"
    Call irasykZodi
    ret  
r07:mov tmpW, "BH"
    Call irasykZodi
    ret  
r10:mov tmpW, "AX"
    Call irasykZodi
    ret  
r11:mov tmpW, "CX"
    Call irasykZodi
    ret  
r12:mov tmpW, "DX"
    Call irasykZodi
    ret  
r13:mov tmpW, "BX"
    Call irasykZodi
    ret  
r14:mov tmpW, "SP"
    Call irasykZodi
    ret  
r15:mov tmpW, "BP"
    Call irasykZodi
    ret  
r16:mov tmpW, "SI"
    Call irasykZodi
    ret  
r17:mov tmpW, "DI"
    Call irasykZodi      
    ret
rasykreg endp       
                              
irasyk proc    
ieskokpabaigos:    
    MOV di, dx      
    CMP DS:[di], "$"
    JNE irasyk1simb 
    RET 
irasyk1simb:
    MOV cx, 1h
	MOV ah, 40h
	MOV bx, rd
    INT	21h
	JC	klaidaRasant
    INC dx
    JMP ieskokpabaigos
    RET  
irasyk endp

irasykZodi proc
    MOV cx, 1h
	MOV ah, 40h
	MOV bx, rd
	inc dx
    INT	21h
	JC	klaidaRasant    
        
    MOV cx, 1h
	MOV ah, 40h
	MOV bx, rd
	dec dx
    INT	21h
	JC	klaidaRasant
	RET    
irasykZodi endp

irasykBaita proc
    MOV cx, 1h
	MOV ah, 40h
	MOV bx, rd
    INT	21h
	JC	klaidaRasant
	ret     
irasykBaita endp

rasykIsNaujEil proc    
    mov dx, offset entr
    MOV cx, 2h
	MOV ah, 40h
	MOV bx, rd
    INT	21h
	JC	klaidaRasant
	RET
rasykIsNaujEil endp
    
rasykkableli proc
    mov dx, offset kabl
    MOV cx, 1h
	MOV ah, 40h
	MOV bx, rd
    INT	21h
	JC	klaidaRasant
	ret     
rasykkableli endp                                                        
 ;_______________________________________________________________________   
irasykifaila:

	INT	21h        			;ra�ymas � fail�
	JC	klaidaRasant		;jei ra�ant � fail� �vyksta klaida, nustatomas carry fla
	JMP skaito1                                                                                                                                                                                                                                                                                               
;rezultato failo uzdarymas
  uzdarytiRasymui:
             MOV  ah, 3Eh                      ;21h pertraukimo failo u�darymo funkcijos numeris
             MOV  bx, rd                    ;� bx �ra�om rezultato failo deskriptoriaus numer�
             INT  21h                          ;failo u�darymas
             JC   klaidaUzdarantRasymui        ;jei u�darant fail� �vyksta klaida, nustatomas carry flag
	
;Duomen� failo u�darymas
  uzdarytiSkaitymui1:
             MOV  ah, 3Eh                      ;21h pertraukimo failo u�darymo funkcijos numeris
             MOV  bx, d1d                   ;� bx �ra�om duomen� failo deskriptoriaus numer�
             INT  21h                          ;failo u�darymas
             JC   klaidaUzdarantSkaitymui1	  ;jei u�darant fail� �vyksta klaida, nustatomas carry flag           
	     
pabaiga:
             MOV  ah, 4Ch                       ;reikalinga kiekvienos programos pabaigoj
             MOV  al, 0                         ;reikalinga kiekvienos programos pabaigoj
             INT  21h                           ;reikalinga kiekvienos programos pabaigoj




klaidaRasant:
	    mov ah, 9h
            mov dx, offset klra
            int 21h
            JMP pabaiga
	JMP	uzdarytiRasymui
klaidaUzdarantRasymui:
	    mov ah, 9h
            mov dx, offset kluzra
            int 21h
            JMP pabaiga
	JMP	uzdarytiSkaitymui1
klaidaUzdarantSkaitymui1:
	    mov ah, 9h
            mov dx, offset kluzsk1
            int 21h
            JMP pabaiga
	JMP	pabaiga  
		
END pratimas22