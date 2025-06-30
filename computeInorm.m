function Inorm = computeInorm(data)
% Compute percentile values based on luminance

[~,I] = sort(data(5,:));
[~,I2] = sort(I);
Inorm = (I2-1)/(size(I2,2)-1)*100; % normalised to be 0:100

end