 ;*Dissassembler*
 ;*Kestutis Gimbutas, 4 kursas, 3 grupe, programu sistemos*         
          
          
.model small

bufdydis EQU 1            ;konstanta bufDydis (lygi 1) - skaitymo ir raðymo buferiø dydþiai

.stack 100h   

.data         
      ilgis1 DB  2 dup (0)             ;pirmo  failko duomenu ilgis (simboliu skaicius)
	 ilgis22 DB  2 dup (0)
      duom1  DB  "duom.txt", 0;30 dup (0)            ;duomenø failo pavadinimas, pasibaigiantis nuliniu simboliu (C sintakse - '\0')
      rez    DB  "rez.txt", 0;30 dup (0)            ;rezultatø failo pavadinimas, pasibaigiantis nuliniu simboliu
      skbuf1 DB  bufdydis dup (?)      ;skaitymo buferis pirmo failo
      r1buf  DB  bufdydis dup (?)      ;rasymo buferis
      r2buf  DB  bufdydis dup (?)      ;laikinas atminties buferis                                
      d1d    DW  ?                     ;vieta, skirta saugoti duomenø failo deskriptoriaus numerá ("handle")
      rd     DW  ?                     ;vieta, skirta saugoti rezultato failo deskriptoriaus numerá     
      fp     DW  00h                   ;file pointer, poslinkis nuo filepointerio pradzios
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
        
        tmp DW ? 
      tmpsk DB 0h
      modrm DB 0h
        reg DB 0h
        arw DB 0h
       kabl DB ","
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
             JC   help                        ;jei atidarant failà skaitymui ávyksta klaida, nustatomas carry flag
             MOV  d1d, ax	                  ;atmintyje iðsisaugom duomenø failo deskriptoriaus numeri           
           
;*rezultato failo sukurimas/atidarymas rasymui*

rez1atid:

             MOV  ah, 3Ch			          ;21h pertraukimo failo sukûrimo funkcijos numeris
             MOV  cx, 0		                  ;kuriamo failo atributai
             MOV  dx, offset rez              ;vieta, kur nurodomas failo pavadinimas, pasibaigiantis nuliniu simboliu
             INT  21h                         ;sukuriamas failas; jei failas jau egzistuoja, visa jo informacija iðtrinama
             JC   help      ;jei kuriant failà skaitymui ávyksta klaida, nustatomas carry flag
             MOV  rd, ax                      ;atmintyje iðsisaugom rezultato failo deskriptoriaus numerá

			 
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
    ;CALL rasykrm
    CALL rasykkableli
    
    CALL rasykreg        
    JMP ciklas

;_____________________________________________________________
;PROCEDUROS

skaityk1baita proc            
    mov al, 0
	mov bx, d1d
	mov cx, 0
	mov dx, fp
	inc fp
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

    ;CALL rasykrm
    ;CALL rasykkableli
    ;CALL rasykreg





rasykreg proc
xor ax, ax      
mov al, reg
add al, arw
mov bx, 2
mul bx
mov bx, ax
mov dx, offset tmp
jmp cs:TblReg[bx]    
TblReg dw r00, r01, r02, r03, r04, r05, r06, r07
       dw r10, r11, r12, r13, r14, r15, r16, r17 
r00:mov tmp, "AL"
    Call irasykZodi 
    ret
r01:mov tmp, "CL"
    Call irasykZodi
    ret 
r02:mov tmp, "DL"
    Call irasykZodi
    ret  
r03:mov tmp, "BL"
    Call irasykZodi
    ret  
r04:mov tmp, "AH"
    Call irasykZodi
    ret  
r05:mov tmp, "CH"
    Call irasykZodi
    ret  
r06:mov tmp, "DH"
    Call irasykZodi
    ret  
r07:mov tmp, "BH"
    Call irasykZodi
    ret  
r10:mov tmp, "AX"
    Call irasykZodi
    ret  
r11:mov tmp, "CX"
    Call irasykZodi
    ret  
r12:mov tmp, "DX"
    Call irasykZodi
    ret  
r13:mov tmp, "BX"
    Call irasykZodi
    ret  
r14:mov tmp, "SP"
    Call irasykZodi
    ret  
r15:mov tmp, "BP"
    Call irasykZodi
    ret  
r16:mov tmp, "SI"
    Call irasykZodi
    ret  
r17:mov tmp, "DI"
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

	INT	21h        			;raðymas á failà
	JC	klaidaRasant		;jei raðant á failà ávyksta klaida, nustatomas carry fla
	JMP skaito1                                                                                                                                                                                                                                                                                               
;rezultato failo uzdarymas
  uzdarytiRasymui:
             MOV  ah, 3Eh                      ;21h pertraukimo failo uþdarymo funkcijos numeris
             MOV  bx, rd                    ;á bx áraðom rezultato failo deskriptoriaus numerá
             INT  21h                          ;failo uþdarymas
             JC   klaidaUzdarantRasymui        ;jei uþdarant failà ávyksta klaida, nustatomas carry flag
	
;Duomenø failo uþdarymas
  uzdarytiSkaitymui1:
             MOV  ah, 3Eh                      ;21h pertraukimo failo uþdarymo funkcijos numeris
             MOV  bx, d1d                   ;á bx áraðom duomenø failo deskriptoriaus numerá
             INT  21h                          ;failo uþdarymas
             JC   klaidaUzdarantSkaitymui1	  ;jei uþdarant failà ávyksta klaida, nustatomas carry flag           
	     
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