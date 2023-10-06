cd /D "%~dp0"
call yue.exe -l -t ..\lua ..\
call love.exe --console ..\lua
