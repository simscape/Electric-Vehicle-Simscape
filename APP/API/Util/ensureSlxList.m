function out = ensureSlxList(in)
%ENSURESLXLIST Append .slx extension to basenames that don't already have it.
%   out = ensureSlxList(in) takes a string/cellstr of model names and
%   returns a cellstr where every entry ends with '.slx'.
    in = string(in);
    add = ~endsWith(lower(in), ".slx");
    in(add) = in(add) + ".slx";
    out = cellstr(in);
end
