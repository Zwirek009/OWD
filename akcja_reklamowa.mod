# parametry
set SEGMENTY;							# segmenty rynku
set MEDIA;								# media reklamowe
param progSkutecznosci;					# liczba odbiorcow (w tys.), po przekroczeniu ktorej spada skutecznosc
param wartoscNiskiejSkutecznosci;		# czesc skutecznosci po przekroczeniu progu
param minOdbiorcowOgolem;				# minimalna liczba odbiorcow ogolem [tys.]
param minOdbiorcow {SEGMENTY};			# minimalna liczba odbiorcow w danych segmentach [tys.]
param cenaReklamy {MEDIA};				# cena jednostki reklamowej w danych mediach [tys. zl]
param udzialy {MEDIA, SEGMENTY};		# udzialy poszczegolnych segmentow rynku w ogolnej liczbie odbiorcow

# zmienne decyzyjne
var ReklamaStd {m in MEDIA} >= 0, integer;	# liczba kupionych jednostek reklamy standardowej skutecznosci 
var ReklamaNis {m in MEDIA} >= 0, integer;	# liczba kupionych jednostek reklamy niskiej skutecznosci

var Odbiorcy {s in SEGMENTY} >=0, integer;	# liczba odbiorcow [tys.]

# funkcja celu
minimize koszt: sum {m in MEDIA} cenaReklamy[m]*(ReklamaStd[m]+ReklamaNis[m]);

# ograniczenia
subject to ogr1 {s in SEGMENTY}: Odbiorcy[s]>=minOdbiorcow[s];

# przelaczenie na solver calkowitoliczbowy
option solver cplex;

