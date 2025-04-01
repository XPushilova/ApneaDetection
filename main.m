% =========================================================================
%             BPC-ABS 2024 PROJECT
% =========================================================================
%   INPUT DATA
%   -folder contains following files:
%       -dataset_ABS.mat        file with dataset
%       -Anotace.txt            data annotation 
%       -main.m                 main script for data evaluation
%       -F1skore.m              function for results calculation
%       -apneaDetection.m       YOUR FUNCTION FOR EVALUATION
% 
% DATA DESCTIPTION
%   -Dataset contains PSG data from apnoic patients, each line is one
%   minute of recording with following type of record:
%         -Flow and Pres - respiration record from upper airways using 
%       thermocouple and pressure sensor (Fs=32Hz)
%       -Thor and Abdo - plethysmography record of respiratory movements
%       from thorax and abdomen  (Fs=32Hz)
%       -SpO2 - oxymetry (Fs=1Hz)
%       -Central, Obstruct, Hypo - binary annotation signals indicating
%       presence of respective event (Fs=32Hz, only informative!)
% 
%   -Annotation is text file with each line having numeric value:
%       1 - Central apnea
%       2 - Obstructive apnea
%       3 - Hypopnea
%       4 - Normal sleep recording
% 
% ======================================================================
%% data load 
clearvars
close all hidden
clc

showresults = 1; % 0 or 1 whether you want to write results into command window

load('dataset_ABS.mat');
Target=load('Anotace.txt');
N=(length(Target));
Result=zeros(N,1);

%% main loop for evaluation
for i=1:N
    data=dataset(i);
    

    %===================================================%
    class = apneaDetection(data);
    %===================================================%
    Result(i) = class;
    
    if showresults
        if class == Target(i)
            disp(['Record number ' num2str(i) ' is CORRECT (' num2str(class) ')'])
        else
            disp(['Record number ' num2str(i) ' is classified as ' num2str(class) ' and should be ' num2str(Target(i))])
        end
    end

end
%% Results calculation
SCORE = F1skore(Target,Result)    % calculates Score
