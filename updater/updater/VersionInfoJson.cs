namespace updater;

public class VersionInfoJson
{
    // 大版本号
    public string major { get; set; }
    // 小版本号
    public string minor { get; set; }
    // 修订号
    public string patch { get; set; }
    // 构建号
    public string build { get; set; }
    // 版本类型（更新通道）
    public string channel { get; set; }
}