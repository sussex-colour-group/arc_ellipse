function data = transformHSData(inputData)

% modified from arc_ImageAnalysis/plotMeanMB_hyperspec

for i = 1:size(inputData,1)
    name = inputData.name(i);
    name = name{1};
    if length(name) == 14 % please, dearest future humans, use leading zeros when storing data
        picId(i) = str2num(name(1:4));
    else
        picId(i) = str2num(name(1:3));
    end
end

% meta.variableNames = {'location','season','LogAxisRatio','EllipseAngle','EllipseArea'};

data = NaN(5,max(picId));

% location
data(1,[330:509,743:951]) = 0; % Tromso
data(1,[510:740,952:1165]) = 1; % Oslo

% season
data(2,[510:740,330:509]) = 1; % Summer
data(2,[952:1165,743:951]) = 3; % Winter

for i = 1:size(inputData,1)
    data(3,picId(i)) = inputData.LogAxisRatio(i);
    data(4,picId(i)) = inputData.EllipseAngleUnnormed(i);
    data(5,picId(i)) = inputData.EllipseArea(i);
end

data = data'; % TODO

end