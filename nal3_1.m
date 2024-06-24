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

            % Preveri, če je velikost trenutnega odseka enaka velikosti značilnice
            if all(size(currentSection) == size(feature))
                distance = sqrt(sum((currentSection(:) - feature(:)).^2));

                % Posodobi, če je najden boljši ujemanje
                if distance < minDistance
                    minDistance = distance;
                    newCenter = [floor(j + width / 2), floor(k + height / 2)];
                    coordinates = [j, k];
                end
            end
        end
    end

    % Posodobi značilnico na novi najdeni položaj
    feature = double(imcrop(video(:, :, :, i), [coordinates(1), coordinates(2), width, height]));
    center = newCenter;
    % Označi igralca na trenutnem frame-u
    frame = insertShape(frame, 'Rectangle', [center(1) - width / 2, center(2) - height / 2, width, height], 'LineWidth', 2, 'Color', 'red');
    video(:, :, :, i) = frame;
    
    % Ponastavi minimalno razdaljo za naslednji frame
    minDistance = inf;
end

% Shranjevanje posodobljenega videa
videoFile = VideoWriter('evklidska_razdalja_sprotno_ucenje.avi');
open(videoFile);
writeVideo(videoFile, video);
close(videoFile);


% VideoReader: Ustvari objekt za branje video datoteke.
% read: Prebere celoten video in ga shrani v 4-dimenzionalno matriko, kjer prve tri dimenzije predstavljajo barvne kanale (RGB) slike, četrta dimenzija pa predstavlja zaporedje sličic (frames).
% Izbor značilnice:
% 
% imshow: Prikaže prvi frame videa, ki služi kot osnova za izbor značilnice.
% ginput: Omogoča uporabniku, da ročno izbere dve točki na sliki, ki določata območje zanimanja (npr. igralca).
% Izračuna se koordinate in dimenzije območja, ki se nato izreže iz prvega frame-a. Ta izrez služi kot referenčna značilnica za sledenje.
% Sledenje skozi video:
% 
% Algoritem prehaja skozi vsak frame videa.
% Za vsak frame se izračuna iskalno območje okoli zadnjega znanega centra značilnice, ki omogoča sledenje gibanja objekta.
% Znotraj iskalnega območja se za vsak možen izsek izračuna Evklidska razdalja do referenčne značilnice.
% Evklidska razdalja in izbor najboljšega ujemanja:
% 
% Razdalja se izračuna kot kvadratna razdalja med trenutnim izsekom in referenčno značilnico.
% Če je ta razdalja manjša od trenutno najmanjše zabeležene razdalje, se izseku dodeli novi "najboljši" status, in njegove koordinate postanejo novi center značilnice.
% Posodabljanje značilnice in označevanje:
% 
% Po najdbi najboljšega ujemanja se značilnica posodobi z izsekom iz trenutnega frame-a.
% Na frame-u se nato označi položaj igralca z vstavljanjem pravokotnika.
% Shranjevanje posodobljenega videa:
% 
% Po končanem sledenju se video s sledilnimi označbami shrani v novo datoteko z uporabo VideoWriter.
% Ta algoritem sledenja je primeren za situacije, kjer je mogoče objekt sledenja razmeroma natančno izolirati na začetku. Metoda sprotnega učenja, ki posodablja referenčno značilnico na vsakem frame-u, omogoča prilagajanje na spremembe v videzu in položaju objekta. Kljub temu pa obstaja tveganje, da algoritem "izgubi" sled objekta v primeru prevelikih sprememb ali okluzij.
