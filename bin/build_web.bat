cd /D "%~dp0"
call "C:\Program Files\7-Zip\7z.exe" a -r "emoji-merge.zip" -w ..\* -xr!bin -xr!builds -xr!steam -xr!.git -xr!*.yue
rename "emoji-merge.zip" "emoji-merge.love"
call npx love.js.cmd -m 104457600 -t "emoji-merge" "E:\code\emoji-merge\bin\emoji-merge.love" ..\builds\web
del "emoji-merge.love"
copy index.html ..\builds\web\index.html
