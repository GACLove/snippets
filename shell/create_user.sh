#!/bin/bash

# --- 配置 ---
# 默认 Home 目录的基础路径
DEFAULT_HOME_BASE="/mnt/data"
# sudo 权限组的名称 (Debian/Ubuntu 通常是 sudo, CentOS/RHEL 通常是 wheel)
SUDO_GROUP="sudo"
# --- 配置结束 ---

# 检查脚本是否以 root 或 sudo 权限运行
if [ "$(id -u)" -ne 0 ]; then
   echo "错误：此脚本需要以 root 或 sudo 权限运行。"
   exit 1
fi

echo "--- 用户创建工具 ---"

# 检查是否使用复用模式
REUSE_MODE=false
if [ "$1" = "--reuse" ] || [ "$1" = "-r" ]; then
    REUSE_MODE=true
    shift  # 移除 --reuse 参数
    echo "*** 复用模式：将复用已存在的用户环境 ***"
fi

# 1. 获取用户名
if [ "$#" -ge 1 ]; then
    USERNAME="$1"
    echo "使用命令行参数用户名: ${USERNAME}"
else
    echo -n "请输入用户名: "
    read USERNAME
    if [ -z "$USERNAME" ]; then
        echo "错误：用户名不能为空。"
        exit 1
    fi
fi

# 检查用户是否已存在
if getent passwd "$USERNAME" > /dev/null 2>&1; then
    echo "错误：用户 '$USERNAME' 已存在。"
    exit 1
fi

# 2. 获取 Home 目录
if [ "$#" -ge 2 ]; then
    USER_HOME="$2"
    echo "使用命令行参数 Home 目录: ${USER_HOME}"
else
    DEFAULT_USER_HOME="${DEFAULT_HOME_BASE}/${USERNAME}"
    echo -n "请输入 Home 目录路径 [默认: ${DEFAULT_USER_HOME}]: "
    read USER_HOME
    if [ -z "$USER_HOME" ]; then
        USER_HOME="$DEFAULT_USER_HOME"
    fi
fi

# 复用模式：检测已存在的用户信息
if [ "$REUSE_MODE" = true ]; then
    echo
    echo "--- 复用模式：检测已存在的用户环境 ---"
    
    # 检查 Home 目录是否存在
    if [ ! -d "$USER_HOME" ]; then
        echo "错误：Home 目录 '$USER_HOME' 不存在，无法复用。"
        exit 1
    fi
    
    # 获取 Home 目录的所有者信息
    HOME_STAT=$(stat -c "%u:%g" "$USER_HOME" 2>/dev/null)
    if [ $? -ne 0 ]; then
        echo "错误：无法获取 Home 目录的所有者信息。"
        exit 1
    fi
    
    DETECTED_UID=$(echo "$HOME_STAT" | cut -d: -f1)
    DETECTED_GID=$(echo "$HOME_STAT" | cut -d: -f2)
    
    echo "检测到的 UID: $DETECTED_UID"
    echo "检测到的 GID: $DETECTED_GID"
    
    # 检查 UID 是否已被占用（在当前系统中）
    if getent passwd "$DETECTED_UID" > /dev/null 2>&1; then
        EXISTING_USER=$(getent passwd "$DETECTED_UID" | cut -d: -f1)
        echo "警告：UID $DETECTED_UID 在当前系统中已被用户 '$EXISTING_USER' 占用。"
        echo -n "是否继续使用该 UID？(y/N): "
        read CONFIRM_UID
        if [ "$CONFIRM_UID" != "y" ] && [ "$CONFIRM_UID" != "Y" ]; then
            echo "操作已取消。"
            exit 0
        fi
    fi
    
    # 检查 GID 是否存在，如果不存在则创建对应的组
    if ! getent group "$DETECTED_GID" > /dev/null 2>&1; then
        echo "组 GID $DETECTED_GID 不存在，将创建新组..."
        groupadd -g "$DETECTED_GID" "$USERNAME"
        if [ $? -ne 0 ]; then
            echo "错误：创建组 GID $DETECTED_GID 失败。"
            exit 1
        fi
        echo "已创建组: $USERNAME (GID: $DETECTED_GID)"
    fi
    
    USER_UID="$DETECTED_UID"
    USER_GID="$DETECTED_GID"
    UID_OPTION="-u ${USER_UID}"
    GID_OPTION="-g ${USER_GID}"
    
    echo "将使用检测到的 UID: $USER_UID, GID: $USER_GID"
    
