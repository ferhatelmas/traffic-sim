clear all; % clear all predefined variables
close all; % close all plot screens

%------------- Adjustable parameters -------------%
car_length = 4; % in meters
simulation_run_length = 60; % in minutes

velocity_limit_low = 20;  % low speed of the generated cars in km/h
velocity_limit_high = 60; % high speed of the generated cars in km/h

%	in one minute at the average
%	0.9  for 40 cars
%	1.15 for 35 cars
%	1.4  for 30 cars 
%	1.85 for 25 cars 
%	2.4  for 20 cars
avg_car_generation_number = 1.4;

occupancy_constant_LD = 6; % in feets

% interval used in California, Minnesota, SMD ...
d_time_interval = 5; % in minutes

%-------------------------------------------------%

%------------- one car stop variables ------------%
line = 0; % 0 for left line, 1 for right line
section = 4; % 0 for 1-1000km, 1 for 1001-2000km, 2 for 2001-3000km, 3 for 3001-4000km, 4 for 4001-5000km, 
time = 20; % round(rand()*simulation_run_length*.8333); % specifies the minute in which car started to stop 
duration = 41; % round(rand()*simulation_run_length*.1667); % specifies the number of minutes in which car have stopped
%-------------------------------------------------%


%------------- California Algorithm --------------%
t1_threshold = .1;
t2_threshold = .1;
t3_threshold = .1;

occdf_first = [];
occdf_second = [];
occdf_third = [];
occdf_fourth = [];
occdf_fifth = [];

occrdf_first = [];
occrdf_second = [];
occrdf_third = [];
occrdf_fourth = [];
occrdf_fifth = [];

docctd_first = [];
docctd_second = [];
docctd_third = [];
docctd_fourth = [];
docctd_fifth = [];

% 0 for no incident, 1 for incident existance
california_incident_detector_first = [];
california_incident_detector_second = [];
california_incident_detector_third = [];
california_incident_detector_fourth = [];
california_incident_detector_fifth = []; 
%-------------------------------------------------%

%------------- Minnesota Algorithm --------------%
t1_minnesota = .1;
tc_minnesota = .1;

delta_occ_first = [];
delta_occ_second = [];
delta_occ_third = [];
delta_occ_fourth = [];
delta_occ_fifth = [];

delta_occ_d_first = [];
delta_occ_d_second = [];
delta_occ_d_third = [];
delta_occ_d_fourth = [];
delta_occ_d_fifth = [];

max_occ_first = [];
max_occ_second = [];
max_occ_third = [];
max_occ_fourth = [];
max_occ_fifth = [];

% 0 for no incident, 1 for incident existance
minnesota_incident_detector_first = [];
minnesota_incident_detector_second = [];
minnesota_incident_detector_third = [];
minnesota_incident_detector_fourth = [];
minnesota_incident_detector_fifth = []; 
%-------------------------------------------------%

%------------- SMD --------------%
ts_threshold = .1;

% 0 for no incident, 1 for incident existance
smd_incident_detector_first = [];
smd_incident_detector_second = [];
smd_incident_detector_third = [];
smd_incident_detector_fourth = [];
smd_incident_detector_fifth = []; 
%-------------------------------------------------%

%------------- vector declarations -------------%
velocity_left = [];  % the vector that holds the velocities of the cars on the left line
velocity_right = []; % the vector that holds the velocities of the cars on the right line

cars_left = []; % the vector that holds the locations of the cars on the left line
cars_right = []; % the vector that holds the locations of the cars on the right line

% the vectors that holds the inflow and outflow of the right and left sections
q1in = [];
q1out = [];
q2in = [];
q2out = [];
q3in = [];
q3out = [];
q4in = [];
q4out = [];
q5in = [];
q5out = [];

% the vectors that holds average velocities of the right and left sections
avg_velocity_first_left = [];
avg_velocity_second_left = [];
avg_velocity_third_left = [];
avg_velocity_fourth_left = [];
avg_velocity_fifth_left = [];
avg_velocity_first_right = [];
avg_velocity_second_right = [];
avg_velocity_third_right = [];
avg_velocity_fourth_right = [];
avg_velocity_fifth_right = [];

% the vectors that holds densities of the right and left sections
density_first_left = [];
density_second_left = [];
density_third_left = [];
density_fourth_left = [];
density_fifth_left = [];
density_first_right = [];
density_second_right = [];
density_third_right = [];
density_fourth_right = [];
density_fifth_right = [];

% the vectors that holds occupancies of the right and left sections
occupancy_first_left = [];
occupancy_second_left = [];
occupancy_third_left = [];
occupancy_fourth_left = [];
occupancy_fifth_left = [];
occupancy_first_right = [];
occupancy_second_right = [];
occupancy_third_right = [];
occupancy_fourth_right = [];
occupancy_fifth_right = [];
%-------------------------------------------------%

%--------------- One car stop flags --------------%
cars_stop_left = []; % the vector that holds the flags of cars on the left line whether cars must stop or not; 0 for not, 1 for stop
cars_stop_right = []; % the vector that holds the flags of cars on the right line whether car must stop or not; 0 for not, 1 for stop

stop_list = [];

is_stop_successful = 0; % to check whether stop is successful
%-------------------------------------------------%


% conversion of km/h to m/sec
velocity_limit_low = round(velocity_limit_low * 1000 / 3600);
velocity_limit_high = round(velocity_limit_high * 1000 / 3600);

% calculation of occupancy divisor
% car_length is converted from meters to feets
occupancy_divisor = 5280 / ((occupancy_constant_LD + car_length / .3048) * 1.609);

% initial number of cars in each section
first_section_old_number_of = 0;
second_section_old_number_of = 0;
third_section_old_number_of = 0;
fourth_section_old_number_of = 0;
fifth_section_old_number_of = 0;

