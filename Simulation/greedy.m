function recommended_lot = greedy(sample,walk_time)
%recommend the parking lot which is the closest to the destination

%sample: [td,ta,tl,d,tr]
% td: departure time (min) (0 ~ 24 x 60)
% ta: arrival time (min) (0 ~ 24 x 60)
% tl: leave time (min) (0 ~ 24 x 60)
% d: destination building (index) (1 ~ 10)

%walk_time: a 14x10 matrix for walking time from parking lots to buildings 

%search_time: how many times it has tried


d = sample(4);
search_times = sample(6);
% compute walk time
Ct = walk_time(:,d)';
% ascending the walk time
[~, order] = sort(Ct);
% always recommend the closest parking lot
recommended_lot = order(search_times);
end