clear all;


n = 1:20;
d_c = 0.8;
m = 1./d_c;

coeff = -(2.*(-1).^n.*m.^2)./(n.^2.*(m-1).*pi.^2).*sin((n.*(m-1).*pi)./m);

rms = sqrt(sum(coeff.^2))./sqrt(2);
fact = sqrt(sum(n.^2.*coeff.^2))./sqrt(2);

f = 50e3;
sigma = 5.8e7;
d_strand = 100e-6;
fill = 0.35;
H_peak = 2e3;

mu0_const = 4.*pi.*1e-7;


H_rms = H_peak.*fact;

delta = 1./sqrt(pi.*mu0_const.*sigma.*f);

gr = (pi.^2.*d_strand.^6)./(128.*delta.^4);
fact_tmp = 1.*gr.*(32.*fill)./(sigma.*pi.^2.*d_strand.^4);
P = fact_tmp.*(H_rms.^2);
P = sum(P)


% add
f_vec = f.*n;
H_rms_vec = (H_peak.*coeff)./sqrt(2);

delta = 1./sqrt(pi.*mu0_const.*sigma.*f_vec);

gr = (pi.^2.*d_strand.^6)./(128.*delta.^4);
fact_tmp = 1.*gr.*(32.*fill)./(sigma.*pi.^2.*d_strand.^4);
P = fact_tmp.*(H_rms_vec.^2);
P = sum(P)