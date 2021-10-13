;disablecollision = 1

;-----------------------------------------------------------------------------------
        ;Init all interrupts and clear screen
game   
        sei
        lda #$81
        sta $dc0d 
        sta $dd0d
        lda #$00
        sta $d019
        sta $d01a
        lda #0
        sta $d020
        sta $d021
        lda #$03  ;VIC2 BANK #$03 should be set in game
        sta $dd00 ;as title mixes VIC2 banks.
        lda #$1b  
        sta $d011
        
        ;Reset game map position 
        
        lda #<mapstart 
        sta mapsm+1
        lda #>mapstart
        sta mapsm+2
        
        ;Reset all necessary pointers
        
        ldx #0
initpointers2
        lda #0
        sta pointerstart,x
        inx
        cpx #pointersend-pointerstart
        bne initpointers2
        
        lda #$00
        sta speed
        sta speedstore
        sta firebutton
        
        ;Set the value of the energy counter
        
        lda #40
        sta energycount
        lda #$c0
        sta energyout+1
        
        ;Set game charset type
        
        lda #$12
        sta $d018
        lda #$18
        sta $d016
        
        ;Background colour settings 
        ;for start screen should match 
        ;the colour of the very first 
        ;level.
        
        lda d022table
        sta csm1+1
        lda d023table
        sta csm2+1
        
;-----------------------------------------------------------------------------------

        ;Draw the game map start screen, and use WHITE
        ;MULTICOLOUR as the main fill colour.
        
        ldx #$00
clrscr1 lda startscreen,x
        sta $0400,x
        lda startscreen+$100,x
        sta $0500,x
        lda startscreen+$200,x
        sta $0600,x
        lda startscreen+$2e8,x
        sta $06e8,x
        lda #$09
        sta $d800,x
        sta $d900,x
        sta $da00,x
        sta $dae8,x
        inx
        bne clrscr1
        
        ;Fill out the temporary rows that draw the map
        
        ldx #$00
clrme   lda #$20
        sta rowtemp1,x
        inx
        cpx #$50
        bne clrme

;-----------------------------------------------------------------------------------        

        ;Before unleashing the interrupts
        ;init all pointers.
        
        ldx #$00
initpointers
        lda #0
        sta pointers,x
        inx
        cpx #pointersend-pointers
        bne initpointers
        
        ;Set pointers
        
        lda #8
        sta speedlimit
        lda #32
        sta spawnlimit 
        lda #1
        sta level
        clc
        adc #$30
        sta leveltext
        
        lda #1
        sta speedlimit
        
        ;Inititialise score 
        
        ldx #$00
zeroscore
        lda #$30
        sta score,x
        inx
        cpx #6
        bne zeroscore

