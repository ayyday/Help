echo on

echo dir
SET RunDir=/d d:\Microsoft Visual Studio\2017\Professional\MSBuild\15.0\Bin
cd %RunDir%

echo build
set ProjectPaht=D:\Angel\git_demo\WebMVCLI\WebMVCLI.sln
set VSVer=10.0
set OutDir=D:\\Angel\\outputBuild\\WebMVCLI
set LogFile=D:\\Angel\\outputBuild\\WebMVCLI.log
msbuild %ProjectPaht% /p:VisualStudioVersion=%VSVer%;outdir="%OutDir%" /fileLogger /fileLoggerParameters:LogFile="%LogFile%";Verbosity=diagnostic;Encoding=UTF-8 /m

pause