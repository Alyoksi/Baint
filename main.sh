#!/bin/bash

# Обозначение курсора
CURSOR="#"

# Координаты курсора
X=0
Y=0

# Размеры поля
WIDTH=70
HEIGTH=20

# Flags
# Показывать ли курсор?
ISCURSOR=1

# Текущий цвет
CUR_COL="@"

# Текущий инструмен:
# 1 - Кисточка
# 2 - Ластик
# 3 - Заливка
# 4 - Без инструмента/парящий режим (стартовый инструмент)
CUR_TOOL="4"

# функция, создающая поле
create_board(){
  M=()
  for((i=0;i<WIDTH*HEIGTH;i++))
  do
    M[i]=" "
  done
  draw_board
}

# функция, рисующая границы поля
draw_border(){
  printf "|"
  for((i=0;i<WIDTH;i++))
  do
    printf "-"
  done
  printf "|\n"
}

# функция, рисующая границы окон инструментов
draw_menu_border_line(){
  if [[ $CUR_TOOL = "1" ]]
  then
    printf "|#######| "
  else
    printf "|-------| "
  fi
  if [[ $CUR_TOOL = "2" ]]
  then
    printf "|########| "
  else
    printf "|--------| "
  fi
  if [[ $CUR_TOOL = "3" ]]
  then
    printf "|######| "
  else
    printf "|------| "
  fi
  if [[ $CUR_TOOL = "4" ]]
  then
    printf "|#######| "
  else
    printf "|-------| "
  fi

  printf "|-----------------|\n"
}

# функция, рисующая названия инструментов
draw_menu_name_line(){
  printf "|1.Brush| "
  printf "|2.Eraser| "
  printf "|3.Fill| "
  printf "|4.Hover| "
  printf "|Current symbol: %s|\n" "$CUR_COL"
}

# функция, рисующая только верхнее меню
draw_tools(){
  draw_menu_border_line
  draw_menu_name_line
  draw_menu_border_line
}

# функция, рисующая всё поле
draw_board(){
  clear

  draw_tools
  draw_border
  for((i=0; i<HEIGTH;i++))
  do
    printf "|"
    for((j=0;j<WIDTH;j++))
    do
      # Если координаты курсора
      if [[ $i -eq $Y ]] && [[ $j -eq $X ]]
      then
        # Если пользователь хочет отобразить курсор
        if [[ $ISCURSOR -eq 1 ]]
        then
          printf "%s" "$CURSOR"
        else
          printf "%s" "${M[$WIDTH*i+j]}"
        fi
      else
        printf "%s" "${M[$WIDTH*i+j]}"
      fi
    done
    printf "| "
    if [[ $i -eq 0 ]]
    then
      printf "Use wasd to navigate on board."
    fi
    if [[ $i -eq 1 ]]
    then
      printf "Press q to quit."
    fi
    if [[ $i -eq 2 ]]
    then
      printf "Press r to change current color."
    fi
    if [[ $i -eq 3 ]]
    then
      printf "Press c to hide/show cursor."
    fi
    printf "\n"
  done
  draw_border
}

quit_game(){
    read -n 1 -s -p "Do you really want to quit [y/n]?"
    while :
    do
        case $REPLY in
            y|Y) exit
            ;;
            n|N) return
            ;;
        esac
        read -n 1 -s
    done
}

# функции, отвечающие за движение курсора
move_up(){
  if [[ $Y-1 -ge 0 ]]
  then
    Y=$((Y-1))
  fi
}
move_down(){
  if [[ $Y+1 -le $HEIGTH-1 ]]
  then
    Y=$((Y+1))
  fi
}
move_right(){
  if [[ $X+1 -le $WIDTH-1 ]]
  then
    X=$((X+1))
  fi
}
move_left(){
ISCURSOR=1
  if [[ $X-1 -ge 0 ]]
  then
    X=$((X-1))
  fi
}

# Функция изменения цвета
change_current_color(){
    read -n 1 -s -p "Which symbol to use for drawing? "
    if [[ $REPLY != [a-zA-Z~!@#$%^\&*()\[\]\{\}_+\-=\|:\;\'\"/?.,\<\>\\] ]]
    then
      printf "%s" "Invalid character. Only allowed a-zA-Z~!@#$%^&*()[]{}_+-=|:;'\"/?.,<>\\. Enter new symbol: "
    else
      CUR_COL="$REPLY"
      return
    fi

    while :
    do
      read -n 1 -s
      if [[ $REPLY = [a-zA-Z] ]]
      then
        CUR_COL="$REPLY"
        break
      fi
    done
}

# Функция скрытия/показывания курсора
hide_cursor(){
  if [[ $ISCURSOR -eq 1 ]]
  then
    ISCURSOR=0
  else
    ISCURSOR=1
  fi
}

# Функция использование выбранного инструмента
use_tool(){
  if [[ $CUR_TOOL = "1" ]]
  then
      draw
  fi
  if [[ $CUR_TOOL = "2" ]]
  then
      erase
  fi
  if [[ $CUR_TOOL = "3" ]]
  then
      fill $X $Y
  fi
}

# Функция закраски текущей клетки
draw(){
  M[WIDTH*Y+X]="$CUR_COL"
}

# Функция чистки(?) текущей клетки
erase(){
  M[WIDTH*Y+X]=" "
}

# Функция заливки из текущей клетки
fill(){
  local x=$1
  local y=$2

  if test "${M[WIDTH*y+x]}" != " "
  then
    return
  fi

  M[WIDTH*y+x]=$CUR_COL

  y=$((y-1))
  if [[ $y -ge 0 ]] && test M[WIDTH*y+x] != " "
  then
    fill $x $y
  fi
  y=$((y+2))
  if [[ $y -le $HEIGTH-1 ]] && test [WIDTH*y+x] != " "
  then
    fill $x $y
  fi
  y=$((y-1))
  if [[ $x+1 -le $WIDTH-1 ]] && test M[WIDTH*y+x+1] != " "
  then
    fill $x+1 $y
  fi
  if [[ $x-1 -ge 0 ]] && test M[WIDTH*y+x-1] != " "
  then
    fill $x-1 $y
  fi
}

# main цикл
start_game(){
  while :
  do
    read -n 1 -s
    case $REPLY in
      # Change tool
      1)
        CUR_TOOL=1
        use_tool
      ;;
      2)
        CUR_TOOL=2
        use_tool
      ;;
      3)
        CUR_TOOL=3
        use_tool
      ;;
      4)
        CUR_TOOL=4
      ;;
      "")
        if [[ $CUR_TOOL = "3" ]]
        then
          fill $X $Y
        fi
      ;;

      # show/hide cursor
      c)
        hide_cursor
      ;;
      # quit
      q)
        quit_game
      ;;
      # change color
      r)
        change_current_color
      ;;

      # navigation
      w)
        move_up
        use_tool
      ;;
      s)
        move_down
        use_tool
      ;;
      a)
        move_left
        use_tool
      ;;
      d)
        move_right
        use_tool
      ;;
    esac

  draw_board
  done
}



# Запуск Baint
create_board
start_game
