%% Czyszczenie workspace
clc;
clear all;
close ALL;

%% Wczytanie obrazu
im = imread('4.PNG');
[H,L,CH] = size(im);

%% Podzia³ na kana³y
im_blue = im(:,:,1);
im_green = im(:,:,2);
im_red = im(:,:,3);

%% Wy¶wietlenie kana³ów
% subplot(1,3,1)
% imshow(im_blue);
% title('Kana³ niebieski');
% subplot(1,3,2)
% imshow(im_green);
% title('Kana³ zielony');
% subplot(1,3,3)
% imshow(im_red);
% title('Kana³ czerwony');

%% Wybranie jednego z kana³ów
im_one = im_blue;

%% Erozja
se = strel('cube',3);
im_one = imerode(im_one,se);

%% Dylacja
im_one = imdilate(im_one,se);

%% Przeszukanie wszystkich kolumn - wyznaczenie maksimow (ograniczenie do 150 pierwszych wierszy obrazu)
maksy = [];

for i = 1:L
    temp = im_one(1:150,i);
    temp = double(temp);
    maximum = max(temp);
    [x,y]=find(temp==maximum);
    maksy = [maksy;x(1,1)];
end

%% Filtr dyfuzyjny

h = imdiffusefilt(im_one, 'NumberOfIterations', 10);
%figure; 
%imshow(h,[]);

%% Progowanie
% Compute the thresholds
thresh = multithresh(h,1);
 
% Apply the thresholds to obtain segmented image
seg_I = imquantize(h,thresh);
 
% Show the various segments in the segmented image in color
RGB = label2rgb(seg_I);

%figure 
%imshow(RGB)
%title('Segmented Image');

%% Jeden z kana³ów wysegmentowanego obrazu

im = RGB(:,:,2);

% figure;
% imshow(im);
%title('Jeden z kana³ów po segmentacji obrazu')
%% Wyznaczenie gornej linii - ograniczenie poszukiwania do 0.4 wysokosci obrazu
upper_line = [];
upper_part = floor(0.4*L);

for i = 1:L
    temp = im(1:upper_part,i);
    [x,y]=find(temp==max(im));
    upper_line = [upper_line;x(1,1)];
end

%% Przefiltrowanie wyników (gornej linii) filtrem medianowym
upper_line = medfilt1(upper_line,20,'truncate');

%% Wyrysowanie wyniku na wybranym kanale

% figure;
% imshow(im_one);
% hold on;
% plot(upper_line,'r-','LineWidth',3);

%% Zapis binarnego obrazu
% imwrite(im, 'mask_image.jpg');

%% Aktywny kontur

%stworzenie bazy do maski
mask = false(size(im));

%wyrysownaie bialej linii - górnej czesci naskorka
for i = 1:L
    wiersz = upper_line(i);
    wiersz = floor(wiersz);
    mask(wiersz,i) = 1;
end

% figure, imshow(mask)
% title('Maska pocz±tkowa');

maxIterations = 100; 
bw = activecontour(im, mask, maxIterations, 'Chan-Vese');
  
% Display segmented image
% figure, imshow(bw)
% title('Wygegmentowany naskórek');

%% Zapis wysegmentowanego naskorka
% imwrite(bw, 'segmented.jpg');

%% Wyciecie naskorka z obrazu oryginalnego
naskorek = im_blue;
naskorek(bw == 0) = 0;
% imshow(nowy)

%% Prezentacja wynikow
figure(1)
subplot(1,4,1)
imshow(im);
title('Wygegmentowany obraz');

subplot(1,4,2)
imshow(im_one);
hold on;
plot(upper_line,'r-','LineWidth',3);
title('Górna linia naskórka');
hold off

subplot(1,4,3)
imshow(mask)
title('Maska pocz±tkowa');

subplot(1,4,4)
imshow(naskorek);
title('Wygegmentowany naskórek');


%% Dolna linia naskórka - znalezienie pierwszego piksela od dolu, wiekszego od zera
lower_line = [];

for i = 1:L

    temp = bw(:,i);
    [x1,y1]=find(temp==max(bw(:,i)));
    lower_line = [lower_line;x1(end,1)];

end
%% Przefiltrowanie wyników (gornej linii) filtrem medianowym
lower_line = medfilt1(lower_line,20,'truncate');

%% Poprawienie górnej linii po aktywnych konturach - wybor pierwszego piksela wiekszego od 0
upper_line2 = [];
for i = 1:L

    temp2 = bw(1:upper_part,i);
    [x,y]=find(temp2==max(bw));
    
    upper_line2 = [upper_line2;x(1,1)];

end
%% Wyrysowanie gornej i dolnej linii     
figure(2);
imshow(im_one);
hold on;
plot(lower_line,'r-','LineWidth',3);
plot(upper_line2,'r-','LineWidth',3);
hold off;
