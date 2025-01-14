%Get 5 band's bandpass signal and the 2~4 bands' envelopes
%Input:
%        sig_in(input signal)
%        state_b(original bandpass filter's state)
%        state_e(original envelopes filter's state)
%output:
%        bands(bandpass signal)
%        state_b(final state of bandpass filters)
%        envelopes(envelopes of the bandpass signal)
%        state_e(final state of envelopes filters)
function [bands, envelopes ]=melp_5b(sig_in)
global bands_in_s bands_out_s butt_bp_num butt_bp_den
global envelop_in_s envelop_out_s smooth_num smooth_den
bands(1:5,1:180) = 0;
envelopes(1:4,1:180) = 0;
for i=1:5
    %[bands(i,:),state_b(i,:)] = filter(butt_bp_num(i,:), butt_bp_den(i,:), sig_in, state_b(i,:));%modify by jiangwenbin
    [bands(i,:),bands_in_s(i,:),bands_out_s(i,:)] = melp_iir(butt_bp_num(i,:),butt_bp_den(i,:), sig_in,bands_in_s(i,:),bands_out_s(i,:));
    %[bands(i,:),state_b(i,:)]=melp_iir(sig_in,state_b(i,:),butt_bp_ord,...
    %butt_bp_num(i,:),butt_bp_den(i,:),180);
end
temp1=abs(bands(2:5,:));
for i=1:4
    %[envelopes(i,:),state_e(i,:)] = filter(smooth_num(1,:), smooth_den(1,:), temp1(i,:), state_e(i,:)); %modify by jiangwenbin
    [envelopes(i,:),envelop_in_s(i,:),envelop_out_s(i,:)] = melp_iir(smooth_num, smooth_den, temp1(i,:),envelop_in_s(i,:),envelop_out_s(i,:));
    %[envelopes(i,:),state_e(i,:)]=melp_iir(temp1(i,:),state_e(i,:),smooth_ord,...
    %smooth_num(1,:),smooth_den(1,:),180);
end
end