else
    # 原有的交互式模式
    # 3. 获取 UID
    if [ "$#" -ge 3 ]; then
        USER_UID="$3"
        echo "使用命令行参数 UID: ${USER_UID}"
        UID_OPTION="-u ${USER_UID}"
    else
        echo -n "请输入 UID（留空自动分配）: "
        read USER_UID
        if [ -n "$USER_UID" ]; then
            # 检查 UID 是否为数字
            case "$USER_UID" in
                ''|*[!0-9]*) 
                    echo "错误：UID 必须是数字。"
                    exit 1
                    ;;
            esac
            # 检查 UID 是否已被占用
            if getent passwd "$USER_UID" > /dev/null 2>&1; then
                echo "错误：UID $USER_UID 已被占用。"
                exit 1
            fi
            UID_OPTION="-u ${USER_UID}"
        else
            UID_OPTION=""
        fi
    fi

    # 4. 获取 GID
    if [ "$#" -ge 4 ]; then
        USER_GID="$4"
        echo "使用命令行参数 GID: ${USER_GID}"
        GID_OPTION="-g ${USER_GID}"
    else
        echo -n "请输入 GID（留空自动分配）: "
        read USER_GID
        if [ -n "$USER_GID" ]; then
            # 检查 GID 是否为数字
            case "$USER_GID" in
                ''|*[!0-9]*) 
                    echo "错误：GID 必须是数字。"
                    exit 1
                    ;;
            esac
            # 检查 GID 是否已存在，如果不存在则创建
            if ! getent group "$USER_GID" > /dev/null 2>&1; then
                echo "组 GID $USER_GID 不存在，将创建新组..."
                groupadd -g "$USER_GID" "$USERNAME"
                if [ $? -ne 0 ]; then
                    echo "错误：创建组 GID $USER_GID 失败。"
                    exit 1
                fi
                echo "已创建组: $USERNAME (GID: $USER_GID)"
            fi
            GID_OPTION="-g ${USER_GID}"
        else
            GID_OPTION=""
        fi
    fi
fi

# 构建 .ssh 目录和文件路径
USER_SSH_DIR="${USER_HOME}/.ssh"
USER_AUTH_KEYS="${USER_SSH_DIR}/authorized_keys"

echo
echo "--- 即将创建用户，信息如下 ---"
echo "用户名: ${USERNAME}"
echo "Home 目录: ${USER_HOME}"
echo "UID: ${USER_UID:-自动分配}"
echo "GID: ${USER_GID:-自动分配}"
if [ "$REUSE_MODE" = true ]; then
    echo "模式: 复用现有环境"
fi
echo

# 确认创建
echo -n "确认创建用户？(y/N): "
read CONFIRM
if [ "$CONFIRM" != "y" ] && [ "$CONFIRM" != "Y" ]; then
    echo "用户创建已取消。"
    exit 0
fi

# 复用模式下，不需要创建 Home 目录的父目录（因为已存在）
if [ "$REUSE_MODE" = false ]; then
    # 检查并创建 Home 目录的父目录
    HOME_PARENT=$(dirname "$USER_HOME")
    if [ ! -d "$HOME_PARENT" ]; then
        echo "创建父目录: $HOME_PARENT"
        mkdir -p "$HOME_PARENT"
        if [ $? -ne 0 ]; then
            echo "错误：无法创建父目录 '$HOME_PARENT'。"
            exit 1
        fi
    fi
fi

# 创建用户
echo "正在创建用户 '$USERNAME'..."
if [ "$REUSE_MODE" = true ]; then
    # 复用模式：不创建 home 目录（使用 --no-create-home）
    if [ -n "$UID_OPTION" ] && [ -n "$GID_OPTION" ]; then
        useradd --home "$USER_HOME" --no-create-home -s /bin/bash $UID_OPTION $GID_OPTION "$USERNAME"
    elif [ -n "$UID_OPTION" ]; then
        useradd --home "$USER_HOME" --no-create-home -s /bin/bash $UID_OPTION "$USERNAME"
    elif [ -n "$GID_OPTION" ]; then
        useradd --home "$USER_HOME" --no-create-home -s /bin/bash $GID_OPTION "$USERNAME"
    else
        useradd --home "$USER_HOME" --no-create-home -s /bin/bash "$USERNAME"
    fi
