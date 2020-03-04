function disp_set_error(tag, name, var, data_cmp, data_ref, idx_train, idx_test)

% disp
fprintf('%s\n', tag);
figure('name', [name ' / ' tag])

% error
field = fieldnames(var);
for i=1:length(field)
    vec_cmp = data_cmp.(field{i});
    vec_ref = data_ref.(field{i});
    vec = abs(vec_cmp-vec_ref)./vec_ref;
    
    subplot(length(field), 1, i)
    disp_var(field{i}, vec, idx_train, idx_test)
end

end

function disp_var(tag, vec, idx_train, idx_test)

fprintf('    %s\n', tag)
disp_var_sub('train', vec(idx_train))
disp_var_sub('test', vec(idx_test))

histogram(1e2.*vec(idx_train))
hold('on')
histogram(1e2.*vec(idx_test))
grid('on')
legend({'train', 'test'})
xlabel('err [%]')
ylabel('n [1]')
title(tag, 'interpreter', 'none')

end

function disp_var_sub(tag, vec)

v_mean = mean(vec);
v_rms = rms(vec);
v_max = max(vec);
fprintf('        %s / mean = %.3f %% / rms = %.3f %% / max = %.3f %%\n', tag, 1e2.*v_mean, 1e2.*v_rms, 1e2.*v_max)

end

