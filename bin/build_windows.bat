call "C:\Program Files\7-Zip\7z.exe" a -r "emoji-merge.zip" -w ..\* -xr!bin -xr!builds -xr!steam -xr!.git -xr!.yue
rename "emoji-merge.zip" "emoji-merge.love"
copy /b "love.exe"+"emoji-merge.love" "emoji-merge.exe"
del "emoji-merge.love"
mkdir "emoji-merge"
for %%I in (*.dll) do copy %%I "emoji-merge\"
for %%I in (*.txt) do copy %%I "emoji-merge\"
copy "emoji-merge.exe" "emoji-merge\"
del "emoji-merge.exe"
call "C:\Program Files\7-Zip\7z.exe" a "emoji-merge.zip" "emoji-merge\"
del /q "emoji-merge\"
rmdir /q "emoji-merge\"
copy "emoji-merge.zip" ..\builds\windows\
del "emoji-merge.zip"
