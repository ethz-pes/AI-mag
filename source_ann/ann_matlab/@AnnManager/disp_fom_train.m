function disp_fom_train(self)

fprintf('n_train : %d\n', self.fom.n_train)
fprintf('n_test : %d\n', self.fom.n_test)

disp_fom_sub('inp', self.var_inp, self.fom.inp, 'set')
disp_fom_sub('out_ref', self.var_out, self.fom.out_ref, 'set')
disp_fom_sub('out_nrm', self.var_out, self.fom.out_nrm, 'set')
disp_fom_sub('out_ann', self.var_out, self.fom.out_ann, 'set')
disp_fom_sub('out_nrm / out_ref', self.var_out, self.fom.err_ann_nrm, 'err');
disp_fom_sub('out_ann / out_ref', self.var_out, self.fom.err_ann_ref, 'err');

end

function disp_fom_sub(tag, var, fom, type)

% disp
fprintf('%s\n', tag);
figure('name', tag)

% var
for i=1:length(var)
    name_tmp = var{i}.name;
    fom_tmp = fom.(name_tmp);
    
    subplot(length(var), 1, i)
    disp_fom_var(name_tmp, fom_tmp, type)
end

end

function disp_fom_var(tag, fom, type)

fprintf('    %s\n', tag)
disp_value('train', fom.train, type)
disp_value('test', fom.test ,type)

disp_hist(tag, fom, type)

end

function disp_value(tag, fom, type)

switch type
    case 'set'
        fprintf('        %s / avg = %.3e / std_dev = %.3e / min = %.3e / max = %.3e\n', tag, fom.v_avg, fom.v_std_dev, fom.v_min, fom.v_max)
    case 'err'
        fprintf('        %s / mean = %.2f %% / rms = %.2f %% / max = %.2f %%\n', tag, 1e2.*fom.v_mean, 1e2.*fom.v_rms, 1e2.*fom.v_max)
    otherwise
        error('invalid type')
end

end

function disp_hist(tag, fom, type)

hold('on')
switch type
    case 'set'
        histogram(fom.train.vec)
        histogram(fom.test.vec)
        xlabel('x [1]')
        ylabel('n [1]')
    case 'err'
        histogram(1e2.*fom.train.vec)
        histogram(1e2.*fom.test.vec)
        xlabel('err [%]')
        ylabel('n [1]')
    otherwise
        error('invalid type')
end
grid('on')
legend({'train', 'test'})
title(tag, 'interpreter', 'none')

end
