#include "getopt.h"
#include <Windows.h>
#include <stdio.h>
#include <wchar.h>

#pragma warning(disable : 4996)

void AddToStartup(const wchar_t* appName, const wchar_t* appPath, const wchar_t* appParams)
{
    wprintf(L"Add %ls to startup\n", appName);

    HKEY hKey;
    // 创建或打开注册表键
    LONG result = RegCreateKeyEx(HKEY_CURRENT_USER, L"SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Run", 0, NULL, REG_OPTION_NON_VOLATILE, KEY_SET_VALUE, NULL, &hKey, NULL);

    if (result == ERROR_SUCCESS) {
        wprintf(L"Open or create reg key.\n");

        // 构建启动命令，包括路径和参数
        wchar_t commandLine[520];
        wcscpy(commandLine, appPath); // 复制路径
        wcscat(commandLine, L" ");   // 添加空格分隔
        wcscat(commandLine, appParams); // 添加参数

        // 设置应用程序自启动值
        result = RegSetValueEx(hKey, appName, 0, REG_SZ, (const BYTE*)commandLine, (wcslen(commandLine) + 1) * sizeof(wchar_t));
        // 关闭注册表键
        RegCloseKey(hKey);

        if (result == ERROR_SUCCESS) {
            wprintf(L"Application has been added to startup.\n");
        }
        else {
            wprintf(L"Failed to set registry value.\n");
            char errorMessage[256];
            FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, NULL, result, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), errorMessage, 256, NULL);
            wprintf(L"Error: %s\n", errorMessage);
        }
    }
    else {
        wprintf(L"Failed to create registry key.\n");
        char errorMessage[256];
        FormatMessage(FORMAT_MESSAGE_FROM_SYSTEM, NULL, result, MAKELANGID(LANG_NEUTRAL, SUBLANG_DEFAULT), errorMessage, 256, NULL);
        wprintf(L"Error: %s\n", errorMessage);
    }
}

int main(int argc, char* argv[])
{
    int ret = -1;
    int option_index = 0;
    struct option long_options[] =
    {
        {"autostart", required_argument, NULL, 'a'},
        {NULL,     0,                 NULL,  0}
    };

    wchar_t appName[256];
    wchar_t appPath[256];
    wchar_t appParams[256];

    while ((ret = getopt_long(argc, argv, "", long_options, &option_index)) != -1)
    {
        printf("ret = %c\t", ret);
        if (optarg) {
            printf("optarg = %s\t", optarg);
        }
        printf("option_index = %d\n", option_index);
        switch (ret)
        {
        case 'a':
            // Convert char to wchar_t
            MultiByteToWideChar(CP_UTF8, 0, optarg, -1, appParams, 256);

            // Get the full path of the current executable
            DWORD len = GetModuleFileName(NULL, appPath, 256);
            if (len == 0 || len == 256) {
                wprintf(L"Error getting module file name.\n");
                return 1;
            }
            appPath[len] = L'\0'; // Ensure null termination

            // Add the current executable to startup
            AddToStartup(L"Draw Student ID Helper", appPath, L"");

            // 找到路径中的最后一个反斜杠，并将其替换为 null 字符，以移除文件名
            wchar_t* backslash = wcsrchr(appPath, L'\\');
            if (backslash != NULL) {
                *backslash = L'\0'; // 现在 appPath 不包含文件名
            }
            else {
                wprintf(L"Error: The path does not contain a backslash.\n");
                return 1;
            }

            wchar_t otherAppPath[256];
            wcscpy(otherAppPath, appPath);
            wcscat(otherAppPath, appParams);

            char path[MAX_PATH];
            GetModuleFileNameA(NULL, path, MAX_PATH);
            for (unsigned int i = strlen(path); i > 0; i--)
                if (path[i] == '\\' || path[i] == '/')
                {
                    path[i] = '\0';
                    break;
                }
            printf("当前程序运行目录: %s\n", path);

            // Add the other executable to startup
            AddToStartup(L"Draw Student ID", otherAppPath, L" ");
            break;

        default:
            break;
        }
    }
    return 0;
}