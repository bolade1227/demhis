
***Women exposed to FP need (v621!=.)

tab1 v384*
gen x1_1hearFP=(v384a==1 | v384b==1 | v384c==1) if v625!=.
tab x1_1hearFP
lab var x1_1hearFP"heards information on FP on media"
lab def x1_1hearFP 1"yes" 0"no"
lab val x1_1hearFP x1_1hearFP

recode v106 (0=0 "no education")(1=1 "primary")(2 3=2 "secondary+"), gen(x2_1)
lab var x2_1"education" 

tab v717
tab v717, nol
recode v717 (1=1 "yes")(0 2 4 6 7 8 9=0 "no"), gen(x2_2pro)
lab var x2_2pro"works as professional/technical/managerial"
tab x2_2pro

tab v732
tab v732, nol
recode v732 (2=1 "yes")(1 3=0 "no"), gen(x2_3season)
lab var x2_3season"works seasonally"

tab v190
tab v190, nol
recode v190 (1 2=1 "poor")(3/5=0 "non-poor"), gen(x2_4)
lab var x2_4"household wealth"

tab v025
tab v025, nol
rename v025 x2_5

tab v613
tab v613, nol
recode v613 (0/3=1 "wants < 4 children")(4/92=0 "wants >= 4 children")(96= 96 "non-numeric response"), gen(x3_1ferpref)
lab var x3_1ferpref"ideal number of children"
tab x3_1ferpref

tab v313
tab v313, nol
recode v313 (3=1 "yes")(0/2=0 "no"), gen(x3_2modernFP)
lab var x3_2modernFP"uses modern contraception"

tab v511
tab v511, nol
recode v511 (min/17=1 "1st union < 18")(18/49=2 "1st union >= 18"), gen(x3_3union1)
lab var x3_3union1"age at 1st union"

tab v212
recode v212 (min/17=1 "1st birth < 18")(18/49=2 "1st birth >= 18"), gen(x3_4birth1)
lab var x3_4birth1"age at 1st birth"


tab v206
tab v207
gen v206_207=v206+v207
recode v206_207 (1/92=1 "child died >=1")(0=0 "no child died"), gen(x3_5)
lab var x3_5"child death"
drop v206_207

xi : tfr2 i.x1_1hearFP i.x2_1 i.x2_2pro i.x2_3season i.x2_4 i.x3_1ferpref i.x3_2modernFP i.x3_3union1 i.x3_4birth1 i.x3_5

