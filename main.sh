#!/bin/bash
running=true
numberOfPlayers=0
maxPlayers=4
minPlayers=1
randomN=0
guessedN=0
round=0
fields=0
positions=(0 0 0 0)
ponsLeft=(4 4 4 4)
Logo="
  _                    _         
 | |                  | |        
 | |       _   _    __| |   ___  
 | |      | | | |  / _\` |  / _ \ 
 | |____  | |_| | | (_| | | (_) |
 |______|  \__,_|  \__,_|  \___/ 
                                 
"
Map=(
"1 1                          2 2"
"1 1			      2 2"
"             □ □ ⚿              "
"             □ ■ □              "
"             □ ■ □              "
"             □ ■ □              "
"     ⚿ □ □ □ □ ■ □ □ □ □ □      "
"     □ ■ ■ ■ ■ ⛝ ■ ■ ■ ■ □      "
"     □ □ □ □ □ ■ □ □ □ □ ⚿      "
"             □ ■ □              "
"             □ ■ □              "
"             □ ■ □              "
"             ⚿ □ □              "
"3 3			      4 4"
"3 3			      4 4"
)
loadMap(){
  for (( i = 0; i < ${#Map[@]}; i++ )); do
	echo "${Map[i]}"
  done
}
choosePlayers(){
	echo "Choose number of players:"
	echo "1.One player"
	echo "2.Two players"
	echo "3.Three players"
	echo "4.Four Players"
	read numberOfPlayers
	if [[ -n "$numberOfPlayers" ]]; then
		if (( $numberOfPlayers > $maxPlayers || $numberOfPlayers < $minPlayers )); then
			echo "Wrong amount of players, try again!"
			choosePlayers
		fi
	else
		echo "Come on..."
		choosePlayers
	fi
}
intro(){
echo "$Logo"
echo "Welcome to ludo!"
choosePlayers
}
randomNumber(){
randomN=$(shuf -i 1-7 -n 1)
}
howManyFields(){
local buffer=$((randomN > guessedN ? randomN - guessedN : guessedN - randomN))
if (( buffer == 1 )); then
	fields=3
	echo "Almost!"
elif (( buffer == 2 )); then
	fields=2
	echo "Quite close"
elif (( buffer == 3 )); then
	fields=1
	echo "Not bad"
else
	echo "Bad guess ;("
fi
echo "The number is: $randomN"
}

guessNumber(){
local min=1
local max=7
echo "Player $((round+1)) round. Guess number from 1 to 7."
read guessedN
if [[ -n "$guessedN" ]]; then
	if [[ $((guessedN)) -gt $((max)) || $((guessedN)) -lt $((min)) ]]; then
	    echo "Wrong number, try again!"
    	    guessNumber
	fi
else
        echo "Come on..."
        guessNumber
fi
}

verification(){
if [[ $guessedN == $randomN ]]; then
	echo "Perfect!"
	if [[ ${positions[round]} -eq 0 ]]; then
		echo "Pawn entry"
		positions[round]=1
	else
		fields=4
	fi
else
	howManyFields
	if [[ $fields -eq 0 ]]; then
		echo "Player $((round+1)) remains at: ${positions[$round]}."
	fi
fi
}

moving(){
local max=$((40+${ponsLeft[round]}))
if [[ ${positions[round]} -ne 0 && $((${positions[round]}+fields)) -le $max ]]; then
	if [[ $((${positions[round]}+fields)) -gt 40 && $((${positions[round]}+fields)) -lt $max ]]; then
		echo "You cant move at that field in base. Player $((round+1)) remains at: ${positions[$round]}."
	else
	((positions[round] += fields))
	echo "Moved $fields fields. Current position of Player$((round+1)): ${positions[$round]}."
	fi
elif [[ $fields -ne 0 ]]; then
	echo "You cant move that many fields! Player $((round+1)) remains at: ${positions[$round]}."
fi
}

nextRound(){
if [[ $fields -ne 4 && ${positions[round]} -ne 1 ]]; then
	((round++))
fi
}

collision(){
for (( i = 0 ; i < $numberOfPlayers ; i++ )); do
	if [[ $i -ne $round && ${positions[i]} -eq ${positions[round]} && ${positions[i]} -gt 1 ]]; then
		echo "Pawn of Player $((i+1)) has been slain!"
		((positions[i] = 1))
	fi
done
}

info(){
for (( i = 0 ; i < $numberOfPlayers ; i++ )); do
	echo "Player $(($i+1)):"
	echo "Position: ${positions[$i]}"
	echo "Pons left: ${ponsLeft[$i]}"
	echo ""
done
}

#Main
clear
intro
clear
echo "$Logo"
while [ running ]; do
clear
echo "$Logo"
loadMap
echo ""
info

if [[ $round -eq $numberOfPlayers ]]; then
	round=0
fi

randomNumber
guessNumber
verification
moving

if [[ ${positions[round]} -gt 40 ]]; then
	echo "Pawn of Player $((round+1)) has entered the base!"
	((ponsLeft[round]--))
	((positions[round]=0))
	if [[ ${ponsLeft[round]} -eq 0 ]]; then
		echo "Player $((round+1)) has won!"
		break
	fi
fi

collision
nextRound

fields=0
sleep 3
done
echo "Game Over!"
