function app = launch_subtask1_rebuild()
%LAUNCH_SUBTASK1_REBUILD Launch the rebuild version with its paths prioritised.
basePath = fileparts(mfilename('fullpath'));
restoredefaultpath;
addpath(genpath(basePath), '-begin');
app = subtask1_gui(basePath);
end
