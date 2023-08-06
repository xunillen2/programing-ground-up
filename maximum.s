.section .data  # assemblerske direktive ili pseudo operacije
                # Nisu direktno prevedene u mašinski i ne izvodi ih računalo.
                # Sekcije prikazuju skecije programa. npr. data skecije prikazuje memorijsku
                # pohranu koju će naš program koristiti za podatke

data_items:
    .long 3,67,43,22,45,75,32,12,222,3,21,4,0
.section .text
.globl _start   # Simbol. Pokazuju neku lokaciju u programu
                # Biti će zamjenjen sa nećime tijkom asemblanja i linkanja,
                # I zapravo nam omogućuju da memorijske lokacije pokazujemo rijećima
                #.globl kaže linkeru da ne baca sibol nakon asemblanja, 
                # i omogućuje nam vanjsko korištenje

_start:         # Labela, definira simbol i daje mu vrijednost.
                # Ime simbola koji završava sa dvotočkom.
                # (vrijednost je adr slj. instrukcije ispot labele)
    # %edi - Index
    # %ebx - Largest data item found
    # %eax - Current data item

    xor     %edi, %edi
    movl    %edi, %ebx
    start_loop:
        movl    data_items(,%edi,4), %eax
        cmpl    $0, %eax
        je      loop_end
        incl    %edi
        cmpl    %ebx, %eax
        jle     start_loop
        movl    %eax, %ebx
        jmp     start_loop

    loop_end:
        movl    $1, %eax
        int     $0x80
