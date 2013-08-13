function fileNameFound = checkStretchFile(fName,visualizationTitles, indicesToCheck)
    fileNameFound = 0;
    for i = indicesToCheck
       if strfind(lower(fName),lower(visualizationTitles{i})) > 0
           fileNameFound = 1;
           break;
       end
    end
    
end