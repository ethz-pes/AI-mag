function disp_fom_train(self)
% Display on screen and plot the figures on merit of the datasets.
%
%    Plot the size of the datasets (training and test).
%    Plot the datasets and the error metrics.
%
%    (c) 2019-2020, ETH Zurich, Power Electronic Systems Laboratory, T. Guillod

% display size
fprintf('n_train : %d\n', self.fom.n_train)
fprintf('n_test : %d\n', self.fom.n_test)

% display and plot the datasets
disp_fom_sub('inp', self.var_inp, self.fom.inp, 'set')
disp_fom_sub('out_ref', self.var_out, self.fom.out_ref, 'set')
disp_fom_sub('out_nrm', self.var_out, self.fom.out_nrm, 'set')
disp_fom_sub('out_ann', self.var_out, self.fom.out_ann, 'set')

% display and plot the error between two datasets
disp_fom_sub('out_nrm / out_ref', self.var_out, self.fom.err_nrm_ref, 'err');
disp_fom_sub('out_ann / out_ref', self.var_out, self.fom.err_ann_ref, 'err');

end

function disp_fom_sub(tag, var, fom, type)
% Display and plot a dataset.
%
%    Parameters:
%        tag (str): name of the dataset
%        var (cell): description of the variables
%        fom (struct): figures of merit of the dataset
%        type (str): type of the dataset ('set' or 'err')

% disp name
fprintf('%s\n', tag);
figure('name', tag)

% plot and display each variable in the dataset
for i=1:length(var)
    % get the variable
    name_tmp = var{i}.name;
    switch type
        case 'set'
            var_err_tmp = 'set';
        case 'err'
            var_err_tmp = var{i}.var_err;
        otherwise
            error('invalid dataset type')
    end
    fom_tmp = fom.(name_tmp);
    
    % plot and display
    subplot(length(var), 1, i)
    disp_fom_var(name_tmp, fom_tmp, var_err_tmp)
end

end

function disp_fom_var(tag, fom, type)
% Display and plot a variable.
%
%    Parameters:
%        tag (str): name of the variable
%        fom (struct): figures of merit of the variable
%        type (str): type of the variable ('abs' or 'rel')

% display on screen (split training and test datasets)
fprintf('    %s\n', tag)
disp_value('train', fom.train, type)
disp_value('test', fom.test ,type)

% plot the histogram
disp_hist(tag, fom.train, fom.test, type)

end

function disp_value(tag, fom, type)
% Display a variable on the screen.
%
%    Parameters:
%        tag (str): name of the variable
%        fom (struct): figures of merit of the variable
%        type (str): type of the variable ('set' or 'rel_abs' or 'abs_abs' or 'rel_sign' or 'abs_sign')

switch type
    case 'set'
        fprintf('        %s / avg = %.3e / rms = %.3e / std_dev = %.3e / min = %.3e / max = %.3e\n',...
            tag, fom.v_avg, fom.v_rms, fom.v_std_dev, fom.v_min, fom.v_max)
    case {'abs_abs', 'abs_sign'}
        fprintf('        %s / avg = %.3e / rms = %.3e / std_dev = %.3e / min = %.3e / max = %.3e / prc_99 = %.3e\n',...
            tag, fom.v_avg, fom.v_rms, fom.v_std_dev, fom.v_min, fom.v_max, fom.v_prc_99)
    case {'rel_abs', 'rel_sign'}
        fprintf('        %s / avg = %.2f %% / rms = %.2f %% / std_dev = %.2f %% / min = %.2f %% / max = %.2f %% / prc_99 = %.2f %%\n',...
            tag, 1e2.*fom.v_avg, 1e2.*fom.v_rms, 1e2.*fom.v_std_dev, 1e2.*fom.v_min, 1e2.*fom.v_max, 1e2.*fom.v_prc_99)
    otherwise
        error('invalid dataset type')
end

end

function disp_hist(tag, fom_train, fom_test, type)
% Plot a variable with an histogram (split training and test datasets).
%
%    Parameters:
%        tag (str): name of the variable
%        fom_train (struct): figures of merit of the variable (training)
%        fom_test (struct): figures of merit of the variable (testing)
%        type (str): type of the variable ('set' or 'rel_abs' or 'abs_abs' or 'rel_sign' or 'abs_sign')

hold('on')
switch type
    case 'set'
        histogram(fom_train.vec)
        histogram(fom_test.vec)
        xlabel('x [1]')
        ylabel('n [1]')
        vec_train = [fom_train.v_min fom_train.v_max];
        vec_test = [fom_test.v_min fom_test.v_max];
    case {'abs_abs', 'abs_sign'}
        histogram(fom_train.vec)
        histogram(fom_test.vec)
        xlabel('x [1]')
        ylabel('n [1]')
        vec_train = [fom_train.v_min fom_train.v_max fom_train.v_avg fom_train.v_prc_99];
        vec_test = [fom_test.v_min fom_test.v_max fom_test.v_avg fom_test.v_prc_99];
    case {'rel_abs', 'rel_sign'}
        histogram(1e2.*fom_train.vec)
        histogram(1e2.*fom_test.vec)
        xlabel('err [%]')
        ylabel('n [1]')
        vec_train = 1e2.*[fom_train.v_min fom_train.v_max fom_train.v_avg fom_train.v_prc_99];
        vec_test = 1e2.*[fom_test.v_min fom_test.v_max fom_test.v_avg fom_test.v_prc_99];
    otherwise
        error('invalid dataset type')
end
plot(vec_train, zeros(1, length(vec_train)), 'sb', 'MarkerFaceColor', 'b')
plot(vec_test, zeros(1, length(vec_test)), '*r', 'MarkerFaceColor', 'r')
grid('on')
legend({'train', 'test'})
title(tag, 'interpreter', 'none')

end
