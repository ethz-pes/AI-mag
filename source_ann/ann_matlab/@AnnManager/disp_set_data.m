function disp_set_data(self, tag, var, data)

% disp
fprintf('%s\n', tag);
figure('name', tag)

% var
for i=1:length(var)
    name_tmp = var{i}.name;
    vec = data.(name_tmp);
    
    subplot(length(var), 1, i)
    disp_var(name_tmp, vec, self.idx_train, self.idx_test)
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