%线性预测分析
%输入: 一帧200个样点的数据 "1+a1..."
%输出: LPC系数

function f=melp_lpc(s)
global ham_win;
%w=0.54-0.46*cos(2*pi*((1:200)-1)/199);
v=s.*ham_win;                                   %Add a window
%for i=1:11
%  r(i)=sum(v(i:200).*v(1:201-i))/200;
%end													%Autocorrelation
%a=-r(2)/r(1);
%b=(1-a^2)*r(1);
%for i=1:9
%   k=-(r(i+2)+sum(r(2:i+1).*fliplr(a)))/b;
%   b=b*(1-k^2);
%   a=[a,0]+k*[fliplr(a),1];								%Levinson-Durbin algorithm
%end
%a=levinson(r,10);
a=lpc(v,10);

f=a.*0.994.^(1:11);                 %Bandwidth expansion coefficient
f=f(2:11);
end