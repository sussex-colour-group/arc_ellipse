function [CI,CI_relative] = compute95pctCI(x)

% Source: https://uk.mathworks.com/matlabcentral/answers/159417-how-to-calculate-the-confidence-interval#answer_155952

x = x(~isnan(x));

SEM = std(x)/sqrt(length(x));               % Standard Error
ts = tinv([0.025  0.975],length(x)-1);      % T-Score
CI_relative = ts*SEM;                       % Confidence Intervals, relative to mean
CI = mean(x) + CI_relative;                 % Confidence Intervals

end