function Pt = Markov_Model(lambda, mu, n, s, o)
% Markov Chain model for parking lot occupency prediction
% according to the paper "Finding Available Parking Spaces Made Easy"

% M(lambda, mu, s, n, o) Markov Model
% lambda: arrival rate
% mu: parking rate = 1/(expected parking time)
% n: parking space number
% s: time
% o: occupied space number

% input protect
if mu == 0 || isnan(mu)
    mu = 1e-10;
end

% Q = zeros(n+1);
q = zeros(1,n);
qq = zeros(1,n);
for i = 1:n
    q(i) = -(lambda + (i-1) * mu);
    qq(i) = i*mu;
end
q = [q,-n*mu];
Q = diag(q) + [[zeros(n,1),lambda*eye(n)];zeros(1,n+1)] + [zeros(1,n+1);[diag(qq),zeros(n,1)]];
Ptt = expm(s * Q);
Pt = Ptt(o+1,:);
end