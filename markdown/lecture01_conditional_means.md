In almost all of our work, we seek to make predictions about what will
happen under certain circumstances. Our basic tool for doing this is the
conditional mean. Today we'll make the link between conditional means
and regression.

Unconditional Means
===================

In most of our day-to-day thinking, we use unconditional means as the
basis for making predictions. For instance, if I asked you to predict
the temperature on June 1st of this year, you'd most likely simply say
it would be the average temperature for that day or that time of year.

In the example below, I calculate the mean of math test scores in the
plans dataset and use it as a prediction. I calculate the error term,
then calculate the mean sqrm uared error (which is exactly what it
sounds like) as a measure of how good this prediction is. As the graphic
shows, the mean is a pretty terrible predictor for most people.

It's worth remembering though, that the unconditional mean serves as the
basis for a very large amount of policymaking.

    . sort byses1

    . graph twoway scatter bynels2m byses1, msize(vtiny)

    . egen uncond_mean=mean(bynels2m)

    . gen uncond_mean_error=bynels2m-uncond_mean
    (276 missing values generated)

    . gen uncond_mean_error_sq=uncond_mean_error*uncond_mean_error
    (276 missing values generated)

    . quietly sum uncond_mean_error_sq

    . scalar uncond_mean_mse=r(mean)

    . graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) (line unco
    > nd_mean byses1,lcolor(blue)), legend(order(2 "Unconditional Mean"))

    . graph export "../plots/uncond_mean.png",replace
    (file ../plots/uncond_mean.png written in PNG format)

![](https://github.com/wdoyle42/lpo9952/blob/master/plots/uncond_mean.png)
\# Conditonal Means

With condtional means, we start using more information to think about
how we will make our prediction. One of the simplest ways to do this in
a bivariate sense is to calculate the mean of the dependent variable for
individuals who are above average and below average.

    . egen sesq2=cut(byses1), group(2)
    (924 missing values generated)

    . egen cond_mean2=mean(bynels2m), by(sesq2)

    . gen cond_mean2_error=bynels2m-cond_mean2
    (276 missing values generated)

    . gen cond_mean2_error_sq=cond_mean2_error*cond_mean2_error
    (276 missing values generated)

    . quietly sum cond_mean2_error_sq

    . scalar cond_mean2_mse=r(mean)

    . graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
    >              (line uncond_mean byses1,lcolor(blue)) ///
    >              (line cond_mean2 byses1,lcolor(orange)), ///
    >               legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 grou
    > ps") )

    . graph export "../plots/cond_mean2.png",replace
    (file ../plots/cond_mean2.png written in PNG format)

Regression is the conditional mean
==================================

Regression is based on the idea of the expected value of y given,
E(Y|X). If X can take on only two values, then regression will give two
predictions.

    . egen sesq4=cut(byses1), group(4)
    (924 missing values generated)

    . egen cond_mean4=mean(bynels2m), by(sesq4)

    . gen cond_mean4_error=bynels2m-cond_mean4
    (276 missing values generated)

    . gen cond_mean4_error_sq=cond_mean4_error*cond_mean2_error
    (276 missing values generated)

    . quietly sum cond_mean4_error_sq

    . scalar cond_mean4_mse=r(mean)

    . scalar li
    cond_mean4_mse =  .01528936
    cond_mean2_mse =  .01600496
    uncond_mean_mse =  .01832291

    . graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
    >              (line uncond_mean byses1,lcolor(blue)) ///
    >              (line cond_mean2 byses1,lcolor(orange)) ///
    >              (line cond_mean4 byses1,lcolor(yellow)), ///    
    >              legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 group
    > s" 4 "Conditional Mean, 4 Groups") )

    . graph export "../plots/cond_mean4.png",replace
    (file ../plots/cond_mean4.png written in PNG format)

    . // Regression
    . reg bynels2m byses1

          Source |       SS       df       MS              Number of obs =   15236
    -------------+------------------------------           F(  1, 15234) = 3532.18
           Model |  53.2360435     1  53.2360435           Prob > F      =  0.0000
        Residual |    229.6024 15234  .015071708           R-squared     =  0.1882
    -------------+------------------------------           Adj R-squared =  0.1882
           Total |  282.838444 15235  .018565044           Root MSE      =  .12277

    ------------------------------------------------------------------------------
        bynels2m |      Coef.   Std. Err.      t    P>|t|     [95% Conf. Interval]
    -------------+----------------------------------------------------------------
          byses1 |   .0795636   .0013387    59.43   0.000     .0769396    .0821877
           _cons |   .4504293   .0009962   452.15   0.000     .4484766    .4523819
    ------------------------------------------------------------------------------

    . predict reg_predict
    (option xb assumed; fitted values)
    (924 missing values generated)

    . predict reg_error, residual
    (924 missing values generated)

    . gen reg_error_sq=reg_error*reg_error
    (924 missing values generated)

    . quietly sum reg_error_sq

    . scalar reg_mse=r(mean)

    . graph twoway (scatter bynels2m byses1,msize(vtiny) mcolor(black)) ///
    >              (line uncond_mean byses1,lcolor(blue)) ///
    >              (line cond_mean2 byses1,lcolor(orange)) ///
    >              (line cond_mean4 byses1,lcolor(yellow)) ///
    >              (line reg_predict byses1,lcolor(red)), ///        
    >              legend(order(2 "Unconditional Mean" 3 "Condtional Mean, 2 group
    > s" 4 "Conditional Mean, 4 Groups" 5 "Regression Prediction") )

    . scalar li
       reg_mse =  .01506973
    cond_mean4_mse =  .01528936
    cond_mean2_mse =  .01600496
    uncond_mean_mse =  .01832291

    . graph export "../plots/cond_mean_regress.png",replace
    (file ../plots/cond_mean_regress.png written in PNG format)
