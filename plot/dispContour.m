function []=dispContour(maps,threshold,contourColor,dashedColor,transparency,lineWidth,linestyle)
if min(size(maps))>1
    if ~isempty(threshold)
        if max(max(maps))>=threshold
            if min(min(maps))<=threshold
                hold on
                [~, hContour] = contourf(flipud(maps),[0 threshold],contourColor,'linewidth',lineWidth,'linestyle',linestyle);
                drawnow;  % this is important, to ensure that FacePrims is ready in the next line!
                hFills = hContour.FacePrims;  % array of TriangleStrip objects
                [hFills.ColorType] = deal('truecoloralpha');  % default = 'truecolor'
                for i=1:3
                    hFills(1).ColorData(i) = dashedColor(i);
                end
                hFills(1).ColorData(4) = transparency;
                if ~isempty(find(maps>=threshold)) && numel(find(maps>=threshold))<numel(maps)
                    hFills(2).ColorData(4) = 0;
                end
            end
        end
    end
end
hold off
end
