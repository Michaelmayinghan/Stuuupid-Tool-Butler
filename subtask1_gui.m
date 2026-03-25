function subtask1_gui()
%SUBTASK1_GUI Top-level launcher for the Subtask 1 GUI.
    repoRoot = fileparts(mfilename('fullpath'));
    addpath(genpath(repoRoot));
    currentDir = pwd;
    cleanupObj = onCleanup(@() cd(currentDir));
    cd(fullfile(repoRoot, 'subtask1'));
    subtask1_gui_app_internal();
end
