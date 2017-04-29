% Y = rand(4);
% %% Computing correlation matrix
% % v = randn(1e5,10); result = cov(v)
%
% t = cov(Y);
% %% Choelsky decomposition
% L = chol(t, 'lower');
% X = zeros(4);
% size(X)
% for i=1:4
%     X(i, :) = randn(1,4);
%     X(i, :) = X(i, :) - mean(X(i, :));
%     X(i, :) = X(i, :) ./ std(X(i, :));
% end;
% % [q, r] = qr(X); q*q'
% mean(X(1, :))
% std(X(2, :))
% Z = X*L;
% %% testing
% t_2 = cov(Z);
% %% result
% t
% t_2

% Showing filtered data


% filtered_data_show = 1;
% if(filtered_data_show)
%     S = FilteredFileContent(1, 'chb01_04.mat');
%     S.plotContent(1, 4);
% end;
% [l,s,a,b] = folderExplore();
% [start, length] = get_seizure_period(sprintf('Datach/ch01/%s',a(1, 1).name));
a = 1;
b = 2;
c = [2, 3, 4, 2, 3, 2];
d = 'ana';
patient(1).name = 'John Doe';
patient(1).billing = 127.00;
patient(1).test = [79, 75, 73; 180, 178, 177.5; 220, 210, 205];

patient(2).name = 'John Doe';
patient(2).billing = 127.00;
patient(2).test = [79, 75, 73; 180, 178, 177.5; 220, 210, 205];
patient
s = struct('a', a, 'b', b, 'c', c, 'd', d);
c = struct2cell(s);
d = cell2struct(c,{ 'a', 'b', 'c', 'd'});