% main simulation loop that iterates in minutes
for simulation_length_min=1:simulation_run_length 
	
	%------ initializations of the vectors for minute by minute macro calculations ------%
	generated_cars_number_of = 0;
	
	avg_velocity_first_left = [avg_velocity_first_left, 0];
	avg_velocity_second_left = [avg_velocity_second_left, 0];
	avg_velocity_third_left = [avg_velocity_third_left, 0];
	avg_velocity_fourth_left = [avg_velocity_fourth_left, 0];
	avg_velocity_fifth_left = [avg_velocity_fifth_left, 0];
	avg_velocity_first_right = [avg_velocity_first_right, 0];
	avg_velocity_second_right = [avg_velocity_second_right, 0];
	avg_velocity_third_right = [avg_velocity_third_right, 0];
	avg_velocity_fourth_right = [avg_velocity_fourth_right, 0];
	avg_velocity_fifth_right = [avg_velocity_fifth_right, 0];
	
	density_first_left = [density_first_left, 0];
	density_second_left = [density_second_left, 0];
	density_third_left = [density_third_left, 0];
	density_fourth_left = [density_fourth_left, 0];
	density_fifth_left = [density_fifth_left, 0];
	density_first_right = [density_first_right, 0];
	density_second_right = [density_second_right, 0];
	density_third_right = [density_third_right, 0];
	density_fourth_right = [density_fourth_right, 0];
	density_fifth_right = [density_fifth_right, 0];
	%-------------------------------------------------%

	if simulation_length_min == time
		if line == 0
			for i=1:length(cars_left)
				if cars_left(i) > 1000 * section && cars_left(i) <= 1000 * (section + 1)
					stop_list = [stop_list, i];
				end
			end
			if length(stop_list) > 0 
				is_stop_successful = 1;
				cars_stop_left(stop_list(round(length(stop_list)/2))) = 1;
				velocity_left(stop_list(round(length(stop_list)/2))) = 0;
			end	
		else 
			for i=1:length(cars_right)
				if cars_right(i) > 1000 * section && cars_right(i) <= 1000 * (section + 1)
					stop_list = [stop_list, i];
				end
			end
			if length(stop_list) > 0 
				is_stop_successful = 1;
				cars_stop_right(stop_list(round(length(stop_list)/2))) = 1;
				velocity_right(stop_list(round(length(stop_list)/2))) = 0;
			end	
		end
	elseif simulation_length_min == time + duration
		if line == 0
			for i=1:length(cars_left) 
				if cars_stop_left(i) == 1
					cars_stop_left(i) = 0;
					break;
				end
			end
		else
			for i=1:length(cars_right) 
				if cars_stop_right(i) == 1
					cars_stop_right(i) = 0;
					break;
				end
			end
		end
	end
	
	
	% main simulation loop that iterates in seconds
	for simulation_length_sec=1:60 %fixed
	
		% Car Generation Operations
		if exprnd(avg_car_generation_number) < 1
			generated_velocity = randi([velocity_limit_low, velocity_limit_high], 1, 1);
			generated_cars_number_of = generated_cars_number_of + 1;
			% choose line of new car according to occupancy
			% 0 for right line, 1 for left line, 2 for none
			% if both lines are not appropriate, then do not generate a car
			if (length(cars_right) > 0 && cars_right(1) < car_length + 1) && (length(cars_left) > 0 && cars_left(1) < car_length + 1) 				
				generated_line = 2;
				generated_cars_number_of = generated_cars_number_of - 1;
				
			% if right is not appropriate, generate for left
			elseif length(cars_right) > 0 && cars_right(1) < car_length + 1
				generated_line = 1;
				is_other_to_be_checked = 0;
			
			% if left is not appropriate, generate for right
			elseif length(cars_left) > 0 && cars_left(1) < car_length + 1
				generated_line = 0;
				is_other_to_be_checked = 0;
			
			% if both are appropriate, choose one randomly
			else 
				generated_line = round(rand());
				is_other_to_be_checked = 1;				
			end
			
			% if chosen line is right
			if generated_line == 0
	
				% if right line is empty, put the car directly
				if length(cars_right) == 0
					cars_right = randi([1, generated_velocity], 1, 1);
					velocity_right = [generated_velocity];
					cars_stop_right = [0];
				else
					% if left line is not appropriate, then try to put the car to the right line with varied headways
					% this will succeed since right line is checked at first and has at least one available position
					if is_other_to_be_checked == 0 
					
						% first try for 2 sec headway 
						headway = 2 * generated_velocity;
						if cars_right(1)-car_length-headway>0
							cars_right = [randi([1, cars_right(1)-car_length-headway], 1, 1), cars_right];
							velocity_right = [generated_velocity, velocity_right];
							cars_stop_right = [0, cars_stop_right];
						% second try for 1 sec headway
						else
							headway = 1 * generated_velocity;
							if cars_right(1)-car_length-headway>0
								cars_right = [randi([1, cars_right(1)-car_length-headway], 1, 1), cars_right];
								velocity_right = [generated_velocity, velocity_right];
								cars_stop_right = [0, cars_stop_right];
							% third try for 0.5 sec headway
							else
								headway = round(0.5 * generated_velocity);
								if cars_right(1)-car_length-headway>0
									cars_right = [randi([1, cars_right(1)-car_length-headway], 1, 1), cars_right];
									velocity_right = [generated_velocity, velocity_right];
									cars_stop_right = [0, cars_stop_right];
								% last try for no headway
								else 
									cars_right = [randi([1, cars_right(1)-car_length], 1, 1), cars_right];
									velocity_right = [generated_velocity, velocity_right];
									cars_stop_right = [0, cars_stop_right];
								end
							end
						end
					% if left line is also appropriate, then try one of them with varied headways but favor the right line
					% this will succeed since one of the lines has at least one available position
					else
						% first try for 2 sec headway 
						headway = 2 * generated_velocity;
						% try for right
						if cars_right(1)-car_length-headway>0
							cars_right = [randi([1, cars_right(1)-car_length-headway], 1, 1), cars_right];
							velocity_right = [generated_velocity, velocity_right];
							cars_stop_right = [0, cars_stop_right];
						% if right fails, then try for left
						else
							% if left line is empty, put the car directly
							if length(cars_left) == 0
								cars_left = randi([1, generated_velocity], 1, 1);
								velocity_left = [generated_velocity];
								cars_stop_left = [0];
							% try for left
							elseif cars_left(1)-car_length-headway>0
								cars_left = [randi([1, cars_left(1)-car_length-headway], 1, 1), cars_left];
								velocity_left = [generated_velocity, velocity_left];
								cars_stop_left = [0, cars_stop_left];
							% second try for 1 sec headway 
							else 
								headway = 1 * generated_velocity;
								% try for right
								if cars_right(1)-car_length-headway>0
									cars_right = [randi([1, cars_right(1)-car_length-headway], 1, 1), cars_right];
									velocity_right = [generated_velocity, velocity_right];
									cars_stop_right = [0, cars_stop_right];
								% try for left
								elseif cars_left(1)-car_length-headway>0
									cars_left = [randi([1, cars_left(1)-car_length-headway], 1, 1), cars_left];
									velocity_left = [generated_velocity, velocity_left];
									cars_stop_left = [0, cars_stop_left];
								% third try for 0.5 sec headway 
								else
									headway = round(0.5 * generated_velocity);
									% try for right
									if cars_right(1)-car_length-headway>0
										cars_right = [randi([1, cars_right(1)-car_length-headway], 1, 1), cars_right];
										velocity_right = [generated_velocity, velocity_right];
										cars_stop_right = [0, cars_stop_right];
									% try for left
									elseif cars_left(1)-car_length-headway>0
										cars_left = [randi([1, cars_left(1)-car_length-headway], 1, 1), cars_left];
										velocity_left = [generated_velocity, velocity_left];
										cars_stop_left = [0, cars_stop_left];
									% last try for no headway just for right
									else 
										cars_right = [randi([1, cars_right(1)-car_length], 1, 1), cars_right];
										velocity_right = [generated_velocity, velocity_right];
										cars_stop_right = [0, cars_stop_right];
									end
								end
							end
						end
					end
				end
				
			% if chosen line is left
			elseif generated_line == 1 
				
				% if left line is empty, put the car directly
				if length(cars_left) == 0
					cars_left = randi([1, generated_velocity], 1, 1);
					velocity_left = [generated_velocity];	
					cars_stop_left = [0];
				else
					% if right line is not appropriate, then try to put the car to the left line with varied headways
					% this will succeed since left line is checked at first and has at least one available position
					if is_other_to_be_checked == 0 
					
						% first try for 2 sec headway 
						headway = 2 * generated_velocity;
						if cars_left(1)-car_length-headway>0
							cars_left = [randi([1, cars_left(1)-car_length-headway], 1, 1), cars_left];
							velocity_left = [generated_velocity, velocity_left];
							cars_stop_left = [0, cars_stop_left];
						% second try for 1 sec headway
						else
							headway = 1 * generated_velocity;
							if cars_left(1)-car_length-headway>0
								cars_left = [randi([1, cars_left(1)-car_length-headway], 1, 1), cars_left];
								velocity_left = [generated_velocity, velocity_left];
								cars_stop_left = [0, cars_stop_left];
							% third try for 0.5 sec headway
							else
								headway = round(0.5 * generated_velocity);
								if cars_left(1)-car_length-headway>0
									cars_left = [randi([1, cars_left(1)-car_length-headway], 1, 1), cars_left];
									velocity_left = [generated_velocity, velocity_left];
									cars_stop_left = [0, cars_stop_left];
								% last try for no headway
								else 
									cars_left = [randi([1, cars_left(1)-car_length], 1, 1), cars_left];
									velocity_left = [generated_velocity, velocity_left];
									cars_stop_left = [0, cars_stop_left];
								end
							end
						end
					% if right line is also appropriate, then try one of them with varied headways but favor the left line
					% this will succeed since one of the lines has at least one available position
					else
						% first try for 2 sec headway 
						headway = 2 * generated_velocity;
						% try for left
						if cars_left(1)-car_length-headway>0
							cars_left = [randi([1, cars_left(1)-car_length-headway], 1, 1), cars_left];
							velocity_left = [generated_velocity, velocity_left];
							cars_stop_left = [0, cars_stop_left];
						% if left fails, then try for right
						else
							% if right line is empty, put the car directly
							if length(cars_right) == 0
								cars_right = randi([1, generated_velocity], 1, 1);
								velocity_right = [generated_velocity];
								cars_stop_right = [0];
							% try for right
							elseif cars_right(1)-car_length-headway>0
								cars_right = [randi([1, cars_right(1)-car_length-headway], 1, 1), cars_right];
								velocity_right = [generated_velocity, velocity_right];
								cars_stop_right = [0, cars_stop_right];
							% second try for 1 sec headway 
							else 
								headway = 1 * generated_velocity;
								% try for left
								if cars_left(1)-car_length-headway>0
									cars_left = [randi([1, cars_left(1)-car_length-headway], 1, 1), cars_left];
									velocity_left = [generated_velocity, velocity_left];
									cars_stop_left = [0, cars_stop_left];
								% try for right
								elseif cars_right(1)-car_length-headway>0
									cars_right = [randi([1, cars_right(1)-car_length-headway], 1, 1), cars_right];
									velocity_right = [generated_velocity, velocity_right];
									cars_stop_right = [0, cars_stop_right];
								% third try for 0.5 sec headway 
								else
									headway = round(0.5 * generated_velocity);
									% try for left
									if cars_left(1)-car_length-headway>0
										cars_left = [randi([1, cars_left(1)-car_length-headway], 1, 1), cars_left];
										velocity_left = [generated_velocity, velocity_left];
										cars_stop_left = [0, cars_stop_left];
									% try for right
									elseif cars_right(1)-car_length-headway>0
										cars_right = [randi([1, cars_right(1)-car_length-headway], 1, 1), cars_right];
										velocity_right = [generated_velocity, velocity_right];
										cars_stop_right = [0, cars_stop_right];
									% last try for no headway just for left
									else 
										cars_left = [randi([1, cars_left(1)-car_length], 1, 1), cars_left];
										velocity_left = [generated_velocity, velocity_left];
										cars_stop_left = [0, cars_stop_left];
									end
								end
							end
						end
					end
				end
			end
		end
	
		% the vectors that holds the locations and velocities of the processed cars 
		temp_velocity_left = [];
		temp_velocity_right = [];
		temp_cars_left = [];
		temp_cars_right = [];
		
		% the vectors that holds the stop flags of the processed cars
		temp_cars_stop_left = [];
		temp_cars_stop_right = [];
	
		% the number of the cars on the road 
		for_length = length(cars_left) + length(cars_right);
		
		% Car Movement Operations
		% the main loop that iterates for each car on the road
		for i=1:for_length
			
			% if 
			% there are cars only on the left line
			% or
			% 	there are cars on the left and right lines 
			% 	and 
			% 		the location of the left car is smaller than the location of the right car
			%		or
			% 		the locations are same but left car is faster than the right car
			% then the left line is selected
			if (length(cars_left) > 0 && length(cars_right) > 0 && (cars_left(1) < cars_right(1) || (cars_left(1) == cars_right(1) && velocity_left(1) >= velocity_right(1)))) || (length(cars_left) > 0 && length(cars_right) == 0)
				
				% get the location and velocity of the first car of the left line
				left_car = cars_left(1);  
				left_velocity = velocity_left(1);
				left_stop = cars_stop_left(1);
				
				if left_stop == 1 
					if length(temp_cars_left) == 0
						temp_cars_left = [left_car];
						temp_velocity_left = [left_velocity];
						temp_cars_stop_left = [left_stop];
					elseif length(temp_cars_left) == 1
						if temp_cars_left(1) < left_car
							temp_cars_left = [temp_cars_left, left_car];
							temp_velocity_left = [temp_velocity_left, left_velocity];
							temp_cars_stop_left = [temp_cars_stop_left, left_stop];
						else
							temp_cars_left = [left_car, temp_cars_left];
							temp_velocity_left = [left_velocity, temp_velocity_left];
							temp_cars_stop_left = [left_stop, temp_cars_stop_left];
						end
					else
						for l=1:length(temp_cars_left)
							if temp_cars_left(l) > left_car
								temp_cars_left = [temp_cars_left(1:l-1), left_car, temp_cars_left(l:end)];
								temp_velocity_left = [temp_velocity_left(1:l-1), left_velocity, temp_velocity_left(l:end)];
								temp_cars_stop_left = [temp_cars_stop_left(1:l-1), left_stop, temp_cars_stop_left(l:end)];
								break;
							elseif l == length(temp_cars_left)
								temp_cars_left = [temp_cars_left, left_car];
								temp_velocity_left = [temp_velocity_left, left_velocity];
								temp_cars_stop_left = [temp_cars_stop_left, left_stop];
							end
						end
					end
					
					cars_left = cars_left(2:end);
					velocity_left = velocity_left(2:end);
					cars_stop_left = cars_stop_left(2:end);
					
					continue;
				end
				
				% get the nearest car that is in front of left_car from vector of the processed cars if exists
				temp_head_forward = -1;
				for j=1:length(temp_cars_left) 
					if temp_cars_left(j) > left_car
						temp_head_forward = temp_cars_left(j);
						break;
					end
				end
				
				% Road is empty, only left_car is exists on left line
				if length(cars_left) == 1 && temp_head_forward == -1
					
					% accelarate the car by 4 m/s**2
					if left_velocity < 21 
						left_car = left_car + left_velocity + 2;
						left_velocity = left_velocity + 4;
					else 
						left_car = left_car + round((left_velocity + 25) / 2);
						left_velocity = 25;
					end
					
					% add the car to the velocity and location vectors of the processed cars
					if left_car <= 5000
						if length(temp_cars_left) == 0
							temp_cars_left = [left_car];
							temp_velocity_left = [left_velocity];
							temp_cars_stop_left = [left_stop];
						elseif length(temp_cars_left) == 1
							if temp_cars_left(1) < left_car
								temp_cars_left = [temp_cars_left, left_car];
								temp_velocity_left = [temp_velocity_left, left_velocity];
								temp_cars_stop_left = [temp_cars_stop_left, left_stop];
							else
								temp_cars_left = [left_car, temp_cars_left];
								temp_velocity_left = [left_velocity, temp_velocity_left];
								temp_cars_stop_left = [left_stop, temp_cars_stop_left];
							end
						else
							for l=1:length(temp_cars_left)
								if temp_cars_left(l) > left_car
									temp_cars_left = [temp_cars_left(1:l-1), left_car, temp_cars_left(l:end)];
									temp_velocity_left = [temp_velocity_left(1:l-1), left_velocity, temp_velocity_left(l:end)];
									temp_cars_stop_left = [temp_cars_stop_left(1:l-1), left_stop, temp_cars_stop_left(l:end)];
									break;
								elseif l == length(temp_cars_left)
									temp_cars_left = [temp_cars_left, left_car];
									temp_velocity_left = [temp_velocity_left, left_velocity];
									temp_cars_stop_left = [temp_cars_stop_left, left_stop];
								end
							end
						end
					end
					
					% remove the car from the actual velocity and location vectors
					cars_left = [];
					velocity_left = [];
					cars_stop_left = [];
				
				% There are other cars
				% think about [de, ac]celaration and/or takeover
				else 
					
					% choose the car that is in front of us(processed or actual vector) 
					if length(cars_left) > 1 && temp_head_forward == -1
						state = cars_left(2);
					elseif length(cars_left) == 1 && temp_head_forward > -1
						state = temp_head_forward;
					else
						if cars_left(2) < temp_head_forward
							state = cars_left(2);
						else
							state = temp_head_forward;
						end
					end
					
					% calculate spacing, state is the location of the head car
					distance = state - left_car - car_length;
					
					% spacing is sufficient to protect the 2 headway with acceleration
					if distance > 3 * left_velocity
						
						if left_velocity == 0 && state - left_car - car_length < 2
							temp_cars_left = [temp_cars_left, left_car];
							temp_velocity_left = [temp_velocity_left, left_velocity];
							temp_cars_stop_left = [temp_cars_stop_left, left_stop];
							
							cars_left = cars_left(2:end);
							velocity_left = velocity_left(2:end);
							cars_stop_left = cars_stop_left(2:end);
						else
							if left_velocity < 21
								path = left_velocity + 2;
								left_velocity = left_velocity + 4;
							else
								path = round((left_velocity + 25) / 2);
								left_velocity = 25;
							end
							
							left_car = left_car + path;
						
							if left_car <= 5000
								if length(temp_cars_left) == 0
									temp_cars_left = [left_car];
									temp_velocity_left = [left_velocity];
									temp_cars_stop_left = [left_stop];
								elseif length(temp_cars_left) == 1
									if temp_cars_left(1) < left_car
										temp_cars_left = [temp_cars_left, left_car];
										temp_velocity_left = [temp_velocity_left, left_velocity];
										temp_cars_stop_left = [temp_cars_stop_left, left_stop];
									else
										temp_cars_left = [left_car, temp_cars_left];
										temp_velocity_left = [left_velocity, temp_velocity_left];
										temp_cars_stop_left = [left_stop, temp_cars_stop_left];
									end
								else
									for l=1:length(temp_cars_left)
										if temp_cars_left(l) > left_car
											temp_cars_left = [temp_cars_left(1:l-1), left_car, temp_cars_left(l:end)];
											temp_velocity_left = [temp_velocity_left(1:l-1), left_velocity, temp_velocity_left(l:end)];
											temp_cars_stop_left = [temp_cars_stop_left(1:l-1), left_stop, temp_cars_stop_left(l:end)];
											break;
										elseif l == length(temp_cars_left)
											temp_cars_left = [temp_cars_left, left_car];
											temp_velocity_left = [temp_velocity_left, left_velocity];
											temp_cars_stop_left = [temp_cars_stop_left, left_stop];
										end
									end
								end
							end
							
							cars_left = cars_left(2:end);
							velocity_left = velocity_left(2:end);
							cars_stop_left = cars_stop_left(2:end);
							
						end
						
					% spacing is sufficient to protect the 2 headway without acceleration, continue with current velocity
					elseif distance == 3 * left_velocity
						
						left_car = left_car + left_velocity;
					
						if left_car <= 5000
							if length(temp_cars_left) == 0
								temp_cars_left = [left_car];
								temp_velocity_left = [left_velocity];
								temp_cars_stop_left = [left_stop];
							elseif length(temp_cars_left) == 1
								if temp_cars_left(1) < left_car
									temp_cars_left = [temp_cars_left, left_car];
									temp_velocity_left = [temp_velocity_left, left_velocity];
									temp_cars_stop_left = [temp_cars_stop_left, left_stop];
								else
									temp_cars_left = [left_car, temp_cars_left];
									temp_velocity_left = [left_velocity, temp_velocity_left];
									temp_cars_stop_left = [left_stop, temp_cars_stop_left];
								end
							else
								for l=1:length(temp_cars_left)
									if temp_cars_left(l) > left_car
										temp_cars_left = [temp_cars_left(1:l-1), left_car, temp_cars_left(l:end)];
										temp_velocity_left = [temp_velocity_left(1:l-1), left_velocity, temp_velocity_left(l:end)];
										temp_cars_stop_left = [temp_cars_stop_left(1:l-1), left_stop, temp_cars_stop_left(l:end)];
										break;
									elseif l == length(temp_cars_left)
										temp_cars_left = [temp_cars_left, left_car];
										temp_velocity_left = [temp_velocity_left, left_velocity];
										temp_cars_stop_left = [temp_cars_stop_left, left_stop];
									end
								end
							end
						end
						
						cars_left = cars_left(2:end);
						velocity_left = velocity_left(2:end);
						cars_stop_left = cars_stop_left(2:end);
						
					% spacing is not sufficient to protect the 2 headway with(out) acceleration
					% check for the possibility of the takeover
					else 
					
						% initially attempt to increase the velocity
						pass_velocity = left_velocity;
						if pass_velocity < 21 
							pass_velocity = pass_velocity + 4;
						else 
							pass_velocity = 25;
						end	
						path = round((pass_velocity + left_velocity) / 2);
						
						% the vector that holds the cars that are in the part of the other line that we will use while takeover
						pass_list = [];
						
						head_car = 5075;
						
						% find the cars that are in the part of the other line that we will use while takeover
						for j=1:length(cars_right)
							if cars_right(j) >= left_car && cars_right(j) <= (left_car + path)
								pass_list = [pass_list, cars_right(j)];
							elseif cars_right(j) > (left_car + path)
								head_car = cars_right(j);
								break;
							end
						end
						for j=1:length(temp_cars_right)
							if temp_cars_right(j) >= left_car && temp_cars_right(j) <= (left_car + path)
								pass_list = [pass_list, temp_cars_right(j)];
							elseif temp_cars_right(j) > (left_car + path)
								if temp_cars_right(j) < head_car
									head_car = temp_cars_right(j);
								end
								break;
							end
						end
						
						pass_list = sort(pass_list, 'descend');
						
						% flag for whether takeover is successful or not
						is_pass_successful = 0;
						
						% pass_list is empty so advance the location with protecting the .5 headway 
						if length(pass_list) == 0
						
							for k=path:-1:1
							
								if head_car - left_car - path - car_length >= round(0.5 * pass_velocity)
									is_pass_successful = 1;
									
									left_car = left_car + path;
									pass_velocity = 2 * path - left_velocity; 
									if pass_velocity < 0 
										pass_velocity = 0; 
									elseif pass_velocity > 25
										pass_velocity = 25;
									end
									
									if left_car <= 5000
										if length(temp_cars_right) == 0
											temp_cars_right = [left_car];
											temp_velocity_right = [pass_velocity];
											temp_cars_stop_right = [left_stop];
										elseif length(temp_cars_right) == 1
											if temp_cars_right(1) < left_car
												temp_cars_right = [temp_cars_right, left_car];
												temp_velocity_right = [temp_velocity_right, pass_velocity];
												temp_cars_stop_right = [temp_cars_stop_right, left_stop];
											else
												temp_cars_right = [left_car, temp_cars_right];
												temp_velocity_right = [pass_velocity, temp_velocity_right];
												temp_cars_stop_right = [left_stop, temp_cars_stop_right];
											end
										else
											for l=1:length(temp_cars_right)
												if temp_cars_right(l) > left_car
													temp_cars_right = [temp_cars_right(1:l-1), left_car, temp_cars_right(l:end)];
													temp_velocity_right = [temp_velocity_right(1:l-1), pass_velocity, temp_velocity_right(l:end)];
													temp_cars_stop_right = [temp_cars_stop_right(1:l-1), left_stop, temp_cars_stop_right(l:end)];
													break;
												elseif l == length(temp_cars_right)
													temp_cars_right = [temp_cars_right, left_car];
													temp_velocity_right = [temp_velocity_right, pass_velocity];
													temp_cars_stop_right = [temp_cars_stop_right, left_stop];
												end
											end
										end
									end
									
									cars_left = cars_left(2:end);
									velocity_left = velocity_left(2:end);
									cars_stop_left = cars_stop_left(2:end);
									break;
								else
									path = path - 1;
								end
							end
						end
						
						% try taking over cars as much as you can
						for j=1:length(pass_list)
						
							for k=path:-1:1
							
								if left_car + path - car_length >= pass_list(j) && left_car + distance - pass_list(j) >= car_length && ((j==1 && head_car - left_car - path - car_length >= round(0.5 * pass_velocity)) || (j > 1 && pass_list(j-1) - left_car - path - car_length >= round(0.5 * pass_velocity)))
									is_pass_successful = 1;
									
									left_car = left_car + path;
									pass_velocity = 2 * path - left_velocity;
									if pass_velocity < 0 
										pass_velocity = 0;
									elseif pass_velocity > 25
										pass_velocity = 25;										
									end
									
									if left_car <= 5000
										if length(temp_cars_right) == 0
											temp_cars_right = [left_car];
											temp_velocity_right = [pass_velocity];
											temp_cars_stop_right = [left_stop];
										elseif length(temp_cars_right) == 1
											if temp_cars_right(1) < left_car
												temp_cars_right = [temp_cars_right, left_car];
												temp_velocity_right = [temp_velocity_right, pass_velocity];
												temp_cars_stop_right = [temp_cars_stop_right, left_stop];
											else
												temp_cars_right = [left_car, temp_cars_right];
												temp_velocity_right = [pass_velocity, temp_velocity_right];
												temp_cars_stop_right = [left_stop, temp_cars_stop_right];
											end
										else
											for l=1:length(temp_cars_right)
												if temp_cars_right(l) > left_car
													temp_cars_right = [temp_cars_right(1:l-1), left_car, temp_cars_right(l:end)];
													temp_velocity_right = [temp_velocity_right(1:l-1), pass_velocity, temp_velocity_right(l:end)];
													temp_cars_stop_right = [temp_cars_stop_right(1:l-1), left_stop, temp_cars_stop_right(l:end)];
													break;
												elseif l == length(temp_cars_right)
													temp_cars_right = [temp_cars_right, left_car];
													temp_velocity_right = [temp_velocity_right, pass_velocity];
													temp_cars_stop_right = [temp_cars_stop_right, left_stop];
												end
											end
										end
									end
									
									cars_left = cars_left(2:end);
									velocity_left = velocity_left(2:end);
									cars_stop_left = cars_stop_left(2:end);
									break;
								else
									path = path - 1;
									if left_car + path == pass_list(j) 
										path = path - car_length;
										break;
									end
								end
							
							end
						end
						
						% if we can't enter between cars in the pass_list, try the end of the last car in the pass_list 
						if length(pass_list) > 0 && is_pass_successful == 0
						
							last_distance = pass_list(end) - left_car - round(0.5 * pass_velocity) - car_length;
							
							if  last_distance >= car_length
							
								is_pass_successful = 1;
							
								left_car = left_car + last_distance;
								pass_velocity = 2 * last_distance - left_velocity;
								if pass_velocity < 0 
									pass_velocity = 0;
								elseif pass_velocity > 25
									pass_velocity = 25;
								end
								
								if left_car <= 5000
									if length(temp_cars_right) == 0
										temp_cars_right = [left_car];
										temp_velocity_right = [pass_velocity];
										temp_cars_stop_right = [left_stop];
									elseif length(temp_cars_right) == 1
										if temp_cars_right(1) < left_car
											temp_cars_right = [temp_cars_right, left_car];
											temp_velocity_right = [temp_velocity_right, pass_velocity];
											temp_cars_stop_right = [temp_cars_stop_right, left_stop];
										else
											temp_cars_right = [left_car, temp_cars_right];
											temp_velocity_right = [pass_velocity, temp_velocity_right];
											temp_cars_stop_right = [left_stop, temp_cars_stop_right];
										end
									else
										for l=1:length(temp_cars_right)
											if temp_cars_right(l) > left_car
												temp_cars_right = [temp_cars_right(1:l-1), left_car, temp_cars_right(l:end)];
												temp_velocity_right = [temp_velocity_right(1:l-1), pass_velocity, temp_velocity_right(l:end)];
												temp_cars_stop_right = [temp_cars_stop_right(1:l-1), left_stop, temp_cars_stop_right(l:end)];
												break;
											elseif l == length(temp_cars_right)
												temp_cars_right = [temp_cars_right, left_car];
												temp_velocity_right = [temp_velocity_right, pass_velocity];
												temp_cars_stop_right = [temp_cars_stop_right, left_stop];
											end
										end
									end
								end
								
								cars_left = cars_left(2:end);
								velocity_left = velocity_left(2:end);	
								cars_stop_left = cars_stop_left(2:end);
							end
						end
						
						% if takeover is not possible, decelerate on the same line with 2 headway
						if is_pass_successful == 0
							
							% if spacing is between .5 headway and 3 headway 
							if round(left_velocity / 2) < distance && distance < 3 * left_velocity
								final_speed = round((2 * distance - left_velocity) / 5);
								path = round((left_velocity + final_speed) / 2);
								left_velocity = final_speed;
								
								left_car = left_car + path;
						
								if left_car <= 5000
									if length(temp_cars_left) == 0
										temp_cars_left = [left_car];
										temp_velocity_left = [left_velocity];
										temp_cars_stop_left = [left_stop];
									elseif length(temp_cars_left) == 1
										if temp_cars_left(1) < left_car
											temp_cars_left = [temp_cars_left, left_car];
											temp_velocity_left = [temp_velocity_left, left_velocity];
											temp_cars_stop_left = [temp_cars_stop_left, left_stop];
										else
											temp_cars_left = [left_car, temp_cars_left];
											temp_velocity_left = [left_velocity, temp_velocity_left];
											temp_cars_stop_left = [left_stop, temp_cars_stop_left];
										end
									else
										for l=1:length(temp_cars_left)
											if temp_cars_left(l) > left_car
												temp_cars_left = [temp_cars_left(1:l-1), left_car, temp_cars_left(l:end)];
												temp_velocity_left = [temp_velocity_left(1:l-1), left_velocity, temp_velocity_left(l:end)];
												temp_cars_stop_left = [temp_cars_stop_left(1:l-1), left_stop, temp_cars_stop_left(l:end)];
												break;
											elseif l == length(temp_cars_left)
												temp_cars_left = [temp_cars_left, left_car];
												temp_velocity_left = [temp_velocity_left, left_velocity];
												temp_cars_stop_left = [temp_cars_stop_left, left_stop];
											end
										end
									end
								end
								
								cars_left = cars_left(2:end);
								velocity_left = velocity_left(2:end);
								cars_stop_left = cars_stop_left(2:end);
								
							% spacing is less than .5 headway
							% decelerate, final speed definitely becomes *0* because spacing is so small
							% headway is zero (congestion)
							else
								final_speed = 0;
								left_velocity = final_speed;
								path = distance;
								
								left_car = left_car + path;
					
								if left_car <= 5000
									if length(temp_cars_left) == 0
										temp_cars_left = [left_car];
										temp_velocity_left = [left_velocity];
										temp_cars_stop_left = [left_stop];
									elseif length(temp_cars_left) == 1
										if temp_cars_left(1) < left_car
											temp_cars_left = [temp_cars_left, left_car];
											temp_velocity_left = [temp_velocity_left, left_velocity];
											temp_cars_stop_left = [temp_cars_stop_left, left_stop];
										else
											temp_cars_left = [left_car, temp_cars_left];
											temp_velocity_left = [left_velocity, temp_velocity_left];
											temp_cars_stop_left = [left_stop, temp_cars_stop_left];
										end
									else
										for l=1:length(temp_cars_left)
											if temp_cars_left(l) > left_car
												temp_cars_left = [temp_cars_left(1:l-1), left_car, temp_cars_left(l:end)];
												temp_velocity_left = [temp_velocity_left(1:l-1), left_velocity, temp_velocity_left(l:end)];
												temp_cars_stop_left = [temp_cars_stop_left(1:l-1), left_stop, temp_cars_stop_left(l:end)]; 
												break;
											elseif l == length(temp_cars_left)
												temp_cars_left = [temp_cars_left, left_car];
												temp_velocity_left = [temp_velocity_left, left_velocity];
												temp_cars_stop_left = [temp_cars_stop_left, left_stop];
											end
										end
									end
								end
								
								cars_left = cars_left(2:end);
								velocity_left = velocity_left(2:end);
								cars_stop_left = cars_stop_left(2:end);
							end
						end
					end
				end
			% if 
			% there are cars only on the right line
			% or
			% 	there are cars on the left and right lines 
			% 	and 
			% 		the location of the right car is smaller than the location of the left car
			%		or
			% 		the locations are same but right car is faster than the left car
			% then the right line is selected
			elseif (length(cars_left) > 0 && length(cars_right) > 0 && (cars_left(1) > cars_right(1) || (cars_left(1) == cars_right(1) && velocity_left(1) < velocity_right(1)))) || (length(cars_left) == 0 && length(cars_right) > 0)
				
				% get the location and velocity of the first car of the right line
				right_car = cars_right(1); 
				right_velocity = velocity_right(1); 
				right_stop = cars_stop_right(1);
				
				if right_stop == 1 
					if length(temp_cars_right) == 0
						temp_cars_right = [right_car];
						temp_velocity_right = [right_velocity];
						temp_cars_stop_right = [right_stop];
					elseif length(temp_cars_right) == 1
						if temp_cars_right(1) < right_car
							temp_cars_right = [temp_cars_right, right_car];
							temp_velocity_right = [temp_velocity_right, right_velocity];
							temp_cars_stop_right = [temp_cars_stop_right, right_stop];
						else
							temp_cars_right = [right_car, temp_cars_right];
							temp_velocity_right = [right_velocity, temp_velocity_right];
							temp_cars_stop_right = [right_stop, temp_cars_stop_right];
						end
					else
						for l=1:length(temp_cars_right)
							if temp_cars_right(l) > right_car
								temp_cars_right = [temp_cars_right(1:l-1), right_car, temp_cars_right(l:end)];
								temp_velocity_right = [temp_velocity_right(1:l-1), right_velocity, temp_velocity_right(l:end)];
								temp_cars_stop_right = [temp_cars_stop_right(1:l-1), right_stop, temp_cars_stop_right(l:end)];
								break;
							elseif l == length(temp_cars_right)
								temp_cars_right = [temp_cars_right, right_car];
								temp_velocity_right = [temp_velocity_right, right_velocity];
								temp_cars_stop_right = [temp_cars_stop_right, right_stop];
							end
						end
					end
					
					cars_right = cars_right(2:end);
					velocity_right = velocity_right(2:end);
					cars_stop_right = cars_stop_right(2:end);
					
					continue;
				end
				% get the nearest car that is in front of right_car from vector of the processed cars if exists
				temp_head_forward = -1;
				for j=1:length(temp_cars_right) 
					if temp_cars_right(j) > right_car
						temp_head_forward = temp_cars_right(j);
						break;
					end
				end
		
				% Road is empty, only right_car is exists on right line
				if length(cars_right) == 1 && temp_head_forward == -1
					
					% accelarate the car by 4 m/s**2
					if right_velocity < 21 
						right_car = right_car + right_velocity + 2;
						right_velocity = right_velocity + 4;
					else 
						right_car = right_car + round((right_velocity + 25) / 2);
						right_velocity = 25;
					end
					
					% add the car to the velocity and location vectors of the processed cars
					if right_car <= 5000
						if length(temp_cars_right) == 0
							temp_cars_right = [right_car];
							temp_velocity_right = [right_velocity];
							temp_cars_stop_right = [right_stop];
						elseif length(temp_cars_right) == 1
							if temp_cars_right(1) < right_car
								temp_cars_right = [temp_cars_right, right_car];
								temp_velocity_right = [temp_velocity_right, right_velocity];
								temp_cars_stop_right = [temp_cars_stop_right, right_stop];
							else
								temp_cars_right = [right_car, temp_cars_right];
								temp_velocity_right = [right_velocity, temp_velocity_right];
								temp_cars_stop_right = [right_stop, temp_cars_stop_right];
							end
						else
							for l=1:length(temp_cars_right)
								if temp_cars_right(l) > right_car
									temp_cars_right = [temp_cars_right(1:l-1), right_car, temp_cars_right(l:end)];
									temp_velocity_right = [temp_velocity_right(1:l-1), right_velocity, temp_velocity_right(l:end)];
									temp_cars_stop_right = [temp_cars_stop_right(1:l-1), right_stop, temp_cars_stop_right(l:end)];
									break;
								elseif l == length(temp_cars_right)
									temp_cars_right = [temp_cars_right, right_car];
									temp_velocity_right = [temp_velocity_right, right_velocity];
									temp_cars_stop_right = [temp_cars_stop_right, right_stop];
								end
							end
						end
					end
					
					% remove the car from the actual velocity and location vectors
					cars_right = [];
					velocity_right = [];
					cars_stop_right = [];
					
				% There are other cars
				% think about [de, ac]celaration and/or takeover
				else

					% choose the car that is in front of us(processed or actual vector) 
					if length(cars_right) > 1 && temp_head_forward == -1
						state = cars_right(2);
					elseif length(cars_right) == 1 && temp_head_forward > -1
						state = temp_head_forward;
					else
						if cars_right(2) < temp_head_forward
							state = cars_right(2);
						else
							state = temp_head_forward;
						end
					end
					
					% calculate spacing, state is the location of the head car
					distance = state - right_car - car_length;
					
					% spacing is sufficient to protect the 2 headway with acceleration
					if distance > 3 * right_velocity
						
						if right_velocity == 0 && state - right_car - car_length < 2
							temp_cars_right = [temp_cars_right, right_car];
							temp_velocity_right = [temp_velocity_right, right_velocity];
							temp_cars_stop_right = [temp_cars_stop_right, right_stop];
							
							cars_right = cars_right(2:end);
							velocity_right = velocity_right(2:end);
							cars_stop_right = cars_stop_right(2:end); 
						else 
							if right_velocity < 21 
								path = right_velocity + 2;
								right_velocity = right_velocity + 4;
							else
								path = round((right_velocity + 25) / 2);
								right_velocity = 25;
							end
							
							right_car = right_car + path;
						
							if right_car <= 5000
								if length(temp_cars_right) == 0
									temp_cars_right = [right_car];
									temp_velocity_right = [right_velocity];
									temp_cars_stop_right = [right_stop];
								elseif length(temp_cars_right) == 1
									if temp_cars_right(1) < right_car
										temp_cars_right = [temp_cars_right, right_car];
										temp_velocity_right = [temp_velocity_right, right_velocity];
										temp_cars_stop_right = [temp_cars_stop_right, right_stop];
									else
										temp_cars_right = [right_car, temp_cars_right];
										temp_velocity_right = [right_velocity, temp_velocity_right];
										temp_cars_stop_right = [right_stop, temp_cars_stop_right];
									end
								else
									for l=1:length(temp_cars_right)
										if temp_cars_right(l) > right_car
											temp_cars_right = [temp_cars_right(1:l-1), right_car, temp_cars_right(l:end)];
											temp_velocity_right = [temp_velocity_right(1:l-1), right_velocity, temp_velocity_right(l:end)];
											temp_cars_stop_right = [temp_cars_stop_right(1:l-1), right_stop, temp_cars_stop_right(l:end)];
											break;
										elseif l == length(temp_cars_right)
											temp_cars_right = [temp_cars_right, right_car];
											temp_velocity_right = [temp_velocity_right, right_velocity];
											temp_cars_stop_right = [temp_cars_stop_right, right_stop];
										end
									end
								end
							end
							
							cars_right = cars_right(2:end);
							velocity_right = velocity_right(2:end);
							cars_stop_right = cars_stop_right(2:end); 
						end
					% spacing is sufficient to protect the 2 headway without acceleration, continue with current velocity	
					elseif distance == 3 * right_velocity
						right_car = right_car + right_velocity;
					
						if right_car <= 5000
							if length(temp_cars_right) == 0
								temp_cars_right = [right_car];
								temp_velocity_right = [right_velocity];
								temp_cars_stop_right = [right_stop];
							elseif length(temp_cars_right) == 1
								if temp_cars_right(1) < right_car
									temp_cars_right = [temp_cars_right, right_car];
									temp_velocity_right = [temp_velocity_right, right_velocity];
									temp_cars_stop_right = [temp_cars_stop_right, right_stop];
								else
									temp_cars_right = [right_car, temp_cars_right];
									temp_velocity_right = [right_velocity, temp_velocity_right];
									temp_cars_stop_right = [right_stop, temp_cars_stop_right];
								end
							else
								for l=1:length(temp_cars_right)
									if temp_cars_right(l) > right_car
										temp_cars_right = [temp_cars_right(1:l-1), right_car, temp_cars_right(l:end)];
										temp_velocity_right = [temp_velocity_right(1:l-1), right_velocity, temp_velocity_right(l:end)];
										temp_cars_stop_right = [temp_cars_stop_right(1:l-1), right_stop, temp_cars_stop_right(l:end)];
										break;
									elseif l == length(temp_cars_right)
										temp_cars_right = [temp_cars_right, right_car];
										temp_velocity_right = [temp_velocity_right, right_velocity];
										temp_cars_stop_right = [temp_cars_stop_right, right_stop];
									end
								end
							end
						end
						cars_right = cars_right(2:end);
						velocity_right = velocity_right(2:end);
						cars_stop_right = cars_stop_right(2:end);
						
					% spacing is not sufficient to protect the 2 headway with(out) acceleration
					% check for the possibility of the takeover
					else 
					
						% initially attempt to increase the velocity
						pass_velocity = right_velocity;
						if pass_velocity < 21 
							pass_velocity = pass_velocity + 4;
						else 
							pass_velocity = 25;
						end
						
						path = round((pass_velocity + right_velocity) / 2);
						
						% the vector that holds the cars that are in the part of the other line that we will use while takeover
						pass_list = [];
						
						head_car = 5075;
						
						% find the cars that are in the part of the other line that we will use while takeover
						for j=1:length(cars_left)
							if cars_left(j) >= right_car && cars_left(j) <= (right_car + path)
								pass_list = [pass_list, cars_left(j)];
							elseif cars_left(j) > (right_car + path)
								head_car = cars_left(j);
								break;
							end
						end
						for j=1:length(temp_cars_left)
							if temp_cars_left(j) >= right_car && temp_cars_left(j) <= (right_car + path)
								pass_list = [pass_list, temp_cars_left(j)];
							elseif temp_cars_left(j) > (right_car + path)
								if temp_cars_left(j) < head_car
									head_car = temp_cars_left(j);
								end
								break;
							end
						end
						
						pass_list = sort(pass_list, 'descend');
						
						% flag for whether takeover is successful or not
						is_pass_successful = 0;
						
						% pass_list is empty so advance the location with protecting the .5 headway 
						if length(pass_list) == 0
						
							for k=path:-1:1
							
								if head_car - right_car - path - car_length >= round(0.5 * pass_velocity)
									is_pass_successful = 1;
									
									right_car = right_car + path;
									pass_velocity = 2 * path - right_velocity;
									if pass_velocity < 0 
										pass_velocity = 0; 
									elseif pass_velocity > 25
										pass_velocity = 25;
									end
									
									if right_car <= 5000
										if length(temp_cars_left) == 0
											temp_cars_left = [right_car];
											temp_velocity_left = [pass_velocity];
											temp_cars_stop_left = [right_stop];
										elseif length(temp_cars_left) == 1
											if temp_cars_left(1) < right_car
												temp_cars_left = [temp_cars_left, right_car];
												temp_velocity_left = [temp_velocity_left, pass_velocity];
												temp_cars_stop_left = [temp_cars_stop_left, right_stop];
											else
												temp_cars_left = [right_car, temp_cars_left];
												temp_velocity_left = [pass_velocity, temp_velocity_left];
												temp_cars_stop_left = [right_stop, temp_cars_stop_left];
											end
										else
											for l=1:length(temp_cars_left)
												if temp_cars_left(l) > right_car
													temp_cars_left = [temp_cars_left(1:l-1), right_car, temp_cars_left(l:end)];
													temp_velocity_left = [temp_velocity_left(1:l-1), pass_velocity, temp_velocity_left(l:end)];
													temp_cars_stop_left = [temp_cars_stop_left(1:l-1), right_stop, temp_cars_stop_left(l:end)];
													break;
												elseif l == length(temp_cars_left)
													temp_cars_left = [temp_cars_left, right_car];
													temp_velocity_left = [temp_velocity_left, pass_velocity];
													temp_cars_stop_left = [temp_cars_stop_left, right_stop];
												end
											end
										end
									end
									
									
									cars_right = cars_right(2:end);
									velocity_right = velocity_right(2:end);
									cars_stop_right = cars_stop_right(2:end);
									break;
								else
									path = path - 1;
								end
							end
						end
						
						% try taking over cars as much as you can
						for j=1:length(pass_list)
						
							for k=path:-1:1
							
								if right_car + path - car_length >= pass_list(j) && right_car + distance - pass_list(j) >= car_length && ((j==1 && head_car - right_car - path - car_length >= round(0.5 * pass_velocity)) || (j > 1 && pass_list(j-1) - right_car - path - car_length >= round(0.5 * pass_velocity)))
									is_pass_successful = 1;
									
									right_car = right_car + path;
									pass_velocity = 2 * path - right_velocity;
									if pass_velocity < 0 
										pass_velocity = 0;
									elseif pass_velocity > 25
										pass_velocity = 25;
									end
									
									if right_car <= 5000
										if length(temp_cars_left) == 0
											temp_cars_left = [right_car];
											temp_velocity_left = [pass_velocity];
											temp_cars_stop_left = [right_stop];
										elseif length(temp_cars_left) == 1
											if temp_cars_left(1) < right_car
												temp_cars_left = [temp_cars_left, right_car];
												temp_velocity_left = [temp_velocity_left, pass_velocity];
												temp_cars_stop_left = [temp_cars_stop_left, right_stop];
											else
												temp_cars_left = [right_car, temp_cars_left];
												temp_velocity_left = [pass_velocity, temp_velocity_left];
												temp_cars_stop_left = [right_stop, temp_cars_stop_left];
											end
										else
											for l=1:length(temp_cars_left)
												if temp_cars_left(l) > right_car
													temp_cars_left = [temp_cars_left(1:l-1), right_car, temp_cars_left(l:end)];
													temp_velocity_left = [temp_velocity_left(1:l-1), pass_velocity, temp_velocity_left(l:end)];
													temp_cars_stop_left = [temp_cars_stop_left(1:l-1), right_stop, temp_cars_stop_left(l:end)];
													break;
												elseif l == length(temp_cars_left)
													temp_cars_left = [temp_cars_left, right_car];
													temp_velocity_left = [temp_velocity_left, pass_velocity];
													temp_cars_stop_left = [temp_cars_stop_left, right_stop];
												end
											end
										end
									end
									
									cars_right = cars_right(2:end);
									velocity_right = velocity_right(2:end);
									cars_stop_right = cars_stop_right(2:end);
									break;
								else
									path = path - 1;
									if right_car + path == pass_list(j) 
										path = path - car_length;
										break;
									end
								end
							
							end
						end
						
						% if we can't enter between cars in the pass_list, try the end of the last car in the pass_list 
						if length(pass_list) > 0 && is_pass_successful == 0
						
							last_distance = pass_list(end) - right_car - round(0.5 * pass_velocity) - car_length;
							
							if  last_distance >= car_length
							
								is_pass_successful = 1;
							
								right_car = right_car + last_distance;
								pass_velocity = 2 * last_distance - right_velocity;								
								if pass_velocity < 0 
									pass_velocity = 0;
								elseif pass_velocity > 25
									pass_velocity = 25;
								end
								
								if right_car <= 5000
									if length(temp_cars_left) == 0
										temp_cars_left = [right_car];
										temp_velocity_left = [pass_velocity];
										temp_cars_stop_left = [right_stop];
									elseif length(temp_cars_left) == 1
										if temp_cars_left(1) < right_car
											temp_cars_left = [temp_cars_left, right_car];
											temp_velocity_left = [temp_velocity_left, pass_velocity];
											temp_cars_stop_left = [temp_cars_stop_left, right_stop];
										else
											temp_cars_left = [right_car, temp_cars_left];
											temp_velocity_left = [pass_velocity, temp_velocity_left];
											temp_cars_stop_left = [right_stop, temp_cars_stop_left];
										end
									else
										for l=1:length(temp_cars_left)
											if temp_cars_left(l) > right_car
												temp_cars_left = [temp_cars_left(1:l-1), right_car, temp_cars_left(l:end)];
												temp_velocity_left = [temp_velocity_left(1:l-1), pass_velocity, temp_velocity_left(l:end)];
												temp_cars_stop_left = [temp_cars_stop_left(1:l-1), right_stop, temp_cars_stop_left(l:end)];
												break;
											elseif l == length(temp_cars_left)
												temp_cars_left = [temp_cars_left, right_car];
												temp_velocity_left = [temp_velocity_left, pass_velocity];
												temp_cars_stop_left = [temp_cars_stop_left, right_stop];
											end
										end
									end
								end
									
								cars_right = cars_right(2:end);
								velocity_right = velocity_right(2:end);
								cars_stop_right = cars_stop_right(2:end);								
							end
						end
						
						% if takeover is not possible, decelerate on the same line with 2 headway
						if is_pass_successful == 0
						
							% if spacing is between .5 headway and 3 headway 
							if round(right_velocity/2) < distance && distance < 3 * right_velocity
								final_speed = round((2 * distance - right_velocity) / 5);
								path = round((right_velocity + final_speed) / 2);
								right_velocity = final_speed;
								
								right_car = right_car + path;
					
								if right_car <= 5000
									if length(temp_cars_right) == 0
										temp_cars_right = [right_car];
										temp_velocity_right = [right_velocity];
										temp_cars_stop_right = [right_stop];
									elseif length(temp_cars_right) == 1
										if temp_cars_right(1) < right_car
											temp_cars_right = [temp_cars_right, right_car];
											temp_velocity_right = [temp_velocity_right, right_velocity];
											temp_cars_stop_right = [temp_cars_stop_right, right_stop];
										else
											temp_cars_right = [right_car, temp_cars_right];
											temp_velocity_right = [right_velocity, temp_velocity_right];
											temp_cars_stop_right = [right_stop, temp_cars_stop_right];
										end
									else
										for l=1:length(temp_cars_right)
											if temp_cars_right(l) > right_car
												temp_cars_right = [temp_cars_right(1:l-1), right_car, temp_cars_right(l:end)];
												temp_velocity_right = [temp_velocity_right(1:l-1), right_velocity, temp_velocity_right(l:end)];
												temp_cars_stop_right = [temp_cars_stop_right(1:l-1), right_stop, temp_cars_stop_right(l:end)];
												break;
											elseif l == length(temp_cars_right)
												temp_cars_right = [temp_cars_right, right_car];
												temp_velocity_right = [temp_velocity_right, right_velocity];
												temp_cars_stop_right = [temp_cars_stop_right, right_stop];
											end
										end
									end
								end
								
								cars_right = cars_right(2:end);
								velocity_right = velocity_right(2:end);
								cars_stop_right = cars_stop_right(2:end);
								
							% spacing is less than .5 headway
							% decelerate, final speed definitely becomes *0* because spacing is so small
							% headway is zero (congestion)
							else
								final_speed = 0;
								right_velocity = final_speed;
								path = distance;
								
								right_car = right_car + path;
					
								if right_car <= 5000
									if length(temp_cars_right) == 0
										temp_cars_right = [right_car];
										temp_velocity_right = [right_velocity];
										temp_cars_stop_right = [right_stop];
									elseif length(temp_cars_right) == 1
										if temp_cars_right(1) < right_car
											temp_cars_right = [temp_cars_right, right_car];
											temp_velocity_right = [temp_velocity_right, right_velocity];
											temp_cars_stop_right = [temp_cars_stop_right, right_stop];
										else
											temp_cars_right = [right_car, temp_cars_right];
											temp_velocity_right = [right_velocity, temp_velocity_right];
											temp_cars_stop_right = [right_stop, temp_cars_stop_right];
										end
									else
										for l=1:length(temp_cars_right)
											if temp_cars_right(l) > right_car
												temp_cars_right = [temp_cars_right(1:l-1), right_car, temp_cars_right(l:end)];
												temp_velocity_right = [temp_velocity_right(1:l-1), right_velocity, temp_velocity_right(l:end)];
												temp_cars_stop_right = [temp_cars_stop_right(1:l-1), right_stop, temp_cars_stop_right(l:end)];
												break;
											elseif l == length(temp_cars_right)
												temp_cars_right = [temp_cars_right, right_car];
												temp_velocity_right = [temp_velocity_right, right_velocity];
												temp_cars_stop_right = [temp_cars_stop_right, right_stop];
											end
										end
									end
								end
								cars_right = cars_right(2:end);
								velocity_right = velocity_right(2:end);
								cars_stop_right = cars_stop_right(2:end);
							end
						end
					end
				end
			end	
		end
		
		% all cars are processed and put into temp vectors
		% update actual vectors from processed vectors
		cars_left = temp_cars_left;
		cars_right = temp_cars_right;
		velocity_left = temp_velocity_left;
		velocity_right = temp_velocity_right;
		
		% update actual stop vectors
		cars_stop_left = temp_cars_stop_left; 
		cars_stop_right = temp_cars_stop_right;
		
		% intialization of the average velocities of sections
		temp_avg_velocity_first_left = 0;
		temp_avg_velocity_second_left = 0;
		temp_avg_velocity_third_left = 0;
		temp_avg_velocity_fourth_left = 0;
		temp_avg_velocity_fifth_left = 0;
		temp_avg_velocity_first_right = 0;
		temp_avg_velocity_second_right = 0;
		temp_avg_velocity_third_right = 0;
		temp_avg_velocity_fourth_right = 0;
		temp_avg_velocity_fifth_right = 0;
		
		% intialization of the number of cars in each section
		temp_avg_velocity_first_left_counter = 0;
		temp_avg_velocity_second_left_counter = 0;
		temp_avg_velocity_third_left_counter = 0;
		temp_avg_velocity_fourth_left_counter = 0;
		temp_avg_velocity_fifth_left_counter = 0;
		temp_avg_velocity_first_right_counter = 0;
		temp_avg_velocity_second_right_counter = 0;
		temp_avg_velocity_third_right_counter = 0;
		temp_avg_velocity_fourth_right_counter = 0;
		temp_avg_velocity_fifth_right_counter = 0;
		
		% find the number of the cars in each section of the left line
		for i=1:length(velocity_left)
	
			if cars_left(i) <= 1000
				temp_avg_velocity_first_left = temp_avg_velocity_first_left + velocity_left(i);
				temp_avg_velocity_first_left_counter = temp_avg_velocity_first_left_counter + 1;
			elseif cars_left(i) <= 2000
				temp_avg_velocity_second_left = temp_avg_velocity_second_left + velocity_left(i);
				temp_avg_velocity_second_left_counter = temp_avg_velocity_second_left_counter + 1;
			elseif cars_left(i) <= 3000
				temp_avg_velocity_third_left = temp_avg_velocity_third_left + velocity_left(i);
				temp_avg_velocity_third_left_counter = temp_avg_velocity_third_left_counter + 1;
			elseif cars_left(i) <= 4000
				temp_avg_velocity_fourth_left = temp_avg_velocity_fourth_left + velocity_left(i);
				temp_avg_velocity_fourth_left_counter = temp_avg_velocity_fourth_left_counter + 1;
			else
				temp_avg_velocity_fifth_left = temp_avg_velocity_fifth_left + velocity_left(i);
				temp_avg_velocity_fifth_left_counter = temp_avg_velocity_fifth_left_counter + 1;
			end
		end
	
		% find the number of the cars in each section of the right line
		for i=1:length(velocity_right)
	
			if cars_right(i) <= 1000
				temp_avg_velocity_first_right = temp_avg_velocity_first_right + velocity_right(i);
				temp_avg_velocity_first_right_counter = temp_avg_velocity_first_right_counter + 1;
			elseif cars_right(i) <= 2000
				temp_avg_velocity_second_right = temp_avg_velocity_second_right + velocity_right(i);
				temp_avg_velocity_second_right_counter = temp_avg_velocity_second_right_counter + 1;
			elseif cars_right(i) <= 3000
				temp_avg_velocity_third_right = temp_avg_velocity_third_right + velocity_right(i);
				temp_avg_velocity_third_right_counter = temp_avg_velocity_third_right_counter + 1;
			elseif cars_right(i) <= 4000
				temp_avg_velocity_fourth_right = temp_avg_velocity_fourth_right + velocity_right(i);
				temp_avg_velocity_fourth_right_counter = temp_avg_velocity_fourth_right_counter + 1;
			else
				temp_avg_velocity_fifth_right = temp_avg_velocity_fifth_right + velocity_right(i);
				temp_avg_velocity_fifth_right_counter = temp_avg_velocity_fifth_right_counter + 1;
			end
		end
	
		% accumulate average velocities of each section at a second
		if temp_avg_velocity_first_left_counter ~= 0
			avg_velocity_first_left(end) = avg_velocity_first_left(end) + temp_avg_velocity_first_left / temp_avg_velocity_first_left_counter;
		end
		if temp_avg_velocity_second_left_counter ~= 0
			avg_velocity_second_left(end) = avg_velocity_second_left(end) + temp_avg_velocity_second_left / temp_avg_velocity_second_left_counter;
		end
		if temp_avg_velocity_third_left_counter ~= 0
			avg_velocity_third_left(end) = avg_velocity_third_left(end) + temp_avg_velocity_third_left / temp_avg_velocity_third_left_counter;
		end
		if temp_avg_velocity_fourth_left_counter ~= 0
			avg_velocity_fourth_left(end) = avg_velocity_fourth_left(end) + temp_avg_velocity_fourth_left / temp_avg_velocity_fourth_left_counter;
		end
		if temp_avg_velocity_fifth_left_counter ~= 0
			avg_velocity_fifth_left(end) = avg_velocity_fifth_left(end) + temp_avg_velocity_fifth_left / temp_avg_velocity_fifth_left_counter;
		end
		if temp_avg_velocity_first_right_counter ~= 0		
			avg_velocity_first_right(end) = avg_velocity_first_right(end) + temp_avg_velocity_first_right / temp_avg_velocity_first_right_counter;
		end
		if temp_avg_velocity_second_right_counter ~= 0
			avg_velocity_second_right(end) = avg_velocity_second_right(end) + temp_avg_velocity_second_right / temp_avg_velocity_second_right_counter;
		end
		if temp_avg_velocity_third_right_counter ~= 0
			avg_velocity_third_right(end) = avg_velocity_third_right(end) + temp_avg_velocity_third_right / temp_avg_velocity_third_right_counter;
		end
		if temp_avg_velocity_fourth_right_counter ~= 0
			avg_velocity_fourth_right(end) = avg_velocity_fourth_right(end) + temp_avg_velocity_fourth_right / temp_avg_velocity_fourth_right_counter;
		end
		if temp_avg_velocity_fifth_right_counter ~= 0
			avg_velocity_fifth_right(end) = avg_velocity_fifth_right(end) + temp_avg_velocity_fifth_right / temp_avg_velocity_fifth_right_counter;
		end
	
		% accumulate densities of the sections at a second
		density_first_left(end) = density_first_left(end) + temp_avg_velocity_first_left_counter;
		density_second_left(end) = density_second_left(end) + temp_avg_velocity_second_left_counter;
		density_third_left(end) = density_third_left(end) + temp_avg_velocity_third_left_counter;
		density_fourth_left(end) = density_fourth_left(end) + temp_avg_velocity_fourth_left_counter;
		density_fifth_left(end) = density_fifth_left(end) + temp_avg_velocity_fifth_left_counter;
		density_first_right(end) = density_first_right(end) + temp_avg_velocity_first_right_counter;
		density_second_right(end) = density_second_right(end) + temp_avg_velocity_second_right_counter;
		density_third_right(end) = density_third_right(end) + temp_avg_velocity_third_right_counter;
		density_fourth_right(end) = density_fourth_right(end) + temp_avg_velocity_fourth_right_counter;
		density_fifth_right(end) = density_fifth_right(end) + temp_avg_velocity_fifth_right_counter;
	
	end
	
	% calculate average velocities of each section at a minute
	avg_velocity_first_left(end) = avg_velocity_first_left(end) / 60;
	avg_velocity_second_left(end) = avg_velocity_second_left(end) / 60;
	avg_velocity_third_left(end) = avg_velocity_third_left(end) / 60;
	avg_velocity_fourth_left(end) = avg_velocity_fourth_left(end) / 60;
	avg_velocity_fifth_left(end) = avg_velocity_fifth_left(end) / 60;
	avg_velocity_first_right(end) = avg_velocity_first_right(end) / 60;
	avg_velocity_second_right(end) = avg_velocity_second_right(end) / 60;
	avg_velocity_third_right(end) = avg_velocity_third_right(end) / 60;
	avg_velocity_fourth_right(end) = avg_velocity_fourth_right(end) / 60;
	avg_velocity_fifth_right(end) = avg_velocity_fifth_right(end) / 60;
	
	% calculate average densities of each section at a minute
	density_first_left(end) = density_first_left(end) / 60;
	density_second_left(end) = density_second_left(end) / 60;
	density_third_left(end) = density_third_left(end) / 60;
	density_fourth_left(end) = density_fourth_left(end) / 60;
	density_fifth_left(end) = density_fifth_left(end) / 60;
	density_first_right(end) = density_first_right(end) / 60;
	density_second_right(end) = density_second_right(end) / 60;
	density_third_right(end) = density_third_right(end) / 60;
	density_fourth_right(end) = density_fourth_right(end) / 60;
	density_fifth_right(end) = density_fifth_right(end) / 60;
	
	% calculate average occupancies of each section at a minute
	occupancy_first_left = [occupancy_first_left, density_first_left(end) / occupancy_divisor];
	occupancy_second_left = [occupancy_second_left, density_second_left(end) / occupancy_divisor];
	occupancy_third_left = [occupancy_third_left, density_third_left(end) / occupancy_divisor];
	occupancy_fourth_left = [occupancy_fourth_left, density_fourth_left(end) / occupancy_divisor];
	occupancy_fifth_left = [occupancy_fifth_left, density_fifth_left(end) / occupancy_divisor];
	occupancy_first_right = [occupancy_first_right, density_first_right(end) / occupancy_divisor];
	occupancy_second_right = [occupancy_second_right, density_second_right(end) / occupancy_divisor];
	occupancy_third_right = [occupancy_third_right, density_third_right(end) / occupancy_divisor];
	occupancy_fourth_right = [occupancy_fourth_right, density_fourth_right(end) / occupancy_divisor];
	occupancy_fifth_right = [occupancy_fifth_right, density_fifth_right(end) / occupancy_divisor];
	
	% reset section car counters 
	first_section_current_number_of = 0;
	second_section_current_number_of = 0;
	third_section_current_number_of = 0;
	fourth_section_current_number_of = 0;
	fifth_section_current_number_of = 0;
	
	% count the cars in each section of the left line
	for i=1:length(cars_left)
	
		if cars_left(i) <= 1000
			first_section_current_number_of = first_section_current_number_of  + 1;
		elseif cars_left(i) <= 2000
			second_section_current_number_of = second_section_current_number_of  + 1;
		elseif cars_left(i) <= 3000
			third_section_current_number_of = third_section_current_number_of  + 1;
		elseif cars_left(i) <= 4000
			fourth_section_current_number_of = fourth_section_current_number_of  + 1;	
		else
			fifth_section_current_number_of = fifth_section_current_number_of  + 1;
		end
	end
	
	% count the cars in each section of the left line
	for i=1:length(cars_right)
	
		if cars_right(i) <= 1000
			first_section_current_number_of = first_section_current_number_of  + 1;
		elseif cars_right(i) <= 2000
			second_section_current_number_of = second_section_current_number_of  + 1;
		elseif cars_right(i) <= 3000
			third_section_current_number_of = third_section_current_number_of  + 1;
		elseif cars_right(i) <= 4000
			fourth_section_current_number_of = fourth_section_current_number_of  + 1;	
		else
			fifth_section_current_number_of = fifth_section_current_number_of  + 1;
		end
	end
	
	% we know old number of the cars in each section and generated car number in the minute
	% calculate the flow in chaining fashion
	tempq1in = generated_cars_number_of;
	tempq1out = tempq1in + first_section_old_number_of - first_section_current_number_of;
	first_section_old_number_of = first_section_current_number_of;
	tempq2in = tempq1out;
	tempq2out = tempq2in + second_section_old_number_of - second_section_current_number_of;
	second_section_old_number_of = second_section_current_number_of;
	tempq3in = tempq2out;
	tempq3out = tempq3in + third_section_old_number_of - third_section_current_number_of;
	third_section_old_number_of = third_section_current_number_of;
	tempq4in = tempq3out;
	tempq4out = tempq4in + fourth_section_old_number_of - fourth_section_current_number_of;
	fourth_section_old_number_of = fourth_section_current_number_of;
	tempq5in = tempq4out;
	tempq5out = tempq5in + fifth_section_old_number_of - fifth_section_current_number_of;
	fifth_section_old_number_of = fifth_section_current_number_of;
	
	% update flow vectors
	q1in = [q1in, tempq1in];
	q1out = [q1out, tempq1out];
	q2in = [q2in, tempq2in];
	q2out = [q2out, tempq2out];
	q3in = [q3in, tempq3in];
	q3out = [q3out, tempq3out];
	q4in = [q4in, tempq4in];
	q4out = [q4out, tempq4out];
	q5in = [q5in, tempq5in];
	q5out = [q5out, tempq5out];
