 ;*Dissassembler*
 ;*Kestutis Gimbutas, 4 kursas, 3 grupe, programu sistemos*         
          
          
.model small

bufdydis EQU 1            ;konstanta bufDydis (lygi 1) - skaitymo ir raðymo buferiø dydþiai

.stack 100h   

.data         
      ilgis1 DB  2 dup (0)             ;pirmo  failko duomenu ilgis (simboliu skaicius)
	 ilgis22 DB  2 dup (0)
      duom1  DB  "TEST.COM", 0;30 dup (0)            ;duomenø failo pavadinimas, pasibaigiantis nuliniu simboliu (C sintakse - '\0')
      rez    DB  "rez.txt", 0;30 dup (0)            ;rezultatø failo pavadinimas, pasibaigiantis nuliniu simboliu
      skbuf1 DB  bufdydis dup (?)      ;skaitymo buferis pirmo failo
      r1buf  DB  bufdydis dup (?)      ;rasymo buferis
      r2buf  DB  bufdydis dup (?)      ;laikinas atminties buferis                                
      d1d    DW  ?                     ;vieta, skirta saugoti duomenø failo deskriptoriaus numerá ("handle")
      rd     DW  ?                     ;vieta, skirta saugoti rezultato failo deskriptoriaus numerá
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

        c00 DB "ADD $"
        c01 DB "ADD $"
        c02 DB "ADD $"
        c03 DB "ADD $"
        c04 DB "ADD AL, $"
        c05 DB "ADD AX, $"          
        c06 DB "Push ES $"
        c07 DB "Pop ES $"
        c0E DB "Push CS $"
        c0F DB "Pop CS $"
        c16 DB "Push SS $"
        c17 DB "Pop SS $"
        c1E DB "Push DS $"
        c1F DB "Pop DS $"  
        c28 DB "Sub $"
        c29 DB "Sub $"
        c2A DB "Sub $"
        c2B DB "Sub $"    
        c2C DB "Sub AL, $"
        c2D DB "Sub AX, $"    
        c38 DB "Cmp $"
        c39 DB "Cmp $"
        c3A DB "Cmp $"
        c3B DB "Cmp $"         
        c3C db "Cmp AL, $"
        c3D db "Cmp AX, $"
        c50 DB "Push AX $" 
        c51 DB "Push CX $"
        c52 DB "Push DX $"
        c53 DB "Push BX $"
        c54 DB "Push SP $"
        c55 DB "Push BP $"
        c56 DB "Push SI $"
        c57 DB "Push DI $"
        c58 DB "Pop AX $"
        c59 DB "Pop CX $"
        c5A DB "Pop DX $"
        c5B DB "Pop BX $"
        c5C DB "Pop SP $"
        c5D DB "Pop BP $"
        c5E DB "Pop SI $"
        c5F DB "Pop DI $"        
        c70 DB "JO $"
        c71 DB "JNO $"
        c72 DB "JB $"
        c73 DB "JAE $"
        c74 DB "JE $"
        c75 DB "JNE $"
        c76 DB "JBE $"
        c77 DB "JA $"
        c78 DB "JS $"
        c79 DB "JNS $"
        c7A DB "JP $"
        c7B DB "JNP $"
        c7C DB "JL $"
        c7D DB "JGE $"
        c7E DB "JLE $"
        c7F DB "JG $" 
m80 db ? ;Add/Sub/Cmp
m81 db ? ;Add/Sub/Cmp
m82 db ? ;Add/Sub/Cmp
m83 db ? ;Add/Sub/Cmp
        c88 DB "Mov $"
        c89 DB "Mov $"
        c8A DB "Mov $"
        c8B DB "Mov $"
        c8C DB "Mov $"
        c8E DB "Mov $"
        c8F DB "Pop  $"
        c9A DB "Call cs: $"
        c9B DB "WAIT$"
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
mC2 db "Ret $"
mC3 db "Ret $"
mC6 db "Mov $"
mC7 db "Mov $"
mCB db "Ret $"
mCD db "Int $"
mE3 db "jcxz $"
mE8 db "Call ds: $"
        cE9 DB "jmp $"
        cEA DB "jmp cs:$"
        cEB DB "jmp $"
       
        cF0 DB "LOCK$"                 
        cF1 DB "STC$"        
        cF4 DB "HLT$"
        cF5 DB "CMC$"       
        cF8 DB "CLC$"
        cFA DB "CLI$"
        cFB DB "STI$"
        cFC DB "CLD$" 
        cFD DB "STD$"
