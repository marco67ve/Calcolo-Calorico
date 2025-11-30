' CC.BAS - Calcolo Calorico dei pasti
' by Marco da Venezia, 1989
' Compilare con QuickBASIC (pref. AT con HD)

DEFINT A-Z

DECLARE SUB MemDebug ()
DECLARE SUB CaricaDati (MaxAlimenti)
DECLARE SUB ContaAlimenti (MaxAlimenti)
DECLARE SUB ClsPag ()
DECLARE SUB Cornice (r1, r2, c1, c2, testo, sfondo, titolo$)
DECLARE SUB PrintRiga (riga, col, cursore, testo, sfondo, messaggio$)
DECLARE SUB EditLine (edit$, nCaratteri, car1, car2)
DECLARE SUB Promemoria ()
DECLARE SUB Uscita ()

REM $DYNAMIC ' Forza array a dinamici (utile per la memoria in QB)

DIM SHARED MaxAlimenti AS INTEGER
DIM SHARED TotaleLista AS INTEGER

ContaAlimenti MaxAlimenti

' Array paralleli alimenti
DIM SHARED Nomi$(1 TO MaxAlimenti) ' Stringhe a lunghezza variabile
DIM SHARED Kcal(1 TO MaxAlimenti)

' Lista pasto
TYPE RecordScelto
	IndiceDB AS INTEGER
	Grammi AS INTEGER
END TYPE

DIM SHARED Lista(1 TO 100) AS RecordScelto

' --- MAIN ---
Promemoria

CaricaDati MaxAlimenti

' Ricerca
DO
	PrintRiga 24, 2, 1, 14, 1, "Immetti nome alimento (parziale) o nulla per calcolare il totale: "
	EditLine cercato$, 10, 65, 90
	IF cercato$ = "" THEN EXIT DO
	Trovati = 0: primo = 0: ultimo = 0
	PrintRiga 2, 2, 0, 14, 1, "ID   ALIMENTO" + SPACE$(62) + "Cal" + CHR$(13)
	ClsPag
	PrintRiga 3, 7, 1, 11, 1, cercato$ + "... "
	FOR i = 1 TO MaxAlimenti
		IF INSTR(UCASE$(Nomi$(i)), cercato$) THEN
			IF CSRLIN > 23 THEN
				PrintRiga 24, 2, 1, 14, 1, "Premi ENTER per continuare o ESC per immettere ID alimento "
				k$ = INPUT$(1)
				IF k$ = CHR$(27) THEN EXIT FOR ELSE ClsPag
			END IF
			PrintRiga CSRLIN, 2, 0, 13, 1, LTRIM$(STR$(i))
			PrintRiga CSRLIN, 7, 0, 11, 1, LEFT$(Nomi$(i), 69)
			PrintRiga CSRLIN, 80 - LEN(STR$(Kcal(i))), 0, 10, 1, STR$(Kcal(i)) + CHR$(13)
			Trovati = Trovati + 1
			IF primo = 0 THEN primo = i
			ultimo = i
		END IF
	NEXT i
	IF Trovati = 0 THEN
		PrintRiga 24, 2, 1, 14, 1, "Alimento " + cercato$ + " non presente. Premi un tasto per continuare "
		k$ = INPUT$(1)
	ELSE
		id1$ = LTRIM$(STR$(primo))
		id2$ = LTRIM$(STR$(ultimo))
		PrintRiga 24, 2, 1, 14, 1, "Immetti l'ID (" + id1$ + "ö" + id2$ + ") o nulla per saltare: "
		EditLine scelta$, LEN(STR$(ultimo)) - 1, 48, 57
		scelta = VAL(scelta$)
		IF scelta >= primo AND scelta <= ultimo THEN
			PrintRiga 24, POS(0) + 1, 1, 14, 1, "- Quanti grammi? "
			EditLine gr$, 4, 48, 57
			gr = VAL(gr$)
			IF gr THEN
				TotaleLista = TotaleLista + 1
				Lista(TotaleLista).IndiceDB = scelta
				Lista(TotaleLista).Grammi = gr
				IF TotaleLista = 100 THEN EXIT DO
			END IF
		END IF
	END IF
LOOP

' --- RIEPILOGO
Cornice 1, 25, 1, 79, 15, 1, " CALORIE DEL PASTO "
PrintRiga 2, 2, 0, 14, 1, "ALIMENTO" + SPACE$(59) + "GRAMMI  Cal" + CHR$(13)
' preparazione file rapporto
mm$ = LEFT$(DATE$, 2)
gg$ = MID$(DATE$, 4, 2)
aa$ = RIGHT$(DATE$, 2)
ex$ = MID$(STR$(TIMER \ 60), 2, 3)' estensione in minuti
File$ = "CC" + aa$ + mm$ + gg$ + "." + ex$
OPEN File$ FOR OUTPUT AS #1
PRINT #1, "Pasto del "; gg$; "/"; mm$; "/"; aa$; USING "##:##"; VAL(ex$) \ 60; VAL(ex$) MOD 60
PRINT #1, "ALIMENTO"; TAB(70); "GRAMMI  Cal"