end

%---------------- California Calculations -----------%
for i=1:simulation_run_length
	
	occdf_first = [occdf_first, ((occupancy_first_left(i) + occupancy_first_right(i))/2) - ((occupancy_second_left(i) + occupancy_second_right(i))/2)];
	occdf_second = [occdf_second, ((occupancy_second_left(i) + occupancy_second_right(i))/2) - ((occupancy_third_left(i) + occupancy_third_right(i))/2)];
	occdf_third = [occdf_third, ((occupancy_third_left(i) + occupancy_third_right(i))/2) - ((occupancy_fourth_left(i) + occupancy_fourth_right(i))/2)];
	occdf_fourth = [occdf_fourth, ((occupancy_fourth_left(i) + occupancy_fourth_right(i))/2) - ((occupancy_fifth_left(i) + occupancy_fifth_right(i))/2)];
	occdf_fifth = [occdf_fifth, ((occupancy_fifth_left(i) + occupancy_fifth_right(i))/2)];
	
	occrdf_first = [occrdf_first, (occdf_first(i)/((occupancy_first_left(i) + occupancy_first_right(i))/2))];
	occrdf_second = [occrdf_second, (occdf_second(i)/((occupancy_second_left(i) + occupancy_second_right(i))/2))];
	occrdf_third = [occrdf_third, (occdf_third(i)/((occupancy_third_left(i) + occupancy_third_right(i))/2))];
	occrdf_fourth = [occrdf_fourth, (occdf_fourth(i)/((occupancy_fourth_left(i) + occupancy_fourth_right(i))/2))];
	occrdf_fifth = [occrdf_fifth, (occdf_fifth(i)/((occupancy_fifth_left(i) + occupancy_fifth_right(i))/2))];
	
	if i > d_time_interval 
		docctd_first = [docctd_first, (((occupancy_second_left(i-d_time_interval) + occupancy_second_right(i-d_time_interval))/2) - ((occupancy_second_left(i) + occupancy_second_right(i))/2)) / ((occupancy_second_left(i-d_time_interval) + occupancy_second_right(i-d_time_interval))/2)];
		docctd_second = [docctd_second, (((occupancy_third_left(i-d_time_interval) + occupancy_third_right(i-d_time_interval))/2) - ((occupancy_third_left(i) + occupancy_third_right(i))/2)) / ((occupancy_third_left(i-d_time_interval) + occupancy_third_right(i-d_time_interval))/2)];
		docctd_third = [docctd_third, (((occupancy_fourth_left(i-d_time_interval) + occupancy_fourth_right(i-d_time_interval))/2) - ((occupancy_fourth_left(i) + occupancy_fourth_right(i))/2)) / ((occupancy_fourth_left(i-d_time_interval) + occupancy_fourth_right(i-d_time_interval))/2)];
		docctd_fourth = [docctd_fourth, (((occupancy_fifth_left(i-d_time_interval) + occupancy_fifth_right(i-d_time_interval))/2) - ((occupancy_fifth_left(i) + occupancy_fifth_right(i))/2)) / ((occupancy_fifth_left(i-d_time_interval) + occupancy_fifth_right(i-d_time_interval))/2)];
		docctd_fifth = [docctd_fifth, 0];
	else 
		docctd_first = [docctd_first, 0];
		docctd_second = [docctd_second, 0];
		docctd_third = [docctd_third, 0];
		docctd_fourth = [docctd_fourth, 0];
		docctd_fifth = [docctd_fifth, 0];
	end

