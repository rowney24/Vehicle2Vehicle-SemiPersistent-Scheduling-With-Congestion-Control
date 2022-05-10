%Coded by Ronald Chitauro for my undergrad thesis at Nanjing University of Science and Technology


clc;
clear all;


%Input Parameter One and Code for Validation of Input
NumSubframes = input('Input the number of sub-frames:'); %user defines number of subframes. In the matrix, this is the row

%The following code is important in controlling the user parameters. It reduces system errors by ensuring that the user input the right data

%if the user press return without entering any value
while isempty(NumSubframes) == 1
    disp('Error! You can not leave this field bank! Please enter the number of sub-frames again.   ');
    NumSubframes = input('Input the number of sub-frames:  ');
end 
%if the user enter a value beyond the limit
while NumSubframes < 2000 || NumSubframes > 200000
    disp('Error! The number of subframes should be an absolute integer number, greater than 2000 but not greater than 200 000 for this simulation.   ');
    NumSubframes = input('Input the number of sub-frames:  ');
    %In case the user enters a zero again, i.e leave it blank
  while isempty(NumSubframes) == 1
    disp('Error! You can not leave this field bank! Please enter the number of sub-frames again.   ');
    NumSubframes = input('Input the number of sub-frames:  ');
  end 
end




%Input Parameter Two and Code for Validation of Input
NumSubChannels = input('Input the number of sub-channels:'); %user defines number of subchannels. In the matrix, this is the column

%The following code is important in controlling the user parameters. It reduces system errors by ensuring that the user input the right data

%if the user press return without entering any value
while isempty(NumSubChannels) == 1
    disp('Error! You can not leave this field bank! Please enter the number of sub-channels again.   ');
    NumSubChannels = input('Input the number of sub-channels:  ');
end 
%if the user enter a value beyond the limit
while NumSubChannels < 0 || NumSubChannels > 4
    disp('Error! The number of sub-channels should be an absolute integer number and not greater than 4 for this simulation.   ');
    NumSubChannels = input('Input the number of sub-channels:  ');
    %In case the user enters a zero again, i.e leave it blank
  while isempty(NumSubChannels) == 1
    disp('Error! You can not leave this field bank! Please enter the number of sub-channels again.   ');
    NumSubChannels = input('Input the number of sub-channels:  ');
  end 
end





%Input Parameter Three and Code for Validation of Input
NumVehicles = input('Input the number of vehicles:'); %user defines number of vehicles. In the matrix, this is the 3rd dimension

%if the user press return without entering any value
while isempty(NumVehicles) == 1
    disp('Error! You can not leave this field bank! Please enter the number of vehicles again.   ');
    NumVehicles = input('Input the number of vehicles:  ');
end 
%if the user enter a value beyond the limit
while NumVehicles < 0 || NumVehicles > 10000
    disp('Error! The number of vehicles should be an absolute integer number and not greater than 10 000 for this simulation.   ');
    NumVehicles = input('Input the number of vehicles:  ');
    %In case the user enters a zero again, i.e leave it blank
  while isempty(NumVehicles) == 1
    disp('Error! You can not leave this field bank! Please enter the number of vehicles again.   ');
    NumVehicles = input('Input the number of vehicles:  ');
  end 
end




%Code That define the V2X Pool 
V2Xpool = zeros(NumSubChannels,NumSubframes, NumVehicles); %defines the number of subchannels, subframes and vehicles in the V2X pool










