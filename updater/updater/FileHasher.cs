using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;
using System.Text;
using System.Threading.Tasks;

namespace updater
{
    class FileHasher
    {
        // 通过文件路径计算文件SHA256哈希值
        public static string ComputeSha256Hash(string filePath)
        {
            using (var sha256 = SHA256.Create())
            using (var stream = File.OpenRead(filePath))
            {
                byte[] hashBytes = sha256.ComputeHash(stream);
                return BitConverter.ToString(hashBytes).Replace("-", "").ToLowerInvariant();
            }
        }

        // 验证文件哈希值
        public static bool VerifyFileHash(string filePath, string expectedHash)
        {
            string fileHash = ComputeSha256Hash(filePath);
            return fileHash.Equals(expectedHash, StringComparison.OrdinalIgnoreCase);
        }
    }
}
