FailSafe IT

Jag gjorde databasen för att hålla koll på vilka konsulter som jobbar åt vilka kunder och vad deras uppdrag går ut på. Varje uppdrag hör till en kund och en konsult. Både kunder och konsulter kan ha flera uppdrag.

ER-diagrammet finns som en separat bild i repot och heter ER-diagram.png.

Vill du testa databasen öppnar du FailSafeIT - klar.sql i SSMS och kör hela filen mot LocalDB. Skriptet bygger upp testdatabasen FailSafeIT från början, lägger in testdata och kör frågorna A–E. Om testdatabasen redan finns ersätts den. Fråga C visar hur många uppdrag som pågår just den dag du kör skriptet.

Normalisering
1NF: Varje cell har ett värde. I Kund ligger till exempel mejladress och telefonnummer i varsin kolumn. Om en kund har flera uppdrag får varje uppdrag en egen rad.
2NF: Varje tabell har ett ID som primärnyckel: KundID, KonsultID eller UppdragID. Varje nyckel består av en enda kolumn. Därför finns det ingen del av nyckeln som ett annat fält kan bero på för sig.
3NF: Jag sparar kundens uppgifter i Kund och konsultens uppgifter i Konsult. I Uppdrag sparar jag deras ID:n tillsammans med det som gäller jobbet, som datum och rollbeskrivning. Om en kund byter företagsnamn behöver jag bara ändra det på ett ställe.
