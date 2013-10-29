function table = generate_corr_table(storage)
%
%
%
%
k = 1;
table = zeros(181, 100);
while k < 2

    i = 1;
    cors = zeros(4000,1);
    sig1(:, :) = storage(k, 1, :);
    sig2(:, :) = storage(k, 2, :);
    while i <= 4000
        temp = (sig1 * (i * .00025)) + (sig2 * (1 - (i * .00025)));
        cor = corr(temp, sig1);
        %disp(cor);
        cors(i) = cor;
        i = i + 1;
    end

    i = 1;
    m = .1;
    while i <= 181
        t = find(abs(cors) >= (m - .0025) & abs(cors) <= (m + .0025) );
        table(i, k) = (((t(1) + t(end)) / 2 )* .00025);
        m = m + .005;
        i = i + 1;
    end
    k = k + 1;
end