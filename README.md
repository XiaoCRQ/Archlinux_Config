# ArchLinux_config

这是我的ArchLinux安装和配置文档

## **Arch Linux** 安装文档

### 准备工作

- **Arch Linux** 官方文档[此处](https://wiki.ArchLinuxcn.org/wiki/%E5%AE%89%E8%A3%85%E6%8C%87%E5%8D%97)
- 下载 **Arch Linux** 的镜像

  > [清华源](https://mirrors.tuna.tsinghua.edu.cn/ArchLinux/iso/2024.10.01/)下载
  >
  > [阿里云](https://mirrors.aliyun.com/ArchLinux/iso/2024.10.01/)下载

- 物理机准备启动U盘

  > [rufus](https://rufus.ie/zh/)单镜像刻录
  >
  > [ventoy](https://www.ventoy.net/en/index.html)多镜像刻录

- 虚拟机安装准备

  - 正常创建虚拟机
  - 修改引导为UEFI
    > 虚拟机设置 -> 选项 -> 高级 -> UEFI -> 确定
  - 启动后检测是否为UEFI启动
    > ls /sys/firmware/efi/efivars
    > 报错/文件不存在/文件为空 则不是UEFI启动

### 开始安装

#### 1. 检查是否符合UEFI64模式

- 命令

```text
 cat /sys/firmware/efi/fw_platform_size
```

- 相关文档
  > 如果命令结果为 64，则系统是以 UEFI 模式引导且使用 64 位 x64 UEFI。如果命令结果为 32，则系统是以 UEFI 模式引导且使用 32 位 IA32 UEFI，虽然其受支持，但引导加载程序只能使用 systemd-boot和GRUB。如果文件不存在，则系统可能是以BIOS模式（或 CSM 模式）引导。如果系统没有以您想要的模式（UEFI 或 BIOS）引导启动，请您参考自己的计算机或主板说明书。

#### 2. 连接网络

- 使用 **网线/虚拟机(NAT模式)** 未自动连接下使用

```text
 ip link
```

- 使用 **无线网卡**

```text
 iwctl // 进入网络管理
 station list // 列出网卡列表 [一般 wlan0 为主机无线网卡]
 station <网卡名> connect <wifi> // 连接网络
 quit // 连接成功后退出
```

- 测试 **连接**

```text
 ping bing.com
```

- 设置时区

```text
 timedatectl set-timezone Asia/Shanghai
```

#### 3. 分区管理

- 查看分区和硬盘

```text
 fdisk -l
```

- 创建分区

```text
cfdisk /dev/<你的硬盘>
```

![image](https://raw.githubusercontent.com/xiaoCRQ/ArchLinux_config/main/img/cfdisk.png)

> 按需要分区
> ![image](https://raw.githubusercontent.com/xiaoCRQ/ArchLinux_config/main/img/wiki_disk.png)

- 格式化分区

  > 如果你为Arch准备了单独的EFI分区
  > mkfs.fat -F 32 /dev/efi_system_partition

  - 格式化交换分区

  ```text
   mkswap /dev/<交换分区>
  ```

  - 格式化btrfs文件系统

  ```text
   mkfs.btrfs /dev/<root分区> -f
   mkfs.btrfs /dev/<home分区> -f
  ```

- 挂载分区

  - 挂载root

  ```text
   mount /dev/<root分区> /mnt
   btrfs subvolume create /mnt/@
   umount /mnt
   mount -o noatime,compress=zstd,subvol=@ /dev/<root分区> /mnt
  ```

  - 挂载home

  ```text
  mkdir /mnt/home
  mount -o noatime,compress=zstd /dev/<home分区> /mnt/home
  ```

  - 挂载efi和swap分区

  ```text
  mount /dev/<EFI分区> /mnt/boot/efi --mkdir
  swapon /dev/<swap分区>
  ```

#### 4. 安装 **Arch Linux**

- 选择镜像站

```
 vim /etc/pacman.d/mirrorlist
 添加如下镜像源
 Server = https://mirrors.ustc.edu.cn/ArchLinux/$repo/os/$Arch
 Server = https://mirrors.tuna.tsinghua.edu.cn/ArchLinux/$repo/os/$Arch
```

> 也可以通过以下指令下载中国境内的镜像源，再通过 **vim /etc/pacman.d/mirrorlist** 将需要的镜像源取消注释

```text
 curl -L 'https://ArchLinux.org/mirrorlist/?country=CN&protocol=https' -o /etc/pacman.d/mirrorlist
```

> 缺点是原来的镜像源会被覆盖

- 配置国内镜像源 **AUR**

  - **vim /etc/pacman.conf** 在最后写下如下内容

  ```text
  [ArchLinuxcn]
  Server = https://mirrors.ustc.edu.cn/ArchLinuxcn/$Arch
  Server = https://mirrors.tuna.tsinghua.edu.cn/ArchLinuxcn/$Arch
  Server = https://mirrors.hit.edu.cn/ArchLinuxcn/$Arch
  Server = https://repo.huaweicloud.com/ArchLinuxcn/$Arch
  ```

- 更新包管理器

```text
 pacman -Sy
```

- 安装软件包

```text
  pacstrap -K /mnt base base-devel Linux-zen Linux-zen-headers Linux-firmware git fish grub efibootmgr os-prober openssl networkmanager dhcpcd neovim ntfs-3g intel-ucode bluez bluez-utils btrfs-progs
```

#### 5. **Arch Linux** 基础配置

> 使用 **nvim** 配置文件时
> 可以使用 </> 键来查找要修改的代码
> 可以使用 <n/N> 键来在搜索结果之间跳转

- 挂载配置

```text
 genfstab -U /mnt >> /mnt/etc/fstab
 Arch-chroot /mnt
```

- 时间配置

```text
 ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
 hwclock --systohc
```

- 语言配置

```text
 nvim /etc/locale.gen
 取消en_US.UTF-8和zh_CN.UTF-8前的注释
 locale-gen
 nvim /etc/locale.conf
 第一行写入LANG=en_US.UTF-8
 安装了中文字体之后可以改成zh_CN.UTF-8
 注意: zh_CN.UTF-8在非桌面环境下会导致乱码
```

- 网络配置

```text
 nvim /etc/hostname
 第一行写入你的<主机名称>，任意添(别太任意%……#@$@*&……)
 systemctl enable dhcpcd
 systemctl enable NetworkManager
```

- Initramfs配置

```text
 nvim /etc/mkinitcpio.conf
 在HOOKS中加入btrfs
 mkinitcpio -P
```

- Pacman配置

```text
 检查/etc/pacman.d/mirrorlist
 nvim /etc/pacman.conf
 取消Color和ParallelDownloads前的注释
 加上一行 ILoveCandy  吃豆人彩蛋
 pacman -Syy
```

- 用户配置

  - 设置root密码

  ```text
   passwd
   <输入密码然后回车> [密码的输入是不会显示]
  ```

  - 添加用户

  ```text
   useradd -m -G wheel <用户名>
   passwd <用户名>
  ```

  - 为 **wheel** 组中的用户添加sudo权限 - 类似于windows下的管理员权限

  ```text
   nvim /etc/sudoers
   将 <Uncomment to allow members of group wheel to execute any command>** 下面一行的注释去除
   使用 :w! 强制写入
  ```

  - 设置用户shell

  ```text
   su <用户名>
   查找shell的位置
   whereis fish

   chsh -s <fish的路径 - 第一段路径>
   chsh -s /usr/bin/fish
  ```

- 引导安装

  > [GRUB - wiki](https://wiki.ArchLinuxcn.org/wiki/GRUB)

  - UEFI 系统

  ```text
   sudo grub-install --target=x86_64-efi --efi-direcotry=/boot/efi --bootloader-id=GRUB
  ```

  - BIOS 系统
    > 要安装 **GRUB** 的硬盘(通常为efi分区存在的硬盘)

  ```text
   sudo grub-install --recheck /dev/<你efi分区的硬盘>
  ```

- 引导配置

  - 启用双系统
    > 将最后一行的注释去掉，启用os-prober检测双系统

  ```text
   sudo nvim /etc/default/grub
  ```

  - 更新引导

    > 如果之前为Arch创建了单独的EFI，那么现在将windows的EFI分区挂载到任意目录 例如(/mnt)
    > 运行sudo os-prober看看能不能检测到windows
    > 未检测到windows重启进入系统再运行一遍即可

  ```text
   sudo grub-mkconfig -o /boot/grub/grub.cfg
  ```

- 结束配置

```text
   Ctrl+D 退出登陆
   umount -R /mnt 取消挂载
   reboot 重启
```

#### 6. **Arch Linux** 安装软件

- 连接互联网

  > 无线网卡

  ```text
   nmcli device wifi connect <网络名> --ask
   输入密码回车
  ```

- 安装 **Nvidia** 驱动

  - Nvidia 的 [**wiki**](https://wiki.ArchLinuxcn.org/wiki/NVIDIA) 百科
  - 也可参考下面的hyprland脚本

- 安装重点软件

  - paru

  ```
  sudo pacman-key --lsign-key "farseerfc@ArchLinux.org"
  sudo pacman -S ArchLinuxcn-keyring
  sudo pacman -S paru
  ```

  - Clash-Verge-Rev-Docs

  ```
  paru -S clash-verge-rev-bin
  ```

- 安装常用软件

  - terminal 终端模拟器

  ```text
   sudo pacman -S kitty
  ```

  - Btop 资源监视器

  ```text
   sudo pacman -S btop
  ```

  - Ranger 资源管理器

  ```text
   sudo pacman -S ranger
  ```

  - Rofi 搜索栏【需要桌面环境】

  ```text
   sudo pacman -S rofi
  ```

  - Speedtest 网速测试

  ```text
   sudo pacman -S speedtest-cli
  ```

  - Axel 下载工具

  ```text
   sudo pacman -S axel
  ```

  - Neofetch 系统基本信息

  ```text
   sudo pacman -S neofetch
  ```

  - Lsd 带图标的ls命令

  ```text
   sudo pacman -S lsd
  ```

  - Bat 替代cat的更好文件输出打印

  ```text
   sudo pacman -S bat
  ```

  - Zellij 终端平铺管理

  ```text
   sudo pacman -S zellij
  ```

  - Ffmpeg 媒体资源处理器/依赖项

  ```text
   sudo pacman -S ffmpeg
  ```

  - Ncdu 磁盘空间查看器

  ```text
   sudo pacman -S ncdu
  ```

  - Dust 形象显示磁盘占用

  ```text
   sudo pacman -S dust
  ```

  - Tldr 快速解释命令使用方法

  ```text
   sudo pacman -S ncdu
  ```

  - hollywood 黑客装逼-没啥用

  - Fzf 文件查找

  ```text
   sudo pacman -S fzf
  ```

  - Powertop 电源管理

  ```text
   sudo pacman -S powertop
  ```

  - Pav 声音

  ```text
   sudo pacman -S pavucontrol-qt
   pavucontrol-qt
  ```

  - 字体

  ```text
   sudo pacman -S ttf-jetbrains-mono-nerd adobe-source-han-sans-cn-fonts adobe-source-code-pro-fonts
  ```

- 安装桌面环境

  - Hyprland

    - 使用安装脚本 [来自HyDE](https://github.com/HyDE-Project/HyDE/tree/master)

    ```text
    git clone --depth 1 https://github.com/HyDE-Project/HyDE ~/HyDE
    cd ~/HyDE/Scripts
    ./install.sh
    ```

  - Kde

- 配置桌面环境

  - Hyprland

- 安装桌面管理

```text
 sudo pacman -S sddm
```

- 启动桌面管理

```text
 sudo systemctl enable sddm
```

- 重启

```text
 reboot
```

- 安装输入法

  - 安装

  ```text
   sudo pacman -S fcitx5 fcitx5-chinese-addons fcitx5-configtool
  ```

  - 配置输入法

  ```text
   fcitx5-configtool
  ```

#### 7. 配置软件

- 下载配置文件

  ```text
   git clone https://github.com/XiaoCRQ/ArchLinux_Config
  ```

- 导入配置

  ```text
  ./setup.sh
  ```

- Neovim配置

  ```text
   git clone https://github.com/XiaoCRQ/WhimsVim_starter ~/.config/nvim
   rm -rf ~/.config/nvim/.git
  ```

  ```

  ```

## 其他配置

- [Git使用指南](Git.md)
