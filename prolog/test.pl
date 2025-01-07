%%-------------------------------------------------------------------------%%--
 % Pro-Food-Log Tests
 %
 % Contains the following sets of tests:
 %  - datatype
 %  - ~~core-algorithm~~ % not done
 %  - ~~database~~       % not done
%%-----------------------------------------------------------------------------
:- begin_tests('datatype').

% Time
test('Time: in-bounds', [nondet]) :- time(0.0), time(13.5), time(24.0).
test('Time: negative', [fail]) :- time(-0.5).
test('Time: not 0.25 of an hour', [fail]) :- time(6.33).
test('Time: greater than 24', [fail]) :- time(24.25).

% Price
test('Price: permissable values', [nondet]) :- 
    price(1), price(2), price(3), price(4), price(5).
test('Price: 0', [fail]) :- price(0).
test('Price: interval', [fail]) :- price(2.5).
test('Price: >5', [fail]) :- price(6).

:- end_tests('datatype').