end

for i=1:simulation_run_length
	if occdf_first(i) > t1_threshold && occrdf_first(i) > t2_threshold && docctd_first(i) > t3_threshold
		california_incident_detector_first = [california_incident_detector_first, 1];
	else 
		california_incident_detector_first = [california_incident_detector_first, 0];
	end	
	
	if occdf_second(i) > t1_threshold && occrdf_second(i) > t2_threshold && docctd_second(i) > t3_threshold
		california_incident_detector_second = [california_incident_detector_second, 1];
	else 
		california_incident_detector_second = [california_incident_detector_second, 0];
	end

	if occdf_third(i) > t1_threshold && occrdf_third(i) > t2_threshold && docctd_third(i) > t3_threshold
		california_incident_detector_third = [california_incident_detector_third, 1];
	else 
		california_incident_detector_third = [california_incident_detector_third, 0];
	end
	
	if occdf_fourth(i) > t1_threshold && occrdf_fourth(i) > t2_threshold && docctd_fourth(i) > t3_threshold
		california_incident_detector_fourth = [california_incident_detector_fourth, 1];
	else 
		california_incident_detector_fourth = [california_incident_detector_fourth, 0];
	end
	
	if occdf_fifth(i) > t1_threshold && occrdf_fifth(i) > t2_threshold && docctd_fifth(i) > t3_threshold
		california_incident_detector_fifth = [california_incident_detector_fifth, 1];
	else 
		california_incident_detector_fifth = [california_incident_detector_fifth, 0];
	end
