function [ metVec metVecAvg ] = metaboliteTracker( data, freq, blockDesign, type )
%
%[ metVec metVecAvg ] = metaboliteTracker( data, freq, blockDesign, type )
%
% This function plots the time course of the point defined by freq in ppm.
% Inputs:   data = output from run_pressproc_fmrs (out_aa or output from
%                   data_shift prefereably)
%           freq = frequency in ppm to track
%           blockDesign = ONaverages from run_pressproc_fmrs or [ 0 0 1 1 0
%                       0 1 1 ] where 1 is on averages and 0 is off averages
%           type = 0 or 1 depending if you want to take an average of the
%                   data points around a frequency or just at one point at the
%                   frequency
%
%

% Get the range of ppm values that your peak will be in

kernel =9;
scanTime = (data.tr/1000)*data.rawAverages/60;

highVal = min(find(data.ppm<(freq-0.05 )));
lowVal = max(find(data.ppm>(freq+0.05)));

% get an average value around the peak for each measurement
if type ==0
    
    for i =1:size(data.specs,2)
        metVec(i) = mean(data.specs(lowVal:highVal,i),1);
    end
    metVecAvg = movingAverage(metVec,kernel);
    
    highAmp = mean(real(metVecAvg(5:end-5)))+ std(real(metVecAvg(5:end-5)));
    lowAmp = mean(real(metVecAvg(5:end-5)))- std(real(metVecAvg(5:end-5)));
    
    blockDesign = blockDesign.*highAmp;
    % I don't understand why the following line doesn't work. I just
    % replaces everything with ones. If I can get it to work then the next
    % for loop can be replaced
    
    %blockDesign(blockDesign == 0) = lowAmp;
    for i = 1:length(blockDesign)
        
        if blockDesign(i) == 0
            blockDesign(i) = lowAmp;
        end
    end
    
    figure;
    plot(0:(scanTime/data.sz(2)):(scanTime-scanTime/data.sz(2)), metVec, 0:(scanTime/data.sz(2)):(scanTime-scanTime/data.sz(2)) , blockDesign);
    
    title('Fixed Point ')
    xlabel('Time (min)')

    figure;
    plot(0:(scanTime/data.sz(2)):(scanTime-((kernel+1)*scanTime)/data.sz(2)) , real(metVecAvg((kernel/2):end-((kernel/2)+1))), 0:(scanTime/data.sz(2)):(scanTime-((kernel+1)*scanTime)/data.sz(2)) , blockDesign((kernel/2):end-((kernel/2)+1)));
    title('Averaged Point ')
    xlabel('Time (min)')

    
elseif type ==1
    val = min(find(data.ppm<(freq)));
    metVecAvg = movingAverage(data.specs(val,:),kernel);
    
    highAmp = mean(real(metVecAvg(5:end-5)))+ std(real(metVecAvg));
    lowAmp = mean(real(metVecAvg(5:end-5)))- std(real(metVecAvg));
    
    blockDesign = blockDesign.*highAmp;
    % I don't understand why the following line doesn't work. I just
    % replaces everything with ones. If I can get it to work then the next
    % for loop can be replaced
    
    %blockDesign(blockDesign == 0) = lowAmp;
    for i = 1:length(blockDesign)
        
        if blockDesign(i) == 0
            blockDesign(i) = lowAmp;
        end
    end
    
    
    figure;
    plot(0:(scanTime/data.sz(2)):(scanTime-scanTime/data.sz(2)), data.specs(val,:));
    title('Fixed Point ')
    xlabel('Time (min)')
    
    figure;
    plot(0:(scanTime/data.sz(2)):(scanTime-((kernel+1)*scanTime)/data.sz(2)) , real(metVecAvg((kernel/2):end-((kernel/2)+1))) , [0:(scanTime/data.sz(2)):(scanTime-((kernel+1)*scanTime)/data.sz(2))] , blockDesign((kernel/2):end-((kernel/2)+1)));
    title('Averaged Point ')
    xlabel('Time (min)')
    
end


end





