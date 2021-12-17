function rtv = ErrorFunc(x,y)
    % x is predict value
    % y is real value
    rtv = sum(x.^2 - y.^2);
end