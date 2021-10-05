
           ;Hi score checker
checkhiscore
           sei
           lda #$00
           sta $d019
           sta $d01a
           lda #$81
           sta $dc0d
           sta $dd0d
           lda #$0b
           sta $d011
           lda #0
           sta namefinished
           
         
           
           ;Do check 
           ldx #$00
nextone    lda hslo,x
           sta $c1
           lda hshi,x
           sta $c2

           ldy #$00
scoreget   lda score,y 
scorecmp   cmp ($c1),y 
           bcc posdown
           beq nextdigit
           bcs posfound
nextdigit  iny 
           cpy #scorelen 
           bne scoreget
           beq posfound
posdown    inx 
           cpx #listlen 
           bne nextone
           beq nohiscor
posfound   stx $02
           cpx #listlen-1
           beq lastscor
           
           ldx #listlen-1
copynext   lda hslo,x
           sta $c1
           lda hshi,x
           sta $c2 
           lda nmlo,x
           sta $d1
           lda nmhi,x
           sta $d2
           dex 
           lda hslo,x
           sta $c3 
           lda hshi,x
           sta $c4 
           lda nmlo,x
           sta $d3 
           lda nmhi,x
           sta $d4
           
           ldy #scorelen-1
copyscor   lda ($c3),y
           sta ($c1),y
           dey
           bpl copyscor 
           
           ldy #namelen+1
copyname   lda ($d3),y
           sta ($d1),y
           dey
           bpl copyname
           cpx $02
           bne copynext
           
lastscor   ldx $02
           lda hslo,x
           sta $c1
           lda hshi,x
           sta $c2
           lda nmlo,x
           sta $d1
           lda nmhi,x
           sta $d2
           jmp nameentry
placenewscore
           ldy #scorelen-1
putscore   
           lda score,y 
           sta ($c1),y 
           dey 
           bpl putscore
           
           ldy #namelen-1
putname    lda name,y
           sta ($d1),y 
           dey
           bpl putname
           jsr SaveHiScore
nohiscor   jmp titlescreen

;---------------------------

nameentry   ldx #$00
drawhidata  lda #$20
            sta $0400,x
            sta $0500,x
            sta $0600,x
            sta $06e8,x
            lda #$0f
            sta $d800,x
            sta $d900,x
            sta $da00,x
            sta $dae8,x
            inx
            bne drawhidata
            lda #0
            sta $d015
            
            ldx #$00
puthimessage 
            lda hiscoremessage,x
            sta $0540,x
            lda hiscoremessage+40,x
            sta $0540+80,x
            lda hiscoremessage+80,x
            sta $0540+120,x
            lda hiscoremessage+120,x
            sta $0540+200,x
            lda #5
            sta $d940,x
            lda #$03
            sta $d940+80,x
            sta $d940+120,x
            lda #$0d
            sta $d940+200,x
            inx
            cpx #$28
            bne puthimessage
            
            ldx #$00
clearname   lda #$20
            sta name,x
            inx
            cpx #9
            bne clearname
            
            lda #1
            sta $04
            lda $04
            sta hichar 
            
            lda #0
            sta joydelay 
            
            lda #<name
            sta namesm+1
            lda #>name 
            sta namesm+2
            lda #$03
            sta $dd00
            lda #$1e
            sta $d018
            lda #$08
            sta $d016
            ldx #<singleirq
            ldy #>singleirq
            stx $fffe
            sty $ffff
            lda #$7f
            sta $dc0d
            sta $dd0d
            lda #$1b
            sta $d011
            lda #$01
            sta $d019
            sta $d01a
            lda #1
            jsr musicinit
            cli 
nameentryloop
            lda #0
            sta rt
            cmp rt
            beq *-3
            ldx #$00
showname    lda name,x
            sta $06e0-120,x
            lda #1
            sta $dae0-120,x 
            inx
            cpx #9
            bne showname
            
            lda namefinished
            bne stopnameentry
            jsr joycheck
            jmp nameentryloop
            
stopnameentry 
          
            jmp placenewscore
            
joycheck    lda hichar
namesm      sta name 
            lda joydelay
            cmp #4
            beq joyhiok
            inc joydelay 
            rts 
            
joyhiok     lda #0
            sta joydelay 
            
            ;Check joystick up 
            
hiup        lda #1
            bit $dc00
            bne hidown
            inc hichar
            lda hichar
            cmp #27
            beq deletechar
            cmp #$21
            beq achar
            rts 
hidown      lda #2
            bit $dc00
            bne hifire
            dec hichar
            lda hichar
            beq spacechar
            cmp #29
            beq zchar
            rts 
            
deletechar  lda #30
            sta hichar
            rts
            
spacechar   lda #$20
            sta hichar
            rts 
            
achar       lda #1
            sta hichar 
            rts 
            
zchar       lda #26
            sta hichar 
            rts 
            
hifire      lda $dc00
            !for l = 1 to 5 
              lsr
            !end
            bit firebutton
            ror firebutton
            bmi hinofire
            bvc hinofire
            lda #0
            sta firebutton 
            
            lda hichar
            cmp #$1f
            bne checkendchar 
            
            lda namesm+1
            cmp #<name
            beq donotgoback
            dec namesm+1
            jsr cleanupname
donotgoback rts 

checkendchar  
            cmp #30
            bne charisok
            
            lda #$20
            sta hichar 
            jmp finishednow 
            
charisok    inc namesm+1
            lda namesm+1
            cmp #<name+9
            beq finishednow 
hinofire    rts

finishednow 
            jsr cleanupname 
            lda #1
            sta namefinished
            rts
            
cleanupname ldx #$00
clearcharsn lda name,x
            cmp #30
            beq cleanup
            cmp #31 
            beq cleanup
            jmp skipcleanup
cleanup     lda #$20
            sta name,x
skipcleanup            
            inx
            cpx #namelen
            bne clearcharsn
            rts
            
singleirq   sta sstacka+1
            stx sstackx+1
            sty sstacky+1
            asl $d019
            lda $dc0d
            sta $dd0d
            lda #$00
            sta $d012
            jsr soundplayer
            lda #1
            sta rt
sstacka     lda #0
sstackx     ldx #0
sstacky     ldy #0
            rti
            
joydelay    !byte 0
namefinished !byte 0
hichar !byte 0            
            
            
            
            
           
           
           
           !ct scr
hiscoremessage  
           !text "        congratulations rocketeer       "
           !text " your final score has awarded yourself  "
           !text "    a position on the hi score table    "
           !text "         please enter your name!        "
           
hslo !byte <hiscore1,<hiscore2,<hiscore3,<hiscore4,<hiscore5
hshi !byte >hiscore1,>hiscore2,>hiscore3,>hiscore4,>hiscore5
nmlo !byte <name1,<name2,<name3,<name4,<name5
nmhi !byte >name1,>name2,>name3,>name4,>name5
;--------------------------------------------------------------------------------------------------------------------------