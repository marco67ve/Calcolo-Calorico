# Calcolo Calorico (CC.BAS) - L'utility dietetica per DOS

**Autore:** Marco da Venezia (marco67ve)

**Periodo di Sviluppo:** Anni '80

**Linguaggio:** Microsoft QuickBASIC

**Piattaforma Target:** MS-DOS, PC con CGA/VGA, o Windows NT/XP in console a 16 bit.

---

## Panoramica del Progetto

`CC.BAS` è un'utility snella e veloce, interamente basata su interfaccia a caratteri (console 80x25), progettata per consultare un database calorico e calcolare il totale in Kcal di un pasto, basandosi sui grammi immessi dall'utente.

Il progetto è stato realizzato con un occhio di riguardo all'**efficienza della memoria** e all'**interfaccia utente (UI)**, sfruttando al meglio le capacità del compilatore BASIC dell'epoca.

---

## Architettura e Dettagli Tecnici

Il codice è basato sul concetto di **Array Paralleli** e **Uso Ottimale della Memoria**.

### 1. Gestione dei Dati (Database)

* **Database:** I dati sono memorizzati nel file di testo **`alimenti.csv`**.
* **Struttura del Database (Array):**
    * **`Nomi$(1 TO MaxAlimenti)`:** Stringhe a lunghezza variabile per i nomi degli alimenti.
    * **`Kcal(1 TO MaxAlimenti)`:** Integer (16 bit) per le chilocalorie per 100g.
* **Allocazione Dinamica:** La Sub `ContaAlimenti` legge il file `alimenti.csv` **solo per contare** il numero di righe (`MaxAlimenti`), permettendo al programma di dimensionare gli array **esattamente una volta** (`DIM SHARED`), evitando sprechi o costose ri-allocazioni di memoria.

### 2. Funzionalità Chiave

| Componente | Descrizione | Nota Tecnica |
| :--- | :--- | :--- |
| **Ricerca** | Permette la ricerca rapida per **corrispondenza** (es. cercando "BURR" si trova "Burro..."). | Utilizzo di `INSTR(UCASE$(Nomi$(i)), cercato$)` per una ricerca efficiente e case-insensitive. |
| **Pasto** | Gli alimenti scelti sono memorizzati nell'array di tipo **`TYPE RecordScelto`** (Indice DB + Grammi). | Limite massimo di **100 alimenti** per pasto. |
| **Calcolo** | Il totale calorico finale viene calcolato e memorizzato in una variabile **`Long Integer` (`&`)** (`GrandTotal&`) per prevenire l'overflow (la saturazione a 32767 Kcal), garantendo l'accuratezza anche per pasti ad altissimo contenuto calorico. | Formula: `KcalCalcolate& = (gr / 100) * kcal100`. |
| **Report** | Generazione di un file di testo (es. `CCYYMMDD.EXT`) contenente il riepilogo del pasto e il totale. | L'estensione (`.EXT`) è calcolata sui minuti del `TIMER` per garantire un nome file unico. |
| **Interfaccia** | Uso di SUBs dedicate (`PrintRiga`, `Cornice`) per gestire colori, posizionamento (`LOCATE`) e pulizia della riga, creando un'UI professionale e coerente con lo standard VGA 80x25. |

### 3. Debug e Ottimizzazione di Memoria

* **`DEFINT A-Z`:** Tutte le variabili non dichiarate esplicitamente sono impostate come **Integer (16 bit)** per risparmiare memoria e velocizzare i calcoli, un classico trucco di ottimizzazione del BASIC.
* **`MemDebug`:** Sub integrata che usa `FRE(-2)`, `FRE("")` e `FRE(-1)` per monitorare la memoria disponibile (convenzionale, stringhe e array), cruciale per garantire la compatibilità anche su PC XT/AT con configurazioni di memoria limitate.

---

## Istruzioni per l'Utente e Sviluppatore

### Requisiti del Database (`alimenti.csv`)

Il file CSV deve avere la seguente struttura: `"Descrizione Alimento",KcalPer100g`.

**Importante:**

1.  La descrizione deve essere racchiusa tra virgolette se contiene virgole.
2.  La stringa di descrizione può essere lunga a piacere: il programma la visualizzerà tagliata automaticamente per adattarla al display 80 colonne.
3.  Le calorie (`KcalPer100g`) devono essere un numero positivo.
    * **Protezione Antierrore:** Il codice gestisce l'intervallo di sicurezza **0-999**. Se un valore è minore di 0 o maggiore di 999, viene forzato a 0 per evitare errori (guardia implementata nella Sub `CaricaDati`).

#### Esempio di Aggiunta (da Prompt dei Comandi DOS/Windows):

```bash
echo "Torta di mele di Nonna Papera, manuale delle Giovani Marmotte",231 >> alimenti.csv
```

È necessario che il file alimenti.csv sia presente nella stessa directory dell'eseguibile. Se alimenti.csv non viene trovato, il programma termina immediatamente, restituendo il controllo al DOS, anziché creare un file vuoto e confondere l'utente.
