function arc_ellipseScatter_splitByLocationAndSeason(data,meta,variable)

figure("Position",meta.figSize);
hold on

for location = [0,1]

    plot(data(data(:,1) == location,2) + rand(size(data(data(:,1) == location,2)))/2,...
        data(data(:,1) == location,variable),...
        'o','Color',meta.pltCols{location+1},...
        'DisplayName',meta.locationNames{location+1})
    for season = 1:4
        [~,CI_relative] = compute95pctCI(data(data(:,1) == location & data(:,2) == season,variable));
        errorbar(season - (location/10) - 0.1,...
            mean(data(data(:,1) == location & data(:,2) == season,variable),"omitmissing"),...
            CI_relative(2),...
            'sk','MarkerFaceColor',meta.pltCols{location+1},...
            'HandleVisibility','off')
    end
end
legend('location','best')
xticks(1:4)
xticklabels(meta.seasonNames)
ylabel(meta.variableNames{variable})

end