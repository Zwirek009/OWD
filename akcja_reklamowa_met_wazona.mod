### parametry ###
set SEGMENTY;						# segmenty rynku
set MEDIA;							# media reklamowe
param progSkut;						# liczba odbiorcow (w tys.), po przekroczeniu ktorej spada skutecznosc
param niskaSkut;					# czesc skutecznosci po przekroczeniu progu
param minOdbiorcowOgolem;			# minimalna liczba odbiorcow ogolem [tys.]
param minOdbiorcow {SEGMENTY};		# minimalna liczba odbiorcow w danych segmentach [tys.]
param skut {MEDIA};					# skutecznosc reklamy mierzona liczba odbiorcow ogolem [tys.]
param cenaReklamy {MEDIA};			# cena jednostki reklamowej w danych mediach [tys. zl]
param udzialy {MEDIA, SEGMENTY};	# udzialy poszczegolnych segmentow rynku w ogolnej liczbie odbiorcow

### metoda wazenia ocen - wagi ocen ###
param wagaOdbOgol;
param wagaOdbSegm {SEGMENTY};
param wagaKosztu;

### zmienne pomocnicze ###
var ReklamaStd {m in MEDIA} >= 0, integer;	# liczba kupionych jednostek reklamy standardowej skutecznosci 
var ReklamaNis {m in MEDIA} >= 0, integer;	# liczba kupionych jednostek reklamy niskiej skutecznosci

### zmienne decyzyjne ###
# liczba odbiorcow w segmentach [tys.]
var Odbiorcy {s in SEGMENTY} = sum{m in MEDIA} udzialy[m,s]/100*(skut[m]*ReklamaStd[m]+skut[m]*niskaSkut*ReklamaNis[m]);

# nadmiar odbiorcow w segmentach wzgledem wartosci minimalnych [%]
var NadmiarOdbiorcow {s in SEGMENTY} = (Odbiorcy[s] - minOdbiorcow[s])/(minOdbiorcow[s]/100);

# liczba odbiorcow ogolem [tys.]
var OdbiorcyOgolem = sum {m in MEDIA} (skut[m]*ReklamaStd[m]+skut[m]*niskaSkut*ReklamaNis[m]);

# nadmiar odbiorcow ogolem wzgledem wartosci minimalnej [%]
var NadmiarOdbiorcowOgolem = (OdbiorcyOgolem - minOdbiorcowOgolem)/(minOdbiorcowOgolem/100);

# calkowity koszt akcji reklamowej [tys. zl]
var Koszt = sum {m in MEDIA} cenaReklamy[m]*(ReklamaStd[m]+ReklamaNis[m]);

### funkcja celu - metoda wazenia ocen ###
maximize f_celu: (wagaOdbOgol*NadmiarOdbiorcowOgolem) + (sum {s in SEGMENTY} (wagaOdbSegm[s]*NadmiarOdbiorcow[s])) + (wagaKosztu*(-1)*Koszt);

### ograniczenia ###
# ogolna liczba odbiorcow co najmniej rowna wartosciom celu akcji
subject to ogr1: OdbiorcyOgolem >= minOdbiorcowOgolem;

# liczba odbiorcow w segmentach rynku co najmniej rowna wartosciom celu akcji
subject to ogr2 {s in SEGMENTY}: Odbiorcy[s] >= minOdbiorcow[s];

# ograniczenie liczby odbiorcow o pelnej skutecznosci odbioru danego medium 
subject to ogr3 {m in MEDIA}: skut[m]*ReklamaStd[m] <= progSkut;

# wartosci zmiennych decyzyjnych wieksze od 0
subject to ogr4 {s in SEGMENTY}: Odbiorcy[s] >= 0;
subject to ogr5: OdbiorcyOgolem >= 0;
subject to ogr6: Koszt >= 0;

### rozwiazanie modelu w oparciu o podane dane i prezentacja wynikow ###
option solver minos;		# przelaczenie na solver zmiennoprzecinkowy
data akcja_reklamowa_met_wazona.dat;
solve;
display wagaOdbOgol, wagaOdbSegm, wagaKosztu; 
display ReklamaStd, ReklamaNis, Odbiorcy, NadmiarOdbiorcow, OdbiorcyOgolem, NadmiarOdbiorcowOgolem, Koszt, f_celu;