else
    # 原有模式：创建 home 目录
    if [ -n "$UID_OPTION" ] && [ -n "$GID_OPTION" ]; then
        useradd --home "$USER_HOME" -m -s /bin/bash $UID_OPTION $GID_OPTION "$USERNAME"
    elif [ -n "$UID_OPTION" ]; then
        useradd --home "$USER_HOME" -m -s /bin/bash $UID_OPTION "$USERNAME"
    elif [ -n "$GID_OPTION" ]; then
        useradd --home "$USER_HOME" -m -s /bin/bash $GID_OPTION "$USERNAME"
    else
        useradd --home "$USER_HOME" -m -s /bin/bash "$USERNAME"
    fi
fi

if [ $? -ne 0 ]; then
    echo "错误：创建用户 '$USERNAME' 失败。"
    exit 1
fi

# 将用户添加到 sudo 组
echo "正在将用户添加到 sudo 组..."
usermod -aG "$SUDO_GROUP" "$USERNAME"
if [ $? -ne 0 ]; then
    echo "警告：将用户添加到 sudo 组失败，请手动添加。"
fi

# 处理 SSH 目录
if [ "$REUSE_MODE" = true ]; then
    # 复用模式：检查 SSH 目录是否存在
    if [ -d "$USER_SSH_DIR" ]; then
        echo "SSH 目录已存在，跳过创建。"
        echo "正在验证 SSH 目录权限..."
        
        # 验证并修正权限（以防万一）
        chown -R "$USERNAME:$USERNAME" "$USER_SSH_DIR"
        chmod 700 "$USER_SSH_DIR"
        if [ -f "$USER_AUTH_KEYS" ]; then
            chmod 600 "$USER_AUTH_KEYS"
        fi
    else
        echo "SSH 目录不存在，正在创建..."
        # 创建 .ssh 目录
        mkdir -p "$USER_SSH_DIR"
        if [ $? -ne 0 ]; then
            echo "错误：创建 SSH 目录失败。"
            exit 1
        fi
        
        # 创建空的 authorized_keys 文件
        touch "$USER_AUTH_KEYS"
        if [ $? -ne 0 ]; then
            echo "错误：创建 authorized_keys 文件失败。"
            exit 1
        fi
        
        # 设置所有权和权限
        chown -R "$USERNAME:$USERNAME" "$USER_SSH_DIR"
        chmod 700 "$USER_SSH_DIR"
        chmod 600 "$USER_AUTH_KEYS"
    fi
else
    # 原有模式：创建 SSH 目录
    echo "正在创建 SSH 目录..."
    mkdir -p "$USER_SSH_DIR"
    if [ $? -ne 0 ]; then
        echo "错误：创建 SSH 目录失败。"
        exit 1
    fi

    # 创建空的 authorized_keys 文件
    echo "正在创建 authorized_keys 文件..."
    touch "$USER_AUTH_KEYS"
    if [ $? -ne 0 ]; then
        echo "错误：创建 authorized_keys 文件失败。"
        exit 1
    fi

    # 设置所有权
    echo "正在设置目录所有权..."
    chown -R "$USERNAME:$USERNAME" "$USER_SSH_DIR"
    if [ $? -ne 0 ]; then
        echo "错误：设置所有权失败。"
        exit 1
    fi

    # 设置权限
    echo "正在设置目录权限..."
    chmod 700 "$USER_SSH_DIR"
    chmod 600 "$USER_AUTH_KEYS"
    if [ $? -ne 0 ]; then
        echo "错误：设置权限失败。"
        exit 1
    fi
fi

echo
echo "--- 用户创建完成 ---"
echo "用户名: $USERNAME"
echo "Home 目录: $USER_HOME"
echo "UID: $(id -u $USERNAME)"
echo "GID: $(id -g $USERNAME)"
echo "SSH 目录: $USER_SSH_DIR"
if [ "$REUSE_MODE" = true ]; then
    echo "模式: 复用现有环境（已保留原有数据）"
    echo "提示: 如果需要，请检查 $USER_AUTH_KEYS 文件中的公钥。"
else
    echo "请手动编辑 $USER_AUTH_KEYS 文件添加公钥。"
fi
echo "**请使用 'passwd $USERNAME' 设置用户密码。**"

exit 0
