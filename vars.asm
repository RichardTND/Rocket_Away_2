
scorelen = 6
listlen = 5
namelen = 9


zp=$70

asteroidchar1 = 36
asteroidchar2 = 36+(1*64)
asteroidchar3 = 36+(2*64)
asteroidchar4 = 36+(3*64)

asteroidchar1b = 37
asteroidchar2b = 37+(1*64)
asteroidchar3b = 37+(2*64)
asteroidchar4b = 37+(3*64)

asteroidchar1c = 38
asteroidchar2c = 38+(1*64)
asteroidchar3c = 38+(2*64)
asteroidchar4c = 38+(3*64)

asteroidchar1d = 43
asteroidchar2d = 43+(1*64)
asteroidchar3d = 43+(2*64)
asteroidchar4d = 43+(3*64)

screen = $0400

row0 = screen
row1 = screen+1*40
row2 = screen+2*40
row3 = screen+3*40
row4 = screen+4*40
row5 = screen+5*40
row6 = screen+6*40
row7 = screen+7*40
row8 = screen+8*40
row9 = screen+9*40
row10 = screen+10*40
row11 = screen+11*40
row12 = screen+12*40
row13 = screen+13*40
row14 = screen+14*40
row15 = screen+15*40
row16 = screen+16*40
row17 = screen+17*40
row18 = screen+18*40
row19 = screen+19*40
row20 = screen+20*40
rowtemp1 = $3400
rowtemp2 = $3428
mapstart = $cf00
musicinit = $9000
musicplay = $9003
sfxinit = $9006