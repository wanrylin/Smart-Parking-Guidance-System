function [predicted_time, recommended_lot] = recommend(sample,lot_feature,...
    Tf,walk_time)
% recommendation system due to the Prediction of Markov Chain model

%sample: [td,ta,tl,d,tr]
% td: departure time (min) (0 ~ 24 x 60)
% ta: arrival time (min) (0 ~ 24 x 60)
% tl: leave time (min) (0 ~ 24 x 60)
% d: destination building (index) (1 ~ 10)

%lot_feature: 14x5 matrix for every row [lambda, mu, o,n,tr]
% lambda: arrival rate
% mu: parking rate = 1/(expected parking time)
% n: parking space number
% o: occupied space number
% tr: random generated time indicates the accurate arrival time to second
% (second) (0 ~ 59)

%Tf: 2x14 cell Predicted time for finding a vacant space
% 1st row: each element is a vector predicted finding time
% 2nd row: each element is a mask for last 3% elements 1000 and others 1

%walk_time: a 14x10 matrix for walking time from parking lots to buildings 


% function begin

% get variables
td = sample(1);
ta = sample(2);
d = sample(4);
tr = sample(5);

% time on the road
T = (ta - td) * 60 + tr;

% Markov Model Prediction
% Mp = cell(1,14);
for i = 1:14
    % compute Markov Model
    lambda = lot_feature(i,1);
    mu = lot_feature(i,2);
    o = lot_feature(i,3);
    n = lot_feature(i,4);
    M_prob = Markov_Model(lambda,mu,n,T,o);
%     Mp{1,i} = M_prob;
    Et(i) = sum(M_prob .* Tf{1,i} .* Tf{2,i});
end

% compute walk time
Ct = walk_time(:,d)';

% recommending
Pt = Et + Ct; % total time
[predicted_time, recommended_lot] = min(Pt);

end