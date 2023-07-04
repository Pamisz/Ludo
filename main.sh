#!/bin/bash
# Author           : Patryk Miszke ( s193249@student.pg.edu.pl )
# Created On       : 5.06.2023
# Last Modified By : Patryk Miszke ( s193249@student.pg.edu.pl )
# Last Modified On : 6.06.2023
# Version          : 1.0
#
# Description      :
# Multiplayer game where you have to transport all 4 pawns to the base.
# Players move by guessing numbers in order to go through the board.
#
# Licensed under GPL (see /usr/share/common-licenses/GPL for more details
# or contact # the Free Software Foundation for a copy)
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

declare -A array
rows=15
columns=15
createMap(){
for (( i=0; i<$rows; i++ )); do
        for (( j=0; j<$columns; j++ )); do
                if [[ $i -eq 7 && $j -eq 7 ]]; then
                        array[$i,$j]="X"
                        continue
                fi

                if [[ ($j -eq 7 && $i -gt 2 && $i -lt 12) 
                || ($i -eq 7 && $j -gt 2 && $j -lt 12)
                ]]; then
                        array[$i,$j]="■"
                        continue
                fi

                if [[
                (($i -eq 2 || $i -eq 12) && $j -gt 5 && $j -lt 9)
                || (($i -eq 8 || $i -eq 6) && $j -gt 1 && $j -lt 13)
                || (($j -eq 8 || $j -eq 6) && $i -gt 1 && $i -lt 13)
                || ($i -eq 7 && ($j -eq 2 || $j -eq 12))
                ]]; then
                        array[$i,$j]="□"
                        continue
                fi

                array[$i,$j]=" "
        done
done
array[6,2]="⚿"
array[2,8]="⚿"
array[8,12]="⚿"
array[12,6]="⚿"
}
p1start=(6 2)
p2start=(2 8)
p3start=(8 12)
p4start=(12 6)
loadMap(){
  for (( i=0; i<$rows; i++ )); do
        for (( j=0; j<$columns; j++ )); do
                echo -n "${array[$i,$j]} "
        done
	echo
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
		if [[ $((round+1)) -eq 1 ]]; then
			i=${p1start[0]}
			j=${p1start[1]}
			collision
			array[${p1start[0]},${p1start[1]}]="1"
		elif [[ $((round+1)) -eq 2 ]]; then
			i=${p2start[0]}
                        j=${p2start[1]}
                        collision
			array[${p2start[0]},${p2start[1]}]="2"
		elif [[ $((round+1)) -eq 3 ]]; then
			i=${p3start[0]}
                        j=${p3start[1]}
                        collision
                        array[${p3start[0]},${p3start[1]}]="3"
		elif [[ $((round+1)) -eq 4 ]]; then
			i=${p4start[0]}
                        j=${p4start[1]}
                        collision
                        array[${p4start[0]},${p4start[1]}]="4"
		fi
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

collision(){
if [[ "${array[$i,$j]}" == "1" ]]; then
	echo "Pawn of Player 1 has been slain!"
	positions[0]=0
elif [[ "${array[$i,$j]}" == "2" ]]; then
	echo "Pawn of Player 2 has been slain!"
        positions[1]=0
elif [[ "${array[$i,$j]}" == "3" ]]; then
        echo "Pawn of Player 3 has been slain!"
        positions[2]=0
elif [[ "${array[$i,$j]}" == "4" ]]; then
        echo "Pawn of Player 4 has been slain!"
        positions[3]=0
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
		for (( i=0; i<$rows; i++ )); do
        		for (( j=0; j<$columns; j++ )); do
                		if [[ "${array[$i,$j]}" == "$((round+1))" && ${positions[round]} -ne 1 && $fields -ne 0 ]]; then
					if ! [[ ($i -eq 7 && $j -gt 2 && $j -lt 12) || ($j -eq 7 && $i -gt 2 && $i -lt 12) ]]; then
						local start=($i $j)
						for (( k=0; k<$fields; k++ )); do
							if [[ $i -lt 7 && $j -lt 7 && $i -gt 1 ]]; then
								if [[ $j -eq 6 && $i -ne 2 ]]; then
									((i--))
								else
									((j++))
                                        			fi
							elif [[ $i -lt 7 && $j -gt 7  && $j -lt 13 ]]; then
								if [[ ($j -eq 8 && $i -ne 6) || $j -eq 12 ]]; then
									((i++))
								else
                                                                        ((j++))
                                                                fi
							elif [[ $i -gt 7 && $j -lt 7 && $j -gt 1 ]]; then
								if [[ ($j -eq 6 && $i -ne 8) || $j -eq 2 ]]; then
                                                                        ((i--))
								else
									((j--))
                                        			fi
							elif [[ $i -gt 7 && $j -gt 7 && $i -lt 13 ]]; then
								if [[ $j -eq 8 && $i -ne 12 ]]; then
                                                                        ((i++))
								else
                                                                	((j--))
                                                                fi
							elif [[ $i -eq 7 && $j -gt 1 && $j -lt 7 ]]; then
								if [[ ${positions[round]} -gt 40 ]]; then
									((j++))
								else
									((i--))
								fi
							elif [[ $i -eq 7 && $j -lt 13 && $j -gt 7 ]]; then
                                                                if [[ ${positions[round]} -gt 40 ]]; then
                                                                        ((j--))
                                                                else
                                                                        ((i++))
                                                                fi
							elif [[ $i -gt 1 && $i -lt 7 && $j -eq 7 ]]; then
                                                                if [[ ${positions[round]} -gt 40 ]]; then
                                                                        ((i++))
                                                                else
                                                                        ((j++))
                                                                fi
							elif [[ $i -lt 13 && $i -gt 7 && $j -eq 7 ]]; then
                                                                if [[ ${positions[round]} -gt 40 ]]; then
                                                                        ((i--))
                                                                else
                                                                        ((j--))
                                                                fi
							fi
						done
						collision
						array[$i,$j]="$((round+1))"
						if [[ ${start[@]} == ${p1start[@]} || ${start[@]} == ${p2start[@]} || ${start[@]} == ${p3start[@]} || ${start[@]} == ${p4start[@]} ]]; then
							array[${start[0]},${start[1]}]="⚿"
						else
							array[${start[0]},${start[1]}]="□"
						fi
						break
					fi
				fi
        		done
  		done
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

info(){
for (( i = 0 ; i < $numberOfPlayers ; i++ )); do
	echo "Player $(($i+1)):"
	echo "Position: ${positions[$i]}"
	echo "Pons left: ${ponsLeft[$i]}"
	echo
done
}

#Main
createMap
clear
intro
clear
echo "$Logo"
while [ running ]; do
clear
echo "$Logo"
loadMap
echo
info

if [[ $round -eq $numberOfPlayers ]]; then
	round=0
fi

randomNumber
echo "$randomN"
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
