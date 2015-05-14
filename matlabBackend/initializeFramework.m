function [VisceralPaths, logFile] = initializeFramework()
%
% Author: Markus Krenn @ CIR Lab (Medical University of Vienna)
% email:  markus.krenn@meduniwien.ac.at
%
%% clean up
clc;
close all;
clear all;

%% initialize paths
restoredefaultpath();

% add code paths
javaaddpath('res/mysql-connector-java-5.1.18-bin.jar');
addpath(genpath('db_functions'));
addpath(genpath('backend_functions'));
addpath(genpath('external'));

%% set data paths
logFile = ['./logFiles/log-File-' num2str(timestamp) '.txt'];

% modify your data paths here
% this directory points to the location where all data is located (volumes,
% annotations, segmentation estimates, registration,...)
rootDir = '/project/visceral/DATA/';

% volume, annotation and segmentation paths
VisceralPaths.volumePath            = [ rootDir, 'GeoS_oriented_Volumes_Annotators/' ];
VisceralPaths.expertAnnotationPath  = [ rootDir, 'manual_annotations_flipped/' ];
VisceralPaths.regPath               = [ rootDir, 'registrations/' ];
VisceralPaths.participantSeg        = [ rootDir, 'participant_segmentations/'];
VisceralPaths.scSegmentations       = [ rootDir, 'silver_corpus_segmentations/'];
end