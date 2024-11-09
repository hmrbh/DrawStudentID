using System;
using System.Diagnostics;

namespace updater
{
    class DebugLogger
    {
        private static readonly Lazy<DebugLogger> lazy = new Lazy<DebugLogger>(() => new DebugLogger());

        public static DebugLogger Instance { get { return lazy.Value; } }

        private Process cmdProcess;
        private ProcessStartInfo startInfo;

        private DebugLogger()
        {
            // 初始化CMD进程
            startInfo = new ProcessStartInfo("cmd.exe")
            {
                RedirectStandardInput = true,
                UseShellExecute = false,
                CreateNoWindow = false
            };

            cmdProcess = new Process
            {
                StartInfo = startInfo
            };
            cmdProcess.Start();
        }

        public void Log(string message)
        {
            // 向CMD窗口写入日志
            cmdProcess.StandardInput.WriteLine("echo " + message);
        }

        // 关闭CMD窗口
        public void Close()
        {
            if (cmdProcess != null && !cmdProcess.HasExited)
            {
                cmdProcess.StandardInput.WriteLine("exit");
                cmdProcess.WaitForExit();
                cmdProcess.Close();
            }
        }
    }
}