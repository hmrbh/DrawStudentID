using System.IO;
using System.Text.Json.Nodes;

namespace updater
{
    public struct FileChanges
    {
        public string Name { get; set; }
        public long Size { get; set; }
        public string Sha256 { get; set; }
    }

    public struct UpdateInfo
    {
        public int Major { get; set; }
        public int Minor { get; set; }
        public int Patch { get; set; }
        public int Build { get; set; }
        public string Channel { get; set; }
        public string PublishDate { get; set; }
        public string ReleaseNotes { get; set; }
        public bool Mandatory { get; set; }
        public List<FileChanges> DeleteFiles { get; set; }
        public List<FileChanges> UpdateFiles { get; set; }
    }

    public class JsonVersion
    {
        private UpdateInfo updateInfo;

        public JsonVersion(string filePath)
        {
            updateInfo = LoadJsonFile(filePath);
        }

        public int GetMajorVersion() { return updateInfo.Major; }
        public int GetMinorVersion() { return updateInfo.Minor; }
        public int GetPatch() { return updateInfo.Patch; }
        public int GetBuild() { return updateInfo.Build; }
        public string GetChannel() { return updateInfo.Channel; }
        public string GetPublishDate() { return updateInfo.PublishDate; }
        public string GetReleaseNotes() { return updateInfo.ReleaseNotes; }
        public bool GetMandatory() { return updateInfo.Mandatory; }
        public List<FileChanges> GetDeleteFiles() { return updateInfo.DeleteFiles; }
        public List<FileChanges> GetUpdateFiles() { return updateInfo.UpdateFiles; }

        private static UpdateInfo LoadJsonFile(string filePath)
        {
            UpdateInfo updateInfo = new UpdateInfo();
            string jsonString = File.ReadAllText(filePath);
            JsonNode forecastNode = JsonNode.Parse(jsonString)!;
            // -------- Version Info -------- //
            JsonNode key_version = forecastNode!["version"]!;
                // -------- Major Version -------- //
                JsonNode key_major = key_version["major"];
                updateInfo.Major = (int)key_major;
                // -------- Minor Version -------- //
                JsonNode key_minor = key_version["minor"];
                updateInfo.Minor = (int)key_minor;
                // -------- Patch Version -------- //
                JsonNode key_patch = key_version["patch"];
                updateInfo.Patch = (int)key_patch;
                // -------- Build Version -------- //
                JsonNode key_build = key_version["build"];
                updateInfo.Build = (int)key_build;
                // -------- Channel -------- //
                JsonNode key_channel = key_version["channel"];
                updateInfo.Channel = (string)key_channel;
                // -------- Publish Date -------- //
                JsonNode key_publishDate = key_version["publishDate"];
                updateInfo.PublishDate = (string)key_publishDate;
                // -------- Release Notes -------- //
                JsonNode key_releaseNotes = key_version["releaseNotes"];
                updateInfo.ReleaseNotes = (string)key_releaseNotes;
                // -------- Mandatory -------- //
                JsonNode key_mandatory = key_version["mandatory"];
                updateInfo.Mandatory = (bool)key_mandatory;
            // -------- End Version Info -------- //

            // -------- File Changes -------- //
            JsonNode key_fileChanges = forecastNode!["file_changes"]!;
                // -------- Delete Fils -------- //
                JsonNode key_deleteFiles = key_fileChanges!["delete"]!;

                if (key_deleteFiles != null)
                {
                    updateInfo.DeleteFiles = key_deleteFiles.AsArray().Select(x => new FileChanges
                    {
                        Name = x["name"].ToString(),
                        Size = (long)x["size"],
                        Sha256 = x["sha256"].ToString()
                    }).ToList();
                }
                else
                {
                    updateInfo.DeleteFiles = new List<FileChanges>();
                }

                // -------- Update Files -------- //
                JsonNode key_updateFiles = key_fileChanges!["update"]!;
                if (key_updateFiles != null)
                {
                    updateInfo.UpdateFiles = key_updateFiles.AsArray().Select(x => new FileChanges
                    {
                        Name = x["name"].ToString(),
                        Size = (long)x["size"],
                        Sha256 = x["sha256"].ToString()
                    }).ToList();
                }
                else
                {
                    updateInfo.UpdateFiles = new List<FileChanges>();
                }
            // -------- End File Changes -------- //

            //DebugLogger.Instance.Log(updateInfo.DeleteFiles[0].Name);
            //DebugLogger.Instance.Log(updateInfo.DeleteFiles[0].Size.ToString());
            //DebugLogger.Instance.Log(updateInfo.DeleteFiles[0].Sha256);
            //DebugLogger.Instance.Log(updateInfo.UpdateFiles[0].Name);
            //DebugLogger.Instance.Log(updateInfo.UpdateFiles[0].Size.ToString());
            //DebugLogger.Instance.Log(updateInfo.UpdateFiles[0].Sha256);
            //DebugLogger.Instance.Log(updateInfo.UpdateFiles[1].Name);
            //DebugLogger.Instance.Log(updateInfo.UpdateFiles[1].Size.ToString());
            //DebugLogger.Instance.Log(updateInfo.UpdateFiles[1].Sha256);

            return updateInfo;
        }
    }
}