
;------------------------------------------------------------------------------------------------------------------------
;Title screen code

            !align $ff,0
            
titlescreen
            
       
        sei
        lda #$81
        sta $dc0d 
        sta $dd0d
        lda #$00
        sta $d019
        sta $d01a
        lda #$00
        sta $d020
        sta $d021
        
        sta firebutton
        sta charbit
        lda #<scrolltext
        sta messread+1
        lda #>scrolltext
        sta messread+2
        ldx #$00
buildscreen
        lda #$20
        sta $0400,x
        sta $0500,x
        sta $0600,x
        sta $06e8,x
        lda $7f40,x
        sta $5800,x
        lda $7f40+$100,x
        sta $5900,x
        lda $7f40+$200,x
        sta $5a00,x
        lda $7f40+$2e8,x
        sta $5ae8,x
        lda $8328,x
        sta $d800,x
        lda $8328+$100,x
        sta $d900,x
        lda $8328+$200,x
        sta $da00,x
        lda $8328+$2e8,x
        sta $dae8,x
        inx
        bne buildscreen
        
        ldx #$00
maketext
        lda hiscoretable,x 
        sta $0518,x
        lda hiscoretable+40,x
        sta $0518+80,x 
        lda hiscoretable+80,x
        sta $0518+160,x 
        lda hiscoretable+120,x
        sta $0518+200,x
        lda hiscoretable+160,x
        sta $0518+240,x 
        lda hiscoretable+200,x
        sta $0518+280,x
        lda hiscoretable+240,x
        sta $0518+320,x 
        
        
        lda #$05
        sta $d918,x
        sta $d918+80,x
        sta $d918+160,x
        sta $d918+200,x
        sta $d918+240,x
        sta $d918+280,x
        sta $d918+320,x
        sta $d918+360,x
        lda #$0b 
        sta $dad0,x
        lda #$09 
        sta $daf8,x
        inx
        cpx #$28
        bne maketext
        lda #$0e
        sta $d022
        lda #$06
        sta $d023
        
        lda #$48
        sta $d018
        lda #$18
        sta $d016
        lda #$3b
        sta $d011
        lda #$02
        sta $dd00
        lda #$18
        sta $d016
        
        lda #%00111111
        sta $d015
        sta $d01c
        lda #0
        sta $d01b 
        ldx #$00
blzsetup  
        lda blztable,x
        sta objpos,x
        lda blztable2,x
        sta objpos2,x
        inx
        cpx #$10
        bne blzsetup 
        ldx #$00
blzsetup2
        lda blzlogo,x
        sta $07f8,x
       
        sta $5bf8,x
        lda blzcolour,x
        sta $d027,x
        inx
        cpx #$08
        bne blzsetup2
        lda #$04
        sta $d025
        lda #$01
        sta $d026
        
        
        
        
        ldx #<tirq1
        ldy #>tirq1
        lda #$7f
        stx $fffe
        sty $ffff
        ldx #<nmi
        ldy #>nmi
        stx $fffa
        sty $fffb
        sta $dc0d 
        sta $dd0d
        lda #$02
        sta $d012
        lda #$1b
        sta $d011
        lda #$01
        sta $d01a
        sta $d019
        lda #1
        jsr musicinit
       
        cli
        jmp titleloop
       
tirq1     sta tstacka1+1
          stx tstackx1+1
          sty tstacky1+1
          lda $dc0d
          sta $dd0d
          asl $d019
         
          lda #$12
          sta $d012
           jsr soundplayer
          ldx #<tirq2 
          ldy #>tirq2
          stx $fffe
          sty $ffff
        
        
tstacka1  lda #0
tstackx1  ldx #0
tstacky1  ldy #0
nmi       rti 

tirq2     sta tstacka2+1
          stx tstackx2+1
          sty tstacky2+1
          asl $d019
          lda #$66 
          sta $d012 
          lda #$02
          sta $dd00
          lda #$3b 
          sta $d011
          lda #$18
          sta $d016 
          lda #$68
          sta $d018 
      
          jsr expandlogo2
          
          
          ldx #<tirq3 
          ldy #>tirq3 
          stx $fffe
          sty $ffff
