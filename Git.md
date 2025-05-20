
# Git 使用教程笔记（按场景分类）

---

## 📦 初始化与配置

### 登陆账户

```bash
  git config --global user.email "you@example.com"
  git config --global user.name "Your Name"
```

### 初始化仓库

```bash
git init                 # 初始化本地仓库
git clone <url>          # 克隆远程仓库
```

### 全部推送

- 首次推送

```bash
git add .                     # 添加所有更改（包括新文件、修改、删除）
git commit -m "你的提交信息"   # 提交更改

git remote add origin https://github.com/yourname/my-project.git

git push --set-upstream origin main
```

- 全部推送

```bash
git add .                     # 添加所有更改（包括新文件、修改、删除）
git commit -m "你的提交信息"   # 提交更改
git push                      # 推送到远程仓库
```

- 强制推送

```bash
git push  --force
```

### SSH 推送

```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
cat ~/.ssh/id_ed25519.pub
复制密钥放入https://github.com/settings/keys
git remote set-url origin git@github.com:username/project.git
```
