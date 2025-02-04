import gdown

# 下载预训练模型
url = "https://drive.google.com/drive/folders/1Srf-WYUixK0wiUddc9y3pNKHHno5PN6R?usp=sharing"
gdown.download_folder(url, output="weights", quiet=False)
