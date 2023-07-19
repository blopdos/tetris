title �����
cls
@echo off
SETLOCAL ENABLEDELAYEDEXPANSION

:: ���᪠��� �� �ࠢ�����
echo [1;12H��ࠢ�����:
echo [2;12Ha - �����
echo [3;12Hd - ��ࠢ�
echo [4;12Hw - ������
echo [5;12Hs - ����
echo [6;12H�� ������ ������� ��������� �᪫����

:: ���樠������ ��஢��� ����
for /L %%a in (0,1,15) do (
  for /L %%b in (0,1,7) do set field_%%a_%%b=0
)

:nextfigure
call :getfigure

:: ����� 䨣�� ������ �� �⨬ ���न��⠬
set figposx=3
set figposy=0

:: �஢��塞, ��� �� �������� �ࠧ� �� �� ������ 䨣���
call :applyfigure %figposx% %figposy% :testcollision

if errorlevel 1 (
  :: ���� �������� - ��㥬 䨣��� � ��襬, �� ��� ����祭�
  call :applyfigure %figposx% %figposy% :setblock
  call :redraw
  echo [5;4HGAME[6;4HOVER[10;1H
  pause
  exit
)

:nextmove
:: ���㥬 䨣���
call :applyfigure %figposx% %figposy% :setblock
call :redraw

set nextposx=%figposx%
set nextposy=%figposy%

:: ���� ������ ��� ⠩����. �� ⠩���� �롨ࠥ� ��ਠ�� s
choice /C "sawd" /D s /T 1 > NUL

set choiceIndex=%errorlevel%

:: ��ࠥ� 䨣��� � ���� � �����
call :applyfigure %figposx% %figposy% :clearblock

if "%choiceIndex%"=="2" (
  :: �������� �����
  set /A nextposx=%figposx%-1

  :: �஢�ઠ ��������
  call :applyfigure !nextposx! %figposy% :testcollision

  :: �� �������� ��㥬 䨣��� �� �०��� ���� � �஡������ ����� �����
  if errorlevel 1 goto :nextmove
)

if "%choiceIndex%"=="4" (
  :: �������� ��ࠢ�
  set /A nextposx=%figposx%+1

  :: �஢�ઠ ��������
  call :applyfigure !nextposx! %figposy% :testcollision

  :: �� �������� ��㥬 䨣��� �� �०��� ���� � �஡������ ����� �����
  if errorlevel 1 goto :nextmove
)

if "%choiceIndex%"=="1" (
  :: �������� ����
  set /A nextposy=%figposy%+1

  :: �஢�ઠ ��������
  call :applyfigure %figposx% !nextposy! :testcollision

  if errorlevel 1 (
    :: �� �������� �������� ���, 䨣�� ��⠥��� �� ���� ���ᥣ��
    call :applyfigure %figposx% %figposy% :setblock

    :: ���ࠥ� ���������� ���
    call :removefulllines
    goto :nextfigure
  )
)

if "%choiceIndex%"=="3" (
  :: ������
  call :rotateright

  :: �஢�ઠ ��������
  call :applyfigure %figposx% %figposy% :testcollision

  :: �� �������� ������ ���⭮
  if errorlevel 1 call :rotateleft
)

:: ����� ������
set figposx=%nextposx%
set figposy=%nextposy%
goto :nextmove

:: ����ᮢ�� ��஢��� ����
:: ��ࠬ����: ���
:: ������塞�� ���祭��: ���
:redraw

:: ��६�頥� ����� � ��१����뢠�� ���� �� �࠭�
:: �� �ᯮ��㥬 CLS, ��⮬� �� ���ᮢ�� ������,
:: � ����ࠦ���� � �⮬ ��砥 ������
echo [1;1H��������ͻ
for /L %%a in (0,1,7) do (
  set /A y1=%%a * 2
  set /A y2=%%a * 2 + 1
  call :drawline !y1! !y2!
)
echo ��������ͼ
goto :eof

:: ����ᮢ�� ���� ��ப ��஢��� ���� � ����� ��ப� ⥪��
:: ��ࠬ����:
::   %1 - Y-���न��� ��ப� �� ����, ����� �⮡ࠦ�����
::        � ���孥� ��� ��ப� ⥪��
::   %2 - Y-���न��� ��ப� �� ����, ����� �⮡ࠦ�����
::        � ������ ��� ��ப� ⥪��
:drawline
set LINE=�
for /L %%x in (0,1,7) do (
  :: �������� ��ப� ����稢����� �஡����
  if "!field_%1_%%x!!field_%2_%%x!"=="00" set LINE=!LINE! 
  if "!field_%1_%%x!!field_%2_%%x!"=="10" set LINE=!LINE!�
  if "!field_%1_%%x!!field_%2_%%x!"=="01" set LINE=!LINE!�
  if "!field_%1_%%x!!field_%2_%%x!"=="11" set LINE=!LINE!�
)
echo %LINE%�
goto :eof

:: ���砩�� �롮� 䨣���
:: ��ࠬ����: ���
:: ������塞�� ���祭��: ���
:: ��⠭�������� ��६����:
::   figdefx, figdefy - ��।������ 䨣���
::   mat11, mat12, mat21, mat22 - ����� �८�ࠧ������
:getfigure

:: figtype - ⨯ 䨣���
set /A figtype=%RANDOM% %% 4

:: figflip - 䫠� ��ࠦ����
:: ��� ���� ᨬ������� 䨣�� (������ � ������� �����)
:: - �롮� ����� ����
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

:: ��� ᨬ������ 䨣���
:: figflip - �롮� ����� ���� 䨣�ࠬ�
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

:: ����� �����筮��
set mat11=0
set mat12=1
set mat21=1
set mat22=0

:: �᫨ �㦭� ��ࠦ���� - ��ࠦ��� �⭮�⥫쭮 �� Y
if "%figflip%"=="1" set mat12=-1
goto :eof

:: ������ �� �ᮢ�� ��५��
:: ��ࠬ����: ���
:: ������塞�� ���祭��: ���
:: �ᯮ���� � ������� ��६����:
::   mat11, mat12, mat21, mat22 - ����� �८�ࠧ������
:rotateright
set matTmp=%mat11%
set /A mat11=-%mat21%
set /A mat21=%matTmp%
set matTmp=%mat12%
set /A mat12=-%mat22%
set /A mat22=%matTmp%
goto :eof

:: ������ ��⨢ �ᮢ�� ��५��
:: ��ࠬ����: ���
:: ������塞�� ���祭��: ���
:: �ᯮ���� � ������� ��६����:
::   mat11, mat12, mat21, mat22 - ����� �८�ࠧ������
:rotateleft
set matTmp=%mat21%
set /A mat21=-%mat11%
set /A mat11=%matTmp%
set matTmp=%mat22%
set /A mat22=-%mat12%
set /A mat12=%matTmp%
goto :eof

:: �ਬ������ 䨣���
:: ��ࠬ����:
::   %1 - X-���न��� ��砫� 䨣���
::   %2 - Y-���न��� ��砫� 䨣���
::   %3 - �����, ��뢠��� ��� ������� ����� 䨣���
:: ����� �ᯮ���� ��६����:
::   mat11, mat12, mat21, mat22 - ����� �८�ࠧ������
:: �᫨ ����� �����頥� ��� 1, applyfigure
:: �४�頥� ࠡ��� � ⮦� �����頥� 1
:applyfigure
for /L %%a in (0,1,3) do (
  set /A X=mat11 * !figdefx:~%%a,1! + mat12 * !figdefy:~%%a,1! + %1
  set /A Y=mat21 * !figdefx:~%%a,1! + mat22 * !figdefy:~%%a,1! + %2
  call %3 !X! !Y!
  if errorlevel 1 exit /B 1
)
goto :eof

:: ����� �ਬ������ 䨣���
:: �������� ���� ���� � �����
:: ��ࠬ����:
::   %1 - X-���न��� �����
::   %2 - Y-���न��� �����
:: �����頥�: 0
:setblock
set field_%2_%1=1
exit /B 0

:: ����� �ਬ������ 䨣���
:: ��頥� ���� ���� � �����
:: ��ࠬ����:
::   %1 - X-���न��� �����
::   %2 - Y-���न��� �����
:: �����頥�: 0
:clearblock
set field_%2_%1=0
exit /B 0

:: ����� �ਬ������ 䨣���
:: �஢���� �������� � ��ﬨ ���� ��� ���������� ������
:: ��ࠬ����:
::   %1 - X-���न��� �����
::   %2 - Y-���न��� �����
:: �����頥�:
::   1, �᫨ ���� �������� ��� �� �।����� ����;
::   0, �᫨ ���� ᢮�����
:testcollision
if %1 geq 8 exit /B 1
if %1 lss 0 exit /B 1
if %2 lss 0 exit /B 1
if %2 geq 16 exit /B 1
if "!field_%2_%1!"=="1" exit /B 1
exit /B 0

:: ���ࠥ� � ���� ���������� ��ப� � ᤢ����� ��ப�,
:: ��室�騥�� ��� �࠭���, ����
:: ��ࠬ����: ���
:: ������塞�� ���祭��: ���
:removefulllines
set COPYTOLINE=15

:: ��ॡ�ࠥ� ��ப� ᭨�� �����
for /L %%y in (15,-1,0) do (
  set LINEFULL=1

  :: �஢�ઠ ��ப� %%y
  for /L %%x in (0,1,7) do (
    if "!field_%%y_%%x!"=="0" set LINEFULL=0
  )

  if "!LINEFULL!"=="0" (
    :: ��ப� ��࠭���� - ��������, �� ���� ᤢ����� ����
    if not "!COPYTOLINE!"=="%%y" (
      :: ���� ��� ����� ��ப 㤠���� - �����㥬 ������ ��ப� ����
      for /L %%x in (0,1,7) do (
        set field_!COPYTOLINE!_%%x=!field_%%y_%%x!
      )
    )

    :: �������� �᢮��������� ��ப�
    set /A COPYTOLINE=!COPYTOLINE! - 1
  )
)

:: ��ࠥ� �᢮�����訥�� ���孨� ��ப�
for /L %%y in (%COPYTOLINE%,-1,0) do (
  for /L %%x in (0,1,7) do (
    set field_%%y_%%x=0
  )
)

goto :eof
