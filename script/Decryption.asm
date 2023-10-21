%include "io.inc"
extern _printf
section .data
table: db "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/",0
input: db "YWJjZGVmZ2hpamtsbW5vcHFyc3R1dnd4eXowMTIzNDU2Nzg=",0
stringlength: db 0 ; to be calculated
output: db "11111111111111111111111111111111111111111111111111111111111111111"
section .text
global CMAIN
CMAIN:
    mov ebp, esp; for correct debugging
    ;write your code here
    xor eax,eax
    xor ecx,ecx
    xor edx,edx
    mov esi,input
    mov edi,output            
    mov ebx,table
    ComputeLength:
    mov al,[esi+ecx]
    cmp al,0
    je  Process
    inc  ecx  ;ecx contains the length of the string
    jmp ComputeLength
    
    Process:
    mov [stringlength],ecx ;saving string length incase I need to use ecx as a counter again
    xor ecx,ecx 
    xor eax,eax
    mov esi,input

    FindBase64: ;we use linear search algorithm to find base64 for the input string
    xor ecx,ecx
    mov al,[esi]
    cmp al,"="  
    je label
    cmp al,0
    je DecryptionProcess
    looping:
    mov dl,[ebx+ecx]
    cmp al,dl
    jne notyetfound
    mov [esi],cl ;if found, we save the index (representing base64) in esi
    inc esi
    jmp FindBase64 
    notyetfound:
    inc cl
    jmp looping  
    label: ;subtituting every '=' with a number out of Base64 range 
    ;because '=' character in ASCII is represented as 61
    mov byte[esi],127 
    jmp DecryptionProcess
    DecryptionProcess: ;we use eax as the backup register and we work on ebx and edx
    xor eax,eax
    xor ebx,ebx
    mov ecx,[stringlength]
    xor edx,edx
    mov esi,input
    
    MainCode: 
    cmp ecx,0
    je Finish
    cmp byte[esi+2],127
    je TwoEqualsCase
    cmp byte[esi+3],127
    je OneEqualCase
    jmp GeneralCase
    
    GeneralCase: ;convert 4 bytes of base64 into 3 ASCII characters
    mov eax,[esi]
    bswap eax
    mov ebx,eax ;obtaining first byte of ASCII
    mov edx,eax
    shr ebx,24 
    shl ebx,2
    shr edx,20
    and edx,11b
    add ebx,edx
    mov [edi],bl
    inc edi
    
    mov ebx,eax ;obtaining second byte of ASCII
    mov edx,eax
    shr ebx,16
    shl ebx,4
    shr edx,10
    and edx,1111b
    add ebx,edx
    mov [edi],bl
    inc edi
    
    mov ebx,eax ;obtaining third byte of ASCII
    mov edx,eax
    shr ebx,8
    and ebx,11b
    shl ebx,6
    and edx,111111b
    add ebx,edx
    mov [edi],bl
    inc edi
    
    add esi,4 
    sub ecx,4
    jmp MainCode
    
    OneEqualCase:
    mov eax,[esi]
    bswap eax
    mov edx,eax ;obtaining first byte of ASCII
    mov ebx,eax
    shr ebx,24
    shl ebx,2
    shr edx,20
    and edx,11b
    add ebx,edx
    mov [edi],bl
    inc edi
    
    mov edx,eax ;obtaining second byte of ASCII
    mov ebx,eax
    shr ebx,16
    shl ebx,4
    shr edx,10
    and edx,1111b
    add ebx,edx
    mov [edi],bl
    inc edi
    jmp Finish
    
    TwoEqualsCase:
    mov eax,[esi]
    bswap eax
    mov edx,eax ;obtaining one byte ASCII 
    mov ebx,eax
    shr ebx,24
    shl ebx,2
    shr edx,20
    and edx,11b
    add ebx,edx
    mov [edi],bl
    inc edi
    jmp Finish
    
     
    Finish:
    mov byte[edi],0 ;null terminator for the _printf function
    push output
    call _printf
    add esp,4
    
    ret