a = [ 1,2,3,2,1,2];
partition = cvpartition(a, 'KFold', 2)
partition.training(1)