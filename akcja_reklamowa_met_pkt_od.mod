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

### przedzialowa metoda punktu odniesienia ###
param epsilon;	# arbitralnie mala stala dodatnia
param gamma;	# niezadowolenie uzytkownika z nieosiagniecia poziomu rezerwacji
param beta;		# dodatkowe zwiekszenie zadowolenia uzytkownika ponad poziom aspiracji

param aspOdbOgol;
param aspOdbSgm {s in SEGMENTY};
param aspKoszt;

param rezerwOdbOgol;
param rezerwOdbSgm {s in SEGMENTY};
param rezerwKoszt;

### zmienne przedzialowej metody punktu odniesienia ###
var zOgol;
var zSegm {s in SEGMENTY};
var zKoszt;

var zMin;

### zmienne pomocnicze ###
var ReklamaStd {m in MEDIA} >= 0, integer;	# liczba kupionych jednostek reklamy standardowej skutecznosci 
var ReklamaNis {m in MEDIA} >= 0, integer;	# liczba kupionych jednostek reklamy niskiej skutecznosci

### zmienne decyzyjne ###
# liczba odbiorcow w segmentach [tys.]
var Odbiorcy {s in SEGMENTY} = sum {m in MEDIA} udzialy[m,s]/100*(skut[m]*ReklamaStd[m]+skut[m]*niskaSkut*ReklamaNis[m]);

# nadmiar odbiorcow w segmentach wzgledem wartosci minimalnych [%]
var NadmiarOdbiorcow {s in SEGMENTY} = (Odbiorcy[s] - minOdbiorcow[s])/(minOdbiorcow[s]/100);

# liczba odbiorcow ogolem [tys.]
var OdbiorcyOgolem = sum {m in MEDIA} (skut[m]*ReklamaStd[m]+skut[m]*niskaSkut*ReklamaNis[m]);

# nadmiar odbiorcow ogolem wzgledem wartosci minimalnej [%]
var NadmiarOdbiorcowOgolem = (OdbiorcyOgolem - minOdbiorcowOgolem)/(minOdbiorcowOgolem/100);

# calkowity koszt akcji reklamowej [tys.]
var Koszt = sum {m in MEDIA} cenaReklamy[m]*(ReklamaStd[m]+ReklamaNis[m]);

### funkcja celu - metoda wazenia ocen ###
maximize f_celu: zMin + (epsilon * (zOgol+ sum{s in SEGMENTY} zSegm[s] + zKoszt));

### ograniczenia ###
# ograniczenie liczby odbiorcow o pelnej skutecznosci odbioru danego medium 
subject to ogr1 {m in MEDIA}: skut[m]*ReklamaStd[m] <= progSkut;

# wartosci zmiennych decyzyjnych wieksze od 0
subject to ogr2 {s in SEGMENTY}: Odbiorcy[s] >= 0;
subject to ogr3: OdbiorcyOgolem >= 0;
subject to ogr4: Koszt >= 0;

# metoda przedzialowego punktu odniesienia
subject to ogr5: zMin <= zOgol;
subject to ogr6 {s in SEGMENTY}: zMin <= zSegm[s];
subject to ogr7: zMin <= zKoszt;

subject to ogr8: zOgol <= gamma*((NadmiarOdbiorcowOgolem-aspOdbOgol)/(aspOdbOgol-rezerwOdbOgol));
subject to ogr9: zOgol <= ((NadmiarOdbiorcowOgolem-aspOdbOgol)/(aspOdbOgol-rezerwOdbOgol));
subject to ogr10: zOgol <= beta*((NadmiarOdbiorcowOgolem-aspOdbOgol)/(aspOdbOgol-rezerwOdbOgol))+1;

subject to ogr11 {s in SEGMENTY}: zSegm[s] <= gamma*((NadmiarOdbiorcow[s]-aspOdbSgm[s])/(aspOdbSgm[s]-rezerwOdbSgm[s]));
subject to ogr12 {s in SEGMENTY}: zSegm[s] <= ((NadmiarOdbiorcow[s]-aspOdbSgm[s])/(aspOdbSgm[s]-rezerwOdbSgm[s]));
subject to ogr13 {s in SEGMENTY}: zSegm[s] <= beta*((NadmiarOdbiorcow[s]-aspOdbSgm[s])/(aspOdbSgm[s]-rezerwOdbSgm[s]))+1;

subject to ogr14: zKoszt <= gamma*((Koszt-aspKoszt)/(aspKoszt-rezerwKoszt));
subject to ogr15: zKoszt <= ((Koszt-aspKoszt)/(aspKoszt-rezerwKoszt));
subject to ogr16: zKoszt <= beta*((Koszt-aspKoszt)/(aspKoszt-rezerwKoszt))+1;

### rozwiazanie modelu w oparciu o podane dane i prezentacja wynikow ###
option solver cplex;		# przelaczenie na solver calkowitoliczbowy
data akcja_reklamowa_met_pkt_od.dat;
solve;
display epsilon, gamma, beta, aspOdbSgm, aspOdbOgol, aspKoszt, rezerwOdbOgol, rezerwOdbSgm, rezerwKoszt;
display  ReklamaStd, ReklamaNis, Odbiorcy, NadmiarOdbiorcow, OdbiorcyOgolem, NadmiarOdbiorcowOgolem, Koszt, f_celu;

