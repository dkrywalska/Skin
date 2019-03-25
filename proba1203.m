%% Czyszczenie workspace
clc;
clear all;
close ALL;

%% Wczytanie obrazu
im = imread('596.jpg');
[H,L,CH] = size(im);

%% Podzia³ na kana³y
im_blue = im(:,:,1);
im_green = im(:,:,2);
im_red = im(:,:,3);

%% Wy¶wietlenie kana³ów
subplot(1,3,1)
imshow(im_blue);
title('Kana³ niebieski');
subplot(1,3,2)
imshow(im_green);
title('Kana³ zielony');
subplot(1,3,3)
imshow(im_red);
title('Kana³ czerwony');

%% Wybranie jednego z kana³ów
im_one = im_blue;

% figure;
% imshow(im_one);
% title('Wybrany kana³ - kana³ czerwony');

%% Filtrowanie - filtr medianowy
% im_one = medfilt2(im_one);

%% Erozja
se = strel('cube',3);
im_one = imerode(im_one,se);

%% Dylacja
im_one = imdilate(im_one,se);

%% Przeszukanie wszystkich kolumn - wyznaczenie maksimow
maksy = [];

for i = 1:L
    temp = im_one(1:150,i);
    temp = double(temp);
    maximum = max(temp);
    [x,y]=find(temp==maximum);
    maksy = [maksy;x(1,1)];
end
hold off

%% Filtr dyfuzyjny

h = imdiffusefilt(im_one, 'NumberOfIterations', 10);
figure; 
imshow(h,[]);

%% Progowanie
% Compute the thresholds
thresh = multithresh(h,1);
 
% Apply the thresholds to obtain segmented image
seg_I = imquantize(h,thresh);
 
% Show the various segments in the segmented image in color
RGB = label2rgb(seg_I);

figure 
imshow(RGB)
title('Segmented Image');

%% Jeden z kana³ów wysegmentowanego obrazu

imshow(RGB(:,:,2));
im = RGB(:,:,2);
title('Jeden z kana³ów po segmentacji obrazu')

%% Erozja + (?) filtr medianowy

SE = strel('arbitrary',eye(3));
im = imerode(im,SE);
% imshow(im);
% im = medfilt2(im);

%%
upper_line = [];

upper_part = floor(0.4*L);
for i = 1:L

    temp = im(1:upper_part,i);
    [x,y]=find(temp==max(im));
    
    upper_line = [upper_line;x(1,1)];

end
hold off

%% Przefiltrowanie wyników filtrem medianowym
upper_line = medfilt1(upper_line,10);
%% Wyrysowanie wyniku na wybranym kanale

figure
imshow(im_one);
hold on
plot(upper_line,'r-','LineWidth',3);

%% Zapis binarnego obrazu
imwrite(im, 'mask_image.jpg');

