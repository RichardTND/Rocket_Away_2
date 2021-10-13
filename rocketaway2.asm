;Rocket Away 2 
;Written by Richard Bayliss
;(Starhawk)
;(C) 2021 Blazon

!source "vars.asm"

;Generate program 
!to "rocketaway2.prg",cbm

;2x2 Character set (in game gfx chars)
*=$0800
!bin "bin\2x2charset.prg",,2
*=$1000
!source "diskaccess.asm"
        ;The title screen scroll text message ...
           !ct scr
scrolltext !text " ... hello there and welcome to *** rocket away ii *** ...   code, "
           !text "sprites, sound effects and music were all done by starhawk ...   "
           !text "other graphics were drawn by firelord ...   1x1 charset by dirk s ...   "
           !text "tape loader source by martin piper ...   "
           !text "(c) 2021 blazon games "
           !text "division ...   how to play: plug a joystick into port 2 ...   this is a hi score attack challenge ...   the object "
            !text "of this game is to guide your rocket safely through the asteroid belt ...   "
           !text "the further you progress, the faster the game will get ...   pick up star pods (marked as b) "
           !text "for bonus points ...   avoid collision with asteroids, otherwise your rocket's energy will "
           !text "drain quickly ...   once your energy is drained, your rocket will explode and "
           !text "the game will then be over ...   there are 8 levels to complete in total ...   try to fly as far as you can in order "
           !text "to gain a super high score ...   this game carries a safety warning, for its high speed action ...   it is not ideal for those who are drunk, as it may "
           !text "make you even more dizzy and possibly sick, hahaha! ...   special thank you goes to baracuda for "
           !text "help and support, also to firelord for the game graphics and loading bitmap ...   "
           !text "i do hope you enjoy playing this game, as much as i have had fun programming it "
           !text "...   press fire to play ...   bye bye ...                                      "
           !byte 0
 
;--------------------------------------------------------------------------------------------------------------------------
                     
           ;Hi score list
           *=$1700
           
           
!ct scr
hiscoretable
          !text "             (c) 2021 blazon            "
          !text "       - today's best rocketeers -      "
          !text "           1. "
hiscorestart          
name1     !text "starhawk  "
hiscore1  !text "230000          "
          !text "           2. " 
name2     !text "firelord  "
hiscore2  !text "228240          "
          !text "           3. "
name3     !text "baracuda  "
hiscore3  !text "137510          "
          !text "           4. "
name4     !text "logiker   "
hiscore4  !text "065250          "
          !text "           5. "
name5     !text "blazon    "  
hiscore5  !text "050000          "
hiscoreend
name      !text "          "

;---------------------------------------------------------------------------------------

          * = $1900
          
        ;Import main title screen code
        !source "titlecode.asm"
        
        
;------------------------------------------------------------------------------------------------------------------------
         
          ;Game sprites
          *=$2000
          !bin "bin\sprites.spr"
 
;--------------------------------------------------------------------------------------------------------------------------
         
          ;Title screen charset
          *=$3800
          !bin "bin\1x1charset.bin"
 
;--------------------------------------------------------------------------------------------------------------------------
                    
;Game start
        *=$4000
        
        ;Hidden cheat 
        lda $dc00
        lsr
        lsr
        lsr
        bcs nocheat
        
        lda #$2c
        sta egy1
        sta egy2
nocheat        
        ;NTSC/PAL checker
        
p1      lda $d012
p2      cmp $d012
        beq p2
        bmi p1 
        cmp #$20
        bcc setntsc 
        lda #1
        sta system
        jmp .next0
setntsc lda #0    
        sta system
.next0        
        ldx #$00
spritegrabber 
        lda $25c0,x
        sta $65c0,x
        lda $2600,x
        sta $6600,x
        lda $2640,x
        sta $6640,x
        lda $2680,x
        sta $6680,x
        lda $26c0,x
        sta $66c0,x
        lda $2700,x
        sta $6700,x
        inx
        cpx #$40
        bne spritegrabber 
        
.next        
        
        ;Call disk access to load hiscores
        ;(If tape version is being used then
        ;ignore DOS)
        
        jsr LoadHiScores
        
        ;Disable Kernal RAM for more stable 
        ;interrupts and allow use of higher
        ;memory, where necessary.
        
        lda #$35
        sta $01
        
        ;Jump to the front end presentation
        
        jmp titlescreen
        
        ;Import main game source code 
        !source "gamecode.asm"
        


;--------------------------------------------------------------------------------------------------------------------------

           * = $6000
           !bin "bin\logo.prg",,2
           
;--------------------------------------------------------------------------------------------------------------------------
           
           * = $8800
           !source "hiscore.asm"
          
;--------------------------------------------------------------------------------------------------------------------------
   
           ;Music data 
           *=$9000
           !bin "bin\music.prg",,2
   
;-----------------------------------------------------------------------------------------
           
           ;Game map data 
           *=$a200
mapend           
           !bin "bin\gamemap.bin"
mapstart = *-40           
           
;----------------------------------------------------------------------------------------

           ;Game start screen 
           *=$e000
startscreen           
           !bin "bin\startscreen.bin"
           
;---------------------------------------------------------------------------------------           