end

%-----------------------------------------------------------%

%---------------- Minnesota Calculations -----------%
for i=1:simulation_run_length
	
	delta_occ_first = [delta_occ_first, ((occupancy_first_left(i) + occupancy_first_right(i))/2) - ((occupancy_second_left(i) + occupancy_second_right(i))/2)];
	delta_occ_second = [delta_occ_second, ((occupancy_second_left(i) + occupancy_second_right(i))/2) - ((occupancy_third_left(i) + occupancy_third_right(i))/2)];
	delta_occ_third = [delta_occ_third, ((occupancy_third_left(i) + occupancy_third_right(i))/2) - ((occupancy_fourth_left(i) + occupancy_fourth_right(i))/2)];
	delta_occ_fourth = [delta_occ_fourth, ((occupancy_fourth_left(i) + occupancy_fourth_right(i))/2) - ((occupancy_fifth_left(i) + occupancy_fifth_right(i))/2)];
	delta_occ_fifth = [delta_occ_fifth, ((occupancy_fifth_left(i) + occupancy_fifth_right(i))/2)];
	
	if i > d_time_interval
		delta_occ_d_first = [delta_occ_d_first, ((occupancy_first_left(i-d_time_interval) + occupancy_first_right(i-d_time_interval))/2) - ((occupancy_second_left(i-d_time_interval) + occupancy_second_right(i-d_time_interval))/2)];
		delta_occ_d_second = [delta_occ_d_second, ((occupancy_second_left(i-d_time_interval) + occupancy_second_right(i-d_time_interval))/2) - ((occupancy_third_left(i-d_time_interval) + occupancy_third_right(i-d_time_interval))/2)]; 
		delta_occ_d_third = [delta_occ_d_third, ((occupancy_third_left(i-d_time_interval) + occupancy_third_right(i-d_time_interval))/2) - ((occupancy_fourth_left(i-d_time_interval) + occupancy_fourth_right(i-d_time_interval))/2)];
		delta_occ_d_fourth = [delta_occ_d_fourth, ((occupancy_fourth_left(i-d_time_interval) + occupancy_fourth_right(i-d_time_interval))/2) - ((occupancy_fifth_left(i-d_time_interval) + occupancy_fifth_right(i-d_time_interval))/2)];
		delta_occ_d_fifth = [delta_occ_d_fifth, ((occupancy_fifth_left(i-d_time_interval) + occupancy_fifth_right(i-d_time_interval))/2)];
	else
		delta_occ_d_first = [delta_occ_d_first, 0];
		delta_occ_d_second = [delta_occ_d_second, 0];
		delta_occ_d_third = [delta_occ_d_third, 0];
		delta_occ_d_fourth = [delta_occ_d_fourth, 0];
		delta_occ_d_fifth = [delta_occ_d_fifth, 0];
	end
	
	max_occ_first = [max_occ_first, max(delta_occ_d_first(i), delta_occ_d_second(i))];
	max_occ_second = [max_occ_second, max(delta_occ_d_second(i), delta_occ_d_third(i))];
	max_occ_third = [max_occ_third, max(delta_occ_d_third(i), delta_occ_d_fourth(i))];
	max_occ_fourth = [max_occ_fourth, max(delta_occ_d_fourth(i), delta_occ_d_fifth(i))];
	max_occ_fifth = [max_occ_fifth, max(delta_occ_d_fifth(i), 0)];
	
	if delta_occ_first(i)/max_occ_first(i) > tc_minnesota && (delta_occ_first(i) - delta_occ_d_first(i))/max_occ_first(i) > t1_minnesota
		minnesota_incident_detector_first = [minnesota_incident_detector_first, 1];
	else
		minnesota_incident_detector_first = [minnesota_incident_detector_first, 0];
	end
	
	if delta_occ_second(i)/max_occ_second(i) > tc_minnesota && (delta_occ_second(i) - delta_occ_d_second(i))/max_occ_second(i) > t1_minnesota
		minnesota_incident_detector_second = [minnesota_incident_detector_second, 1];
	else
		minnesota_incident_detector_second = [minnesota_incident_detector_second, 0];
	end
	
	if delta_occ_third(i)/max_occ_third(i) > tc_minnesota && (delta_occ_third(i) - delta_occ_d_third(i))/max_occ_third(i) > t1_minnesota
		minnesota_incident_detector_third = [minnesota_incident_detector_third, 1];
	else
		minnesota_incident_detector_third = [minnesota_incident_detector_third, 0];
	end
	
	if delta_occ_fourth(i)/max_occ_fourth(i) > tc_minnesota && (delta_occ_fourth(i) - delta_occ_d_fourth(i))/max_occ_fourth(i) > t1_minnesota
		minnesota_incident_detector_fourth = [minnesota_incident_detector_fourth, 1];
	else
		minnesota_incident_detector_fourth = [minnesota_incident_detector_fourth, 0];
	end
	
	if delta_occ_fifth(i)/delta_occ_d_fifth(i) > tc_minnesota && (delta_occ_fifth(i) - delta_occ_d_fifth(i))/delta_occ_d_fifth(i) > t1_minnesota
		minnesota_incident_detector_fifth = [minnesota_incident_detector_fifth, 1];
	else
		minnesota_incident_detector_fifth = [minnesota_incident_detector_fifth, 0];
	end
