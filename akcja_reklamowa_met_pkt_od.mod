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

param minKosztCelu;

### przedzialowa metoda punktu odniesienia ###
param epsilon;	# arbitralnie mala stala dodatnia
param gamma;	# niezadowolenie uzytkownika z nieosiagniecia poziomu rezerwacji
param beta;		# dodatkowe zwiekszenie zadowolenia uzytkownika ponad poziom aspiracji

param aspiracjaOdbOgol;
param aspiracjaOdbSgm {s in SEGMENTY};
param aspiracjaKoszt;

param rezerwacjaOdbOgol;
param rezerwacjaOdbSgm {s in SEGMENTY};
param rezerwacjaKoszt;

var z_ogol;
var z_segm {s in SEGMENTY};
var z_koszt;

var z_min;

### zmienne pomocnicze ###
var ReklamaStd {m in MEDIA} >= 0, integer;	# liczba kupionych jednostek reklamy standardowej skutecznosci 
var ReklamaNis {m in MEDIA} >= 0, integer;	# liczba kupionych jednostek reklamy niskiej skutecznosci

### zmienne decyzyjne ###
# liczba odbiorcow w segmentach [tys.]
var Odbiorcy {s in SEGMENTY} = sum {m in MEDIA} udzialy[m,s]/100*(skutecznosc[m]*ReklamaStd[m]+skutecznosc[m]*wartoscNiskiejSkutecznosci*ReklamaNis[m]);

# nadmiar odbiorcow w segmentach wzgledem wartosci minimalnych [%]
var NadmiarOdbiorcow {s in SEGMENTY} = (Odbiorcy[s] - minOdbiorcow[s])/(minOdbiorcow[s]/100);

# liczba odbiorcow ogolem [tys.]
var OdbiorcyOgolem = sum {m in MEDIA} (skutecznosc[m]*ReklamaStd[m]+skutecznosc[m]*wartoscNiskiejSkutecznosci*ReklamaNis[m]);

# nadmiar odbiorcow ogolem wzgledem wartosci minimalnej [%]
var NadmiarOdbiorcowOgolem = (OdbiorcyOgolem - minOdbiorcowOgolem)/(minOdbiorcowOgolem/100);

# calkowity koszt akcji reklamowej [tys.]
var Koszt = sum {m in MEDIA} cenaReklamy[m]*(ReklamaStd[m]+ReklamaNis[m]);

# nadmiar wzgledem minimalnego kosztu spelniajacego ograniczenia zadania [%]
var NadmiarKosztu = (minKosztCelu - Koszt)/(minKosztCelu/100);

### funkcja celu - metoda wazenia ocen ###
maximize f_celu: z_min + (epsilon * (z_ogol+ sum{s in SEGMENTY} z_segm[s] + z_koszt));

### ograniczenia ###
# ograniczenie liczby odbiorcow o pelnej skutecznosci odbioru danego medium 
subject to ogr1 {m in MEDIA}: skutecznosc[m]*ReklamaStd[m] <= progSkutecznosci;

# wartosci zmiennych decyzyjnych wieksze od 0
subject to ogr2 {s in SEGMENTY}: Odbiorcy[s] >= 0;
subject to ogr3: OdbiorcyOgolem >= 0;
subject to ogr4: Koszt >= 0;

# metoda przedzialowego punktu odniesienia
subject to ogr5: z_min <= z_ogol;
subject to ogr6 {s in SEGMENTY}: z_min <= z_segm[s];
subject to ogr7: z_min <= z_koszt;

subject to ogr8: z_ogol <= gamma*((NadmiarOdbiorcowOgolem-aspiracjaOdbOgol)/(aspiracjaOdbOgol-rezerwacjaOdbOgol));
subject to ogr9: z_ogol <= ((NadmiarOdbiorcowOgolem-aspiracjaOdbOgol)/(aspiracjaOdbOgol-rezerwacjaOdbOgol));
subject to ogr10: z_ogol <= beta*((NadmiarOdbiorcowOgolem-aspiracjaOdbOgol)/(aspiracjaOdbOgol-rezerwacjaOdbOgol))+1;

subject to ogr11 {s in SEGMENTY}: z_segm[s] <= gamma*((NadmiarOdbiorcow[s]-aspiracjaOdbSgm[s])/(aspiracjaOdbSgm[s]-rezerwacjaOdbSgm[s]));
subject to ogr12 {s in SEGMENTY}: z_segm[s] <= ((NadmiarOdbiorcow[s]-aspiracjaOdbSgm[s])/(aspiracjaOdbSgm[s]-rezerwacjaOdbSgm[s]));
subject to ogr13 {s in SEGMENTY}: z_segm[s] <= beta*((NadmiarOdbiorcow[s]-aspiracjaOdbSgm[s])/(aspiracjaOdbSgm[s]-rezerwacjaOdbSgm[s]))+1;

subject to ogr14: z_koszt <= gamma*((Koszt-aspiracjaKoszt)/(aspiracjaKoszt-rezerwacjaKoszt));
subject to ogr15: z_koszt <= ((Koszt-aspiracjaKoszt)/(aspiracjaKoszt-rezerwacjaKoszt));
subject to ogr16: z_koszt <= beta*((Koszt-aspiracjaKoszt)/(aspiracjaKoszt-rezerwacjaKoszt))+1;

### rozwi¹zanie modelu w oparciu o podane dane i prezentacja wynikow ###
option solver cplex;		# przelaczenie na solver calkowitoliczbowy
data akcja_reklamowa_met_pkt_od.dat;
solve;
display ReklamaStd, ReklamaNis, Odbiorcy, NadmiarOdbiorcow, OdbiorcyOgolem, NadmiarOdbiorcowOgolem, Koszt, NadmiarKosztu, f_celu;

