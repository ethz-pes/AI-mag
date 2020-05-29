function test()

tri = get_map_str_to_int('tri');
sin = get_map_str_to_int('sin');

id_vec = [tri sin tri sin];

c = [1 2 3 4];
d = [4 5 6 8];

[a, v] = get_map_fct([tri, sin], id_vec, @get_fct, {c, d})

end

function [a, b] = get_fct(id, c, d)

a = c+d;
b = c-d;

end