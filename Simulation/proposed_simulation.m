% ECE 514 project
% developer: Ruilin Wang
% 2023/11/30

%% the developing version of simulation system
% 1.parking lot is modeled by Markov Chain model and M/M/m/m Queue model
% reference: "Finding Available Parking Spaces Made Easy"
%            "Predicting Parking Lot Occupancy in Vehicular Ad Hoc Networks"
% 2.recommendation system is designed based on the prediction of parking lot
% occupency and time for finding a vacant space in parking lot

clear all
close all
clc
%% simulation metrics
period = 30; % period time (min) for computing the features for parking lot
full_percentage = 0.97;
num_samples = 1000;

%% generate some random data samples

% samples: Nx5 matrix for each row:[Td, Ta, Tl, d, Tr]
%Td: departure time (min)
%Ta: arrival time (5 <= Ta - Td <= 30) (min)
%Tl: leave time (60 <= Tl - Ta) (min)
%d: destination building number (1~10)
%Tr: random arriving second (0~59) (second)

% random generate data samples
% random_departure = randi([420, 600], 1000, 1);
% random_arrival = random_departure + randi([5, 30], 1000, 1);
% random_leave = random_arrival + randi([60, 420], 1000, 1);
% random_destination = randi([1, 10], 1000, 1);
% random_second = randi([0, 59], 1000, 1);
% samples = [random_departure,random_arrival,random_leave,random_destination,random_second];
% dataset = sortrows(samples, 1);

% read data samples from dataset
load("dataset.mat");

% generate random index of row
rowCount = size(Dataset, 1); % num of rows in Dataser
% pick num_samples of different index randomly
randIndices = randperm(rowCount, num_samples); 
% pick dataset
dataset = Dataset(randIndices, :);


% reciever for the result
left = [];

% wasting time counter
waste = 0; 
%% read constant features
load("campus_feature.mat");

%% generate buffer

% for every parking lot
parking_lot = cell(1,14);

for i = 1:14
    park_size = park_capacity(i,:);
    % generate buffer
    lot_model = zeros([park_size(2),6]);
    % fill buffer with the overnight cars
    num_cars = park_size(1);
    cars_departure = ones([num_cars,1]) * -1;
    cars_arrival = randi([1, 1440], num_cars, 1);
    cars_leave = cars_arrival + 1440;
    cars_destination = ones([num_cars,1]) * -2;
    cars_second = randi([0, 59], num_cars, 1);
    lot_model(1:num_cars,:) = [zeros([num_cars,1]),cars_departure,cars_arrival,cars_leave,cars_destination,cars_second];
    % save lotmodel into parking_lot
    parking_lot{1,i} = lot_model;
end

% for on the way
onroad = [];

% save("testset1.mat","dataset","parking_lot");

%% simulating the system by every minutes

% get the index
index = unique(dataset(:,1))';
index_min = min(dataset(:,1));
index_max = max(dataset(:,3));