end
%-----------------------------------------------------------%

%---------------- SMD Calculations -----------%
for i=1:simulation_run_length
	
	if i > d_time_interval
	
		if (((occupancy_first_left(i) + occupancy_first_right(i)) / 2) - mean([occupancy_first_left(i-d_time_interval:i), occupancy_first_right(i-d_time_interval:i)])) / std([occupancy_first_left(i-d_time_interval:i), occupancy_first_right(i-d_time_interval:i)]) >= ts_threshold
			smd_incident_detector_first = [smd_incident_detector_first, 1];
		else
			smd_incident_detector_first = [smd_incident_detector_first, 0];
		end
		
		if (((occupancy_second_left(i) + occupancy_second_right(i)) / 2) - mean([occupancy_second_left(i-d_time_interval:i), occupancy_second_right(i-d_time_interval:i)])) / std([occupancy_second_left(i-d_time_interval:i), occupancy_second_right(i-d_time_interval:i)]) >= ts_threshold
			smd_incident_detector_second = [smd_incident_detector_second, 1];
		else
			smd_incident_detector_second = [smd_incident_detector_second, 0];
		end
		
		if (((occupancy_third_left(i) + occupancy_third_right(i)) / 2) - mean([occupancy_third_left(i-d_time_interval:i), occupancy_third_right(i-d_time_interval:i)])) / std([occupancy_third_left(i-d_time_interval:i), occupancy_third_right(i-d_time_interval:i)]) >= ts_threshold
			smd_incident_detector_third = [smd_incident_detector_third, 1];
		else
			smd_incident_detector_third = [smd_incident_detector_third, 0];
		end
		
		if (((occupancy_fourth_left(i) + occupancy_fourth_right(i)) / 2) - mean([occupancy_fourth_left(i-d_time_interval:i), occupancy_fourth_right(i-d_time_interval:i)])) / std([occupancy_fourth_left(i-d_time_interval:i), occupancy_fourth_right(i-d_time_interval:i)]) >= ts_threshold
			smd_incident_detector_fourth = [smd_incident_detector_fourth, 1];
		else
			smd_incident_detector_fourth = [smd_incident_detector_fourth, 0];
		end
		
		if (((occupancy_fifth_left(i) + occupancy_fifth_right(i)) / 2) - mean([occupancy_fifth_left(i-d_time_interval:i), occupancy_fifth_right(i-d_time_interval:i)])) / std([occupancy_fifth_left(i-d_time_interval:i), occupancy_fifth_right(i-d_time_interval:i)]) >= ts_threshold
			smd_incident_detector_fifth = [smd_incident_detector_fifth, 1];
		else
			smd_incident_detector_fifth = [smd_incident_detector_fifth, 0];
		end
	
	else 
		
		if (((occupancy_first_left(i) + occupancy_first_right(i)) / 2) - mean([occupancy_first_left(1:i), occupancy_first_right(1:i)])) / std([occupancy_first_left(1:i), occupancy_first_right(1:i)]) >= ts_threshold
			smd_incident_detector_first = [smd_incident_detector_first, 1];
		else
			smd_incident_detector_first = [smd_incident_detector_first, 0];
		end
		
		if (((occupancy_second_left(i) + occupancy_second_right(i)) / 2) - mean([occupancy_second_left(1:i), occupancy_second_right(1:i)])) / std([occupancy_second_left(1:i), occupancy_second_right(1:i)]) >= ts_threshold
			smd_incident_detector_second = [smd_incident_detector_second, 1];
		else
			smd_incident_detector_second = [smd_incident_detector_second, 0];
		end
		
		if (((occupancy_third_left(i) + occupancy_third_right(i)) / 2) - mean([occupancy_third_left(1:i), occupancy_third_right(1:i)])) / std([occupancy_third_left(1:i), occupancy_third_right(1:i)]) >= ts_threshold
			smd_incident_detector_third = [smd_incident_detector_third, 1];
		else
			smd_incident_detector_third = [smd_incident_detector_third, 0];
		end
		
		if (((occupancy_fourth_left(i) + occupancy_fourth_right(i)) / 2) - mean([occupancy_fourth_left(1:i), occupancy_fourth_right(1:i)])) / std([occupancy_fourth_left(1:i), occupancy_fourth_right(1:i)]) >= ts_threshold
			smd_incident_detector_fourth = [smd_incident_detector_fourth, 1];
		else
			smd_incident_detector_fourth = [smd_incident_detector_fourth, 0];
		end
		
		if (((occupancy_fifth_left(i) + occupancy_fifth_right(i)) / 2) - mean([occupancy_fifth_left(1:i), occupancy_fifth_right(1:i)])) / std([occupancy_fifth_left(1:i), occupancy_fifth_right(1:i)]) >= ts_threshold
			smd_incident_detector_fifth = [smd_incident_detector_fifth, 1];
		else
			smd_incident_detector_fifth = [smd_incident_detector_fifth, 0];
		end
		
	end
