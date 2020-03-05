function hash = get_hash_random()

rng('shuffle');

engine = java.security.MessageDigest.getInstance('MD5');
hash = double(typecast(engine.digest, 'uint8'));
engine.update(typecast(rand(), 'uint8'));
hash = bitxor(hash, double(typecast(engine.digest, 'uint8')));

hash = sprintf('%.2x', hash);

end