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

% Izračunaj histogram značilnice za vsak barvni kanal
featureHistogramR = histcounts(feature(:, :, 1), numBins, 'Normalization', 'probability');
featureHistogramG = histcounts(feature(:, :, 2), numBins, 'Normalization', 'probability');
featureHistogramB = histcounts(feature(:, :, 3), numBins, 'Normalization', 'probability');
% Združi histograma v en sam vektor
featureHistogram = [featureHistogramR, featureHistogramG, featureHistogramB];


% Določi velikost iskalne okolice okoli igralca
searchAreaSize = 2 * [width, height];
center = [floor((point1(1) + point2(1)) / 2), floor((point1(2) + point2(2)) / 2)];

% Začetna nastavitev minimalne razdalje
minDistance = inf;

% Zanka čez vse frame-e v videu
for i = 1:size(video, 4)
    frame = video(:, :, :, i);
    
    for j = (center(1) - searchAreaSize(1) / 2):(center(1) + searchAreaSize(1) / 2) - width
        for k = (center(2) - searchAreaSize(2) / 2):(center(2) + searchAreaSize(2) / 2) - height
            currentSection = double(imcrop(frame, [j, k, width, height]));
            % Izračunaj histogram za vsak barvni kanal
            sectionHistogramR = histcounts(currentSection(:, :, 1), numBins, 'Normalization', 'probability');
            sectionHistogramG = histcounts(currentSection(:, :, 2), numBins, 'Normalization', 'probability');
            sectionHistogramB = histcounts(currentSection(:, :, 3), numBins, 'Normalization', 'probability');
            % Združi histograma v en sam vektor
            sectionHistogram = [sectionHistogramR, sectionHistogramG, sectionHistogramB];
            
            % Izračunaj razdaljo med histogramoma
            distance = sum((sectionHistogram - featureHistogram).^2);
            
            % Posodobi, če je najden boljši ujemanje
            if distance < minDistance
                minDistance = distance;
                newCenter = [floor(j + width / 2), floor(k + height / 2)];
                coordinates = [j, k];
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
videoFile = VideoWriter('mera_podobnosti_sprotno_ucenje.avi');
open(videoFile);
writeVideo(videoFile, video);
close(videoFile);



% Naložitev in priprava videa:
% 
% VideoReader: Ustvari objekt VideoReader, ki omogoča branje video datoteke.
% read: Prebere vse sličice (frames) iz video datoteke in jih shrani v spremenljivko video. Vsaka sličica je 4-dimenzionalno polje, kjer so prve tri dimenzije RGB barvne komponente sličice, četrta dimenzija pa predstavlja zaporedje sličic.
% Izbira značilnice:
% 
% Uporabnik izbere dva klika na prvem frame-u videa za določitev območja (pravokotnika), ki predstavlja objekt sledenja (npr. igralec).
% Na podlagi izbranih točk se izračunajo koordinate in dimenzije območja.
% Ta območje se nato izreže iz prve sličice in shrani kot feature - referenčna značilnica, ki se bo uporabljala za sledenje.
% Histogram značilnice:
% 
% Zgradi se histogram barv referenčne značilnice feature, ki zajema razporeditev barvnih vrednosti znotraj izbranega območja.
% Histogram je 3-dimenzionalno polje, ki predstavlja porazdelitev intenzitet barv v območju RGB.
% Sledenje skozi video:
% 
% Koda prehaja skozi vsako sličico videa.
% Za vsako sličico se določi iskalno območje (searchAreaSize) okoli trenutnega centra značilnice, kar omogoča, da se iskanje osredotoči na verjetno lokacijo objekta na naslednji sličici.
% Znotraj iskalnega območja se za vsak potencialni izsek izračuna histogram in se primerja s histogramom referenčne značilnice.
% Merilo za primerjavo je kvadrat razlike med histogramoma, ki daje oceno podobnosti izseka z referenčno značilnico.
% Posodobitev lokacije in označevanje:
% 
% Ko je najden izsek z najmanjšo razdaljo (največjo podobnostjo), se njegove koordinate shranijo kot novi center značilnice.
% Na trenutni sličici se nato označi najdeni objekt, da lahko vidno sledimo gibanju skozi video.
% Shranjevanje posodobljenega videa:
% 
% Po končanem sledenju se video s sledilnimi označbami shrani v novo datoteko.
% Ključni del kode je uporaba barvnih histogramov kot metoda za primerjavo podobnosti med izbranim območjem na prvi sličici in potencialnimi območji na naslednjih sličicah. Ta metoda omogoča sledenje objektu skozi čas, kljub morebitnim manjšim spremembam v videzu ali gibanju.
