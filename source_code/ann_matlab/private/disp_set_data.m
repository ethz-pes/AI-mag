function disp_set_data(tag, var, data, idx_train, idx_test)

% disp
fprintf('%s\n', tag);
figure('name', tag)

% var
field = fieldnames(var);
for i=1:length(field)
    vec = data.(field{i});
    
    subplot(length(field), 1, i)
    disp_var(field{i}, vec, idx_train, idx_test)
end

end

function disp_var(tag, vec, idx_train, idx_test)

fprintf('    %s\n', tag)
disp_var_sub('train', vec(idx_train))
disp_var_sub('test', vec(idx_test))

histogram(vec(idx_train))
hold('on')
histogram(vec(idx_test))
grid('on')
legend({'train', 'test'})
xlabel('x [1]')
ylabel('n [1]')
title(tag, 'interpreter', 'none')

end

function disp_var_sub(tag, vec)

v_avg = mean(vec);
v_std_dev = std(vec);
v_max = max(vec);
v_min = min(vec);
fprintf('        %s / avg = %.3e / std_dev = %.3e / min = %.3e / max = %.3e\n', tag, v_avg, v_std_dev, v_min, v_max)

end