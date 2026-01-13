*zaawansowana ekonometria projekt kod
clear
*ustawianie wymiarow czasowych
xtset country_id year

replace infant_mort=infant_mort*1000

summarize life_expect
summarize adult_mortality
summarize infant_mort
summarize bmi
summarize gghed
summarize che_gdp
summarize une_gni

*OSZACOWNIE MODELI
*model Pooled OLS
regress life_expect adult_mortality bmi infant_mort gghed che_gdp une_gni
estimates store pols

*model LSDV
ssc install reghdfe
ssc install ftools
reghdfe life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, noconst absorb(country_id) 
estimates store lsdv

*model between effects BE
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, be
estimates store be

*model random effects RE
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, re
estimates store re

*model two-way RE
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni i.year, re
estimates store re2w

*model fixed effects FE
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, fe
estimates store fe

*model two-way FE
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni i.year, fe
estimates store fe2w

*model correlation random effects CRE
foreach var of varlist adult_mortality infant_mort bmi gghed che_gdp une_gni {
	egen mean_`var' = mean(`var'), by(country_id)
	generate deviance_`var' = `var' - mean_`var'
}
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni mean_*, re
estimates store cre

*model two-way CRE
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni mean_* i.year, re
estimates store cre2w

*3. QUALITY PUBLICATION TABLE
estout pols re fe, cells(b(star fmt(3)) se(fmt(3))) stats(F sigma_u sigma_e N_g N) unstack starlevels(* 0.05 ** 0.01 *** 0.001) 

*6. WNIOSKOWANIE O WYBORZE FE VS RE VS POLS
*test istotności efektów indywidualnych
*model FE
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, fe
*ostatnia linijka - statystyka testowa=174.67 a jej pvalue=0, odrzucamy hipotezę zerową że efekty indywidualne są zerowe (nieistotne), więc efekty indywidualne są istotne
*model RE
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, re
xttest0
*statystyka testowa testu LM=16899.24 a jej pvalue=0, odrzucamy hipotezę zerową o tym że nie ma żadnego zróżnicowania pomiędzy podmiotami ze wzgledu na efekty indywidualne, więc efekty indywidualne są istotne

*wniosek: efekty indywidualne istotne zarówno w modelu FE jak i RE, więc modele te są lepsze niż POLS

*test hausmana
hausman fe re
*statystyka testowa=265.35 a jej pvalue=0, odrzucamy hipotezę zerową o tym że kowariancja pomiędzy efektami indywidualnymi a zmiennymi niezależnymi wynosi 0

*wniosek: ze względu na występującą korelację pomiędzy efektami indywidualnymi a zmiennymi niezależnymi, korzystanie z modelu RE jest niepoprawne, więc należy wybrać model FE

*cała populacja vs losowa próbka - w tekście

*przedstawić czym może być efekt indywidualny i opisać czy będzie skorelowany z regresorami z modelu - w tekście


*WYBOR MODELU NAJLEPSZEGO
*z poprzedniego mamy ze skupiamy sie na FE

*model two-way fe prawdopodobnie bedzie lepszy - trzeba napisac cos teoretycznego
*teraz trzeba sie zastanowic czy jeszcze jakos bedziemy zmieniac ten model

*zgodnie z przeslankami teoratycznymi prawdopodobnie bedzie heteroskedastycznosc i autokorelacja bledow losowych wiec sprawdzamy

*homoskedastyczność składnika losowego
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, fe 
xttest3
*statystyka 2.3e+05, pvalue=0 wiec odrzucamy h0 i mamy heteroskedastycznosc

xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni i.year, fe 
xttest3
*statystyka 1.5e+05, pvalue=0 wiec odrzucamy h0 i mamy heteroskedastycznosc

*autokorelacja składnika losowego
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, fe
xtserial life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, output
*statystyka 56.236, pvalue=0 wiec odrzucamy h0 o braku autokorelacji

xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni i.year, fe
xtserial life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, output
*statystyka 56.236, pvalue=0 wiec odrzucamy h0 o braku autokorelacji

*zeby w miare sobie poradzic z tym wykorzystamy do modelu macierze odporne
*model two-way FE z macierza odporna
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni i.year, fe vce(robust)
estimates store fe2wrob

xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, fe vce(robust)
estimates store ferob
*i ten model chyba powinien byc najlepszy

*jeszcze tylko sprawdzimy forme funkcyjna dla pewnosci

*test poprawności (liniowości) formy funkcyjnej
*wartosci dopasowane
drop yhat yhat2 yhat3
xtreg life_expect adult_mortality infant_mort bmi gghed che_gdp une_gni, fe vce(robust)
predict yhat, xbu
generate yhat2=yhat^2
generate yhat3=yhat^3

*test RESET w formie fitted
xtreg life_expect yhat yhat2 yhat3, fe vce(robust)
*1 potega istotna, a 2 i 3 NIE, wiec mozna wniskowac ze forma powinna byc prawidlowa
*mozna tą tabelkę pokazac w pracy

*formalny test hipotezy o dopasowaniu
test yhat2 yhat3
*statystyka testowa=2.78 a jej pvalue=0.0651, więc przekracza 5%, mozemy stwierdzic ze nawet formalnie nie ma podstaw do odrzucenia h0 o poprawnosci


*QUALITY PUBLICATION TABLE koncowe
estout pols lsdv be re re2w cre fe fe2w fe2wrob, cells(b(star fmt(3)) se(fmt(3))) stats(F sigma_u sigma_e N_g N) unstack starlevels(* 0.05 ** 0.01 *** 0.001) indicate(rep dummies = mean* *year)

estout ferob fe2wrob, cells(b(star fmt(3)) se(fmt(3))) stats(F sigma_u sigma_e N_g N) unstack starlevels(* 0.05 ** 0.01 *** 0.001) indicate(rep dummies = *year)

estout fe2wrob, cells(b(star fmt(3)) se(fmt(3))) stats(F sigma_u sigma_e N_g N) unstack starlevels(* 0.05 ** 0.01 *** 0.001) indicate(rep dummies = *year)


