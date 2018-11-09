echo on

set WebName=WebMVCLI
echo WebName=%WebName%

echo dir
SET RunDir=C:\Program Files (x86)\IIS Express
c:
cd  C:\Program Files (x86)\IIS Express

echo run iisexpress
iisexpress /site:%WebName%

pause