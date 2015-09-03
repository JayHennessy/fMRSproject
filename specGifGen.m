function [  ] = specGifGen( data, filename, delayTime, peakType )
% This function makes a gif from the output of run_pressproc (not the
% averaged output). It should be used to visually see the change in the
% spectrum over time. Its input is a out_aa variable, and a filename that 
% you would like to store the output GIF in and optionally speclim that 
% can be the string name of the metabolite you want ot see(or this could 
% be left blank to see the whole spectrum and it writes a GIF
% output to the current directory

if nargin<4
    speclim = [1 data.sz(1)];
end

% define spectral window in ppm
if strcmp(peakType,'NAA')
    x(1) = 1.5;
    x(2) = 2.5;
    lowVal = min(find(data.ppm<(x(2))));
    highVal = max(find(data.ppm>(x(1))));
    speclim = [lowVal highVal];

elseif strcmp(peakType, 'water')
    x(1) = 4;
    x(2) = 6;
    lowVal = min(find(data.ppm<(x(2))));
    highVal = max(find(data.ppm>(x(1))));
    speclim = [lowVal highVal];

elseif strcmp(peakType, 'lactate')
    x(1) = 0.7;
    x(2) = 1.9;
    lowVal = min(find(data.ppm<(x(2))));
    highVal = max(find(data.ppm>(x(1))));
    speclim = [lowVal highVal];

end

% find limits for the x and y axis

ymin = min(min(data.specs(speclim(1):speclim(2),:)));
ymax = max(max(data.specs(speclim(1):speclim(2),:)));
limmean = mean([ymin ymax]);
limits = [ymin-(limmean/2) ymax+(limmean/2)];

% make max and min lines 
[pk loc] = findpeaks(real(data.specs(speclim(1):speclim(2),100)));
pknum = find(pk == max(pk));
pminloc= loc(pknum);
pmin = min(data.specs(speclim(1)+pminloc-1,:));
pmax = max(data.specs(speclim(1)+pminloc-1,:));
%pmin = min(data.specs((xloc+lowVal),:));
maxline = ones(length(data.ppm(speclim(1):speclim(2))),1)*pmax;
minline = ones(length(data.ppm(speclim(1):speclim(2))),1)*pmin;


for i = 1:data.sz(2)
    
    TIME =  i*(data.tr/1000)/60;
    plot(data.ppm(speclim(1):speclim(2)),real(data.specs(speclim(1):speclim(2),i)),'black',data.ppm(speclim(1):speclim(2)),maxline,'red',data.ppm(speclim(1):speclim(2)),minline,'blue')
    ylim(limits);
    xlim([x(1) x(2)]);
    text(xlim, ylim,strcat('TIME : ', num2str(TIME)));
    drawnow
    frame = getframe(1);
    im = frame2im(frame);
    [A,map] = rgb2ind(im,256);
    if i == 1;
        imwrite(A,map,filename,'gif','LoopCount',Inf,'DelayTime', delayTime);
    else
        imwrite(A,map,filename,'gif','WriteMode','append','DelayTime',delayTime);
    end
end

end

