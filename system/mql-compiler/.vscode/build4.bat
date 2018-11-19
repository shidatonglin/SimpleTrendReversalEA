@echo off

set metaeditor="C:\Program Files (x86)\XM Global MT4\metaeditor.exe"
set include_path="C:\Users\Tony\AppData\Roaming\MetaQuotes\Terminal\98A82F92176B73A2100FCD1F8ABD7255\MQL4"

set file_path=%1
set file_path=%file_path:"=%
set file_name=%2
set file_name=%file_name:"=%
set file_ext=%3
set file_ext=%file_ext:"=%
set command=%4

%metaeditor% /compile:"%file_path%\%file_name%%file_ext%" /inc:%include_path% %command% /log

type "%file_path%\%file_name%.log"
del "%file_path%\%file_name%.log"