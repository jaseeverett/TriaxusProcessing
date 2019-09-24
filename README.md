# TriaxusProcessing

NOTE: This is a very basic HOWTO. I do intend to write a better one on time, but at the moment there is no time - JDE

This repo is a compilation of scripts which allow the processsing of LOPC + Triaxus data from the CSIRO MNF. 

The two scripts you will need to worry about are:
* Triaxus_Process_VOYAGENAME.m
* Triaxus_2DPlot_VOYAGENAME.m

It is good practice to make a copy of these two files and replace "VOYAGENAME" with some identifier for your specific voyage as there are processing attributes which will specific to each voyage.

In Triaxus_Process_* you will need to set up the location of all the input files - LOPC, CTD (scan) and EcoTriplet - and the output directories.

We do some preliminary processing of the CTD scan data to remove obviously bad data, but since this is still prelimiary data from during the voyage, we don't spend much time. We are more interested in broad features and large scale changes in oceanography to relate to plankton data.

This script will call a range of other functions which will individually process each input file, and then merge all the outputs into a single MATLAB structure which is appended to the .mat file. 

When you have finished running Triaxus_Process_* and you have the output file for each deployment, you can run setup and run Triaxus_2DPlot_* to get the spatial plot. There are a range of colobar limits at the top which can be changed to make the plots interpretibale to your particular dataset.

**This code requires that my LOPC_Toolbox files are downloaded and the MATLAB Statistics Toolbox and the GSW_Oceanographic toolbox are installed (http://www.teos-10.org/software.htm).** All should be added to your path so they are visible from "TriaxusProcessing"

**Troubleshooting** If you run into problems with the code, and there is no obvious MATLAB error, start by looking at the raw LOPC and Ecotriplet data files in a decent text editor. Both sets of files seem to introduce garbage at points within the transmission. Possibly due to interruptions with the communications. There is only rudimentary error checking of the input files so these problems are not always apparent from MATLAB. There can also be comm breaks in mid data packet which create incomplete lines. These are harder to find but equally cause troubles. Careful inspection of the data files may be needed. You don't need the Ecotrioplet files to process the LOPC so you can set these filenames to {''} and therefore the software will not look for them.
