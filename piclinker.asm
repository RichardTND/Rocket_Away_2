;Rocket Away picture linker

    !to "rocketaway2+.prg",cbm
    
    
    *=$0900 
    
    lda $02a6
    sta system
    lda #0
    sta $d020
    sta $d021
    ldx #$00
drawpic
    lda $3f40,x
    sta $0400,x
    lda $3f40+$100,x
    sta $0500,x
    lda $3f40+$200,x
    sta $0600,x
    lda $3f40+$2e8,x
    sta $06e8,x
    lda $4328,x
    sta $d800,x
    lda $4328+$100,x
    sta $d900,x
    lda $4328+$200,x
    sta $da00,x
    lda $4328+$2e8,x
    sta $dae8,x
    inx
    bne drawpic
    lda #252
    sta 808
    ldx #<irq
    ldy #>irq
    stx $0314
    sty $0315
    lda #$7f
    sta $dc0d
    sta $dd0d
    lda #$36
    sta $d012
    lda #$3b
    sta $d011
    lda #$18
    sta $d018
    sta $d016
    lda #$01
    sta $d019
    sta $d01a
    lda #0
    jsr $1000
    cli 
introloop
     lda $dc00
     lsr
     lsr
     lsr
     lsr
     lsr
     bit firebutton
     ror firebutton
     bmi checkspc
     bvc checkspc
     jmp exitintro
checkspc
     lda $dc01
     lsr
     lsr
     lsr
     lsr
     lsr
     bit firebutton
     ror firebutton
     bmi introloop
     bvc introloop
exitintro
     sei
     ldx #$31
     ldy #$ea
     stx $0314
     sty $0315
     lda #$81
     sta $dc0d
     sta $dd0d
     lda #$1b
     sta $d011
     lda #$00
     sta $d020
     sta $d021
     sta $d019
     sta $d01a
     ldx #$00
sidoff
     lda #$00
     sta $d400,x
     inx
     cpx #$18
     bne sidoff
     lda #$08
     sta $d016
     lda #$00
     sta $d018
     ldx #$00
blackout
     lda transfer,x
     sta $0400,x
     lda #0
     sta $d800,x
     sta $d900,x
     sta $da00,x
     sta $dae8,x
     inx
     bne blackout 
     lda #0
     sta $0800
     cli
     jmp $0400     
     
transfer
     sei
     lda #$34
     sta $01
reloc1     
     ldx #$00
reloc2
     lda linkedprg,x
     sta $0801,x
     inx
     bne reloc2
     inc $0409
     inc $040c
     lda $0409
     bne reloc1
     lda #$37
     sta $01
     cli
     jmp $080d
irq  inc $d019
     lda $dc0d
     sta $dd0d
     lda #$fa
     sta $d012
     
     jsr musicplayer
     jmp $ea7e
     
musicplayer     
     lda system
     cmp #1
     beq pal
     inc ntsctimer
     lda ntsctimer
     cmp #5
     beq resetntsct
pal  jsr $1003
     rts
resetntsct
     lda #0
     sta ntsctimer
     rts

system !byte 0
ntsctimer !byte 0
firebutton !byte 0
     
    *=$1000
    !bin "bin\loadertune.prg",,2
    *=$2000
    !bin "bin\rocketpic.prg",,2
    


!align $ff,0
linkedprg !bin "rocketaway2.prg",,2