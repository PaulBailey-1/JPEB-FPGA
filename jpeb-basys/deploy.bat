@echo off
REM Remove all files from drive D
echo Deleting all files from drive D...
del /s /q D:\*

REM Copy file.bin to drive D
echo Copying bin to drive D...
copy .\jpeb-basys.runs\impl_1\main.bit D:\

echo Deploy Complete.