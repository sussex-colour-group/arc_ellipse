function data_denoised = removeNLdarknoise(data,value)

Inorm = computeInorm(data);
data_denoised = data(:,Inorm >= value);

end