%CODE FOR THE SENSING WINDOW
sensing_vehicles = randi([5,20]);     %The number of vehicles in the past (the sensing window). 

   %Loop for giving giving TBs to the subframes in the sensing window
   %The history should be the same and so this code is maintained for each vehicle 
   for sensing_analyzer = 1:sensing_vehicles
       
       sensing_subframes = randi([1,100]);               %select subframe
       sensing_subchannels = randi([1,NumSubChannels]); %select subchannel
       sensing_periodicity = 100;            %sensing_periodicity
       sensing_reselections = randi([5,25]);             %Number of reselections
       
       check_sensing_subframes = sensing_subframes + (sensing_periodicity * sensing_reselections); %Maximum number of subframes selected by the previous vehicles
       
       while check_sensing_subframes > (1500)  %If the number of subframes chosen is bigger than 1500, reselect again.
                   sensing_subframes = randi([1,100]);               %select subframe
                   sensing_periodicity = randi([0,50]);            %sensing_periodicity
                   sensing_reselections = randi([5,40]);             %Number of reselections 
                   check_sensing_subframes = sensing_subframes + (sensing_periodicity * sensing_reselections);
       end
       
       V2Xpool( sensing_subchannels, sensing_subframes, :) = 777; % 777 denotes the selection of a RB
      
       %This code then make sure that each 
       for sensing_counter = 1:sensing_reselections
                V2Xpool( sensing_subchannels, sensing_subframes + (sensing_periodicity * sensing_counter), :) = 777; % This also selects a 777 in the reserved spots
       end
              
   end
   
   
   debug = 1;     % cool for debugging the sensing window.
   
   

   
   
   
   
   
   
   % The following FOR LOOP does the selection. What a good code!!! Tested!
   for  vehic_select = 1:NumVehicles
       
       %%%%%%%%%%% Variables for the selection window  %%%%%%%%%%%%%%%%%%
       
       sel_trig = randi([1003,1100]); % This represents the time the selection trigger is given
       start_select = randi([0,20]); %This represents the time the selection window starts. maximum delay from the trigger is like 20ms
       end_select = 0; %Initialization
       
       selection_window_size = randi([20,100]);  %This together with the following code allows the selection window to be either 20, 50 or 100 subframes in size.
       
       if selection_window_size < 50 
           end_select = 20; 
       end
       
       if selection_window_size >= 50 || selection_window_size <= 75
           end_select = 50; 
       end
       
       if selection_window_size > 75 
           end_select = 100; 
       end
       
       
       
       
       
       sel_window_start = sel_trig + start_select;       %These two statements highlight the time from which the selection will be made
       sel_window_end = sel_window_start +  end_select;  %End of selection window. The length of the selection window is less than 100 subframes.
       
       
       
       
       %%%%%%% Variables for selection within the selection window  %%%%%%%%%%%
       period_select = 100; %This is for periodicity. can reserve a subframe
       mult_Periodicity = randi([5,15]); %These are the number of times the vehicle can reserve.
       
         
       
       
       sf_select = randi([sel_window_start, sel_window_end]); %This randomly chooses the subframe from which the RB will be selected from the selection window
       sc_select = randi([1,NumSubChannels]); %This randomly chooses the subchannel from which the RB will be selected.
       
      %The above two lines allows the vehicle to select its resource's SF
      %and Sub-Channel WITHIN THE SELECTION WINDOW.
      
      % at the same time the number of subframes chosen should not exceed the number of subframes the user defined. the vehicles should not select outside the subframe range
       
      check_selected_subframes = sf_select + (period_select * mult_Periodicity);
      
      while V2Xpool( sc_select, sf_select,  vehic_select) == 777  %This is to avoid selecting what previous vehicles already reserved
           sf_select = randi([sel_window_start, sel_window_end]); %This randomly chooses the subframe from which the RB will be selected from the selection window
           sc_select = randi([1,NumSubChannels]); %This randomly chooses the subchannel from which the RB will be selected.
      end
      
      %to avoid subframes already selected by other vehicles. If you avaoid selecting what other vehicles selected then you automatically avoid colliding with their reservations 
      
      if vehic_select>1
          while V2X_collision_detector(sc_select, sf_select) == 1  %This is to avoid selecting what previous vehicles already reserved
           sf_select = randi([sel_window_start, sel_window_end]); %This randomly chooses the subframe from which the RB will be selected from the selection window
           sc_select = randi([1,NumSubChannels]); %This randomly chooses the subchannel from which the RB will be selected.
          end 
      end
      
      %NOTE: OUTSIDE THE SELECTION WINDOW, WE CAN NOT AVOID COLLISION WITH
      %THE SUBFRAMES PREVIOUSLY SELECTED BY THE PREVIOUS VEHICLES. WE WILL
      %REPRESENT THEM IN THE COLLISION WINDOWS BY THE NUMBER (NumVehicles +1)
      
      while check_selected_subframes > NumSubframes
              while V2Xpool( sc_select, sf_select,  vehic_select) == NumVehicles  %This is to avoid selecting what previous vehicles already reserved
                   sf_select = randi([sel_window_start, sel_window_end]); %This randomly chooses the subframe from which the RB will be selected from the selection window
                   sc_select = randi([1,NumSubChannels]); %This randomly chooses the subchannel from which the RB will be selected.
              end
          mult_Periodicity = randi([3, 15]);        %The Number of times the vehicle reserves multiplied by the Periodicity should be less than Number of subframes
          period_select = randi([0,100]);
          check_selected_subframes = sf_select + (period_select * mult_Periodicity);
      end
       
       
       V2Xpool( sc_select, sf_select,  vehic_select) = 1; % 1 denotes the selection of a RB
       
       %to select other resources because of Periodicity and Reselection, We use the
       %following function. We have to make sure that when the device
       %reserve some resources, it wont select the resource that are within
       %the defined number of subframes.
       
       for reservation_counter = 1:mult_Periodicity
           if (sf_select + (period_select * reservation_counter)) < NumSubframes %We should not have more subframes than the predefined
               V2Xpool( sc_select, sf_select + (period_select * reservation_counter) ,  vehic_select) = 1; % This also selects a 1 in the reserved spots
          
           end
       end
   
   results_yessir = find(V2Xpool == 1); %Cool for debugging
   
  
  %%%%%%%% Now onto the code that tests to see if there are any collisions .%%%%%%%% 
  
  % We are going to use these parameters to control the addition of
  % Matrices within the Multidimensional Matrix. I will add elements in the
  % matrix that are on the same position at the same time and move up until
  % i add for the whole matrix. Places where the matrix is more than 1
  % represent a collision.
   
  V2X_collision_detector = zeros(NumSubChannels, NumSubframes);
  
            for vehicle_num_collision = 1: NumVehicles - 1

                if vehicle_num_collision == 1
                    V2X_collision_detector = V2X_collision_detector + V2Xpool(:,:,vehicle_num_collision) + V2Xpool(:,:,vehicle_num_collision + 1);
                end

                if  vehicle_num_collision > 1 
                V2X_collision_detector = V2X_collision_detector + V2Xpool(:,:,vehicle_num_collision + 1);
                end 
                collision_greater_than_one = find(V2X_collision_detector > 1); %shows the places in the collision detection matrix where the number is greater than one
                results_yeah3 = find(V2X_collision_detector > 1); %Cool for debugging


            end
   
   
   
    results_yeah = find(V2Xpool == 1); %Cool for debugging
   
   
   
   %Reselection Loop
   
   
   %Selection of the selection window
   last_subframe = sf_select + (period_select * reservation_counter);
   infinity_duckin = 0;

           while last_subframe < NumSubframes

               prob_reselection = randn(1); %if rand is greater than 0.8 then we keep the pattern we had before reselection. If less than, we have to select with a new pattern


                   if prob_reselection <= 0.8  %Keep the same pattern

                       period_select = 100; %This is for periodicity. can reserve a subframe
                       mult_Periodicity = randi([5,15]); %These are the number of times the vehicle can reserve.
                       sc_select = sc_select+1-1; % The position of the subchannel remain the same
                       sf_select = last_subframe + period_select;
                       

                       if sf_select < NumSubframes
                            while V2X_collision_detector( sc_select, sf_select) == 1 % If the resource has been selected already
                               while infinity_duckin < 1000 %to avoid infinity loop
                               sf_select = last_subframe + period_select + randi(1,100); %Select another resource that is just near the one you were supposed to occupy BUT is unoccuped
                               sc_select = randi([1,NumSubChannels]);
                               infinity_duckin = infinity_duckin+1;
                               end

                               if infinity_duckin >= 100
                                   V2X_collision_detector( sc_select, sf_select) = 0;  %Cheating the infinity loop. I will make V2X_collision_detector( sc_select, sf_select) = 1 again just after the loop is terminated
                               end
                            end


                                    while V2X_collision_detector( sc_select, sf_select) >= 777 % If the resource has been selected already
                                        while infinity_duckin < 100 %to avoid infinity loop
                                            sf_select = last_subframe + period_select + randi(1,100); %Select another resource that is just near the one you were supposed to occupy BUT is unoccuped
                                            sc_select = randi([1,NumSubChannels]);
                                            infinity_duckin = infinity_duckin+1;
                                        end

                                        if infinity_duckin >= 100
                                            V2X_collision_detector( sc_select, sf_select) = 0;  %Cheating the infinity loop. I will make V2X_collision_detector( sc_select, sf_select) = 1 again just after the loop is terminated
                                        end
                                    end

                            if infinity_duckin >= 100
                                   V2X_collision_detector( sc_select, sf_select) = 1;  %Letting the pool remain as it was. The last sf_select will be automatically chosen even though a collision will happen
                            end

                                for reservation_counter = 1:mult_Periodicity
                                       if (sf_select + (period_select * reservation_counter)) < NumSubframes %We should not have more subframes than the predefined
                                           V2Xpool( sc_select, sf_select + (period_select * reservation_counter) ,  vehic_select) = 1; % This also selects a 1 in the reserved spots
                                       end
                                end
                       end
                      

                   end


                   if prob_reselection > 0.8 %Find a new pattern for transmission

                       period_select = 100; %This is for periodicity. can reserve a subframe
                       mult_Periodicity = randi([5,15]); %These are the number of times the vehicle can reserve.
                       sc_select = randi([1,NumSubChannels]); %This randomly chooses the subchannel from which the RB will be selected
                       sf_select = last_subframe + randi([3,100]); %select another subframe

                   if sf_select < NumSubframes
                           while V2X_collision_detector( sc_select, sf_select) == 1 % If the resource has been selected already
                               while infinity_duckin < 100 %to avoid infinity loop
                                       sf_select = sf_select + randi(1,100); %Select another resource that is just near the one you were supposed to occupy BUT is unoccuped
                                       while sf_select>NumSubframes
                                           sf_select = sf_select - randi(1,100);
                                       end
                                       sc_select = randi([1,NumSubChannels]);
                                       infinity_duckin = infinity_duckin+1;
                               end
                               
                               if infinity_duckin >= 100
                                   V2X_collision_detector( sc_select, sf_select) = 0;  %Cheating the infinity loop. I will make V2X_collision_detector( sc_select, sf_select) = 1 again just after the loop is terminated
                               end
                               
                           end
                           
                       
              
                           
                           while V2X_collision_detector( sc_select, sf_select) >= 777 % If the resource has been selected already
                               while infinity_duckin < 100 %to avoid infinity loop
                                   sf_select = sf_select + randi(1,100);randi(1,100); %Select another resource that is just near the one you were supposed to occupy BUT is unoccuped
                                   while sf_select>NumSubframes
                                           sf_select = sf_select - randi(1,100);
                                   end
                                   sc_select = randi([1,NumSubChannels]);
                                   infinity_duckin = infinity_duckin+1;
                               end
                               
                               if infinity_duckin >= 100
                                   V2X_collision_detector( sc_select, sf_select) = 0;  %Cheating the infinity loop. I will make V2X_collision_detector( sc_select, sf_select) = 1 again just after the loop is terminated
                               end
                           end
                           
                           if infinity_duckin >= 100
                                     V2X_collision_detector( sc_select, sf_select) = 1;  %Letting the pool remain as it was. The last sf_select will be automatically chosen even though a collision will happen
                           end
                           
                            for reservation_counter = 1:mult_Periodicity
                                   if (sf_select + (period_select * reservation_counter)) < NumSubframes %We should not have more subframes than the predefined
                                       V2Xpool( sc_select, sf_select + (period_select * reservation_counter) ,  vehic_select) = 1; % This also selects a 1 in the reserved spots
                                   end
                            end


                   end
                   
                   
                       
                   end

                   last_subframe = sf_select + (period_select * reservation_counter);   
           end
   
   
   
   end
   
   
   
   
  

% Probability Code

num_of_elements = 0;   %Initialization: This will add all the elements in the matrix
        
for m = 1:NumSubframes      %rows
    for n = 1:NumSubChannels  %colums
        if V2X_collision_detector(n,m) ~=0
            if V2X_collision_detector(n,m) ~= NumVehicles*777 
                if V2X_collision_detector(n,m) < 777
                 add = V2X_collision_detector(n,m);
                 num_of_elements = num_of_elements + add;
                 add = 0;
                end
            end
        end
    end
end

all_selections = find(V2X_collision_detector >= 1); %Finding the total number of selected resources
all_selections_length = length(all_selections);

sensing_selections = find(V2X_collision_detector == NumVehicles*777);
sensing_selections_length = length(sensing_selections);

total_selections = all_selections_length - sensing_selections_length; %These are the total number of selections made from the selection window

    
total_collisions = num_of_elements - total_selections;

if total_collisions < 0
    total_collisions = 0;
end

bamm = length(find(V2X_collision_detector(:,:)>=2));
bamm2 = length(find(V2X_collision_detector(:,:)>= 100));
real_collisions = bamm-bamm2;

Probability_of_collision = total_collisions/total_selections;
Probability_of_real_collision = real_collisions/total_selections;


 
