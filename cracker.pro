% Cracker Barrel peg game in pure Prolog
% author: Constant Marks, 2019
% license: free to all

c:-['cracker.pro'].

% initial states
state([1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]). 
state([0, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]). 
state([0, 1, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]). 
state([0, 1, 2, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]). 
state([0, 1, 2, 3, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14]). 
state([0, 1, 2, 3, 4, 6, 7, 8, 9, 10, 11, 12, 13, 14]).  

% forward move facts
move(0,1,3).
move(0,2,5).
move(1,3,6).
move(1,4,8).
move(2,4,7).
move(2,5,9).
move(3,6,10).
move(3,7,12).
move(4,7,11).
move(4,8,13).
move(5,8,12).
move(5,9,14).
move(3,4,5).
move(6,7,8).
move(7,8,9).
move(10,11,12).
move(11,12,13).
move(12,13,14).

% lines for printing state
line(1,[4,0,0]).
line(2,[3,1,2]).
line(3,[2,3,5]).
line(4,[1,6,9]).
line(5,[0,10,14]).

% legal moves are the forward rules and backward rules given some F, O, and T peg
legalMoves(F,O,T,move(F,O,T)):-move(F,O,T);move(T,O,F).

% remove peg, P, from peg state list, S, and return all other pegs
remPeg(P,[S|_],S):- P\=S.
remPeg(P,[_|Ss],S):-
  remPeg(P,Ss,S).

% create a new peg state by removing F and O pegs and adding T peg
newState(F,O,T,S, NewSS):-
  findall(R,(remPeg(O,S,R), remPeg(F,S,R)), NewS),
  sort([T|NewS], NewSS). 

% define an empty hole rule
emptyHoles(X,State):- 
  member(X,[0, 1, 2, 3, 4, 5, 6, 7, 8,9,10,11,12,13,14]),
  \+member(X,State).

% define a filled hole rule
filledHoles(X,State):-
  member(X,[0, 1, 2, 3, 4, 5, 6, 7, 8,9,10,11,12,13,14]),
  member(X,State).

% define possible move rules, M, from current state, S
possibleMoves(M, S):-
  emptyHoles(T,S),
  filledHoles(F,S),
  filledHoles(O,S),
  legalMoves(F,O,T,M).

% get a list of all possible moves
allMoves(S, R) :- findall(M, possibleMoves(M, S), R).

% find the length of the list of all possible moves
numMoves(S, L) :- 
  allMoves(S,R), 
  length(R,L).

% New state rule, given a state and a move
makeMove(move(F,O,T),S, NewS):-
  newState(F,O,T,S,NewS). 
 
% Play game
% If only one peg remaining then success!!
playGame(S,Moves, RM, States, RS):-
  length(S,K),
  K = 1, 
  reverse(Moves, RM), 
  reverse(States, RS).

% If more then one peg remaining and no more moves => fail
playGame(S,_, _, _, _):-
  length(S,K),
  K > 1,
  numMoves(S, L),
  L == 0,
  fail. 

% Recursive game play 
playGame(S,Acc1,Moves, Acc2, States):-
  length(S,K),
  K > 1,
  possibleMoves(M, S),
  makeMove(M,S,NewS),
  playGame(NewS,[M|Acc1],Moves,[NewS|Acc2], States).

% helper function to accumulate states and moves
moveNstateAccum(S,Moves,States):-
  playGame(S,[],Moves,[], States),!. 

% game player that returns the first solution
play(State):-
  printState(State),nl,
  moveNstateAccum(State, _, States),
  printStates(States),
  fail; true. 

% game states printer wrapper to print all states from a game play
printStates([S|Ss]):-
  printState(S), nl, 
  printStates(Ss). 

% print state wrapper to print state line by line
printState(S):-line(_,P), printLine(P,S), nl, fail; true. 

% line printer for each line in the peg state board
printLine([T,A,B],S):-
  repeat(' ', T, Tabs),
  dotsNstars(S,A,B,'',DS),
  format('~w ~w',[Tabs,DS]),!.

% helper function to build up indent string as specified by first element in each line list
repeat(_,0,'').
repeat(Str,1,Str).
repeat(Str,Num,Res):-
    Num1 is Num-1,
    repeat(Str,Num1,Res1),
    string_concat(Str, Res1, Res).

% if-then-else helper function (thanks Paul)
ite(Cond,Then,_Else):-Cond,!,Then.
ite(_Cond,_Then,Else):-Else.

% helper function to build up string of stars(pegs) and dots (holes) from second and third
% element in each line list
dotsNstars(S,B,B,Acc,DS):-
  ite(member(B,S),Str='* ',Str='. '),
  string_concat(Acc, Str, DS).

dotsNstars(S,A,B,Acc,DS):-
  A=<B, 
  ite(member(A,S),Str='* ',Str='. '),
  N is A+1,
  string_concat(Acc, Str, Res),
  dotsNstars(S,N,B,Res,DS).

% go plays each of the five unique starting states
go:-
  state(S), printHeader(S), play(S), nl, fail; true. 

% helper function to print a header for each unique game state
printHeader(S):-
  emptyHoles(X,S),
  format(" === ~w ===~n",[X]). 