;-----------------------------------------------------------------------------------
        
        ;Setup start position for the game sprites
        ;(read startpos table and store to object 
        ;read position (not hardware sprite pos yet)
        
        ldx #$00
initpos
        lda startpos,x
        sta objpos,x
        inx
        cpx #$10
        bne initpos
        
        ;Set default sprites for objects
        
        lda #$0b
        sta $d025
        lda #$01
        sta $d026 
        
        ;We want to avoid messed up sprites, 
        ;so store the frames to the hardware
        ;sprite frames.
        
        lda playerframe 
        sta $07f8
        lda starframe1
        sta $07f9
        lda starframe2
        sta $07fa
        lda starframe3
        sta $07fb 
        lda starframe4
        sta $07fc
        lda starframe5
        sta $07fd
        lda starframe6 
        sta $07fe
        lda #$8e
        sta $07ff
        
    
        
        ldx #$00
blueout        
        lda #$0e
        sta $d027,x
        inx
        cpx #$08
        bne blueout 
        
        ;Fill messy screen flick areas with plain 
        ;black
        
        ldx #$00
blackoutflicker
        lda #$00
        sta $db20,x
        lda #$0b 
        sta $db48,x
        inx
        cpx #$28
        bne blackoutflicker
    
        ;Draw energy bar at second but last row 
        ;(as the very last row will be hidden 
        ;due to the VIC2 vertical scroll position
        
        ldx #$00
energydraw
        lda #$23 
        sta $0798,x
        
        lda energycoltable,x
        sta $db98,x
        inx
        cpx #$28
        bne energydraw
        

;-----------------------------------------------------------------------------------        
        
        
        ;Sprite hardware properties 
        
       
        
        lda #%01111110
        sta $d01b
        lda #0
        sta $d017
        sta $d01d
        
        ;Setup IRQ raster interrupt 
        lda #0
        sta $d015
        

;-----------------------------------------------------------------------------------        
        
        ;Display GET READY text in 2x2 charset
        
showgrtext        
              ldx #$00
              ldy #$00
              txa
getgrtext
              lda getreadytext,y
              sta $059b,x
              clc
              adc #$80
              sta $059b+40,x
              lda getreadytext,y
              clc
              adc #$40
              sta $059c,x
              clc
              adc #$80
              sta $059c+40,x
              iny
              inx
              inx
              cpx #18
              bne getgrtext
        

;-----------------------------------------------------------------------------------

              ;Initialise IRQ raster interrupts.
              ;This is made to controll the raster
              ;splits that controls the game 
              ;engine, and scroller
              
        ldx #$fb 
        txs
        ldx #<girq1
        ldy #>girq1
        lda #$7f
        stx $fffe
        sty $ffff
        ldx #<nmi
        ldy #>nmi
        stx $fffa
        sty $fffb
        sta $dc0d
        sta $dd0d
        lda #$36
        sta $d012
        lda #$1b
        sta $d011
        lda #$01
        sta $d01a
        lda #0          ;Initialise music
        jsr musicinit
        cli
        jsr updatepanel

;-----------------------------------------------------------------------------------        

        ;Setup the GET READY response. After fire is 
        ;pressed. The game is ready to start.

getreadyloop
        jsr syncgame
        jsr objpos2sprite
        lda $dc00
        lsr
        lsr
        lsr
        lsr
        lsr
        bit firebutton
        ror firebutton
        bmi getreadyloop
        bvc getreadyloop
        lda #0
        sta firebutton
        ldx #$00
removegetready
        lda #$20
        sta $059b,x
        sta $059b+40,x
        inx
        cpx #18*2
        bne removegetready
        lda #$ff
        sta $d015
        lda #$56
        sta objpos
        
        jmp levelstart
        

;-----------------------------------------------------------------------------------        
          ;IRQ raster interrupts 
          
          ;IRQ 1 - The Main game scroller screen
        
girq1     sta gstacka1+1
          stx gstackx1+1
          sty gstacky1+1
          lda $dc0d
          sta $dd0d
         
          lda speed
          ora #$10
          sta $d011
csm1      lda #$09
          sta $d022
csm2      lda #$0c
          sta $d023
          lda #$ff
          sta $d015
          sta $d01c
          lda #%01111110
          sta $d01b
         
          ldx #<girq2
          ldy #>girq2
          lda #$d1
          stx $fffe
          sty $ffff
          sta $d012
          asl $d019
          
gstacka1  lda #$00
gstackx1  ldx #$00
gstacky1  ldy #$00
          rti

          ;IRQ 2 - The Status panel 
          
girq2     sta gstacka2+1
         
         
          cmp #$15
          beq flip_d011
          lda #$7b 
          sta $d011
           lda #0
          sta $d015
          pha
          pla
          pha
          pla 
          nop
          nop
          nop
          nop
flip_d011
          stx gstackx2+1
          lda #0
          sta $d015
          sta $d022
          sta $d023
          lda #$77
          sta $d011 
          ldx #$5c
          dex
          bne *-1
          lda #$17
          sta $d011
           lda #$0e
          sta $d022
          lda #$06
          sta $d023
         
          sty gstacky2+1
          lda #0
          sta $d015
          
          ldx #<girq1 
          ldy #>girq1 
          lda #$f8
          stx $fffe
          sty $ffff
          sta $d012 
          asl $d019
          jsr soundplayer
gstacka2  lda #$00
gstackx2  ldx #$00
gstacky2  ldy #$00
          rti

;-----------------------------------------------------------------------------------

          ;Get Ready exits, so start game level
          
levelstart
          jsr updatepanel
       
         
          jsr setupnextlevel
         

;-----------------------------------------------------------------------------------         
          
          ;The main body of the main game loop 
          ;(Calling jump subroutines)
          
gameloop  jsr syncgame
          jsr objpos2sprite
          jsr scrollscreen
          jsr randomise
          jsr levelcontrol
          jsr playercontrol
          jsr collision
          jmp gameloop
          

;-----------------------------------------------------------------------------------          

          ;Object position to sprites (Sprite position expansion)

objpos2sprite 
          ldx #$00
xloop     lda objpos,x
          asl 
          ror $d010
          sta $d000,x
          lda objpos+1,x
          sta $d001,x
          inx
          inx
          cpx #$10
          bne xloop
          rts
          

;-----------------------------------------------------------------------------------
        
        ;Update the game score panel 
         
updatepanel ;(2x2 char)
        ldx #$00        
        ldy #$00
        txa
getchar lda panel,y
        sta $0748,x
        clc
        adc #$80
        sta $0770,x
        lda panel,y 
        clc
        adc #$40
        sta $0749,x
        clc
        lda $0749,x
        adc #$80
        sta $0771,x
        iny
        inx
        inx
        cpx #$28
        bne getchar
        rts

;-----------------------------------------------------------------------------------        
        
;Scroll screen data downwards (First control
;the speed value pointer. 


scrollscreen
                lda scrolldelay
                cmp scrolldelayamount
                beq doscroll
                inc scrolldelay
                rts
doscroll        lda #0
                sta scrolldelay
                lda speed
                clc
                adc speedlimit
                sta speed 
                lda speed
                cmp #$08
                bcs switch 
                rts 
                
switch          lda #0
                sta speed
                jsr shiftrows
                jsr getmap ;Fetch the game's map as you scroll
                rts

     
;------------------------------------------------------------------------        
        
                ;Main hard scroll, which moves all 40 columns
                ;down 1 row.
shiftrows                
       ldx #$27
ShiftRows1
       lda row10,x
       sta rowtemp,x
       lda row9,x
       sta row10,x
       lda row8,x
       sta row9,x
       lda row7,x
       sta row8,x
       lda row6,x
       sta row7,x
       lda row5,x
       sta row6,x
       lda row4,x
       sta row5,x
       lda row3,x
       sta row4,x
       lda row2,x
       sta row3,x
       lda row1,x
       sta row2,x
       lda row0,x
       sta row1,x
       lda rowtemp1,x
       sta row0,x
      
       dex
       bpl ShiftRows1
      
FitRow2       
       ldx #$27
ShiftRows2
       
        lda row18,x
        sta row19,x
        lda row17,x
        sta row18,x
        lda row16,x
        sta row17,x
        lda row15,x
        sta row16,x
        lda row14,x
        sta row15,x
        lda row13,x
        sta row14,x
        lda row12,x
        sta row13,x
        lda row11,x
        sta row12,x
        lda rowtemp,x
        sta row11,x
        lda rowtemp2,x
        sta rowtemp1,x
        dex
        bpl ShiftRows2
        jsr scorepoints
        
        rts


;-----------------------------------------------------------------------------------         
        
        ;Grab the game's map and then draw to the row temp 
        ;which is then fetched from the scroll 
        
getmap  ldx #$27
mapsm   lda mapstart,x
        sta rowtemp1,x
        dex
        bpl mapsm
        lda mapsm+1
        sec
        sbc #40
        sta mapsm+1
        lda mapsm+2
        sbc #0
        sta mapsm+2
        cmp #>mapend
        bcc wrap 
        rts
wrap    lda #<mapstart 
        sta mapsm+1
        lda #>mapstart
        sta mapsm+2
        rts
       
;-----------------------------------------------------------------------------------         

;Randomise timer


randomise 
         lda random+1
         sta temp1
         lda random 
         asl
         rol temp1
         asl
         rol temp1
         clc
         adc random 
         pha
         lda temp1
         adc random 
         sta random+1
         pla
         adc #$11
         sta random
         lda random+1
         adc #$36
         sta random+1
         rts
         
;-------------------------------------------------------------------------------------
         
;Level control 

levelcontrol
          inc playtime
          lda playtime
         
          cmp #$30
          beq seconds
          
          
          rts
          
seconds   lda #0
          sta playtime
          inc playtime+1
          lda playtime+1
          cmp #60       ;1 minute per level
          beq levelup
          rts
        

;-------------------------------------------------------------------------------------          

          ;Level complete ... Speed the game until elapsed speed 8
          ;is reached
          
levelup   lda #0
          sta playtime 
          sta playtime+1
          
          
          inc level 
          lda level
          cmp #9
          beq finished
          inc levelspeed
          inc leveltext
          inc maxtospawnlimit
     
          jsr updatepanel
          
          lda #<levelupsfx
          ldy #>levelupsfx
          ldx #7
          jsr sfxinit
          jmp levelstart
          
finished  jmp gamecomplete

;-------------------------------------------------------------------------------------

;Score points (10 points per second survived)

scorepoints
          inc score+4
          ldx #4
scoreloop lda score,x
          cmp #$3a
          bne scoreok
          lda #$30
          sta score,x
          inc score-1,x
scoreok   dex
          bne scoreloop
          jsr updatepanel
          rts

;-------------------------------------------------------------------------------------
          
;Player movement control 
          
playercontrol 
            jsr animation
            lda animstore
            sta $07f8
            lda colourstore
            sta $d027
            lda #1
            bit $dc00
            bne .notup
            ldx objpos+1
            dex 
            dex
            dex
            dex
            cpx #$3a
            bcs storup
            ldx #$3a
storup      stx objpos+1
.notup      lda #2
            bit $dc00
            bne .notdown 
            ldx objpos+1
            inx
            inx
            inx
            inx
            cpx startpos+1
            bcc stordown
            ldx startpos+1
stordown    stx objpos+1            
.notdown            
            lda #4 ;Read joy port 2
            bit $dc00
            bne .notleft
            ldx objpos
            dex
            dex
            cpx #$0a
            bcs storeleft
            ldx #$0a
storeleft    stx objpos  
            rts
.notleft    lda #8
            bit $dc00
            bne notright
            ldx objpos
            inx
            inx
            cpx #$a2
            bcc storeright
            ldx #$a2
storeright  stx objpos 
notright
            rts

;-------------------------------------------------------------------------------------
            
;Animate all those sprites 

animation   jsr dropstars
            lda animdelay
            cmp #3
            beq doanim
            inc animdelay
            rts
doanim      lda #0
            sta animdelay
            ldx animpointer
            lda playerframe,x
            sta animstore
            
            lda playercolour,x
            sta colourstore
            lda starframe1,x
            sta $07f9
            lda starframe2,x
            sta $07fa
            lda starframe3,x
            sta $07fb
            lda starframe4,x
            sta $07fc
            lda starframe5,x
            sta $07fd
            lda starframe6,x
            sta $07fe 
            lda #$8e
            sta $07ff
            lda bonusanim,x
            sta $d02e
            inx
            cpx #8
            beq doanimreset
            inc animpointer
            rts
doanimreset
            ldx #$00
            stx animpointer
            rts

;-------------------------------------------------------------------------------------
            
;Drop the falling stars 

dropstars
            ldx #$00
droploop    lda objpos+3,x
            clc
            adc starspeed+1,x
            cmp #$c4
            bcc notoutset 
            jsr randomise
         
    
selectnew   jsr randomise
            sta selectpointer
            lda selectpointer
            cmp #$0c
            bcc selectnew
            cmp #$a0
            bcs selectnew
            
            sta objpos+2,x
            
            lda #$00
notoutset   sta objpos+3,x
            inx
            inx
            cpx #$0e
            bne droploop
            rts
        

;-------------------------------------------------------------------------------------

              ;Setup the next level
              
setupnextlevel
              ldx level
              lda d022table-1,x
              sta csm1+1
              lda d023table-1,x
              sta csm2+1
              lda spritecolour-1,x
              sta $d028
              sta $d029
              sta $d02a
              sta $d02b
              sta $d02c
              sta $d02d
              lda speedcontrol1-1,x
              sta scrolldelayamount
              lda speedcontrol2-1,x
              sta speedlimit
            
              rts
              

;-------------------------------------------------------------------------------------              
              
              ;Game collision call subroutines
              ;Sprite/Sprite = Collectible 
              ;Sprite/Background = Asteroids
              
collision     jsr spritetosprite
              jsr spritetobackground
              rts

;-------------------------------------------------------------------------------------              
              ;Sprite to sprite collision detection
              
spritetosprite
              lda objpos
              sec
              sbc #06
              sta collstore+0
              clc
              adc #$0c
              sta collstore+1
              lda objpos+1
              sec
              sbc #$0c
              sta collstore+2
              clc
              adc #$18
              sta collstore+3
              
              lda objpos+14
              cmp collstore
              bcc nocollect
              cmp collstore+1
              bcs nocollect
              lda objpos+15
              cmp collstore+2
              bcc nocollect
              cmp collstore+3
              bcs nocollect
              lda #$00
              sta objpos+14
              lda #<pickupsfx
              ldy #>pickupsfx
              ldx #14
              jsr sfxinit
              jsr score1000
nocollect     rts
score1000     inc score+2
              ldx #2
scloop2       lda score,x
              cmp #$3a
              bne scok2
              lda #$30
              sta score,x
              inc score-1,x
scok2         dex
              bne scloop2
              rts

;-------------------------------------------------------------------------------------            
              ;Sprite to background collision detection

spritetobackground
              lda $d000
              sec
xcoord        sbc #$10
              sta zp
              lda $d010
              sbc #$00
              lsr
              lda zp
              ror
              lsr
              lsr
              sta zp+3
              lda $d001
              sec
ycoord        sbc #$2a              
              lsr
              lsr
              lsr
              sta zp+4
              lda #<$0400
              sta zp+1
              lda #>$0400
              sta zp+2
              ldx zp+4
              beq checkchars
bgcloop       lda zp+1
              clc
              adc #$28
              sta zp+1
              lda zp+2
              adc #$00
              sta zp+2
              dex
              bne bgcloop
checkchars    ldy zp+3
              lda (zp+1),y
              
;Macro code for sprite/background collision detection              
              
!macro asteroidcollisiontest asteroidtype {
  
              cmp #asteroidtype
              bne .skip
              jmp rockethit
.skip              
              
}              
              +asteroidcollisiontest asteroidchar1
              +asteroidcollisiontest asteroidchar1b
              +asteroidcollisiontest asteroidchar1c
              +asteroidcollisiontest asteroidchar1d
              +asteroidcollisiontest asteroidchar2
              +asteroidcollisiontest asteroidchar2b
              +asteroidcollisiontest asteroidchar2c
              +asteroidcollisiontest asteroidchar2d 
              +asteroidcollisiontest asteroidchar3
              +asteroidcollisiontest asteroidchar3b
              +asteroidcollisiontest asteroidchar3c
              +asteroidcollisiontest asteroidchar3d
              +asteroidcollisiontest asteroidchar4
              +asteroidcollisiontest asteroidchar4b
              +asteroidcollisiontest asteroidchar4c
              +asteroidcollisiontest asteroidchar4d
              rts
              
;------------------------------------------------------------------------------------                         
              
              ;Player dead - stop background scroll, stars, bonus,etc 
              ;and perform player death, then game over.
              
rockethit    

egy1          dec energycount
egy2          dec energyout+1
              lda energyout+1
              cmp #$97 
              beq destroyplayer
              lda #$20
energyout     sta $07c0

             lda #1
             sta $d027
              rts
              

              
;------------------------------------------------------------------------------------   

;             The player gets destroyed              
              
destroyplayer                
              ldx #14
              lda #<deathsfx
              ldy #>deathsfx
              jsr sfxinit 
             
              lda #0
              sta deathanimpointer
              sta deathanimpointer2
deathloop              
              jsr syncgame
              jsr objpos2sprite
              jsr animation
              lda deathanimpointer
              cmp #$03
              beq dodeathanimation
              inc deathanimpointer
              jmp deathloop
dodeathanimation
              lda #$00
              sta deathanimpointer
              ldx deathanimpointer2
              lda deathframe,x
              sta $07f8
              lda deathcolour,x
              sta $d027
              inx
              cpx #8
              beq removeplayerout
              inc deathanimpointer2
              jmp deathloop


              
;------------------------------------------------------------------------------------   
; GAME OVER
;              
removeplayerout
              lda #$00
              sta $06
              sta objpos
              ldx #14
              lda #<gameoversfx
              ldy #>gameoversfx 
              jsr sfxinit
             
              ldx #$00
              ldy #$00
              txa
getgameovertext
              lda gameovertext,y
              sta $059b,x
              clc
              adc #$80
              sta $059b+40,x
              lda gameovertext,y
              clc
              adc #$40
              sta $059c,x
              clc
              adc #$80
              sta $059c+40,x
              iny
              inx
              inx
              cpx #18
              bne getgameovertext
              
;Game over part in game.

gameoverloop              
              jsr syncgame
              jsr objpos2sprite
              jsr animation
              lda $07f9
              sta $07ff
              lda $d02a
              sta $07ff
              lda $dc00
              lsr
              lsr
              lsr
              lsr
              lsr
              bit firebutton
              ror firebutton
              bmi gameoverloop
              bvc gameoverloop
              jmp checkhiscore
;------------------------------------------------------------------------------------            
              ;Game complete mode.
              
gamecomplete  lda #<sfxthrust
              ldy #>sfxthrust
              ldx #14
              jsr sfxinit
gamecompleteloop
              jsr syncgame
              jsr objpos2sprite
              jsr animation
              lda animstore
              sta $07f8
              lda colourstore
              sta $d027
              jsr scrollscreen
              jsr moveplayerout
              jmp gamecompleteloop
              
moveplayerout

              lda playerframe
              sta $07f8
              ldx objpos+1
              dex
              dex
              cpx #$02
              bcs playbaseok
              ldx #$00
              stx objpos+0
              stx objpos+1
              jmp finishedending
playbaseok    stx objpos+1
              rts
finishedending
               
              
             
              lda #$38
              sta leveltext
              jsr updatepanel
              ldx #14
              lda #<deathsfx
              ldy #>deathsfx
              jsr sfxinit 
                           
                 ldx #$00
              ldy #$00
              txa
getwelldonetext
              lda welldonetext,y
              sta $059b,x
              clc
              adc #$80
              sta $059b+40,x
              lda welldonetext,y
              clc
              adc #$40
              sta $059c,x
              clc
              adc #$80
              sta $059c+40,x
              iny
              inx
              inx
              cpx #18
              bne getwelldonetext
              ldx #$00
clearrow1     lda #$20
              sta $0400,x
              sta $0428,x
              inx
              cpx #$28
              bne clearrow1
              
              jmp gameoverloop
              
;---------------------------------------------------------------------------------------
;
;             Sync game timer 

syncgame      lda #0
              sta rt
              cmp rt 
              beq *-3
              rts
              
              
!align $ff,0              
              
;Pointers
pointers
;-------------------
pointerstart
rt  !byte 0                 ;Raster timer
firebutton !byte 0
level !byte 0               ;Level counter 

scrolldelay !byte 0
scrolldelayamount !byte 0

speed !byte $00             ;Speed control
levelspeed !byte $00        ;Level speed
speedstore !byte $00        ;Soft scroll store pointer 

spawnlimit !byte 0      ;Spawn time limit for next asteroid 
playtime !byte 0,0          ;2 pointers to time each round
animdelay !byte 0
animpointer !byte 0

selectpointer !byte 0
deathanimpointer !byte 0
deathanimpointer2 !byte 0
pointersend
animstore !byte $80
colourstore !byte $0a

speedlimit !byte 8
maxtospawn !byte 5
maxtospawnlimit !byte 1
energycount !byte 0,0
;-------------------

collstore !byte 0,0,0,0

temp1    !byte $5b          
random   !byte %10011101,%10011011

playerframe  !byte $80,$81,$82,$83,$84,$85,$86,$87
playercolour !byte $04,$04,$04,$0a,$07,$0a,$04,$04 

deathframe   !byte $88,$89,$8a,$8b,$8c,$8d,$88,$88
deathcolour  !byte $0a,$07,$0a,$07,$0a,$07,$0a,$07 

starframe1   !byte $8f,$90,$91,$92,$93,$94,$95,$96
starframe2   !byte $91,$92,$93,$94,$95,$96,$8f,$90
starframe3   !byte $93,$94,$95,$96,$8f,$90,$91,$92
starframe4   !byte $95,$96,$8f,$90,$91,$92,$93,$94
starframe5   !byte $92,$93,$94,$95,$96,$8f,$90,$91
starframe6   !byte $94,$95,$96,$8f,$90,$91,$92,$93

bonusanim    !byte $05,$03,$0d,$01,$0d,$03,$05,$0b

;Sprite object position

startpos     !byte $00,$b0 
             !byte $00,$10
             !byte $00,$a4
             !byte $00,$71
             !byte $00,$32
             !byte $00,$98
             !byte $00,$66
             !byte $00,$29
             
starspeed
             !byte $00,$03
             !byte $00,$02
             !byte $00,$03
             !byte $00,$04
             !byte $00,$05
             !byte $00,$06
             !byte $00,$02
             

objpos !byte 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0


;Panel text         
!ct scr
panel   !text "score:"
score !text "000000 level:"
leveltext !text "1"
getreadytext !text "get ready"
gameovertext !text "game over"
welldonetext !text "well done"
              
d022table       !byte $0c,$0a,$0c,$0e,$0c,$08,$0c,$04
d023table       !byte $09,$02,$0b,$06,$09,$02,$0b,$06

spritecolour    !byte $0e,$0d,$0a,$03,$0e,$0d,$0a,$03                
speedcontrol1   !byte $01,$00,$00,$00,$00,$00,$00,$00
speedcontrol2   !byte $01,$01,$02,$03,$04,$05,$06,$07
            
;Sound effects 
             
gameonsfx
           !byte $00,$FC,$08,$A2,$41,$A4,$A6,$A8,$AA,$AC,$AE,$B0,$B2,$B4,$B6,$B8
           !byte $BA,$BC,$00           
        
pickupsfx  !byte $00,$fA,$08,$A4,$41,$B4,$D4,$C4,$B3,$C7,$A1,$11,$00        



levelupsfx !byte $00,$FC,$08,$B0,$41,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB
           !byte $BC,$B0,$B1,$B2,$B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB,$B0,$B1,$B2
           !byte $B3,$B4,$B5,$B6,$B7,$B8,$B9,$BA,$BB,$B0,$B1,$B2,$B3,$B4,$B5,$B6
           !byte $B7,$B8,$B9,$BA,$BB,$91,$11,$00        
           
           
           
deathsfx   !byte $0C,$00,$08,$DC,$81,$b8,$b6,$b4,$b2,$b0,$af,$b8,$b6,$b4,$b2,$b0,$af,$b8,$b6,$b4,$b2,$b0,$af,$00


sfxthrust  !byte $00,$FC,$08,$B0,$81,$A3
           !for c = 1 to 30
           !byte $a3,$a2,$a1,$a2
           !end 
           !byte $11,$00
           

gameoversfx !BYTE $0A,$AA,$08,$B0,$41,$c7,$c3,$c0,$c7,$c3,$c0,$c7,$c3,$d0,0
          
rowtemp    !fill $40,$00           

energycoltable
           !byte $0a,$0a,$0a,$0a,$0a 
           !byte $0a,$0a,$0a,$0a,$0a
           !byte $0f,$0f,$0f,$0f,$0f
           !byte $0f,$0f,$0f,$0f,$0f
           !byte $0d,$0d,$0d,$0d,$0d
           !byte $0d,$0d,$0d,$0d,$0d
           !byte $0d,$0d,$0d,$0d,$0d 
           !byte $0d,$0d,$0d,$0d,$0d
