### parametry ###
set SEGMENTY;						# segmenty rynku
set MEDIA;							# media reklamowe
param progSkutecznosci;				# liczba odbiorcow (w tys.), po przekroczeniu ktorej spada skutecznosc
param wartoscNiskiejSkutecznosci;	# czesc skutecznosci po przekroczeniu progu
param minOdbiorcowOgolem;			# minimalna liczba odbiorcow ogolem [tys.]
param minOdbiorcow {SEGMENTY};		# minimalna liczba odbiorcow w danych segmentach [tys.]
param skutecznosc {MEDIA};			# skutecznosc reklamy mierzona liczba odbiorcow ogolem [tys.]
param cenaReklamy {MEDIA};			# cena jednostki reklamowej w danych mediach [tys. zl]
param udzialy {MEDIA, SEGMENTY};	# udzialy poszczegolnych segmentow rynku w ogolnej liczbie odbiorcow

### zmienne pomocnicze ###
var ReklamaStd {m in MEDIA} >= 0, integer;	# liczba kupionych jednostek reklamy standardowej skutecznosci 
var ReklamaNis {m in MEDIA} >= 0, integer;	# liczba kupionych jednostek reklamy niskiej skutecznosci

### zmienne decyzyjne ###
# liczba odbiorcow w segmentach [tys.]
var Odbiorcy {s in SEGMENTY} = sum{m in MEDIA} udzialy[m,s]/100*(skutecznosc[m]*ReklamaStd[m]+skutecznosc[m]*wartoscNiskiejSkutecznosci*ReklamaNis[m]);

# niedobor odbiorcow w segmentach wzgledem wartosci minimalnych [%]
var NiedoborOdbiorcow {s in SEGMENTY} = (Odbiorcy[s] - minOdbiorcow[s])/(minOdbiorcow[s]/100);

# liczba odbiorcow ogolem [tys.]
var OdbiorcyOgolem = sum {m in MEDIA} (skutecznosc[m]*ReklamaStd[m]+skutecznosc[m]*wartoscNiskiejSkutecznosci*ReklamaNis[m]);

# niedobor odbiorcow ogolem wzgledem wartosci minimalnej [%]
var NiedoborOdbiorcowOgolem = (OdbiorcyOgolem - minOdbiorcowOgolem)/(minOdbiorcowOgolem/100);

# calkowity koszt akcji reklamowej [tys.]
var Koszt = sum {m in MEDIA} cenaReklamy[m]*(ReklamaStd[m]+ReklamaNis[m]);

### funkcja celu ###
minimize koszt: Koszt;

### ograniczenia ###
# ogolna liczba odbiorcow co najmniej rowna wartosciom celu akcji
subject to ogr1: OdbiorcyOgolem >= minOdbiorcowOgolem;

# liczba odbiorcow w segmentach rynku co najmniej rowna wartosciom celu akcji
subject to ogr2 {s in SEGMENTY}: Odbiorcy[s] >= minOdbiorcow[s];

# ograniczenie liczby odbiorcow o pelnej skutecznosci odbioru danego medium 
subject to ogr3 {m in MEDIA}: skutecznosc[m]*ReklamaStd[m] <= progSkutecznosci;

### rozwi¹zanie modelu w oparciu o podane dane i prezentacja wynikow ###
option solver cplex;		# przelaczenie na solver calkowitoliczbowy
data akcja_reklamowa.dat;
solve;
display ReklamaStd, ReklamaNis, Odbiorcy, NiedoborOdbiorcow, OdbiorcyOgolem, NiedoborOdbiorcowOgolem, koszt;

