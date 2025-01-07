%%-------------------------------------------------------------------------%%--
 % Pro-Food-Log Algorithms
 % 
 % A console interfaced application with persistent profiles for choosing the
 % ideal restaurant around UBC for a group of friends.
 % 
 % Requires:
:- use_module(library(persistency)).
%%-----------------------------------------------------------------------------

%%THIS ONE IS IMPORTANT
%%-------------------------------------------------------------------------%%--
 % Database Setup
 % 
 % Defined DB quantities
:- persistent person(name:any).
:- persistent available(name:any, min:any, max:any).
:- persistent budget(name:any, level:any).
:- persistent prefers(name:any, cuisine:any).
 %
 % Create the DB if it isn't already
:- absolute_file_name('users.db', File, [access(write)]), db_attach(File, []).
%%-----------------------------------------------------------------------------


%%-------------------------------------------------------------------------%%--
 % Data Descriptions
 % 
 % Range
 % interp. possible values X could take in the set of points between [Low,High]
 %         with spacing Step. Starts at Low.
 % Returns true when X is in the range [Low,High].
range(Low, High, _, Low) :- Low =< High.
range(Low, High, Step, X) :- Low =< High, LowpStep is Low + Step, 
    range(LowpStep, High, Step, X).
 %
 % Time
 % interp. A 24 hour time with minutes as decimal of the hour. Note that 0 and
 %         24 are both midnight, and that it increases by 0.25 of an hour.
 % Ex. time(17.5).
time(T) :- range(0.0,24.0,0.25,T).
 %
 % Cuisine
 % interp. The cuisine of the food a restaurant makes.
 % Note: the following is the list of recognized cuisines.
cuisine_list(["French", "Italian", "Japanese", "Chinese", "Korean", "Indian", 
              "Malaysian", "Venezuelan", "Persian", "German", "Canadian", "Greek"]).
 %
 % Price
 % interp. The average price of the meals at a restaurant on a scale of 1 to 5.
 %         The ranges corresponding to each level on the scale are as follows:
 %  - 1  ($0.00 to $10.00)
 %  - 2  ($10.01 to $20.00)
 %  - 3  ($20.01 to $40.00)
 %  - 4  ($40.01 to $100.00)
 %  - 5  ($100.01 and above)
price(P) :- range(1, 5, 1, P).

% Convert from a budget in dollars to a price level.
budget_to_price(Budget, 1) :- Budget >= 0, Budget =< 10.
budget_to_price(Budget, 2) :- Budget > 10, Budget =< 20.
budget_to_price(Budget, 3) :- Budget > 20, Budget =< 40.
budget_to_price(Budget, 4) :- Budget > 40, Budget =< 100.
budget_to_price(Budget, 5) :- Budget > 100.

% Convert from a price level to budget in dollars.
price_to_budget(1, 0, 10).
price_to_budget(2, 10, 20).
price_to_budget(3, 20, 40).
price_to_budget(4, 40, 100).
price_to_budget(5, 100, unknown). 

 %
 % IOCase
 % interp. The branch of code that a user response should activate.
 % One of:
 %  - clear                 (remove all users from the database)
 %  - add                   (add a user to the database)
 %  - del                   (remove a user from the database)
 %  - update_availability   (update availability of a user)
 %  - update_budget         (update budget of a user)
 %  - update_cuisines       (update cuisine preferences of a user)
 %  - display_users         (nicely output the users in the database)
 %  - search                (find the best restaurant for the given profiles)
 %  - quit                  (end the food recommender) 
iocase(clear).
iocase(add).
iocase(del).
iocase(update_availability).
iocase(update_budget).
iocase(update_cuisines).
iocase(display_users).
iocase(search).
iocase(quit).
%%-----------------------------------------------------------------------------


%%-------------------------------------------------------------------------%%--
 % Command Line Interface
 %
 % Basic command information prompts
 %