:-go.
/*?- go.
=== 0 ===
    .
   * *
  * * *
 * * * *
* * * * *

    *
   . *
  . * *
 * * * *
* * * * *

    *
   * *
  . . *
 * * . *
* * * * *

    *
   * *
  * . *
 . * . *
. * * * *

    *
   * *
  * * *
 . . . *
. . * * *

    *
   . *
  . * *
 * . . *
. . * * *

    *
   . .
  . . *
 * * . *
. . * * *

    *
   . *
  . . .
 * * . .
. . * * *

    .
   . .
  . . *
 * * . .
. . * * *

    .
   . .
  . . *
 . . * .
. . * * *

    .
   . .
  . . *
 . . * .
. * . . *

    .
   . .
  . . .
 . . . .
. * * . *

    .
   . .
  . . .
 . . . .
. . . * *

    .
   . .
  . . .
 . . . .
. . * . .


=== 1 ===
    *
   . *
  * * *
 * * * *
* * * * *

    *
   * *
  . * *
 . * * *
* * * * *

    .
   . *
  * * *
 . * * *
* * * * *

    .
   * *
  * . *
 . * . *
* * * * *

    .
   * *
  * * *
 . . . *
* . * * *

    .
   . *
  . * *
 * . . *
* . * * *

    .
   . *
  * * *
 . . . *
. . * * *

    .
   . .
  * . *
 . * . *
. . * * *

    .
   . *
  * . .
 . * . .
. . * * *

    .
   . *
  * . .
 . * . .
. * . . *

    .
   . *
  * * .
 . . . .
. . . . *

    .
   . *
  . . *
 . . . .
. . . . *

    .
   . .
  . . .
 . . . *
. . . . *

    .
   . .
  . . *
 . . . .
. . . . .


=== 2 ===
    *
   * .
  * * *
 * * * *
* * * * *

    *
   * *
  * * .
 * * * .
* * * * *

    .
   * .
  * * *
 * * * .
* * * * *

    .
   * *
  * . *
 * . * .
* * * * *

    .
   * *
  * * *
 * . . .
* * * . *

    .
   . *
  * . *
 * . * .
* * * . *

    .
   * *
  . . *
 . . * .
* * * . *

    .
   * .
  . . .
 . . * *
* * * . *

    .
   * .
  . . *
 . . * .
* * * . .

    .
   * .
  . . *
 . . * .
* . . * .

    .
   * .
  . * *
 . . . .
* . . . .

    .
   * .
  * . .
 . . . .
* . . . .

    .
   . .
  . . .
 * . . .
* . . . .

    .
   . .
  * . .
 . . . .
. . . . .


=== 3 ===
    *
   * *
  . * *
 * * * *
* * * * *

    .
   . *
  * * *
 * * * *
* * * * *

    *
   . .
  * * .
 * * * *
* * * * *

    *
   * .
  . * .
 . * * *
* * * * *

    *
   * *
  . . .
 . . * *
* * * * *

    *
   * *
  . * .
 . . . *
* * * . *

    .
   * .
  . * *
 . . . *
* * * . *

    .
   * *
  . * .
 . . . .
* * * . *

    .
   * .
  . . .
 . * . .
* * * . *

    .
   * .
  . . .
 . * . .
* . . * *

    .
   * .
  . . .
 . * . .
* . * . .

    .
   * .
  * . .
 . . . .
* . . . .

    .
   . .
  . . .
 * . . .
* . . . .

    .
   . .
  * . .
 . . . .
. . . . .


=== 4 ===
    *
   * *
  * . *
 * * * *
* * * * *

    *
   * *
  * * *
 * . * *
* . * * *

    *
   * *
  * * *
 * * . .
* . * * *

    *
   . *
  * . *
 * * * .
* . * * *

    *
   * *
  . . *
 . * * .
* . * * *

    .
   . *
  * . *
 . * * .
* . * * *

    .
   . .
  * . .
 . * * *
* . * * *

    .
   . .
  * . *
 . * * .
* . * * .

    .
   . .
  * . *
 . * * .
* * . . .

    .
   . .
  . . *
 . . * .
* * * . .

    .
   . .
  . . *
 . . * .
* . . * .

    .
   . .
  . . .
 . . . .
* . * * .

    .
   . .
  . . .
 . . . .
* * . . .

    .
   . .
  . . .
 . . . .
. . * . .


=== 5 ===
    *
   * *
  * * .
 * * * *
* * * * *

    .
   * .
  * * *
 * * * *
* * * * *

    *
   . .
  . * *
 * * * *
* * * * *

    *
   * .
  . . *
 * * . *
* * * * *

    *
   * *
  . . .
 * * . .
* * * * *

    .
   . *
  * . .
 * * . .
* * * * *

    .
   * *
  . . .
 . * . .
* * * * *

    .
   * *
  . * .
 . . . .
* . * * *

    .
   . *
  . . .
 . . * .
* . * * *

    .
   . *
  . . .
 . . * .
* * . . *

    .
   . *
  . . .
 . . * .
. . * . *

    .
   . *
  . . *
 . . . .
. . . . *

    .
   . .
  . . .
 . . . *
. . . . *

    .
   . .
  . . *
 . . . .
. . . . .
 */