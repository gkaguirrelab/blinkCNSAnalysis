%% figures
%
%       Scan PSI index (out of 26 scans):
%          3.5 PSI: [3 8 13 24 25]
%          7.5 PSI: [9 11 12 20 22]
%          15 PSI: [4 7 16 17 21]
%          30 PSI: [1 2 10 15 18 26]
%          60 PSI: [5 6 14 19 23]
%
%% plot puff intensity as a function of scan number to show counterbalanced sequence

pressures = [30 30 3.75 15 60 60 15 3.75 7.5 30 7.5 7.5 3.75 60 30 15 15 30 60 7.5 15 7.5 60 3.75 3.75 30];

figure();
x = (1:26);
y = log10(pressures);

scatter(x,y,30,'filled');
hold on;
stairs(x,y);
title(['Counterbalanced pressure sequence'], 'FontSize', 14)
ylabel(['Puff pressure [log psi]'], 'FontSize', 14)
xlabel('Acquisition number', 'FontSize', 14)