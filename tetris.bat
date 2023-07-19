title Тетрис
cls
@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: Подсказка об управлении
echo [1;12HУправление:
echo [2;12Ha - влево
echo [3;12Hd - вправо
echo [4;12Hw - поворот
echo [5;12Hs - вниз
echo [6;12HНе забудьте включить английскую раскладку

:: Инициализация игрового поля
for /L %%a in (0,1,15) do (
  for /L %%b in (0,1,7) do set field_%%a_%%b=0
)

:nextfigure
call :getfigure

:: Новая фигура появляется по этим координатам
set figposx=3
set figposy=0

:: Проверяем, нет ли коллизий сразу же при появлении фигуры
call :applyfigure %figposx% %figposy% :testcollision

if errorlevel 1 (
  :: Есть коллизия - рисуем фигуру и пишем, что игра окончена
  call :applyfigure %figposx% %figposy% :setblock
  call :redraw
  echo [5;4HGAME[6;4HOVER[10;1H
  pause
  exit
)

:nextmove
:: Рисуем фигуру
call :applyfigure %figposx% %figposy% :setblock
call :redraw

set nextposx=%figposx%
set nextposy=%figposy%

:: Ждем нажатия или таймаута. При таймауте выбираем вариант s
choice /C "sawd" /D s /T 1 > NUL

set choiceIndex=%errorlevel%

:: Стираем фигуру с поля в памяти
call :applyfigure %figposx% %figposy% :clearblock

if "%choiceIndex%"=="2" (
  :: Движение влево
  set /A nextposx=%figposx%-1

  :: Проверка коллизий
  call :applyfigure !nextposx! %figposy% :testcollision

  :: При коллизии рисуем фигуру на прежнем месте и проболжаем ждать ввода
  if errorlevel 1 goto :nextmove
)

if "%choiceIndex%"=="4" (
  :: Движение вправо
  set /A nextposx=%figposx%+1

  :: Проверка коллизий
  call :applyfigure !nextposx! %figposy% :testcollision

  :: При коллизии рисуем фигуру на прежнем месте и проболжаем ждать ввода
  if errorlevel 1 goto :nextmove
)

if "%choiceIndex%"=="1" (
  :: Движение вниз
  set /A nextposy=%figposy%+1

  :: Проверка коллизий
  call :applyfigure %figposx% !nextposy! :testcollision

  if errorlevel 1 (
    :: При коллизии движения нет, фигура остается на месте навсегда
    call :applyfigure %figposx% %figposy% :setblock

    :: Убираем заполненные ряды
    call :removefulllines
    goto :nextfigure
  )
)

if "%choiceIndex%"=="3" (
  :: Поворот
  call :rotateright

  :: Проверка коллизий
  call :applyfigure %figposx% %figposy% :testcollision

  :: При коллизии поворот обратно
  if errorlevel 1 call :rotateleft
)

:: Новая позиция
set figposx=%nextposx%
set figposy=%nextposy%
goto :nextmove

:: Перерисовка игрового поля
:: Параметры: нет
:: Возвращяемое значение: нет
:redraw

:: Перемещаем курсор и перезаписываем поле на экране
:: Не используем CLS, потому что прорисовка долгая,
:: и изображение в этом случае мигает
echo [1;1H╔════════╗
for /L %%a in (0,1,7) do (
  set /A y1=%%a * 2
  set /A y2=%%a * 2 + 1
  call :drawline !y1! !y2!
)
echo ╚════════╝
goto :eof

:: Перерисовка двух строк игрового поля в одной строке текста
:: Параметры:
::   %1 - Y-координата строки на поле, поторая отображается
::        в верхней части строки текста
::   %2 - Y-координата строки на поле, поторая отображается
::        в нижней части строки текста
:drawline
set LINE=║
for /L %%x in (0,1,7) do (
  :: Следующая строка оканчивается пробелом
  if "!field_%1_%%x!!field_%2_%%x!"=="00" set LINE=!LINE! 
  if "!field_%1_%%x!!field_%2_%%x!"=="10" set LINE=!LINE!▀
  if "!field_%1_%%x!!field_%2_%%x!"=="01" set LINE=!LINE!▄
  if "!field_%1_%%x!!field_%2_%%x!"=="11" set LINE=!LINE!█
)
echo %LINE%║
goto :eof

:: Случайный выбор фигуры
:: Параметры: нет
:: Возвращяемое значение: нет
:: Устанавливает переменные:
::   figdefx, figdefy - определение фигуры
::   mat11, mat12, mat21, mat22 - матрица преобразования
:getfigure

:: figtype - тип фигуры
set /A figtype=%RANDOM% %% 4

:: figflip - флаг отражения
:: Для случая симметричных фигур (квадрат и длинная палка)
:: - выбор между ними
set /A figflip=%RANDOM% %% 2

if "%figtype%"=="0" (
  set figdefx=0122
  set figdefy=0001
)

if "%figtype%"=="1" (
  set figdefx=0112
  set figdefy=0011
)

if "%figtype%"=="2" (
  set figdefx=0112
  set figdefy=0010
)

:: Две симметричные фигуры
:: figflip - выбор между двумя фигурами
if "%figtype%"=="3" (
  if "%figflip%"=="0" (
    set figdefx=0123
    set figdefy=0000
  )

  if "%figflip%"=="1" (
    set figdefx=0101
    set figdefy=0011
  )
)

:: Матрица идентичности
set mat11=0
set mat12=1
set mat21=1
set mat22=0

:: Если нужно отражение - отражаем относительно оси Y
if "%figflip%"=="1" set mat12=-1
goto :eof

:: Поворот по часовой стрелке
:: Параметры: нет
:: Возвращяемое значение: нет
:: Использует и изменяет переменные:
::   mat11, mat12, mat21, mat22 - матрица преобразования
:rotateright
set matTmp=%mat11%
set /A mat11=-%mat21%
set /A mat21=%matTmp%
set matTmp=%mat12%
set /A mat12=-%mat22%
set /A mat22=%matTmp%
goto :eof

:: Поворот против часовой стрелки
:: Параметры: нет
:: Возвращяемое значение: нет
:: Использует и изменяет переменные:
::   mat11, mat12, mat21, mat22 - матрица преобразования
:rotateleft
set matTmp=%mat21%
set /A mat21=-%mat11%
set /A mat11=%matTmp%
set matTmp=%mat22%
set /A mat22=-%mat12%
set /A mat12=%matTmp%
goto :eof

:: Применение фигуры
:: Параметры:
::   %1 - X-координата начала фигуры
::   %2 - Y-координата начала фигуры
::   %3 - колбэк, вызываемый для каждого блока фигуры
:: Также использует переменные:
::   mat11, mat12, mat21, mat22 - матрица преобразования
:: Если колбэк позвращает код 1, applyfigure
:: прекращает работу и тоже возвращает 1
:applyfigure
for /L %%a in (0,1,3) do (
  set /A X=mat11 * !figdefx:~%%a,1! + mat12 * !figdefy:~%%a,1! + %1
  set /A Y=mat21 * !figdefx:~%%a,1! + mat22 * !figdefy:~%%a,1! + %2
  call %3 !X! !Y!
  if errorlevel 1 exit /B 1
)
goto :eof

:: Колбэк применения фигуры
:: Заполняет блок поля в памяти
:: Параметры:
::   %1 - X-координата блока
::   %2 - Y-координата блока
:: Возвращает: 0
:setblock
set field_%2_%1=1
exit /B 0

:: Колбэк применения фигуры
:: Очищает блок поля в памяти
:: Параметры:
::   %1 - X-координата блока
::   %2 - Y-координата блока
:: Возвращает: 0
:clearblock
set field_%2_%1=0
exit /B 0

:: Колбэк применения фигуры
:: Проверяет коллизии с краями поля или заполненным блоком
:: Параметры:
::   %1 - X-координата блока
::   %2 - Y-координата блока
:: Возвращает:
::   1, если блок заполнен или на пределами поля;
::   0, если блок свободен
:testcollision
if %1 geq 8 exit /B 1
if %1 lss 0 exit /B 1
if %2 lss 0 exit /B 1
if %2 geq 16 exit /B 1
if "!field_%2_%1!"=="1" exit /B 1
exit /B 0

:: Убирает с поля заполненные строки и сдвигает строки,
:: находящиеся выше убранных, вниз
:: Параметры: нет
:: Возвращяемое значение: нет
:removefulllines
set COPYTOLINE=15

:: Перебираем строки снизу вверх
for /L %%y in (15,-1,0) do (
  set LINEFULL=1

  :: Проверка строки %%y
  for /L %%x in (0,1,7) do (
    if "!field_%%y_%%x!"=="0" set LINEFULL=0
  )

  if "!LINEFULL!"=="0" (
    :: Строка сохраняется - возможно, ее надо сдвинуть вниз
    if not "!COPYTOLINE!"=="%%y" (
      :: Одна или более строк удалены - копируем данную строку вниз
      for /L %%x in (0,1,7) do (
        set field_!COPYTOLINE!_%%x=!field_%%y_%%x!
      )
    )

    :: Следующая освободившаяся строка
    set /A COPYTOLINE=!COPYTOLINE! - 1
  )
)

:: Стираем освободившиеся верхние строки
for /L %%y in (%COPYTOLINE%,-1,0) do (
  for /L %%x in (0,1,7) do (
    set field_%%y_%%x=0
  )
)

goto :eof
