function [ output ] = data_shift( data , phase0, phase1)
% Note: this function should be performed on out_aa data that has gone
% through run_pressproc. It adds the phase and shifts the data to each
% average in out_aa rather because the original run_pressproc only does
% this to averaged data. This may not be the best way to do this but it
% should give a visual idea of the trace of a metabolite through time.
%
%[ output ] = data_shift( data, phase0, phase1 )
% Inputs: data = out_aa
%         phase0 = zero order phase calculated by run_pressproc
%         phase1 = first order phase calculated by run_pressproc
%
%

tmp = data;
tmp.specs = [];
tmp2 = data;
tmp2.specs = [];

% shift each average left
for i = 1:data.sz(2)
    tmp.sz(2) = 1;
    tmp.specs = data.specs(:,i);
    tmp.fids = data.fids(:,i);
    tmp2 = op_leftshift(tmp,tmp.pointsToLeftshift);
    out1.specs(:,i) = tmp2.specs;
    out1.fids(:,i) = tmp2.fids;
end

tmp2.specs = [];
tmp2.specs = out1.specs;
tmp2.fids = [];
tmp2.fids = out1.fids;
tmp3 = tmp2;
tmp3.specs = [];

% add phase to each average
for i = 1:data.sz(2) 
    
    tmp3.specs = tmp2.specs(:,i);
    tmp3.fids = tmp2.fids(:,i);
    tmp4 = op_addphase(tmp3,phase0,phase1);
    output.specs(:,i) = tmp4.specs;
    output.fids(:,i) = tmp4.fids;

end

x = output.specs;
y = output.fids;
output = tmp4;
output.specs = [];
output.fids = [];
output.specs = x;
output.fids = y;
output.sz(2) = data.sz(2);

end

