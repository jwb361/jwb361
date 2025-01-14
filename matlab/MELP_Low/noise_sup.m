%noise suppression
function gain=noise_sup(gain,G_n)
max_noise=20;
max_atten=6;
if G_n>max_noise;
    G_n=max_noise;
end

%add by jiangwenbin
temp = 1-10^(0.1*(G_n+3-gain));
if temp < 0
    temp = 0;
end
suppress = -10*log10(temp);
if suppress>max_atten
    suppress = max_atten;
end
gain=gain-suppress;
end
% gain_lev=gain-G_n-3;
% if gain_lev>0.001
%     suppress=-10*log10(1-10^(-0.1*gain_lev));
%     if suppress>max_atten
%         suppress=max_atten;
%     end
% else
%     supress=max_atten;
% end
% gain=gain-max_atten;
