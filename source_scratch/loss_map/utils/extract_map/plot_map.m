function plot_map(name, data)

%% surf
figure('name', sprintf('%s / losses', name))
for i=1:length(data.T)
    surf(data.B_peak, data.f, data.P_f_B_peak_T(:,:,i))
    hold('on')
end
set(gca,'yscale','log')
set(gca,'xscale','log')
set(gca,'zscale','log')
grid('on')
xlabel('B_peak [T]', 'interpreter', 'none')
ylabel('f [Hz]', 'interpreter', 'none')
zlabel('P [W/m3]', 'interpreter', 'none')
str = sprintf('%s / losses / P [W/m3]', name);
title(str, 'interpreter', 'none')

end