mF6 db ? ;Mul/Div
mF7 db ? ;Mul/Div
mFF db ? ;Call/jmp/push

             
.code                                  ; kodo segmento pradzia

disasembleris:      
                                                                                                                
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
;KOMANDU ATPAZINIMAS:



atpazinkkomanda:
    cmp al, 00h   ; ADD
    JE  p00
    cmp al, 01h 
    JE  p01  
    cmp al, 02h 
    JE  p02  
    cmp al, 03h 
    JE  p03 
    cmp al, 04h 
    JE  p04   
    cmp al, 05h 
    JE  p05          
    cmp al, 06h   ;push/pop
    JE p06
    cmp al, 07h 
    JE p07
    cmp al, 0Eh 
    JE p0E
    cmp al, 0Fh 
    JE p0F
    cmp al, 16h 
    JE p16
    cmp al, 17h 
    JE p17
    cmp al, 1Eh 
    JE p1E
    cmp al, 1Fh 
    JE p1F                 

    cmp al, 28h         ;sub
    JE p28    
    cmp al, 29h 
    JE p29    
    cmp al, 2Ah 
    JE p2A    
    cmp al, 2Bh 
    JE p2B    
    cmp al, 2Ch 
    JE p2C    
    cmp al, 2Dh 
    JE p2D    
    
    cmp al, 38h         ;cmp    
    JE p38    
    cmp al, 39h 
    JE p39    
    cmp al, 3Ah 
    JE p3A    
    cmp al, 3Bh 
    JE p3B        
                 
    cmp al, 3Ch  ;cmp ax/al
    JE p3C           
    cmp al, 3Dh 
    JE p3D       
    
    cmp al, 50h  ;push/pop
    JE p50
    cmp al, 51h 
    JE p51
    cmp al, 52h 
    JE p52
    cmp al, 53h 
    JE p53
    cmp al, 54h 
    JE p54
    cmp al, 55h 
    JE p55
    cmp al, 56h 
    JE p56
    cmp al, 57h 
    JE p57
    cmp al, 58h 
    JE p58
    cmp al, 59h 
    JE p59
    cmp al, 5Ah 
    JE p5A
    cmp al, 5Bh 
    JE p5B
    cmp al, 5Ch 
    JE p5C
    cmp al, 5Dh 
    JE p5D
    cmp al, 5Eh 
    JE p5E
    cmp al, 5Fh 
    JE p5F
    
    cmp al, 70h   ;Jump
    JE p70   
    cmp al, 71h
    JE p71   
    cmp al, 72h
    JE p72   
    cmp al, 73h
    JE p73   
    cmp al, 74h
    JE p74   
    cmp al, 75h
    JE p75    
    cmp al, 76h
    JE p76   
    cmp al, 77h
    JE p77   
    cmp al, 78h
    JE p78    
    cmp al, 79h
    JE p79   
    cmp al, 7Ah
    JE p7A    
    cmp al, 7Bh
    JE p7B   
    cmp al, 7Ch
    JE p7C   
    cmp al, 7Dh
    JE p7D   
    cmp al, 7Eh
    JE p7E   
    cmp al, 7Fh
    JE p7F
    cmp al, 8Fh      ;pop
    JE p8F    
    cmp al, 9Ah     ;call cs:
    JE p9A                
              
    cmp al, 0A1h    ; MOV
    JE  pA1    
	cmp al, 8Bh
	JE MOVa    	
    cmp al, 0B8h
	JE pB8      
	
	
    cmp al, 0E9h    ; Jump
    JE  pE9    
    cmp al, 0EAh
    JE  pEA       
    cmp al, 0EBh
    JE  pEB          ; TODO jei reikia jmp
                     ; TODO jmp   
        
    cmp al, 0F0h
    JE  pF0    
    cmp al, 0F1h
    JE  pF1                        
    cmp al, 0F4h
    JE  pF4    
    cmp al, 0F5h
    JE  pF5    
    cmp al, 0F8h
    JE  pF8    
    cmp al, 0FAh
    JE  pFA    
    cmp al, 0FBh
    JE  pFB    
    cmp al, 0FCh
    JE  pFC    
    cmp al, 0FDh
    JE  pFD    
    
    MOV DX, offset neatpazinta   
	CALL irasyk
    JMP ciklas
 
   
