@echo off
REM Build ccminer for Android using Docker
REM Builds all Android architectures: ARM64, ARMv7, x86_64

setlocal enabledelayedexpansion

REM Configuration
set IMAGE_NAME=ccminer-android-builder
set IMAGE_TAG=latest
set OUTPUT_DIR=.\build-output
set CLEAN=false
set NO_CACHE=

REM Parse arguments
:parse_args
if "%~1"=="" goto end_parse
if /i "%~1"=="-o" (
    set OUTPUT_DIR=%~2
    shift
    shift
    goto parse_args
)
if /i "%~1"=="--output" (
    set OUTPUT_DIR=%~2
    shift
    shift
    goto parse_args
)
if /i "%~1"=="-c" (
    set CLEAN=true
    shift
    goto parse_args
)
if /i "%~1"=="--clean" (
    set CLEAN=true
    shift
    goto parse_args
)
if /i "%~1"=="-n" (
    set NO_CACHE=--no-cache
    shift
    goto parse_args
)
if /i "%~1"=="--no-cache" (
    set NO_CACHE=--no-cache
    shift
    goto parse_args
)
if /i "%~1"=="-h" goto usage
if /i "%~1"=="--help" goto usage
echo Error: Unknown option: %~1
goto usage

:end_parse

echo.
echo ========================================
echo   ccminer Android Builder
echo ========================================
echo.

REM Check if Docker is installed
docker version >nul 2>&1
if errorlevel 1 (
    echo Error: Docker is not installed or not running
    exit /b 1
)

REM Clean output directory if requested
if "%CLEAN%"=="true" (
    if exist "%OUTPUT_DIR%" (
        echo Cleaning output directory: %OUTPUT_DIR%
        rd /s /q "%OUTPUT_DIR%" 2>nul
    )
)

REM Create output directory
if not exist "%OUTPUT_DIR%" mkdir "%OUTPUT_DIR%"

REM Get absolute path
pushd "%OUTPUT_DIR%"
set OUTPUT_DIR=%CD%
popd

echo Output directory: %OUTPUT_DIR%
echo.

REM Build Docker image
echo [1/2] Building Docker image...
docker build %NO_CACHE% -t %IMAGE_NAME%:%IMAGE_TAG% --progress=plain -f ./build.Dockerfile .

if errorlevel 1 (
    echo Error: Docker image build failed
    exit /b 1
)

echo SUCCESS: Docker image built successfully
echo.

REM Run build container with mounted output directory
echo [2/2] Running build container...
echo Building Android binaries for: ARM64, ARMv7, x86_64
echo.

docker run --rm -v "%OUTPUT_DIR%:/build/output" %IMAGE_NAME%:%IMAGE_TAG%

if errorlevel 1 (
    echo Error: Build failed
    exit /b 1
)

echo.
echo ========================================
echo   Build Complete!
echo ========================================
echo.
echo Output directory structure:
echo %OUTPUT_DIR%
dir /s /b "%OUTPUT_DIR%\ccminer*" 2>nul
echo.
echo Android binaries ready for deployment:
echo   * ARM64 (64-bit):  %OUTPUT_DIR%\android-arm64\ccminer
echo   * ARMv7 (32-bit):  %OUTPUT_DIR%\android-armv7\ccminer
echo   * x86_64:          %OUTPUT_DIR%\android-x86_64\ccminer
echo.

exit /b 0

:usage
echo.
echo Usage: %~nx0 [OPTIONS]
echo.
echo Options:
echo   -o, --output DIR      Output directory (default: .\build-output)
echo   -c, --clean           Clean output directory before build
echo   -n, --no-cache        Build Docker image without cache
echo   -h, --help            Show this help message
echo.
echo Examples:
echo   %~nx0                    # Build all Android architectures
echo   %~nx0 -o .\dist         # Use custom output directory
echo   %~nx0 -c                # Clean before build
echo.
exit /b 0