tstacka2  lda #0
tstackx2  ldx #0
tstacky2  ldy #0 
          rti
          
tirq3     sta tstacka3+1
          stx tstackx3+1
          sty tstacky3+1
          asl $d019 
        
          lda #$c0
          sta $d012
          lda #$03
          sta $dd00
          lda #$1b
          sta $d011
          lda #$08
          sta $d016
          lda #$1e
          sta $d018 
          
          ldx #<tirq4
          ldy #>tirq4
          stx $fffe
          sty $ffff
tstacka3  lda #0
tstackx3  ldx #0
tstacky3  ldy #0
          rti 
          
tirq4     sta tstacka4+1
          stx tstackx4+1
          sty tstacky4+1
          asl $d019 
          lda #$da 
          sta $d012
       
          lda #$03
          sta $dd00
          lda #$1b 
          sta $d011   
          lda xpos 
          ora #$10
          sta $d016
          lda #$12
          sta $d018
          jsr expandlogo
          ldx #<tirq5
          ldy #>tirq5 
          stx $fffe
          sty $ffff
tstacka4  lda #0
tstackx4  ldx #0
tstacky4  ldy #0
          rti 
          
tirq5     sta tstacka5+1
          stx tstackx5+1
          sty tstacky5+1
          asl $d019
          lda #$fa
          sta $d012
          
          
          lda #$02 
          sta $dd00
          lda #$3b
          sta $d011
          lda #$18
          sta $d016
          lda #$68
          sta $d018
          
          
          ldx #<tirq6
          ldy #>tirq6
          stx $fffe
          sty $ffff
          
        
        
tstacka5   lda #0
tstackx5   ldx #0
tstacky5   ldy #0
          rti 
                    
          
tirq6     sta tstacka6+1
          stx tstackx6+1
          sty tstacky6+1
          asl $d019
         nop
         nop
         nop
         nop
           nop
         nop
         nop
         nop
         nop
          lda #$ff
          sta $d012
         
          lda #$00
          sta $d011
          
          
         
        
          ldx #<tirq1
          ldy #>tirq1
          stx $fffe
          sty $ffff
         
tstacka6  lda #0
tstackx6  ldx #0
tstacky6  ldy #0
          rti
          
         
          
         


          
titleloop lda #0
          sta rt
          cmp rt
          beq *-3 
          
          jsr textscroller
          jsr movespritex
          jsr movespritexrev
          lda $dc00
          lsr
          lsr
          lsr
          lsr
          lsr
          bit firebutton
          ror firebutton 
          bmi titleloop
          bvc titleloop
          ldx #$07
          lda #<gameonsfx
          ldy #>gameonsfx
          jsr sfxinit
          jmp game
expandlogo
          ldx #$00
expandloop lda objpos+1,x
            sta $d001,x
            lda objpos,x
            asl
            ror $d010
            sta $d000,x
            inx
            inx
            cpx #16
            bne expandloop
            rts
            
expandlogo2 
           ldx #$00
expandloop2
           lda objpos2+1,x
           sta $d001,x
           lda objpos2,x
           asl
           ror $d010
           sta $d000,x
           inx
           inx
           cpx #16
           bne expandloop2
           rts
           
            
            
textscroller 
          lda xpos
          sec
          sbc #3
          and #7
          sta xpos
          bcs exitscroll
          ora #$10
          sta xpos2
          ldx #$00
movetext  lda $06d1,x
          sta $06d0,x
          inx
          cpx #$50
          bne movetext
messread  lda scrolltext
          cmp #$00
          bne storemess 
          lda #<scrolltext
          sta messread+1
          lda #>scrolltext
          sta messread+2
          jmp messread
storemess 
          ldy charbit
          cpy #1
          beq upper
lower     sta $06d0+39
          clc
          adc #$80 
          sta $06d0+79
          lda #1
          sta charbit
          rts 
