using System.Windows;
using System.Windows.Controls;
using System.Windows.Media.Animation;

namespace updater
{
    public partial class MainWindow : Window
    {
        private bool webConnected = true;
        private bool successReadJson = true;
        FileDownloader fileDownloader;
        JsonVersion jsonFileReader;

        public MainWindow()
        {
            fileDownloader = new FileDownloader();
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

        
        private async Task<bool> CheckForUpdate()
        {
            try
            {
                // 下载版本信息文件 update.json
                await fileDownloader.DownloadFileAsync("https://hmrbh.github.io/update/updater_test/update.json", "update.json");
                jsonFileReader = new JsonVersion("update.json");
                if (jsonFileReader.GetMajorVersion() >= 3)
                {
                    if (jsonFileReader.GetMinorVersion() >= 0)
                    {
                        return true;
                    }
                    else if (jsonFileReader.GetPatch() >= 0)
                    {
                        return true;
                    }
                    else return false;
                }
            }
            catch
            {
                //DebugLogger.Instance.Log(retryCount.ToString());
                MainGrid.Children.Clear();
                webConnected = false;
                var errorText = new TextBlock
                {
                    Text = "错误：无法获取更新信息\n请您检查网络连接或重试",
                    HorizontalAlignment = HorizontalAlignment.Center,
                    VerticalAlignment = VerticalAlignment.Center,
                    Margin = new Thickness(0, -100, 0, 50),
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
                var style2 = new Style(typeof(Button));
                style2.Setters.Add(new Setter(BackgroundProperty, new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.Red)));
                style2.Setters.Add(new Setter(ForegroundProperty, new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.White)));
                closeButton.Style = style2;

                closeButton.Click += (sender, e) => Application.Current.Shutdown();

                MainGrid.Children.Add(closeButton);
                return false;
            }
            return false;
        }

        private async Task TaskFunction()
        {
            //DebugLogger.Instance.Log(FileHasher.ComputeSha256Hash("old_file.txt"));
            //DebugLogger.Instance.Log(FileHasher.VerifyFileHash("updater.exe", "4bfa9bfdbf2a5abf75d0df23f8f7afad0cb25014e99bc7f95e11ec9b6e7726ff") ? "TRUE" : "FALSE");
            bool hasUpdate = await CheckForUpdate();

            await Task.Delay(2000);
            // 任务完成后停止动画
            await Dispatcher.InvokeAsync(() =>
            {
                var loadingAnimation = (Storyboard)FindResource("IndeterminateLoadingAnimation");
                loadingAnimation.Stop();
                if (webConnected && successReadJson)
                {
                    // 清空当前显示的内容
                    MainGrid.Children.Clear();
                    if (hasUpdate)
                    {
                        var updateText = new TextBlock
                        {
                            Text = "发现新版本，是否更新？",
                            HorizontalAlignment = HorizontalAlignment.Center,
                            VerticalAlignment = VerticalAlignment.Center,
                            Margin = new Thickness(0, -100, 0, 50),
                            FontWeight = FontWeights.Bold,
                            Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.White),
                            FontSize = 24
                        };
                        var updateInfoText = new TextBlock
                        {
                            Text = "最新版本：" + jsonFileReader.GetMajorVersion().ToString() + "." + jsonFileReader.GetMinorVersion().ToString() + "." + jsonFileReader.GetPatch().ToString() + "#" + jsonFileReader.GetBuild().ToString(),
                            HorizontalAlignment = HorizontalAlignment.Center,
                            VerticalAlignment = VerticalAlignment.Center,
                            Margin = new Thickness(0, 0, 0, 50),
                            FontWeight = FontWeights.Regular,
                            Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.White),
                            FontSize = 14
                        };
                        MainGrid.Children.Add(updateText);
                        MainGrid.Children.Add(updateInfoText);
                        var updateButton = new Button
                        {
                            Content = "更新",
                            HorizontalAlignment = HorizontalAlignment.Left,
                            VerticalAlignment = VerticalAlignment.Center,
                            Margin = new Thickness(0, 100, 0, -250),
                            Background = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.DeepSkyBlue),
                            Width = 100,
                            Height = 40,
                            FontSize = 16,
                        };
                        MainGrid.Children.Add(updateButton);
                        var cancelButton = new Button
                        {
                            Content = "取消",
                            HorizontalAlignment = HorizontalAlignment.Right,
                            VerticalAlignment = VerticalAlignment.Center,
                            Margin = new Thickness(0, 100, 0, -250),
                            Background = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.White),
                            Width = 100,
                            Height = 40,
                            FontSize = 16,
                        };
                        MainGrid.Children.Add(cancelButton);
                    }
                    else
                    {
                        var updateText = new TextBlock
                        {
                            Text = "当前已经是最新版本",
                            HorizontalAlignment = HorizontalAlignment.Center,
                            VerticalAlignment = VerticalAlignment.Center,
                            FontWeight = FontWeights.Bold,
                            Foreground = new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.White),
                            FontSize = 22
                        };
                        MainGrid.Children.Add(updateText);
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
                        style.Setters.Add(new Setter(BackgroundProperty, new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.DeepSkyBlue)));
                        style.Setters.Add(new Setter(ForegroundProperty, new System.Windows.Media.SolidColorBrush(System.Windows.Media.Colors.White)));
                        closeButton.Style = style;

                        closeButton.Click += (sender, e) => Application.Current.Shutdown();
                        MainGrid.Children.Add(closeButton);
                    }
                }
            });
        }

    }
}