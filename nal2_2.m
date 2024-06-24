clear;
videoObj = VideoReader("squash.avi");
video = read(videoObj, [1 Inf]);  % Preberi celoten video

% Pridobi prvi frame iz videa in ga prikaži
firstFrame = video(:, :, :, 1);
imshow(firstFrame);

% Uporabnik izbere dve točki na sliki za določitev območja igralca
point1 = ginput(1);
point2 = ginput(1);
close;

% Izračunaj koordinate in dimenzije območja igralca
x = min(point1(1), point2(1));
y = min(point1(2), point2(2));
width = abs(point1(1) - point2(1));
height = abs(point1(2) - point2(2));

% Izreži značilnico (območje igralca) iz prvega framea
feature = double(imcrop(firstFrame, [x, y, width, height]));

% Določi število binov za histogram
numBins = 8;
% Izračunaj histogram značilnice
featureHistogram = histcounts(feature, numBins, 'Normalization', 'probability');

% Določi velikost iskalne okolice okoli igralca
searchAreaSize = 2 * [width, height];
center = [floor((point1(1) + point2(1)) / 2), floor((point1(2) + point2(2)) / 2)];

% Začetna nastavitev minimalne razdalje
minDistance = inf;

% Zanka čez vse frame-e v videu
for i = 1:size(video, 4)
    frame = video(:, :, :, i);
    
    % Iskanje najboljše ujemanje histograma v okolici zadnje znane lokacije
    for j = (center(1) - searchAreaSize(1) / 2):(center(1) + searchAreaSize(1) / 2) - width
        for k = (center(2) - searchAreaSize(2) / 2):(center(2) + searchAreaSize(2) / 2) - height
            currentSection = double(imcrop(frame, [j, k, width, height]));
            sectionHistogram = histcounts(currentSection, numBins, 'Normalization', 'probability');
            
            % Izračunaj razdaljo med histogramoma
            distance = sum((sectionHistogram(:) - featureHistogram(:)).^2);

            % Posodobi, če je najden boljši ujemanje
            if distance < minDistance
                minDistance = distance;
                newCenter = [floor(j + width / 2), floor(k + height / 2)];
            end
        end
    end

    % Posodobi center značilnice na novi najdeni položaj
    center = newCenter;
    
    % Označi igralca na trenutnem frame-u
    frame = insertShape(frame, 'Rectangle', [center(1) - width / 2, center(2) - height / 2, width, height], 'LineWidth', 2, 'Color', 'red');
    video(:, :, :, i) = frame;
    
    % Ponastavi minimalno razdaljo za naslednji frame
    minDistance = inf;
end

% Shranjevanje posodobljenega videa
videoFile = VideoWriter('mera_podobnosti.avi');
open(videoFile);
writeVideo(videoFile, video);
close(videoFile);

% 
% Inicializacija in Nalaganje Videoposnetka:
% 
% clear: Odstrani vse spremenljivke iz delovnega okolja.
% VideoReader: Ustvari objekt za branje videoposnetka 'squash.avi'.
% read: Prebere celoten videoposnetek v spremenljivko video.
% Pridobivanje in Prikaz Prvega Frame-a:
% 
% video(:, :, :, 1): Izlušči prvi frame iz naloženega videa.
% imshow: Prikazuje prvi frame, ki bo uporabljen za izbiro značilnice.
% Izbira Območja za Sledenje z Uporabniškim Vnosom:
% 
% ginput: Dobi dve točki, ki jih izbere uporabnik, za določitev območja sledenja (običajno je to območje, kjer se nahaja objekt - igralec).
% Izračun Območja in Izrez Značilnice:
% 
% Izračuna koordinate in dimenzije območja igralca.
% imcrop: Izreže območje igralca iz prvega frame-a za uporabo kot referenčno značilnico.
% Histogramska Analiza Značilnice:
% 
% Določi število binov za histogram (numBins).
% histcounts: Izračuna histogram značilnice z normalizacijo na verjetnostno porazdelitev.
% Določitev Velikosti Iskalne Okolice in Sledenje:
% 
% Določi velikost iskalne okolice okrog igralca.
% Začne zanko čez vse frame-e videa, pri čemer za vsak frame:
% Izračuna histogram za trenutno iskano območje.
% Primerja histogram trenutnega območja s histogramom referenčne značilnice.
% Uporabi kvadrat evklidske razdalje med histogrami kot mero podobnosti.
% Posodobi lokacijo igralca, če je najdeno boljše ujemanje.
% Označevanje in Posodobitev Frame-ov:
% 
% Na vsakem frame-u, kjer je najden objekt, označi igralca z rdečim pravokotnikom.
% Posodobi video s temi označenimi frame-i.
% Shranjevanje Končnega Videoposnetka:
% 
% Ustvari nov VideoWriter objekt.
% Shranjuje posodobljeni videoposnetek v novo datoteko 'mera_podobnosti.avi'.
% Uporaba histograma za sledenje temelji na ideji, da čeprav se lahko položaj objekta spremeni, njegova barvna distribucija ostaja relativno konstantna. Ta metoda je koristna v scenarijih, kjer objekt ni preveč deformiran ali zakrit in kjer osvetlitev ostaja dokaj konstantna. Histogramska primerjava omogoča določeno mero robustnosti proti spremembam v osvetlitvi in perspektivi.
% 


