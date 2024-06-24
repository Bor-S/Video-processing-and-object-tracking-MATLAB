clear;
% Naloži video
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

% Določi velikost iskalne okolice okoli igralca
searchAreaSize = 2 * [width, height];
center = [floor((point1(1) + point2(1)) / 2), floor((point1(2) + point2(2)) / 2)];

% Začetna nastavitev minimalne razdalje
minDistance = inf;

% Zanka čez vse frame-e v videu
for i = 1:size(video, 4)
    frame = video(:, :, :, i);
    
    % Iskanje najboljše ujemanje značilnice v okolici zadnje znane lokacije
    for j = (center(1) - searchAreaSize(1) / 2):(center(1) + searchAreaSize(1) / 2) - width
        for k = (center(2) - searchAreaSize(2) / 2):(center(2) + searchAreaSize(2) / 2) - height
            currentSection = double(imcrop(frame, [j, k, width, height]));
            distance = sqrt(sum((currentSection(:) - feature(:)).^2));

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
videoFile = VideoWriter('evklidska_razdalja.avi');
open(videoFile);
writeVideo(videoFile, video);
close(videoFile);



% Inicializacija in Nalaganje Videoposnetka: Najprej koda izvede clear za brisanje spremenljivk iz delovnega okolja, nato pa naloži videoposnetek 'squash.avi' z uporabo VideoReader objekta. S read funkcijo se prebere celoten video v spremenljivko video.
% 
% Pridobitev in Prikaz Prvega Frame-a: Koda izvleče prvi frame iz naloženega videa in ga prikaže z uporabo imshow.
% 
% Izbor Točk za Določitev Območja Igralca: Uporabnik z uporabo ginput funkcije izbere dve točki na sliki. Te točke določajo območje, na katerem se nahaja igralec (objekt, ki ga želimo slediti).
% 
% Izračun Koordinat in Dimenzij Območja Igralca: Koda izračuna koordinate in dimenzije območja igralca na podlagi izbranih točk.
% 
% Izrez Značilnice (Območja Igralca) iz Prvega Frame-a: Iz prvega frame-a se izreže območje igralca, ki se uporablja kot referenčna značilnica za sledenje.
% 
% Določitev Velikosti Iskalne Okolice: Koda določi velikost okolice, v kateri bo iskala ujemanje značilnice v naslednjih frame-ih.
% 
% Zanka za Sledenje po Vseh Frame-ih Videoposnetka: Koda izvaja zanko čez vse frame-e videoposnetka. Za vsak frame:
% 
% a. Iskanje Najboljšega Ujemanja Značilnice: Koda preišče iskalno okolico za najboljše ujemanje z referenčno značilnico, pri čemer uporabi evklidsko razdaljo za oceno ujemanja.
% 
% b. Posodobitev Lokacije Igralca: Ko je najdeno najboljše ujemanje, se posodobi lokacija igralca.
% 
% c. Označevanje Igralca na Frame-u: Na vsakem frame-u se igralec označi z rdečim pravokotnikom.
% 
% d. Ponastavitev Minimalne Razdalje: Po koncu vsake iteracije se minimalna razdalja ponastavi, pripravljena za iskanje v naslednjem frame-u.
% 
% Shranjevanje Posodobljenega Videoposnetka: Po zaključku sledenja po vseh frame-ih se posodobljeni videoposnetek shrani v novo datoteko 'evklidska_razdalja.avi'.
% 
% Ta pristop za sledenje temelji na primerjavi intenzitet pikslov med referenčno značilnico in iskalnimi okolji v posameznih frame-ih, pri čemer uporablja evklidsko razdaljo kot merilo podobnosti. To je preprosta, a učinkovita metoda za sledenje objektom v videoposnetkih, še posebej, če se objekt ne spreminja močno skozi čas in če so ozadje in svetlobni pogoji razmeroma konstantni.



