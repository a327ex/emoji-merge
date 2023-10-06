call "C:\Program Files\7-Zip\7z.exe" a -r "super-emoji-merge.zip" -w ..\* -xr!bin -xr!builds -xr!steam -xr!.git -xr!.yue
rename "super-emoji-merge.zip" "super-emoji-merge.love"
copy /b "love.exe"+"super-emoji-merge.love" "super-emoji-merge.exe"
del "super-emoji-merge.love"
mkdir "super-emoji-merge"
for %%I in (*.dll) do copy %%I "super-emoji-merge\"
for %%I in (*.txt) do copy %%I "super-emoji-merge\"
copy "super-emoji-merge.exe" "super-emoji-merge\"
del "super-emoji-merge.exe"
call "C:\Program Files\7-Zip\7z.exe" a "super-emoji-merge.zip" "super-emoji-merge\"
del /q "super-emoji-merge\"
rmdir /q "super-emoji-merge\"
copy "super-emoji-merge.zip" ..\builds\windows\
del "super-emoji-merge.zip"
