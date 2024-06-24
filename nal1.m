% Naloži video
videoObj = VideoReader('Holywood.avi');

% Definiraj različne metode interpolacije
methods = {'nearest', 'bilinear_noAA', 'bilinear_AA'};

% Zanka čez metode interpolacije
for m = 1:length(methods)
    % Ponovno preberi video za vsako metodo interpolacije
    videoObj = VideoReader('Holywood.avi');

    % Ustvari nov VideoWriter objekt za shranjevanje pomanjšanega videa za faktor 1/2
    outputVideo = VideoWriter(['output_' methods{m} '_0.5.avi']);
    open(outputVideo);

    % Zanka čez vsak frame v originalnem videu
    while hasFrame(videoObj)
        frame = readFrame(videoObj);

        % Pomanjšaj frame za faktor 1/2
        if strcmp(methods{m}, 'bilinear_AA')
            % Bilinearna interpolacija z antialiasingom
            resizedFrame = imresize(frame, 1/2, 'bilinear', 'Antialiasing', true);
        elseif strcmp(methods{m}, 'bilinear_noAA')
            % Bilinearna interpolacija brez antialiasinga
            resizedFrame = imresize(frame, 1/2, 'bilinear', 'Antialiasing', false);
        else
            % Najbližji sosed
            resizedFrame = imresize(frame, 1/2, 'nearest');
        end

        % Zapiši pomanjšani frame
        writeVideo(outputVideo, resizedFrame);
    end

    % Zapri VideoWriter objekt
    close(outputVideo);
end


% Najbližji Sosed (Nearest Neighbor):
% Ta metoda izbere najbližjo sosednjo vrednost piksla v izvirnem videu za vsak piksel v pomanjšanem videu.
% Rezultat je pogosto bolj "zrnata" ali "kvadratna" slika, saj metoda ne upošteva glajenja med sosednjimi piksli.
% Pričakujemo lahko, da bo video, pomanjšan z metodo najbližjega soseda, imel vidne pixele in manj gladke prehode.
% 
% Bilinearna Interpolacija Brez Antialiasinga:
% Bilinearna interpolacija izračuna vrednost novega piksla kot ponderirano povprečje štirih najbližjih pikslov v izvirnem videu.
% Ta metoda ustvarja bolj gladke slike kot najbližji sosed, vendar lahko brez antialiasinga še vedno povzroči nekaj zamegljenosti in artefaktov.
% Video, pomanjšan z bilinarno interpolacijo brez antialiasinga, bo imel bolj gladke robove in prehode, vendar morda ne bo popolnoma jasen.
% 
% Bilinearna Interpolacija z Antialiasingom:
% Podobno kot zgoraj, vendar ta metoda vključuje dodatno tehniko antialiasinga, ki zmanjšuje vizualne artefakte, kot so "stopničasti" robovi (aliasing).
% Antialiasing pomaga pri glajenju robov in izboljšanju splošne kakovosti slike, še posebej pri pomanjšanih slikah.
% Video, pomanjšan z bilinarno interpolacijo z antialiasingom, bo verjetno imel najboljšo kakovost med tremi metodami, z gladkimi robovi in manj opaznimi artefakti.
% V končni analizi, pričakujemo, da bo video, pomanjšan z metodo najbližjega soseda, najmanj gladek in natančen, medtem ko bo video, pomanjšan z bilinarno interpolacijo z antialiasingom, najbolj gladek in s kakovostnimi detajli. Bilinearna interpolacija brez antialiasinga bo verjetno nekje vmes glede na kakovost in gladkost.



% Nalaganje Videoposnetka: Najprej koda naloži videoposnetek 'Holywood.avi' z uporabo VideoReader objekta. Ta objekt omogoča nadaljnje branje posameznih slik (frames) iz videoposnetka.
% 
% Definicija Metod Interpolacije: Nato definira seznam methods, ki vsebuje tri različne metode interpolacije: 'nearest' (najbližji sosed), 'bilinear_noAA' (bilinearna interpolacija brez antialiasinga) in 'bilinear_AA' (bilinearna interpolacija z antialiasingom).
% 
% Zanka po Metodah Interpolacije: Koda nato izvaja zanko, ki se zaporedoma izvaja za vsako metodo interpolacije.
% 
% a. Branje Videoposnetka za vsako Metodo: Za vsako metodo interpolacije se videoposnetek ponovno naloži z ustvarjanjem novega VideoReader objekta. To je potrebno, ker po branju vseh slik videoposnetka ni mogoče ponovno brati od začetka brez ponovne inicializacije VideoReader objekta.
% 
% b. Ustvarjanje Objekta za Pisanje Videoposnetka: Koda ustvari objekt VideoWriter za shranjevanje rezultatov. Ime datoteke za izhod vsebuje ime metode interpolacije in faktor pomanjšanja (v tem primeru 0.5, kar pomeni pomanjšanje za polovico).
% 
% c. Zanka po Slikah (Frames) Originalnega Videoposnetka: Za vsak frame izvaja naslednje korake:
% - Branje Frame: Prebere trenutni frame iz originalnega videoposnetka.
% - Pomanjšanje Frame: Odvisno od izbrane metode interpolacije se izvede pomanjšanje frame-a za faktor 1/2. Pri 'bilinear_AA' se uporabi bilinearna interpolacija z antialiasingom, pri 'bilinear_noAA' bilinearna interpolacija brez antialiasinga in pri 'nearest' metoda najbližjega soseda.
% - Zapisovanje Pomanjšanega Frame-a: Pomanjšani frame se zapiše v izhodni videoposnetek.
% 
% Zaključek Pisanja Videoposnetka: Po zaključku zanke po vseh slikah se izhodni videoposnetek zapre z close(outputVideo).
% 
% Koda torej ustvari tri različne verzije originalnega videoposnetka, vsako pomanjšano z različno metodo interpolacije, kar omogoča primerjavo kvalitete pomanjšanja med različnimi metodami.
% 