p00:
    MOV DX, offset c00
    MOV arw, 0000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykreg 
    CALL rasykkableli    
    CALL rasykrm
    CALL rasykIsNaujEil      
    JMP ciklas     

p01:
    MOV DX, offset c01
    MOV arw, 1000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykreg 
    CALL rasykkableli    
    CALL rasykrm
    CALL rasykIsNaujEil      
    JMP ciklas   
         
p02:
    MOV DX, offset c02
    MOV arw, 0000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykrm
    CALL rasykkableli    
    CALL rasykreg
    CALL rasykIsNaujEil      
    JMP ciklas     
    
p03:
    MOV DX, offset c03
    MOV arw, 1000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykrm
    CALL rasykkableli    
    CALL rasykreg
    CALL rasykIsNaujEil      
    JMP ciklas     
p04:
    MOV DX, offset c04
    MOV arw, 0000b  
    CALL irasyk 
    mov reg, al
    CALL skaityk1baita 
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil                      
    JMP ciklas      
p05:
    MOV DX, offset c05
    MOV arw, 1000b  
    CALL irasyk 
    mov reg, al
    CALL skaityk1baita 
    push ax
    CALL skaityk1baita
    Call irasykASCIIisAL
    pop ax
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil
    JMP ciklas      
p06:
    MOV DX, offset c06
    JMP pSpauzdinimas    
p07:
    MOV DX, offset c07
    JMP pSpauzdinimas 
p0E:  
    MOV DX, offset c0E
    JMP pSpauzdinimas
p0F:  
    MOV DX, offset c0F
    JMP pSpauzdinimas
p16:    
    MOV DX, offset c16
    JMP pSpauzdinimas
p17:    
    MOV DX, offset c17
    JMP pSpauzdinimas
p1E:    
    MOV DX, offset c1E
    JMP pSpauzdinimas
p1F:                       
    MOV DX, offset c1F
    JMP pSpauzdinimas

p28:                         
    MOV DX, offset c28
    MOV arw, 0000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykreg 
    CALL rasykkableli    
    CALL rasykrm
    CALL rasykIsNaujEil       
    JMP ciklas
p29:                         
    MOV DX, offset c29
    MOV arw, 1000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykreg 
    CALL rasykkableli    
    CALL rasykrm
    CALL rasykIsNaujEil      
    JMP ciklas
p2A:                         
    MOV DX, offset c2A
    MOV arw, 0000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykrm 
    CALL rasykkableli    
    CALL rasykreg
    CALL rasykIsNaujEil      
    JMP ciklas
p2B:                         
    MOV DX, offset c2B
    MOV arw, 1000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykrm 
    CALL rasykkableli    
    CALL rasykreg
    CALL rasykIsNaujEil       
    JMP ciklas
p2C:                         
    MOV DX, offset c2C
    mov reg, al
    CALL skaityk1baita 
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil      
    JMP ciklas
p2D:                         
    MOV DX, offset c2D
    mov reg, al
    CALL skaityk1baita 
    push ax
    CALL skaityk1baita
    Call irasykASCIIisAL
    pop ax
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil              
    JMP ciklas
p38:                         
    MOV DX, offset c38 
    MOV arw, 0000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykrm 
    CALL rasykkableli    
    CALL rasykreg
    CALL rasykIsNaujEil       
    JMP ciklas
