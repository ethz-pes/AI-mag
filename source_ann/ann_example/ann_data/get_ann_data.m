function [n_sol, inp, out_ref, out_nrm] = get_ann_data()

n_sol = 10000;

inp.x_1 = 7.0+3.0.*rand(1, n_sol);
inp.x_2 = 1.0+5.0.*rand(1, n_sol);

out_ref.y_1 = inp.x_1+inp.x_2+0.1.*rand(1, n_sol);
out_ref.y_2 = inp.x_1-inp.x_2+0.1.*rand(1, n_sol);

out_nrm.y_1 = 12.0.*ones(1, n_sol);
out_nrm.y_2 = 5.0.*ones(1, n_sol);

end