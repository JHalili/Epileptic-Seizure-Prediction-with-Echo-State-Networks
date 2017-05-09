function band_st = setUpFrequencyBands( )
    
alpha = struct('name', 'alpha','Fstop1', 7.5 ,'Fpass1', 8, 'Fpass2', 12, ...
    'Fstop2', 12.5,'Dstop1', 0.0001, 'Dpass', 0.057501127785 ,'Dstop2', 0.0001, 'dens', 20);
beta = struct('name', 'beta','Fstop1', 11.5 ,'Fpass1', 12, 'Fpass2', 30,...
    'Fstop2', 30.5,'Dstop1', 0.0001, 'Dpass', 0.057501127785 ,'Dstop2', 0.0001, 'dens', 20);
gamma = struct('name', 'gamma','Fstop1', 31.5 ,'Fpass1', 32, 'Fpass2', 100,...
    'Fstop2', 100.5,'Dstop1', 0.001, 'Dpass', 0.057501127785 ,'Dstop2', 0.0001, 'dens', 20);
theta = struct('name', 'theta', 'Fstop1', 3.5 ,'Fpass1', 4, 'Fpass2', 7,...
    'Fstop2', 7.5,'Dstop1', 0.001, 'Dpass', 0.057501127785 ,'Dstop2', 0.0001, 'dens', 20);

delta = struct('name', 'delta', 'Fpass', 0,  'Fstop', 4,'Dstop1', 0.0001,...
    'Dpass', 0.057501127785 , 'dens', 20);

band_st = struct('alpha', alpha, 'beta', beta, 'gamma', gamma, 'theta', theta, 'delta', delta);

end
