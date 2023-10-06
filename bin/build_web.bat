cd /D "%~dp0"
call "C:\Program Files\7-Zip\7z.exe" a -r "super-emoji-merge.zip" -w ..\* -xr!bin -xr!builds -xr!steam -xr!.git -xr!*.yue
rename "super-emoji-merge.zip" "super-emoji-merge.love"
call npx love.js.cmd -m 52228800 -t "super-emoji-merge" "E:\code\super-emoji-merge\bin\super-emoji-merge.love" ..\builds\web
del "super-emoji-merge.love"
copy index.html ..\builds\web\index.html