p39:                         
    MOV DX, offset c39
    MOV arw, 1000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykrm 
    CALL rasykkableli    
    CALL rasykreg
    CALL rasykIsNaujEil       
    JMP ciklas
p3A:                         
    MOV DX, offset c3A
    MOV arw, 0000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykreg 
    CALL rasykkableli    
    CALL rasykrm
    CALL rasykIsNaujEil       
    JMP ciklas
p3B:                         
    MOV DX, offset c3B
    MOV arw, 1000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykreg 
    CALL rasykkableli    
    CALL rasykrm
    CALL rasykIsNaujEil        
    JMP ciklas    
p3C:
    CALL irasyk                
    mov reg, al          
    CALL skaityk1baita 
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil      
    JMP ciklas
p3D:    
    CALL irasyk                
    mov reg, al          
    CALL skaityk1baita 
    push ax
    CALL skaityk1baita
    Call irasykASCIIisAL
    pop ax
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil      
    JMP ciklas    
p50:                 
    MOV DX, offset c50
    JMP pSpauzdinimas
p51:
    MOV DX, offset c51
    JMP pSpauzdinimas
p52:
    MOV DX, offset c52
    JMP pSpauzdinimas
p53:
    MOV DX, offset c53
    JMP pSpauzdinimas
p54:
    MOV DX, offset c54
    JMP pSpauzdinimas
p55:
    MOV DX, offset c55
    JMP pSpauzdinimas
p56:
    MOV DX, offset c56
    JMP pSpauzdinimas
p57:
    MOV DX, offset c57
    JMP pSpauzdinimas
p58:
    MOV DX, offset c58
    JMP pSpauzdinimas
p59:
    MOV DX, offset c59
    JMP pSpauzdinimas
p5A:
    MOV DX, offset c5A
    JMP pSpauzdinimas
p5B:
    MOV DX, offset c5B
    JMP pSpauzdinimas
p5C:    
    MOV DX, offset c5C
    JMP pSpauzdinimas
p5D:    
    MOV DX, offset c5D
    JMP pSpauzdinimas
p5E:    
    MOV DX, offset c5E
    JMP pSpauzdinimas
p5F:
    MOV DX, offset c5F
    JMP pSpauzdinimas

pSpauzdinimas:
    CALL irasyk        
    CALL rasykIsNaujEil
    JMP ciklas       

p70:
    MOV DX, offset c70 
    jmp p7x
p71:      
    MOV DX, offset c71  
    jmp p7x
p72:
    MOV DX, offset c72  
    jmp p7x    
p73:
    MOV DX, offset c73  
    jmp p7x     
p74:
    MOV DX, offset c74  
    jmp p7x     
p75: 
    MOV DX, offset c75  
    jmp p7x    
p76:
    MOV DX, offset c76  
    jmp p7x     
p77:
    MOV DX, offset c77  
    jmp p7x     
p78: 
    MOV DX, offset c78  
    jmp p7x    
p79: 
    MOV DX, offset c79  
    jmp p7x    
p7A: 
    MOV DX, offset c7A  
    jmp p7x    
p7B:  
    MOV DX, offset c7B  
    jmp p7x   
p7C: 
    MOV DX, offset c7C  
    jmp p7x    
p7D: 
    MOV DX, offset c7D  
    jmp p7x    
p7E:
    MOV DX, offset c7E  
    jmp p7x          
p7F:
    MOV DX, offset c7F  
    jmp p7x 
p7x: 
    CALL irasyk                
    mov reg, al          
    CALL skaityk1baita 
    push ax
    CALL skaityk1baita
    Call irasykASCIIisAL
    pop ax
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil      
    JMP ciklas
p8F:
    MOV DX, offset c8F
    MOV arw, 1000b  
    CALL irasyk 
    CALL skaityk1baita                 
    CALL setmodrmIRreg
    CALL rasykrm
    CALL rasykIsNaujEil       
    JMP ciklas 
