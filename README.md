# ArchLinux_Config

这是我的 `ArchLinux` 配置仓库

## ArchLinux 系统安装

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

- 启动 `虚拟机` / `刻录好的U盘`

### 连接网络

- 使用 **网线/虚拟机(NAT模式)** 未自动连接下使用

```bash
 ip link
```

- 使用 **无线网卡**

```bash
 iwctl // 进入网络管理
 station list // 列出网卡列表 [一般 wlan0 为主机无线网卡]
 station <网卡名> connect <wifi> // 连接网络
 quit // 连接成功后退出
```

- 测试 **连接**

```bash
 ping bing.com
```

- 设置时区

```bash
 timedatectl set-timezone Asia/Shanghai
```

### 分区管理

- 查看分区和硬盘

```bash
 fdisk -l
```

- 创建分区

> 根据需求分区
> 划分 `swap` 分区以及 `linuxfile` 分区

```bash
cfdisk /dev/<你的硬盘>
```

- 格式化分区

  > 如果你为Arch准备了单独的EFI分区 (双系统无需处理)
  > mkfs.fat -F 32 /dev/efi_system_partition

  - 格式化交换分区

  ```bash
   mkswap /dev/<交换分区>
  ```

  - 格式化btrfs文件系统

  ```bash
   mkfs.btrfs /dev/<文件分区> -f
  ```

- 挂载分区

  - 挂载root

  ```bash
   mount /dev/<root分区> /mnt
   btrfs subvolume create /mnt/@
   umount /mnt
   mount -o noatime,compress=zstd,subvol=@ /dev/<root分区> /mnt
  ```

  - 挂载home
  > 若事先准备了 `home` 分区

  ```bash
  mkdir /mnt/home
  mount -o noatime,compress=zstd /dev/<home分区> /mnt/home
  ```

  - 挂载efi和swap分区

  ```bash
  mount /dev/<EFI分区> /mnt/boot/efi --mkdir
  swapon /dev/<swap分区>
  ```

### 安装基础软件

- 选择镜像站

```
 vim /etc/pacman.d/mirrorlist
 添加如下镜像源
 Server = https://mirrors.ustc.edu.cn/ArchLinux/$repo/os/$Arch
 Server = https://mirrors.tuna.tsinghua.edu.cn/ArchLinux/$repo/os/$Arch
```

> 也可以通过以下指令下载中国境内的镜像源，再通过 **vim /etc/pacman.d/mirrorlist** 将需要的镜像源取消注释
> 缺点是原来的镜像源会被覆盖

```bash
 curl -L 'https://ArchLinux.org/mirrorlist/?country=CN&protocol=https' -o /etc/pacman.d/mirrorlist
```

- 更新包管理器

```bash
 pacman -Syu
```

- 安装软件包

```bash
  pacstrap -K /mnt base base-devel Linux-zen Linux-zen-headers Linux-firmware git fish grub efibootmgr os-prober openssl networkmanager dhcpcd neovim ntfs-3g intel-ucode bluez bluez-utils btrfs-progs
```

### 基础设置
>
> 使用 **nvim** 配置文件时
> 可以使用 </> 键来查找要修改的代码
> 可以使用 <n/N> 键来在搜索结果之间跳转

- 挂载配置

```bash
 genfstab -U /mnt >> /mnt/etc/fstab
 arch-chroot /mnt
```

- 时间配置

```bash
 ln -sf /usr/share/zoneinfo/Asia/Shanghai /etc/localtime
 hwclock --systohc
```

- 语言配置

```bash
 nvim /etc/locale.gen
 取消en_US.UTF-8和zh_CN.UTF-8前的注释
 locale-gen
 nvim /etc/locale.conf
 第一行写入LANG=en_US.UTF-8
 安装了中文字体之后可以改成zh_CN.UTF-8
 注意: zh_CN.UTF-8在非桌面环境下会导致乱码
```

- 网络配置

```bash
 nvim /etc/hostname
 第一行写入你的<主机名称>
 systemctl enable dhcpcd
 systemctl enable NetworkManager
```

- Initramfs配置

```bash
 nvim /etc/mkinitcpio.conf
 在HOOKS的括号中添加btrfs
 mkinitcpio -P
```

- Pacman配置

```bash
 检查/etc/pacman.d/mirrorlist
 nvim /etc/pacman.conf
 取消Color和ParallelDownloads前的注释
 加上一行 ILoveCandy  吃豆人彩蛋
 pacman -Syu
```

- 用户配置

  - 设置root密码

  ```bash
   passwd
   <输入密码然后回车> [密码的输入是不会显示]
  ```

  - 添加用户

  ```bash
   useradd -m -G wheel <用户名>
   passwd <用户名>
  ```

  - 为 `wheel` 组中的用户添加sudo权限 - 类似于windows下的管理员权限

  ```bash
   nvim /etc/sudoers
   将 <Uncomment to allow members of group wheel to execute any command>** 下面一行的注释去除
   使用 :w! 强制写入
  ```

  - 设置用户shell

  ```bash
   su <用户名>
   查找shell的位置
   whereis fish

   chsh -s <fish的路径 - 第一段路径>
   chsh -s /usr/bin/fish
  ```