preamble("Welcome to Pro-Food-Log.").
command_info("Please input one of the following commands:
    add : Add a new user with preferences
    del : Delete a user
    clear : Clear all users and preferences
    display_users : Show information about all users
    update_availability : Update a user's availability
    update_budget : Update a user's budget
    update_cuisines : Update a user's cuisine preferences
    search : Find a timing and restaurant matching all users' preferences
    quit : Exit Pro-Food-Log").
bad_user_input("Something went wrong! Please enter valid commands, only run commands on existing users, and format input correctly.").
time_preamble("Enter time in 24h format. Use decimals to specify minutes. Enter a time that is a multiple of 15 minutes. For example:
    Enter 18 for 18:00
    Enter 18.25 for 18:15
    Enter 18.5 for 18:30
    Enter 18.75 for 18:45").
goodbye("Goodbye, see you soon!").
 %
 % Text for displaying users
 %
display_person_preamble(Person, Msg) :- format(string(Msg), "User profile for ~w:", [Person]).
display_person_availability(Person, Min, Max, Msg) :- format(string(Msg), "~w is available from ~2f to ~2f.", [Person, Min, Max]).
display_person_budget(Person, Min, unknown, Msg) :- format(string(Msg), "~w's price range is over $~2f.", [Person, Min]).
display_person_budget(Person, Min, Max, Msg) :- format(string(Msg), "~w's price range is between $~2f and $~2f.", [Person, Min, Max]).
display_person_cuisine(Person, Cuisine, Msg) :- format(string(Msg), "~w likes ~w food.", [Person, Cuisine]).

 %
 % Preference entry prompts
 %
enter_name_new("Enter the name of the new user: ").
enter_min_time("Enter the earliest time the user is available: ").
enter_max_time("Enter the lastest time the user is available: ").
enter_budget("Enter the highest price the user is willing to pay: ").
enter_name_updates("Enter the name of the user to modify: ").
enter_name_delete("Enter the name of the user to delete: ").
cuisine_question(Cuisine, Question) :- format(string(Question), "Does this user like ~w food? Enter yes or no.", [Cuisine]).
 %
 % Get data from the user via the prompts for all the preferences:
 %  - budget
 %  - availability
 %  - cuisine preferences

% Prompt user for budget
get_budget(Price) :- enter_budget(MsgBudget), writeln(MsgBudget), 
    read_line_to_string(current_input, BudgetStr), 
    atom_number(BudgetStr, Budget), budget_to_price(Budget, Price).

% Prompt user for availability
get_availability(MinTime, MaxTime) :- time_preamble(TimeMsg), writeln(TimeMsg),
    enter_min_time(MsgMinTime), writeln(MsgMinTime), 
    read_line_to_string(current_input, MinTimeStr), 
    atom_number(MinTimeStr, MinTimeMaybeInt),
    enter_max_time(MsgMaxTime), writeln(MsgMaxTime), 
    read_line_to_string(current_input, MaxTimeStr), 
    atom_number(MaxTimeStr, MaxTimeMaybeInt),
    MinTime is MinTimeMaybeInt * 1.0, MaxTime is MaxTimeMaybeInt * 1.0, 
    time(MinTime), time(MaxTime).
 
% Prompt user for cuisine preferences
% Note: the user must answer "yes" for the preference to be recorded, any 
%       other response counts as a "no".
get_cuisine_preferences([], Preferences, Preferences) :- !.
get_cuisine_preferences([Cuisine|Rest], Acc, Preferences) :- 
    cuisine_question(Cuisine, Question), writeln(Question), 
    read_line_to_string(current_input, "yes"), 
    get_cuisine_preferences(Rest, [Cuisine|Acc], Preferences), !.
get_cuisine_preferences([_|Rest], Acc, Preferences) :- 
    get_cuisine_preferences(Rest, Acc, Preferences), !.

% Display cuisine preferences for a user
display_cuisines(_, []).
display_cuisines(Person, [Cuisine|Rest]) :- display_person_cuisine(Person, Cuisine, Msg), writeln(Msg),
    display_cuisines(Person, Rest).

% Display preferences for a user
display_person(Person) :- writeln(""), display_person_preamble(Person, Msg), writeln(Msg), 
    available(Person, TimeMin, TimeMax), display_person_availability(Person, TimeMin, TimeMax, AvailabilityMsg), writeln(AvailabilityMsg),
    budget(Person, Budget), price_to_budget(Budget, BudgetMin, BudgetMax), display_person_budget(Person, BudgetMin, BudgetMax, BudgetMsg), writeln(BudgetMsg),
    findall(Cuisine, prefers(Person, Cuisine), Cuisines), display_cuisines(Person, Cuisines).

% Display preferences for all users
display_users([]).
display_users([Person|Rest]) :- display_person(Person), display_users(Rest), !.

% Helper to add cuisine preferences to database
record_preferences(_, []).
record_preferences(Name, [Cuisine|Rest]) :- assert_prefers(Name, Cuisine), 
    record_preferences(Name, Rest).
 % 
 % Search Prompts
 %
search_success("\nDone! Here are the options earliest in the day:\n
-------------------------------------------\n| Time  | Restaurant | Cuisine | Budget |
-------------------------------------------").
search_fail("Search found no restaurants matching all preferences! :(").
search_prompt_num("How many users do you want to invite? Enter a number.").
search_prompt_name("Enter the name of a user to invite.").
 %
 % Search results formatting
 %
% Puts a search result (a meal) in the following format:
%  | HH.xx | RestaurantName | Cuisine | Budget
format_search_result(Time, Restaurant, Cuisine, BudgetMin, BudgetMax, Line) :- 
    format(string(Line), "| ~2f | ~w | ~w | $~2f to $~2f |\n", [Time, Restaurant, Cuisine, BudgetMin, BudgetMax]).

% Converts the search results into a string for output.
% Note: this is a non-tail recursive function which could lead to stack issues
%       if there are enough results in the search.
search_to_string([],"-------------------------------------------\n").
search_to_string([[Restaurant, Time]|OtherOptions], String) :- 
    makes(Restaurant, Cuisine), price(Restaurant, Price), price_to_budget(Price, Min, Max),
    format_search_result(Time, Restaurant, Cuisine, Min, Max, Line), search_to_string(OtherOptions, Result), 
    string_concat(Line, Result, String).

% Get usernames of users to search over
search_get_usernames(0, People, People) :- !.
search_get_usernames(Num, Acc, People) :- search_prompt_name(Msg), writeln(Msg),
    read_line_to_string(current_input, Name), person(Name), X is Num-1, search_get_usernames(X, [Name|Acc], People).

 %
 % Handle input commands
 %
 % Note: there is a handle_input/1 case for each IOCase case.
% Remove all users info from the DB
handle_input(clear) :- retractall_person(_), retractall_available(_, _, _),
     retractall_budget(_, _), retractall_prefers(_, _).

% Create a new profile/user in the DB
handle_input(add) :- enter_name_new(MsgName), writeln(MsgName), 
    read_line_to_string(current_input, Name), 
    get_availability(MinTime, MaxTime), get_budget(Price), 
    cuisine_list(Cuisines), get_cuisine_preferences(Cuisines, [], Preferences),
    assert_person(Name), assert_available(Name, MinTime, MaxTime), 
    assert_budget(Name, Price),
    record_preferences(Name, Preferences).

handle_input(update_availability) :- enter_name_updates(MsgName), 
    writeln(MsgName), read_line_to_string(current_input, Name), 
    get_availability(MinTime, MaxTime), retract_available(Name, _, _),
    assert_available(Name, MinTime, MaxTime).

handle_input(update_budget) :- enter_name_updates(MsgName), writeln(MsgName),
    read_line_to_string(current_input, Name), get_budget(Price), 
    retract_budget(Name, _), assert_budget(Name, Price).

handle_input(update_cuisines) :- enter_name_updates(MsgName), writeln(MsgName),
    read_line_to_string(current_input, Name), cuisine_list(Cuisines),
    get_cuisine_preferences(Cuisines, [], Preferences), 
    retractall_prefers(Name, _), record_preferences(Name, Preferences).

handle_input(del) :- enter_name_delete(MsgName), writeln(MsgName),
    read_line_to_string(current_input, Name), retractall_person(Name), 
    retract_available(Name, _, _), retract_budget(Name, _), retractall_prefers(Name, _).

handle_input(display_users) :- findall(P, person(P), People), display_users(People).

handle_input(quit) :- goodbye(Msg), writeln(Msg), halt.

% Find the earliest time for a meal at each restaurant suitable for the specified users.
handle_input(search) :- search_prompt_num(MsgNum), writeln(MsgNum), read_line_to_string(current_input, NumUsersStr),
    atom_number(NumUsersStr, NumUsers), integer(NumUsers), NumUsers > 0, search_get_usernames(NumUsers, [], People),
    search_for_restaurants(Search, People) -> 
    unique_restaurants(Search, Unique), search_to_string(Unique, Options), 
    search_success(Msg), writeln(Msg), writeln(Options) ; 
    search_fail(Msg), writeln(Msg).

handle_input(_) :- bad_user_input(Msg), writeln(Msg).
 
 %
 % Entry point of program
 %
start :- preamble(Msg), writeln(Msg), loop.
loop :- writeln(""), command_info(Msg), writeln(Msg),
    read_line_to_string(current_input, CommandStr),
    atom_string(Command, CommandStr),                              
    handle_input(Command), loop.
%%-----------------------------------------------------------------------------


%%-------------------------------------------------------------------------%%--
 % Core Searching Algorithm
 %
 % Run the search for all the profiles in the DB
 % Returns: a list of pairs [Restaurant, Time] of the valid places and times to
 %          eat given the users specified.
search_for_restaurants(Search, People) :- 
    bagof([R,T], compatible_restaurant(R, T, People), Search).                    % Find restaurants and times for all people

 % Find compatible restaurants for a list of people
 % Details: Recursively checks if the profiles of people in the DB are
 %          compatible with a restaurant R at time T.
compatible_restaurant(_, _, []).
compatible_restaurant(R, T, [Person|Others]) :- 
    matches_preferences(R, T, Person), compatible_restaurant(R, T, Others).

 % Check if a restaurant at a specific time works for a given person
 % Details: Uses the ground values defined in the DB and in the restaurant
 %          section for people and restaurants respectively to check if
 %          are compatible preferences.
 %
 %          The person's availability must end after the restaurant opens and
 %          start after the restaurant opens.
 %          
 %          The person's budget level must be greater than or equal to the
 %          restaurant's pricing level.
 %
 %          At least one of the person's cuisine preferences must be the
 %          cuisine the restaurant makes.
 %
 %          There must also be a valid meal time given availability and hours.
 %% THIS ONE IMPORTANT!
matches_preferences(R, Time, Person) :- 
    person(Person), restaurant(R),                                                  % Check person and restaurant
    available(Person, StartTime, EndTime), hours(R, Open, Close),                   % Check availability and restaurant hours
    Open =< EndTime, StartTime =< Close,
    budget(Person, PBudget), price(R, RBudget), RBudget =< PBudget,                 % Check budgets and pricing
    makes(R, RCuisine), prefers(Person, PCuisine), PCuisine = RCuisine,             % Check cuisine preferences
    MinTime is max(StartTime, Open), MaxTime is min(EndTime, Close),                % Check for a possible meal time
    range(MinTime, MaxTime, 0.25, Time).

 % Get only the first time for each restaurant from the list of all meals.
 % Details: Done by keeping only the first occurrence of each restaurant.
unique_restaurants(Search, Unique) :- unique_restaurants(Search, [], Unique).       % Interface case
unique_restaurants([], _, []).                                                      % Base case
unique_restaurants([[R,_]|OtherOptions], SeenR, Unique) :- member(R, SeenR),        % Restaurant has been seen already
    unique_restaurants(OtherOptions, SeenR, Unique).
unique_restaurants([[R,T]|OtherOptions], SeenR, [[R,T]|Unique]) :-                  % New restaurant, update best and seen
    unique_restaurants(OtherOptions, [R|SeenR], Unique).
%%-----------------------------------------------------------------------------