p9A:
    MOV DX, offset c9A
    MOV arw, 1000b  
    CALL irasyk 
    mov reg, al
    CALL skaityk1baita 
    push ax
    CALL skaityk1baita
    Call irasykASCIIisAL
    pop ax
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil
    JMP ciklas
p9B:
    MOV DX, offset c9B
    JMP pSpauzdinimas                     
pA1:
    MOV DX, offset cA1
    MOV arw, 0000b
    CALL irasyk                
    mov reg, al          
    CALL skaityk1baita 
    push ax
    CALL skaityk1baita
    Call irasykASCIIisAL
    pop ax
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil      
    JMP ciklas




    
pB8:
    MOV DX, offset cB8
    MOV arw, 1000b
    push ax
    CALL irasyk                
    pop  ax
    SHL al, 5h
    SHR al, 5h
    mov reg, al          
    CALL skaityk1baita 
    push ax
    CALL skaityk1baita
    Call irasykASCIIisAL
    pop ax
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil      
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

pE9:
    MOV DX, offset cE9
    MOV arw, 1000b
    CALL irasyk                
    CALL skaityk1baita 
    push ax
    CALL skaityk1baita
    Call irasykASCIIisAL
    pop ax
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil      
    JMP ciklas

pEA:
    MOV DX, offset cEA
    MOV arw, 1000b
    CALL irasyk                     
    CALL skaityk1baita 
    push ax
    CALL skaityk1baita
    Call irasykASCIIisAL
    pop ax
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil      
    JMP ciklas

pEB:
    MOV DX, offset cEB
    MOV arw, 1000b
    CALL irasyk                 
    CALL skaityk1baita 
    push ax
    CALL skaityk1baita
    Call irasykASCIIisAL
    pop ax
    Call irasykASCIIisAL
    mov tmpB, "h"
    Call irasykBaita
    CALL rasykIsNaujEil      
    JMP ciklas

pF0:
    MOV DX, offset cF0
    JMP pSpauzdinimas
pF1:                  
    MOV DX, offset cF1
    JMP pSpauzdinimas
pF4:
    MOV DX, offset cF4
    JMP pSpauzdinimas
pF5:                  
    MOV DX, offset cF5
    JMP pSpauzdinimas
pF8:                  
    MOV DX, offset cF8
    JMP pSpauzdinimas
pFA:                  
    MOV DX, offset cFA
    JMP pSpauzdinimas
pFB:                  
    MOV DX, offset cFB
    JMP pSpauzdinimas
pFC:                  
    MOV DX, offset cFC
    JMP pSpauzdinimas
pFD:                  
    MOV DX, offset cFD
    JMP pSpauzdinimas
    
    
    
    


;_____________________________________________________________
;PROCEDUROS

skaityk1baita proc            
    mov al, 1
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
    SHL al, 05h
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
jmp cs:TblModRM[bx]    
TblModRM dw o00, o01, o02, o03, o04, o05, o06, o07
         dw o10, o11, o12, o13, o14, o15, o16, o17
         dw o20, o21, o22, o23, o24, o25, o26, o27
         dw orr, orr, orr, orr, orr, orr, orr, orr
