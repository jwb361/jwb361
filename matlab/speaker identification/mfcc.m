function c=mfcc(s,fs,w,nc,p,n,inc,fl,fh)
%MELCEPST Calculate the mel cepstrum of a signal C=(S,FS,W,NC,P,N,INC,FL,FH)
%
%
% Simple use: c=melcepst(s,fs)	% calculate mel cepstrum with 12 coefs, 256 sample frames
%				  c=melcepst(s,fs,'e0dD') % include log energy, 0th cepstral coef, delta and delta-delta coefs
%
% Inputs:
%     s	 speech signal
%     fs  sample rate in Hz (default 11025)
%     nc  number of cepstral coefficients excluding 0'th coefficient (default 12)
%     n   length of frame in samples (default power of 2 < (0.03*fs))
%     p   number of filters in filterbank (default: floor(3*log(fs)) = approx 2.1 per ocatave)
%     inc frame increment (default n/2)
%     fl  low end of the lowest filter as a fraction of fs (default = 0)
%     fh  high end of highest filter as a fraction of fs (default = 0.5)
%
%		w   any sensible combination of the following:
%
%				'R'  rectangular window in time domain
%				'N'	Hanning window in time domain
%				'M'	Hamming window in time domain (default)
%
%		      't'  triangular shaped filters in mel domain (default)
%		      'n'  hanning shaped filters in mel domain
%		      'm'  hamming shaped filters in mel domain
%
%				'p'	filters act in the power domain
%				'a'	filters act in the absolute magnitude domain (default)
%
%			   '0'  include 0'th order cepstral coefficient
%				'E'  include log energy
%				'd'	include delta coefficients (dc/dt)
%				'D'	include delta-delta coefficients (d^2c/dt^2)
%
%		      'z'  highest and lowest filters taper down to zero (default)
%		      'y'  lowest filter remains at 1 down to 0 frequency and
%			   	  highest filter remains at 1 up to nyquist freqency
%
%		       If 'ty' or 'ny' is specified, the total power in the fft is preserved.
%
% Outputs:	c     mel cepstrum output: one frame per row. Log energy, if requested, is the
%                 first element of each row followed by the delta and then the delta-delta
%                 coefficients.
%

if nargin<2 fs=11025; end
if nargin<3 w='M'; end
if nargin<4 nc=12; end
if nargin<5 p=floor(3*log(fs)); end
if nargin<6 n=pow2(floor(log2(0.03*fs))); end
if nargin<9
   fh=0.5;   
   if nargin<8
     fl=0;
     if nargin<7
        inc=floor(n/2);
     end
  end
end

if isempty(w)
   w='M';
end
if any(w=='R')
   z=enframe(s,n,inc);
elseif any (w=='N')
   z=enframe(s,hanning(n),inc);
else
   z=enframe(s,hamming(n),inc);
end
f=rfft(z.');
[m,a,b]=melbankm(p,n,fs,fl,fh,w);
pw=f(a:b,:).*conj(f(a:b,:));
pth=max(pw(:))*1E-20;
if any(w=='p')
   y=log(max(m*pw,pth));
else
   ath=sqrt(pth);
   y=log(max(m*abs(f(a:b,:)),ath));
end
c=rdct(y).';

%�޳�ǰ3��2
c(:,1:3)=[];
c(:,end-1:end)=[];
% nf=size(c,1);
% nc=nc+1;
% if p>nc
%    c(:,nc+1:end)=[];
% elseif p<nc
%    c=[c zeros(nf,nc-p)];
% end
% if ~any(w=='0')
%    c(:,1)=[];
%    nc=nc-1;
% end
% if any(w=='E')
%    c=[log(max(sum(pw),pth)).' c];
%    nc=nc+1;
% end