upper     clc
          adc #$40
          sta $06d0+39
          adc #$80
          sta $06d0+79
          lda #0
          sta charbit
          inc messread+1
          bne exitscroll
          inc messread+2
exitscroll rts          
          
soundplayer
          lda system
          cmp #1
          beq pal
          inc ntsctimer
          lda ntsctimer
          cmp #$06
          beq resetntsc
pal       lda #1
          sta rt
          jsr musicplay
          rts
resetntsc lda #0
          sta ntsctimer
          rts

movespritex
          ldx spritetimerx
          lda sinus,x
          sta objpos
          lda objpos
          clc
          adc #12
          sta objpos+2
          adc #12
          sta objpos+4
          adc #12
          sta objpos+6
          adc #12
          sta objpos+8
          adc #12
          sta objpos+10
          inc spritetimerx
          rts

movespritexrev

          ldx spritetimerx2
          lda sinus,x
          sta objpos2
          lda objpos2
          clc
          adc #12
          sta objpos2+2
          adc #12
          sta objpos2+4
          adc #12
          sta objpos2+6
          adc #12
          sta objpos2+8
          adc #12
          sta objpos2+10
          dec spritetimerx2
          rts
          
          
          
          
          
system !byte 0
ntsctimer !byte 0
xpos !byte 0       
xpos2 !byte 0 
charbit !byte 0
spritetimerx !byte 0
spritetimerx2 !byte 0

blzlogo !byte $97,$98,$99,$9a
         !byte $9b,$9c
         
blzcolour !byte $0f,$0f,$0f,$0f,$0f,$0f,$0f,$0f       


blztable  !byte $10,$fc
          !byte $10+12,$fc
          !byte $10+24,$fc
          !byte $10+36,$fc
          !byte $10+48,$fc
          !byte $10+60,$fc
          !byte $00,$00
          !byte $00,$00
          
blztable2  !byte $70,$1a
          !byte $70+12,$1a
          !byte $70+24,$1a
          !byte $70+36,$1a
          !byte $70+48,$1a
          !byte $70+60,$1a
          !byte $30,$00
          !byte $30,$00          
          
objpos2 !byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
          
!align $ff,$00

sinus 
SINUS !byte 83,84,85,85,86,87
      !byte 87,88,89,89,90,90
      !byte 91,91,92,92,93,93
      !byte 93,94,94,94,95,95
      !byte 95,95,95,96,96,96
      !byte 96,96,96,96,96,96
      !byte 96,96,96,96,95,95
      !byte 95,95,94,94,94,93
      !byte 93,93,92,92,91,91
      !byte 90,90,89,89,88,88
      !byte 87,86,86,85,84,83
      !byte 83,82,81,80,80,79
      !byte 78,77,76,75,74,74
      !byte 73,72,71,70,69,68
      !byte 67,66,65,64,63,62
      !byte 61,60,59,58,57,56
      !byte 55,54,53,52,51,50
      !byte 49,48,47,46,45,44
      !byte 43,42,41,40,39,38
      !byte 37,36,35,34,33,32
      !byte 31,30,30,29,28,27
      !byte 26,26,25,24,23,23
      !byte 22,21,21,20,19,19
      !byte 18,18,17,17,16,16
      !byte 15,15,15,14,14,14
      !byte 13,13,13,13,13,12
      !byte 12,12,12,12,12,12
      !byte 12,12,12,12,12,12
      !byte 13,13,13,13,14,14
      !byte 14,15,15,15,16,16
      !byte 17,17,18,18,19,19
      !byte 20,20,21,22,22,23
      !byte 24,25,25,26,27,28
      !byte 28,29,30,31,32,33
      !byte 34,34,35,36,37,38
      !byte 39,40,41,42,43,44
      !byte 45,46,47,48,49,50
      !byte 51,52,53,54,55,56
      !byte 57,58,59,60,61,62
      !byte 63,64,65,66,67,68
      !byte 69,70,71,72,73,74
      !byte 75,76,77,78,78,79
      !byte 80,81,82,82