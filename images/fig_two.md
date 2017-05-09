%% Adjustable parameters
resSize = 500;
initLen = 2;           % in number of files
bias = 0.5;            % bias so that 0 does not lead to 0
alpha = 0.7;           % small alpha -> more input driven (leak rate)

% Scaling parameters
w_scale = 1;
w_back_scale = 1;
w_in_scale = 1;
bias_scale = 1;
reg = [2, 1, 0.5, 1e-1, 1e-2] ;

kfold = 3;