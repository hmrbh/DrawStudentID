using System;
using System.IO;
using System.Net.Http;
using System.Threading.Tasks;

public class FileDownloader
{
    private readonly HttpClient _httpClient;

    public FileDownloader()
    {
        _httpClient = new HttpClient();
    }

    /// <summary>
    /// 从指定URL异步下载文件并保存到本地路径。
    /// </summary>
    /// <param name="url">文件的URL。</param>
    /// <param name="localFilePath">保存文件的本地路径。</param>
    /// <returns>任务完成时返回。</returns>
    public async Task DownloadFileAsync(string url, string localFilePath)
    {
        try
        {
            using (var response = await _httpClient.GetAsync(url, HttpCompletionOption.ResponseHeadersRead))
            {
                response.EnsureSuccessStatusCode(); // 确保请求成功

                using (var stream = await response.Content.ReadAsStreamAsync())
                using (var fileStream = new FileStream(localFilePath, FileMode.Create, FileAccess.Write, FileShare.None))
                {
                    await stream.CopyToAsync(fileStream); // 将流复制到文件
                }
            }
        }
        catch (Exception ex)
        {
            Console.WriteLine($"下载文件时发生错误: {ex.Message}");
            throw; // 重新抛出异常以便调用者处理
        }
    }
}