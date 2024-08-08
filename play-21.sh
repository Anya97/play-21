echo "Добро пожаловать в игру 21! Введите ваше имя:"
read name
echo "Здравствуйте, $name. Вам выдано 100 фишек для игры."
chips_count=100
chips_count_croupier=100
game_number=0
touch result.txt

while [[ $chips_count -gt 0 ]]; do
  game_number=$(( game_number + 1))
  sum=0
  sum_croupier=0
  echo "Ваше количество фишек - ${chips_count}. Сколько желаете поставить? Напоминаем, что в случае победы вы получите x2 от своей ставки. Введите ставку:"
  while true; do
      read start_bid

      if [[ "$start_bid" =~ ^[0-9]+$ ]] && [ "$start_bid" -ge 1 ] && [ "$start_bid" -le "$chips_count" ]; then
          break
      else
          if ! [[ "$start_bid" =~ ^[0-9]+$ ]]; then
              echo "Ошибка: Введите целое число:"
          elif [ "$start_bid" -gt "$chips_count" ]; then
              echo "Вам не хватает фишек для такой ставки. Ваше количество фишек - ${chips_count}. Введите ставку еще раз:"
          else
              echo "Ставка должна быть больше 0. Введите ставку еще раз:"
          fi
      fi
  done

  echo "Ваша ставка - ${start_bid}"

  while true; do
    random_number=$((1 + $RANDOM % 10))
    (( sum += random_number ))
    echo "Вы достали - ${random_number} очков"
    echo "Вы можете вытянуть следующую карту или закончить ход. Желаете закончить ход? (Да/Нет):"
    read finish
    if [[ "$finish" = "Да" || "$sum" -ge 21 ]]; then
        echo "Ваше суммарное количество очков - ${sum}"
        break
    fi
  done

  echo "Теперь ход крупье..."
  sleep 1
  start_bid_croupier=$((1 + $RANDOM % chips_count_croupier))
  echo "Ставка крупье - ${start_bid_croupier}"
  sleep 1
  while true; do
    random_number_croupier=$((1 + $RANDOM % 10))
    (( sum_croupier += random_number_croupier ))
    echo "Крупье достал - ${random_number_croupier} очков"
    if [ "$sum_croupier" -ge 21 ]; then
        echo "Суммарное количество очков крупье - ${sum_croupier}"
        break
    fi
    sleep 1
  done

  if [[ "$sum" -gt 21 && "$sum_croupier" -le 21 ]]; then
    chips_count_croupier=$(( start_bid_croupier + chips_count_croupier ))
    chips_count=$(( chips_count - start_bid ))
    echo "К сожалению, вы проиграли"
    echo "Результат игры номер ${game_number} - победа крупье" >> result.txt
  elif [[ "$sum_croupier" -gt 21 && "$sum" -le 21 ]]; then
    chips_count=$(( start_bid + chips_count ))
    chips_count_croupier=$(( chips_count_croupier - start_bid_croupier ))
    echo "Поздравляем, вы выиграли! Вам начислено ${chips_count} фишек"
    echo "Результат игры номер ${game_number} - победа ${name}" >> result.txt
  elif [[ "$sum_croupier" -gt 21 && "$sum" -gt 21 ]]; then
    chips_count_croupier=$(( chips_count_croupier - start_bid_croupier ))
    chips_count=$(( chips_count - start_bid ))
    echo "К сожалению, вы и крупье проиграли"
    echo "Результат игры номер ${game_number} - проигрыш ваш и проигрыш крупье" >> result.txt
  else
    difference=$((21-sum))
    difference_croupier=$((21-sum_croupier))

    if [[ "$difference" < "$difference_croupier" ]]; then
      chips_count=$(( start_bid + chips_count ))
      chips_count_croupier=$(( chips_count_croupier - start_bid_croupier ))
      echo "Поздравляем, вы выиграли! Вам начислено ${chips_count} фишек"
      echo "Результат игры номер ${game_number} - победа ${name}" >> result.txt
    elif [[ "$difference" = "$difference_croupier" ]]; then
      chips_count=$(( start_bid + chips_count ))
      chips_count_croupier=$(( start_bid_croupier + chips_count_croupier ))
      echo "У вас ничья! Вам начислено ${chips_count} баллов"
      echo "Результат игры номер ${game_number} - ничья" >> result.txt
    else
      chips_count=$(( chips_count - start_bid ))
      chips_count_croupier=$(( start_bid_croupier + chips_count_croupier ))
      echo "К сожалению, вы проиграли"
      echo "Результат игры номер ${game_number} - победа крупье" >> result.txt
    fi
  fi

  echo "Желаете закончить игру? (Да/Нет):"
  read finish_game
  if [[ "$finish_game" = "Да" || "$chips_count" = 0 || "$chips_count_croupier" = 0 ]]; then
      if [[ "$chips_count" = 0 ]]; then
        echo "Игра окончена, так как у вас не осталось фишек."
      elif [[ "$chips_count_croupier" = 0 ]]; then
        echo "Игра окончена, так как у крупье не осталось фишек."
      fi
      echo "\nИтого:" >> result.txt
      if [[ "$chips_count" > "$chips_count_croupier" ]]; then
        echo "${name}, поздравляем, вы выиграли игру!" >> result.txt
      elif [[ "$chips_count" = "$chips_count_croupier" ]]; then
        echo "${name}, у вас ничья!" >> result.txt
      else
        echo "К сожалению, вы проиграли, не расстраивайтесь!"
      fi
      echo "Ваше количество фишек: ${chips_count}, количество фишек крупье: ${chips_count_croupier}" >> result.txt
      break
  fi
done

cat result.txt
rm result.txt
