function [is_valid, fom] = get_fom(ann_manager_obj, model_type, n_sol, inp, is_valid, ann_type)

% approx
out_approx = get_out_approx(model_type, inp);

% ann
switch ann_type
    case 'ann'
        [is_valid_tmp, fom] = ann_manager_obj.predict_ann(n_sol, inp, out_approx);
    case 'approx'
        [is_valid_tmp, fom] = ann_manager_obj.predict_nrm(n_sol, inp, out_approx);
    otherwise
        error('invalid data')
end

% is_valid
is_valid = is_valid&is_valid_tmp;

end