o00:
mov tmpW, "[B"
Call irasykZodi 
mov tmpW, "X]"
Call irasykZodi
mov tmpB, "+"
CALL irasykBaita
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
mov tmpB, "+"
CALL irasykBaita
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
mov tmpB, "+"
CALL irasykBaita
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
mov tmpB, "+"
CALL irasykBaita
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
CALL skaityk1baita 
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop  ax
Call irasykASCIIisAL
mov  tmpB, "h"
Call irasykBaita 
ret  
o07:
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "X]"
Call irasykZodi
o10:
mov tmpW, "[B"
Call irasykZodi 
mov tmpW, "X]"
Call irasykZodi
mov tmpB, "+"
CALL irasykBaita
mov tmpW, "[S"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi 
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o10neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o10neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret
o11:
mov tmpW, "[B"
Call irasykZodi    
mov tmpW, "X]"
Call irasykZodi
mov tmpB, "+"
CALL irasykBaita
mov tmpW, "[D"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi 
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o11neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o11neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret 
o12:
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "P]"
Call irasykZodi
mov tmpB, "+"
CALL irasykBaita
mov tmpW, "[S"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o12neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o12neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret  
o13:
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "P]"
Call irasykZodi
mov tmpB, "+"
CALL irasykBaita
mov tmpW, "[D"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o13neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o13neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret  
o14:
mov tmpW, "[S"
Call irasykZodi
mov tmpW, "I]"
Call irasykZodi
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o14neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o14neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret  
o15:
mov tmpW, "[D"
Call irasykZodi
mov tmpW, "I]"
Call irasykZodi
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o15neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o15neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret  
o16:
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "P]"
Call irasykZodi 
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o16neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o16neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret  
o17:
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "X]"
Call irasykZodi 
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o17neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o17neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita    
ret    
o20:
mov tmpW, "[B"
Call irasykZodi 
mov tmpW, "X]"
Call irasykZodi
mov tmpB, "+"
CALL irasykBaita
mov tmpW, "[S"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi 
mov tmpW, "+0"
Call irasykZodi 
CALL skaityk1baita 
CMP modrm, 10000b
jb o20neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o20neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret
o21:
mov tmpW, "[B"
Call irasykZodi    
mov tmpW, "X]"
Call irasykZodi
mov tmpB, "+"
CALL irasykBaita
mov tmpW, "[D"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi 
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o21neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o21neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret  
o22:         
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "P]"
Call irasykZodi
mov tmpB, "+"
CALL irasykBaita 
mov tmpW, "[S"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o22neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o22neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret  
o23:         
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "P]"
Call irasykZodi
mov tmpB, "+"
CALL irasykBaita 
mov tmpW, "[D"
Call irasykZodi 
mov tmpW, "I]"
Call irasykZodi
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o23neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o23neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret  
o24:         
mov tmpW, "[S"
Call irasykZodi
mov tmpW, "I]"
Call irasykZodi
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o24neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o24neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita 
ret  
o25:         
mov tmpW, "[D"
Call irasykZodi
mov tmpW, "I]"
Call irasykZodi
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o25neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o25neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret    
o26:         
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "P]"
Call irasykZodi 
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o26neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o26neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita
ret  
o27:         
mov tmpW, "[B"
Call irasykZodi
mov tmpW, "X]"
Call irasykZodi 
mov tmpW, "+0"
Call irasykZodi
CALL skaityk1baita 
CMP modrm, 10000b
jb o27neW
push ax
CALL skaityk1baita
Call irasykASCIIisAL
pop ax
o27neW:
Call irasykASCIIisAL
mov tmpB, "h"
Call irasykBaita   
ret    
orr: 
mov al, modrm
push ax
mov al, reg
push ax
mov al, modrm
SHL al, 5h
SHR al, 5h
mov reg, al
Call rasykreg
pop ax
mov reg, al  
pop ax
mov modrm, al
ret  
rasykrm endp  
 
rasykreg proc
xor ax, ax      
mov al, reg
add al, arw
mov bx, 2
mul bx
mov bx, ax
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
    mov dx, offset tmpW
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
    mov dx, offset tmpB
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

irasykASCIIisAL proc
    mov bl, al    
    shr al, 4
    cmp al, 9                        
    ja raide1                        ;jei al > 9 tai soka i raide
    add al, 30h   
    xor cx, cx
    mov ch, al
    jmp n2
    raide1:     
    add al, 37h
    xor cx, cx  
    mov ch, al
    n2:
    mov al, bl
    shl al, 4
    shr al, 4
    cmp al, 9
    ja raide2 
    add al, 30h
    mov cl, al
    jmp writetmp
    raide2:
    add al, 37h 
    mov cl, al
    writetmp:   
    mov tmpW, cx
    Call irasykZodi    
    ret    
irasykASCIIisAL endp

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
		
END disasembleris