end
%-----------------------------------------------------------%


clear distance;
clear first_section_old_number_of;
clear first_section_current_number_of;
clear second_section_old_number_of;
clear second_section_current_number_of;
clear third_section_old_number_of;
clear third_section_current_number_of;
clear fourth_section_old_number_of;
clear fourth_section_current_number_of;
clear fifth_section_old_number_of;
clear fifth_section_current_number_of;
clear final_speed;
clear for_length;
clear generated_cars_number_of;
clear generated_line;
clear generated_velocity;
clear head_car;
clear headway;
clear is_other_to_be_checked;
clear i;
clear j;
clear k;
clear l;
clear is_pass_successful;
clear last_distance;
clear left_car;
clear left_velocity;
clear occupancy_divisor;
clear pass_list; 
clear pass_velocity;
clear path;
clear simulation_length_min;
clear simulation_length_sec;
clear right_car;
clear right_velocity;
clear state;
clear temp_avg_velocity_fifth_left;
clear temp_avg_velocity_fifth_left_counter;
clear temp_avg_velocity_fifth_right;
clear temp_avg_velocity_fifth_right_counter;
clear temp_avg_velocity_first_left;
clear temp_avg_velocity_first_left_counter;
clear temp_avg_velocity_first_right;
clear temp_avg_velocity_first_right_counter;
clear temp_avg_velocity_fourth_left;
clear temp_avg_velocity_fourth_left_counter;
clear temp_avg_velocity_fourth_right;
clear temp_avg_velocity_fourth_right_counter;
clear temp_avg_velocity_second_left;
clear temp_avg_velocity_second_left_counter;
clear temp_avg_velocity_second_right;
clear temp_avg_velocity_second_right_counter;
clear temp_avg_velocity_third_left;
clear temp_avg_velocity_third_left_counter;
clear temp_avg_velocity_third_right;
clear temp_avg_velocity_third_right_counter;
clear temp_cars_left;
clear temp_cars_right;
clear temp_head_forward;
clear temp_velocity_left;
clear temp_velocity_right;
clear temp_cars_stop_left;
clear temp_cars_stop_right;
clear tempq1in;
clear tempq1out;
clear tempq2in;
clear tempq2out;
clear tempq3in;
clear tempq3out;
clear tempq4in;
clear tempq4out;
clear tempq5in;
clear tempq5out;
