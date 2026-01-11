# Baietii_din_ultima_banca-1
Proiect ASC realizat de Baietii din ultima banca: Rosiu Darius, Alin Silaghi si Sebastian Simion


DOCUMENTAȚIE PROIECT ASSEMBLY (8086) 

Tema: Manipularea unui șir de octeți și operații bitwise 

 Echipa: Rosiu Darius, SIlaghi Alin, Simion Sebastian 

Acest program este dezvoltat în limbaj de asamblare pentru procesorul 8086 și rulează în mediul DOSBox. Scopul proiectului este procesarea unui șir de date (8-16 octeți) introdus de utilizator în format hexazecimal. Programul execută conversii, calcule matematice și logice pe biți, sortări de memorie și transformări circulare, afișând rezultatele într-un mod interactiv. 

Organizarea Echipei și Contribuții: 

Proiectul a fost realizat colaborativ, utilizând GitHub pentru gestionarea versiunilor prin branch-uri și Pull Requests. 

Student 1 (Darius) - Pasul 1: 

Implementarea interfeței de citire (funcția 0Ah a INT 21h). 

Realizarea subrutinei de conversie ASCII-Hex în valoare binară. 

Calculul cuvântului de control C pe 16 biți (operații XOR, OR și suma modulo 256). 

 

Student 2 (Alin) - Pasul 2: 

Implementarea algoritmului de sortare descrescătoare (Bubble Sort). 

Logica de determinare a octetului cu număr maxim de biți de 1 și afișarea poziției acestuia. 

 

Student 3 (Sebi) - Pasul 3: 

Calculul valorii de rotire N bazat pe primii doi biți ai fiecărui octet. 

Implementarea rotirii circulare la stânga. 

Subrutinele de afișare finală a șirului procesat în formatele Hexazecimal și Binar. 

 

Programul utilizează segmentarea memoriei (.DATA, .CODE, .STACK) și setul de instrucțiuni 8086. 

Conversia datelor: Se face prin scăderea valorii ASCII corespunzătoare ('0' pentru cifre sau '7' pentru literele A-F). 

Calculul C: S-au utilizat instrucțiuni de deplasare (SHR, SHL) și măști logice (AND) pentru a izola grupurile de biți cerute. 

Sortarea: S-a ales Bubble Sort pentru simplitatea implementării în Assembly folosind registrele SI și DI. 

Rotirea: S-a folosit instrucțiunea ROL (Rotate Left) cu registrul CL pentru un număr variabil de poziții. 

Prin acest proiect, am aprofundat lucrul cu registrele procesorului, manipularea biților la nivel hardware și colaborarea prin Git. Programul îndeplinește toate cerințele funcționale și oferă o interfață clară pentru utilizator. 

 

 

 
