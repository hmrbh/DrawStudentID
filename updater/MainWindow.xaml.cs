using System;
using System.Diagnostics;
using System.IO;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Media.Animation;

namespace updater
{
    public partial class MainWindow : Window
    {
        private bool webConnected = true;

        public MainWindow()
        {
            //DebugLogger.Instance.Log("这是一个调试日志消息。");
            InitializeComponent();
            StartLoadingAnimation();
            
        }

        private async void StartLoadingAnimation()
        {
            // 获取动画的 Storyboard
            var loadingAnimation = (Storyboard)FindResource("IndeterminateLoadingAnimation");
            loadingAnimation.Begin();

            // 异步调用函数
            await TaskFunction();
        }

        
        private async Task CheckForUpdate()
        {
            try
            {
                // 下载版本信息文件 update.json
                FileDownloader fileDownloader;
                fileDownloader = new FileDownloader();
                await fileDownloader.DownloadFileAsync("https://hmrbh.github.io/update/updater_test/update.json", "update.json");
            } catch {
                MainGrid.Children.Clear();
                webConnected = false;
                var errorText = new TextBlock
                {
                    Text = "错误：无法下载更新文件\n请您检查网络连接或重试",
                    HorizontalAlignment = HorizontalAlignment.Center,
                    VerticalAlignment = VerticalAlignment.Center,
                    Margin = new Thickness(0, -100, 0, 0),
                    FontSize = 22,
                    FontWeight = FontWeights.Bold,
                    Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.Red)
                };
                MainGrid.Children.Add(errorText);

                var closeButton = new Button
                {
                    Content = "关闭",
                    HorizontalAlignment = HorizontalAlignment.Center,
                    VerticalAlignment = VerticalAlignment.Bottom,
                    Margin = new Thickness(0, 0, 0, 50),
                    Width = 100,
                    Height = 40,
                    FontSize = 16,
                };
                // 定义按钮的样式
                var style = new Style(typeof(Button));
                style.Setters.Add(new Setter(Button.BackgroundProperty, new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.Red)));
                style.Setters.Add(new Setter(Button.ForegroundProperty, new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.White)));
                closeButton.Style = style;

                closeButton.Click += (sender, e) => Application.Current.Shutdown();
                MainGrid.Children.Add(closeButton);
            }
        }

        private async Task TaskFunction()
        {
            //DebugLogger.Instance.Log(FileHasher.ComputeSha256Hash("old_file.txt"));
            //DebugLogger.Instance.Log(FileHasher.VerifyFileHash("updater.exe", "4bfa9bfdbf2a5abf75d0df23f8f7afad0cb25014e99bc7f95e11ec9b6e7726ff") ? "TRUE" : "FALSE");
            
            await CheckForUpdate();
            await Task.Delay(2000);
            // 任务完成后停止动画
            await Dispatcher.InvokeAsync(() =>
            {
                var loadingAnimation = (Storyboard)FindResource("IndeterminateLoadingAnimation");
                loadingAnimation.Stop();
                if (webConnected)
                {
                    // 清空当前显示的内容
                    MainGrid.Children.Clear();

                    // 添加新的文本
                    var successText = new TextBlock
                    {
                        Text = "完成",
                        HorizontalAlignment = HorizontalAlignment.Center,
                        VerticalAlignment = VerticalAlignment.Center,
                        FontWeight = FontWeights.Bold,
                        Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.White),
                        FontSize = 22
                    };
                    MainGrid.Children.Add(successText);
                }
            });
        }
    }
}