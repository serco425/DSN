function result = STN_bipolar(stream, package_size)
s_1s = sum(stream);
s_0s = package_size - s_1s;
result = (s_1s - s_0s)/2;
end