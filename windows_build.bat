@"%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe" -property installationPath > tmp.txt
@set /p MSVC_DIR=<tmp.txt
@del tmp.txt

@set MSBUILD="%MSVC_DIR%\MSBuild\Current\Bin\msbuild"

CALL "%MSVC_DIR%\Common7\Tools\vsdevcmd.bat" -arch=amd64 -host_arch=amd64 -app_platform=Desktop || goto :EOF

mkdir deps\build_windows
mkdir build_windows

taskkill /F /IM cl.exe
taskkill /F /IM vctip.exe

set MSBUILDDISABLENODEREUSE=1

cd deps\build_windows
@REM del CMakeCache.txt
cmake -DCMAKE_BUILD_TYPE=Release -DDEP_CMAKE_OPTS="-DCMAKE_POLICY_DEFAULT_CMP0057=NEW" -DDEP_CMAKE_OPTS="-DCMAKE_POLICY_DEFAULT_CMP0054=NEW" .. || goto :EOF
%MSBUILD% ALL_BUILD.vcxproj /m:4 /nr:false /p:Configuration=Release /p:BuildInParallel=false || goto :EOF

cd ..\..\build_windows
@REM del CMakeCache.txt
cmake -DCMAKE_BUILD_TYPE=Release -DCMAKE_PREFIX_PATH="%CD%\..\deps\build_windows\destdir\usr\local" .. || goto :EOF
%MSBUILD% ALL_BUILD.vcxproj /m:4 /nr:false /p:Configuration=Release /p:BuildInParallel=false || goto :EOF

robocopy "src/Release" "bin" /e /purge /xf "*.pdb" || goto :EOF

:EOF