GrandTotal& = 0
FOR i = 1 TO TotaleLista
	idx = Lista(i).IndiceDB
	gr = Lista(i).Grammi
	kcal100 = Kcal(idx)
	KcalCalcolate& = (gr / 100) * kcal100
	GrandTotal& = GrandTotal& + KcalCalcolate&
	IF CSRLIN > 23 THEN
		PrintRiga 24, 2, 1, 14, 1, "Continua "
		k$ = INPUT$(1)
		ClsPag
	END IF
	PrintRiga CSRLIN, 2, 0, 11, 1, LEFT$(Nomi$(idx), 68)
	PrintRiga CSRLIN, 74 - LEN(STR$(gr)), 0, 11, 1, STR$(gr)
	PrintRiga CSRLIN, 80 - LEN(STR$(KcalCalcolate&)), 0, 10, 1, STR$(KcalCalcolate&) + CHR$(13)
	PRINT #1, LEFT$(Nomi$(idx), 68); TAB(75 - LEN(STR$(gr))); STR$(gr); TAB(81 - LEN(STR$(KcalCalcolate&))); STR$(KcalCalcolate&)
NEXT i

PrintRiga CSRLIN, 2, 0, 10, 1, "Totale Calorie:" + STR$(GrandTotal&) + " - File: " + File$
PRINT #1, "Totale Calorie:"; GrandTotal&

Uscita

REM $STATIC
SUB CaricaDati (MaxAlimenti)
		LOCATE 4, 3: MemDebug ' demarcare per debug
	PrintRiga 2, 2, 1, 14, 1, "Caricamento dati "
	OPEN "alimenti.csv" FOR INPUT AS #1
	FOR i = 1 TO MaxAlimenti
		INPUT #1, TempNome$, TempKcal
		Nomi$(i) = TempNome$
		IF TempKcal < 0 OR TempKcal > 999 THEN TempKcal = 0
		Kcal(i) = TempKcal
	NEXT
	CLOSE #1
	PrintRiga 2, 2, 1, 14, 1, "Alimenti caricati:" + STR$(MaxAlimenti)
		LOCATE 5, 3: MemDebug ' demarcare per debug
END SUB

SUB ClsPag
	FOR i = 23 TO 3 STEP -1
		PrintRiga i, 2, 0, 7, 1, SPACE$(78)
	NEXT
END SUB

SUB ContaAlimenti (MaxAlimenti)
	OPEN "alimenti.csv" FOR INPUT AS #1
	Cornice 1, 25, 1, 79, 15, 1, " CALCOLO CALORICO "
	PrintRiga 2, 2, 1, 14, 1, "Lettura database "
	DO UNTIL EOF(1)
		MaxAlimenti = MaxAlimenti + 1
		LINE INPUT #1, alimento$
	LOOP
	CLOSE #1
END SUB

REM $DYNAMIC
SUB Cornice (r1, r2, c1, c2, testo, sfondo, titolo$)
	COLOR testo, sfondo
	FOR i = r1 TO r2
		car$ = CHR$(32): vs$ = CHR$(186): vd$ = vs$
		SELECT CASE i
			CASE r1
				car$ = CHR$(205): vs$ = CHR$(201): vd$ = CHR$(187)
			CASE r2
				car$ = CHR$(205): vs$ = CHR$(200): vd$ = CHR$(188)
		END SELECT
		LOCATE i, c1, 0: PRINT vs$ + STRING$(c2 - c1, car$) + vd$;
	NEXT
	LOCATE r1, 1 + c1 + (c2 - c1 - LEN(titolo$)) \ 2: PRINT titolo$
END SUB

SUB EditLine (edit$, nCaratteri, car1, car2)
	edit$ = ""
	LOCATE , , 1
	DO
		k$ = UCASE$(INKEY$)
		IF k$ = CHR$(13) THEN EXIT DO
		IF k$ = CHR$(8) THEN
			IF LEN(edit$) THEN
				edit$ = LEFT$(edit$, LEN(edit$) - 1)
				LOCATE , POS(0) - 1: PRINT CHR$(32);
				LOCATE , POS(0) - 1
			END IF
		END IF
		IF LEN(edit$) < nCaratteri AND k$ >= CHR$(car1) AND k$ <= CHR$(car2) THEN
			edit$ = edit$ + k$
			PRINT k$;
		END IF
	LOOP
END SUB

REM $STATIC
SUB MemDebug
	COLOR 1, 7
	PRINT USING " Memoria libera: ###### - Spazio stringhe: ###### - Array numerici: ######  "; FRE(-1); FRE(""); FRE(-2);
END SUB

REM $DYNAMIC
SUB PrintRiga (riga, col, cursore, testo, sfondo, messaggio$)
	COLOR testo, sfondo
	LOCATE riga, col, cursore: PRINT SPACE$(80 - col);
	LOCATE riga, col: PRINT messaggio$;
END SUB

REM $STATIC
SUB Promemoria
	OPEN "cc.mem" FOR APPEND AS #1: CLOSE
	OPEN "cc.mem" FOR INPUT AS #1
	IF LOF(1) THEN
		Cornice 7, 22, 4, 76, 0, 3, " Istruzioni rapide "
		WHILE NOT EOF(1)
			LINE INPUT #1, a$
			LOCATE , 5: PRINT a$
		WEND
	END IF
	CLOSE #1
END SUB

SUB Uscita
	PrintRiga 24, 2, 1, 14, 1, "Premi un tasto per uscire "
	k$ = INPUT$(1)
	COLOR 7, 0
	CLS
	END
END SUB


