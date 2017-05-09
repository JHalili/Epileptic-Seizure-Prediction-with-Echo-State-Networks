>> alpha 0.01 => smallest error both training and testing
totalTrainMSE = 0.00351671040232258
totalTestMSE = 0.652109948315666

>> increasing w_in_scale leads to a W_out very input driven, and as a result
training error decreases
but testing goes up. Furthermore states inside the network tend to go to -1 in a
sort of dead state.
reducing it below the value of 0.01 also leads to a higher testing Error and training error compared to 
0.01. However the values change at a slower rate.

>> w_scale
smaller values than 1.6 make the training error go smaller and the testing error higher
w_out becomes more reservoir driven
larger values such as 2 lead to
totalTestMSE =
         0.760890336284193
totalTrainMSE =
       0.00737890293018498
However, this does increase the eigenvalue of the matrix, no longer having the echo state property

reducing it to 1, leads to a testing error of up to 12, while the training error goes up to 0.002... decreases.
In order to preserve the echo state property, the value will be left at 1, making the smallest train/test error so far 
totalTestMSE = 6.38749595192804
       
totalTrainMSE  = 0.00225246069411794

>> bias
current value: 0.1
reducing the bias to 0.01 leads to the following outcome
totalTestMSE =
          8.56947523028236
totalTrainMSE =
       0.00240642813186422
there is a general increase in the error for both the testing and the training error.
However, increasing the bias to 1 leads to a reduce in the error for both test and training
totalTestMSE =
          1.27885760382932
totalTrainMSE =
      0.000729715279434787
Increasing the bias further :

totalTestMSE =
         0.656179464225288
totalTrainMSE =
       0.00374990253421133
which is based on the numbers much smaller, and yet based on the visualizations of the data, much more far away from the desired result 
compared to a bias of 1.
for the value 1.5, the errors are higher and the approximations worse than for a bias of 1.
for a bias of 0.8 the values are
totalTestMSE =
          1.78823090627367
totalTrainMSE =
      0.000868834992750191
A bias of 1 is chosen

>> Regularizatoin
inital value: 1e-2

changing it to 1e-1:
totalTrainMSE =
       0.00160694604146969
totalTestMSE =
          1.29953791097937