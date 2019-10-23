REM custom settings for windows shell

REM set some macros/aliases
REM some unix alias
DOSKEY ls=dir /B $*
DOSKEY l=dir /B $*

DOSKEY rm=del $*

DOSKEY s=cd ..
DOSKEY cdmk=mkdir $* $T cd $*

DOSKEY cp=copy $*
DOSKEY vi=vim $*

DOSKEY edit="C:\Program Files (x86)\Notepad++\notepad++.exe" $*
