clear
close all

% This script is the master control for the processing of Triaxus data.
% Here we set the names of all the input files - LOPC, CTD (scan) and
% EcoTriplet - and the output directories.
%
% We do some preliminary processing of the CTD scan data to remove
% obviously bad data, but since this is still prelimiary data from during
% the voyage, we don't spend much time. We are more interested in broad
% features and large scale changes in oceanography to relate to plankton
% data.
%
% This script will call a range of other functions which will individually
% process each input file, and then merge all the outputs into a single
% MATLAB structure which is appended to the .mat file. 
%
% When you have finished running Triaxus_Process_VOYAGENAME.m and you have
% the output file for each deployment, you can run setup and run
% Triaxus_2DPlot_VOYAGENAME.m to get the spatial plot.
%
% This code requires that the MATLAB Statistics Toolbox is installed and the
% GSW_Oceanographic toolbox is installed (http://www.teos-10.org/software.htm).
%
%
% Written by Jason Everett (UNSW/UQ) with inspiration and some code 
% from the great Lindsay Pender (CSIRO)
% Last Updated 24th September 2019

input_folder = '~/GitHub/TriaxusProcessing/TestData';
output_folder = 'TestData/output';

ESD_Range = [200 35000]; % Size limits for the LOPC data
avg_time = 20; % Number seconds to average over. Keep at 20 (seems to work well) unless you have a good reason to change.

reprocess = 1; % Do you want to reprocess the raw data. Otherwise, just do the merge of all datasets

%% List all the files we need to process
for leg = 1:1 % Loop through all deployments
    
    switch leg
        case 1
            LOPC_files = {[input_folder,filesep,'LOPC',filesep,'LOPC_2017-09-04_062940.dat']};
            CTD_files = {[input_folder,filesep,'scan',filesep,'in2017_v04007Ctd.nc'],...
                [input_folder,filesep,'scan',filesep,'in2017_v04008Ctd.nc'],...
                [input_folder,filesep,'scan',filesep,'in2017_v04009Ctd.nc']};
            EcoTrip_files = {[input_folder,filesep,'EcoTriplet',filesep,'in2017_v04_Dep3-EcoTriplet_2017-09-04.log']};
            Output_Name = [output_folder,filesep,'in2017_v04_Triaxus_Deploy3'];
            
%         case 2
%             LOPC_files = {['']};
%             CTD_files = {['']};
%             EcoTrip_files = {['']};
%             Output_Name = [''];
            
    end
    
    % Setup output folder
    if exist(output_folder,'dir')==0
        eval(['mkdir ',output_folder])
    end
    
    s = Triaxus_Merge(LOPC_files, CTD_files, EcoTrip_files, Output_Name, ESD_Range, avg_time, reprocess);
   
end