- 引导安装

  > [GRUB - wiki](https://wiki.ArchLinuxcn.org/wiki/GRUB)

  - UEFI 系统

  ```bash
   sudo grub-install --target=x86_64-efi --efi-direcotry=/boot/efi --bootloader-id=GRUB
  ```

  - BIOS 系统
    > 当上条指令无法正常使用时启用
    > 选择安装 **GRUB** 的硬盘(通常为efi分区存在的硬盘)

  ```bash
   sudo grub-install --recheck /dev/<你efi分区的硬盘>
  ```

- 引导配置

  - 启用双系统
    > 将最后一行的注释去掉，启用os-prober检测双系统

  ```bash
   sudo nvim /etc/default/grub
  ```

  - 更新引导

    > 如果之前为Arch创建了单独的EFI，那么现在将Windows的EFI分区挂载到任意目录 例如(/mnt)
    > 运行sudo os-prober看看能不能检测到windows
    > 未检测到windows重启进入系统再运行一遍即可

  ```bash
   sudo grub-mkconfig -o /boot/grub/grub.cfg
  ```

### 结束安装

```bash
   Ctrl+D 退出登陆
   umount -R /mnt 取消挂载
   reboot 重启
```

## ArchLinux 系统配置
>
> 此处使用 [End-4](https://github.com/end-4/dots-hyprland) 的 `Hyprland` 配置作为默认配置

### 准备工作

- 连接互联网

> 无线网卡

  ```bash
   nmcli device wifi connect <网络名> --ask
   输入密码回车
  ```

- 开启代理

  - 路由转发

    - 使用移动设备开启热点并连接电脑
    > 无无线网卡可用USB共享网络替代

    - 移动设备打开代理软件
       1. 设置代理端口 http / https
       2. 打开来自局域网的连接

    - 查询路由地址

      ```bash
      ip route show
      显示类似于如下内容 其中 default via 后面的为路由地址
      default via 192.168.2.1 dev wlo1 proto dhcp src 192.168.2.13 metric 600 
      default via 192.168.2.1 dev wlo1 proto dhcp src 192.168.2.13 metric 3003 
      192.168.2.0/24 dev wlo1 proto kernel scope link src 192.168.2.13 metric 600 
      192.168.2.0/24 dev wlo1 proto dhcp scope link src 192.168.2.13 metric 3003 
      ```

    - 设置终端代理

      ```bash
      export http_proxy=http://路由地址:转发端口
      export https_proxy=http://路由地址:转发端口
      ```

    - 检测链接

      ```bash
      ping bing.com
      ping youtube.com
      ```

- 安装重点软件

  - [yay](https://github.com/Jguer/yay)

  ```
  git clone https://aur.archlinux.org/yay.git
  cd yay
  makepkg -si
  ```

  - [paru](https://github.com/Morganamilo/paru)

  ```
  git clone https://aur.archlinux.org/paru.git
  cd paru
  makepkg -si
  ```

  - [Clash-Verge-Rev](https://www.clashverge.dev/)

  ```
  paru -S clash-verge-rev-bin
  ```

### 配置桌面

- [Hyprland](https://hypr.land/) 安装

  - 使用安装脚本 [来自End-4](https://github.com/end-4/dots-hyprland)

    ```bash
    bash <(curl -s https://ii.clsty.link/get)
    ```

- 复制配置

  - `hypr` + `kitty` + `fish`

    ```bash
    ./config/setup.sh
    ```

  - [nvim](https://github.com/XiaoCRQ/WhimsVim)
  > 需要安装 `chafa`
  > 需要安装 [CascadiaCode](https://github.com/ryanoasis/nerd-fonts/releases/download/v3.4.0/CascadiaCode.zip) 字体

- 重启

### 配置软件

- 安装输入法

  - 安装

  ```bash
   sudo pacman -S fcitx5 fcitx5-chinese-addons fcitx5-configtool
  ```

  - 配置输入法

  ```bash
   fcitx5-configtool
  ```

- 安装常用软件

  ```bash
  sudo pacman -S 软件
  ```

  - QQ —— `linuxqq`
  - Office —— `libreoffice-fresh libreoffice-fresh-zh-cn`
  - 终端文件管理器 —— `yazi`
  - 资源监视器 —— `btop`
  - 文件查找 —— `fzf`
  - ls升级 —— `lsd`
  - 显示器配置 —— `nwg-displays`
  - Neovide(nvim的gui渲染程序) —— `neovide`
  - 浏览器 —— `zen-browser`

### 配置登录界面

#### sddm

  ```bash
  sudo pacman -S sddm
  sudo systemctl enable sddm
  ```

#### 无sddm (无缝启动)

##### 设置TTY1自动登录

- 创建overrride

```bash
sudo nvim /etc/systemd/system/getty@tty1.service.d/override.conf
```

- 写入

```bash
[Service]
ExecStart=
ExecStart=-/usr/bin/agetty --autologin <你的用户名> --noclear %I $TERM
```

- 重载systemd

```bash
sudo systemctl daemon-reexec
sudo systemctl daemon-reload
```

- 测试(可选)

> 自动登录为成功

```bash
sudo systemctl restart getty@tty1
```

##### fish自动启动桌面

- 编辑config.fish

```bash
nvim ~/.config/fish/config.fish
```

- 写入

```bash
if test -z "$WAYLAND_DISPLAY"; and test (tty) = "/dev/tty1"
    exec start-hyprland
end
```

##### Hyprland启动若显示需要输入用户密钥

###### 设置keyring为空(安全性略低)

安装seahorse,设置login的密钥为空即可

##### 开机显示锁屏解锁界面

在Hyprland的exec文件下写入

```bash
exec-once = sleep 1 && loginctl lock-session
```
