%% EEG EPILEPY PREDICTION ESN
% load input files into a vector with indices.
averagingWindow = 1000;
g = 1/averagingWindow*ones(averagingWindow,1);

files_all = folderFilteredExplore('Datach_filtered/test');

test_indices = [1, 68, 69, 70]; %67+1, 67+8];
test_files = files_all(test_indices);
files_all(test_indices) = [];
files = files_all;
state_collect = sort([2,10,4,36,200,150, 30, 14, 20, 450,230 ]);

helper= load('correlationMatrix.mat');
Channel_corr = helper.m.channel_correlation;
%% Data properties
frequency_bands = 5;
nr_channels = 18;
inputSize = frequency_bands * nr_channels;
teacherSize = 1;
rand('seed', 58);

%% Adjustable parameters
resSize = 500;
initLen = 3;           % in number of files
bias = 1;            % bias so that 0 does not lead to 0
alpha = 0.01;           % small alpha -> more input driven (leak rate)

% Scaling parameters
w_scale = 1;
w_in_scale = 0.1;
bias_scale = 1;
reg = 1e-1 ;
%% Matrix generation

W_0 = rand(resSize, resSize) - 0.5;
maxEig = max(abs(eigs(W_0)));
W = W_0 * (1.00 / maxEig);

X = rand(nr_channels, resSize*frequency_bands);
L = chol(Channel_corr, 'lower');
Y = L * X;
W_in_t = zeros(inputSize, resSize);
current_index = 0;
for i=1:nr_channels
    for j=1:frequency_bands
        current_index = current_index+1;
        W_in_t(current_index, : )=Y(i, (j-1)*resSize+1:j*resSize);
    end;
end;
W_in = W_in_t';
% W_in = W_in + min(min(W_in));

%% Teacher output, initial res and data assignement
% X (DR) is initialized with 0
X = rand(resSize, 1);
opt = 1;

% temporary variables
% ld = length(fileDirs)
% lf =ch_file_nr

lf = 1;
ld = 1;
for fid = 1: initLen-1
    S = FilteredFileContent(files(fid).patient, files(fid).file_name);
    for ii=1:size(S.data, 2)
        X = (1-alpha)*X + alpha * tanh(w_in_scale * W_in * S.data(:,ii) + w_scale * W*X + bias_scale*bias);
        opt = S.teacher(ii);
    end;
    
end;

disp 'Init part is done';

%% Start training

M = zeros( resSize + nr_channels*5 , resSize + nr_channels*5 );
T = zeros(1,resSize + nr_channels*5 );




for fid = initLen:length(files)
    S = FilteredFileContent(files(fid).patient, files(fid).file_name);
    % split our current training set according to the indexes
    % only the training set is used
    states_training = zeros(length(state_collect), size(S.data, 2));
    
    for jj = 1 : size(S.data, 2)
        X = (1-alpha)*X + alpha * tanh(w_in_scale * W_in * S.data(:, jj) + w_scale * W*X  + bias_scale*bias);
        vect = vertcat( X, S.data(:, jj));
        M = M + vect * vect';         % collecting X data into M
        T = T + vect' * opt;          % collecting output data into T
        opt = S.teacher(jj);
        states_training(:, jj) = X(state_collect)';
    end;
end;

disp ('done with M AND T ');
%% computing the W_out
W_out = (inv(M + reg .* eye(resSize + nr_channels*frequency_bands))*T')';

%% Compute training error
%reset file name and dir name positions

totalTrainMSE1 = 0;
totalTestMSE1 = 0;
for fid = initLen:length(files)
    S = FilteredFileContent(files(fid).patient, files(fid).file_name);
    
    states_training_error = zeros(length(state_collect), size(S.data, 2));
    generated_output = zeros(1, size(S.teacher, 2));
    for jj = 1 : size(S.data, 2)
        X = (1-alpha)*X + alpha*tanh(w_in_scale * W_in * S.data(:, jj) + w_scale * W*X + bias);
        vect = vertcat( X, S.data(:, jj));
        
        
        states_training_error(:, jj) = X(state_collect)';
        
        generated_output(jj) = W_out*vect;
        opt = generated_output(jj);
    end;
    
    totalTrainMSE1 = totalTrainMSE1 + immse(generated_output, S.teacher);
    generated_output = filter(g,1,generated_output);
    nm = sprintf('generated_train%d', fid);
    figure('Name', files(fid).file_name); plottools('on');
    plot(1:size(S.teacher, 2), generated_output, 1:size(S.teacher, 2), S.teacher);
    legend(nm,'teacher');
end;
totalTrainMSE = totalTrainMSE1 / length(files);


%% compute testing error

for fid = 1:length(test_files)
    S = FilteredFileContent(test_files(fid).patient, test_files(fid).file_name);
    
    states_training_error = zeros(length(state_collect), size(S.data, 2));
    generated_output = zeros(1, size(S.teacher, 2));
    % compute error training
    for jj = 1 : size(S.data, 2)
        X = (1-alpha)*X + alpha*tanh(w_in_scale * W_in * S.data(:, jj) + w_scale * W*X + bias_scale * bias);
        vect = vertcat( X, S.data(:, jj));
        
        for s  = 1:length(state_collect)
            states_training_error(s, jj) = X(state_collect(s));
        end;
        generated_output(jj) = W_out*vect;
        opt = generated_output(jj);
    end;
    
    totalTestMSE1 = totalTestMSE1 + immse(generated_output, S.teacher);
    generated_output = filter(g,1,generated_output);
    nm = sprintf('generated_test%d', fid);
    figure('Name',test_files(fid).file_name); plottools('on');
    plot(1:size(S.teacher, 2), generated_output, 1:size(S.teacher, 2), S.teacher);    
    legend(nm,'teacher');
end;
totalTestMSE = totalTestMSE1 / length(test_files);

%% plotting
figure('Name', 'W_out');
plottools('on');
plot(W_out);


%% plot some of the input
figure('Name', 'input');
plottools('on');
hold on;
for i = 1:5
    plot(S.data(i, :))
end;
hold off;

%% plot W
figure('Name', 'Some of W');
plottools('on');
hold on;
for i=1:5
    plot(sort(W(i, :)));
end;
hold off;