%% begin iteration for every minutes
tic;
for i = index_min:index_max
    % i = 720;

    %% recommend parking lots for departure samples
    if ismember(i,index)
        % get the samples departure in this minute
        frame = dataset(dataset(:, 1) == i, :);
        [frame_length,~] = size(frame);

        % Compute the features for each parking lot
        lot_feature = zeros([frame_length,4]);
        for n = 1:14
            lot_model = parking_lot{1,n};
            capacity = length(lot_model);
            occupancy = sum(~all(lot_model == 0, 2));
            lot_model = lot_model(lot_model(:, 5) ~= 0, :);
            mu = 1/(mean(lot_model(:,4) - lot_model(:,3)) * 60);
            % remove overnight cars
            lot_model = lot_model(lot_model(:, 2) ~= -1, :);
            period_start = i - period;
            num_arrival = sum(lot_model(:,3) > period_start,"all");
            lambda = num_arrival/(period * 60); % arrival rate per second
            lot_feature(n,:) = [lambda,mu,occupancy,capacity];
        end

        % Compute the recommended parking lot
        for n = 1:frame_length
            departure_sample = frame(n,:);
            [predicted_time,recommended_lot] = recommend(departure_sample,lot_feature,...
                Tf,walk_time);
            % save recommended_lot variable in the onroad buffer
            onroad = [onroad;[predicted_time,recommended_lot,departure_sample]];
        end

        % resort the onroad buffer as the ascending of arrival time
        %     onroad = sortrows(onroad, 4);
    end

    %% put samples in onroad into every parking lot after arrival

    if ismember(i,onroad(:,4))
        % 2.get the samples arrive in this minute
        arrivals = onroad(onroad(:, 4) == i, :);
        [arrivals_length,~] = size(arrivals);
        arrivals = sortrows(arrivals, 7);
        % 3.save these samples in parking lot buffers respectively
        for n = 1:arrivals_length
            parking_sample = arrivals(n,3:end);
            parking_time = arrivals(n,1);
            lot_num = arrivals(n,2);
            % find the vacant space
            nonZeroRows = any(parking_lot{1,lot_num}, 2);
            occupancy_num = sum(nonZeroRows,"all");

            % if parking lot is full
            if occupancy_num > full_percentage * ceil(park_capacity(lot_num,2))
                % add extract time to Ta: finding time and on the way to next
                % parking lot (2min)
                waste_time = exp(log(1 + park_capacity(lot_num,2)/120)) + 2;
                parking_sample(1,2) = parking_sample(1,2) + 2;

                % recommand a new parking lot
                % Compute the features for each parking lot
                lot_feature = zeros([frame_length,4]);
                for j = 1:14
                    lot_model = parking_lot{1,j};
                    capacity = length(lot_model);
                    occupancy = sum(~all(lot_model == 0, 2));
                    lot_model = lot_model(lot_model(:, 5) ~= 0, :);
                    mu = 1/(mean(lot_model(:,4) - lot_model(:,3)) * 60);
                    % remove overnight cars
                    lot_model = lot_model(lot_model(:, 2) ~= -1, :);
                    period_start = i - period;
                    num_arrival = sum(lot_model(:,3) > period_start,"all");
                    lambda = num_arrival/(period * 60); % arrival rate per second
                    lot_feature(j,:) = [lambda,mu,occupancy,capacity];
                end
                [predicted_time,recommended_lot] = recommend(parking_sample,lot_feature,...
                    Tf,walk_time);
                % resave recommended_lot variable in the onroad buffer
                predicted_time = predicted_time + waste_time;
                onroad = [onroad;[predicted_time,recommended_lot,parking_sample]];

                % remind the waste of time occurs
                waste = waste + 1;
                fprintf("waste time happens %d parking lot: %d\n",waste,lot_num);
            else
                vacancy = find(nonZeroRows == 0, 1); % the avaliable space
                % save new arrived car in the parking lot buffer
                parking_lot{1,lot_num}(vacancy,:) = [parking_time,parking_sample];
            end

        end
        % remove arrived samples from onroad buffer
        onroad = onroad(onroad(:, 4) ~= i, :);
    end


    %% make the samples leave the parking lot buffer
    for n = 1:14
        lot_buffer = parking_lot{1,n};
        % find is there cars going to leave
        if ismember(i,lot_buffer(:,4))
            % find the leaving samples
            indices = find(lot_buffer(:, 4) == i);
            % remove the leaving samples to left matrix
            leaving_samples = lot_buffer(indices,:);
            leaving_samples = [leaving_samples,n * ones([length(indices),1])];
            lot_buffer(indices,:) = 0;
            % save leaving samples to left matrix
            left = [left;leaving_samples];
            parking_lot{1,n} = lot_buffer;
        end
    end
 
    % Print the process
    fprintf('%3.0f%%\n', (i - index_min)/(index_max - index_min + 1)*100);
end

elapsedTime = toc; 
fprintf('running time：%f s\n', elapsedTime);

% save("1st_try_result.mat","left","waste");

average_parking_time = mean(left(:,1));

