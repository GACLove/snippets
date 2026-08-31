#!/usr/bin/env python3
"""
将本地文件夹上传到 Hugging Face Hub（支持符号链接）
"""

import os
import sys
from pathlib import Path
from huggingface_hub import HfApi
import argparse


def get_hf_token():
    """获取 Hugging Face token"""
    try:
        from huggingface_hub import get_token
        token = get_token()
    except:
        token = os.environ.get("HF_TOKEN")

    if not token:
        print("未找到 Hugging Face token!")
        print("请运行: huggingface-cli login")
        print("或设置环境变量: export HF_TOKEN=your_token_here")
        sys.exit(1)
    return token


def upload_file(api, repo_id, local_file_path, repo_path, token, repo_type):
    """上传单个文件"""
    try:
        api.upload_file(
            path_or_fileobj=local_file_path,
            path_in_repo=repo_path,
            repo_id=repo_id,
            repo_type=repo_type,
            token=token,
        )
        print(f"✓ 上传: {repo_path}")
        return True
    except Exception as e:
        print(f"✗ 失败: {repo_path} - {e}")
        return False


def upload_folder_recursive(api, repo_id, local_path, repo_base_path="", token=None, repo_type="model", follow_symlinks=True):
    """
    递归上传文件夹，支持符号链接

    Args:
        api: HfApi 实例
        repo_id: Hugging Face repo ID
        local_path: 本地文件夹路径
        repo_base_path: Hub 上的基础路径
        token: HF token
        repo_type: 仓库类型
        follow_symlinks: 是否跟随符号链接
    """

    local_path = Path(local_path).expanduser().resolve()

    if not local_path.exists():
        print(f"✗ 路径不存在: {local_path}")
        return 0

    uploaded_count = 0

    # 处理文件
    if local_path.is_file():
        repo_path = repo_base_path if repo_base_path else local_path.name
        if upload_file(api, repo_id, str(local_path), repo_path, token, repo_type):
            uploaded_count += 1
        return uploaded_count

    # 处理目录
    if local_path.is_dir():
        try:
            for item in sorted(local_path.iterdir()):
                # 跳过 .cache 目录
                if item.name == ".cache":
                    print(f"⊘ 跳过缓存目录: {item.name}")
                    continue
                # 处理符号链接
                if item.is_symlink():
                    if not follow_symlinks:
                        print(f"⊘ 跳过符号链接: {item.name}")
                        continue

                    # 解析符号链接的实际路径
                    try:
                        real_path = item.resolve()
                        if not real_path.exists():
                            print(f"⊘ 符号链接目标不存在: {item.name} -> {real_path}")
                            continue

                        repo_sub_path = f"{repo_base_path}/{item.name}" if repo_base_path else item.name

                        # 递归上传符号链接指向的内容
                        count = upload_folder_recursive(
                            api, repo_id, str(real_path), repo_sub_path,
                            token, repo_type, follow_symlinks
                        )
                        uploaded_count += count
                    except Exception as e:
                        print(f"✗ 处理符号链接失败: {item.name} - {e}")

                # 处理普通文件
                elif item.is_file():
                    repo_sub_path = f"{repo_base_path}/{item.name}" if repo_base_path else item.name
                    if upload_file(api, repo_id, str(item), repo_sub_path, token, repo_type):
                        uploaded_count += 1

                # 处理普通目录
                elif item.is_dir():
                    repo_sub_path = f"{repo_base_path}/{item.name}" if repo_base_path else item.name
                    count = upload_folder_recursive(
                        api, repo_id, str(item), repo_sub_path,
                        token, repo_type, follow_symlinks
                    )
                    uploaded_count += count

        except Exception as e:
            print(f"✗ 遍历目录失败: {local_path} - {e}")

    return uploaded_count


def main():
    parser = argparse.ArgumentParser(
        description="上传本地文件夹到 Hugging Face Hub（支持符号链接）"
    )
    parser.add_argument(
        "local_path",
        help="本地文件夹路径"
    )
    parser.add_argument(
        "repo_id",
        help="Hugging Face 仓库 ID (格式: username/repo_name)"
    )
    parser.add_argument(
        "--repo-type",
        default="model",
        choices=["model", "dataset", "space"],
        help="仓库类型 (默认: model)"
    )
    parser.add_argument(
        "--private",
        action="store_true",
        help="创建私有仓库"
    )
    parser.add_argument(
        "--no-symlinks",
        action="store_true",
        help="不跟随符号链接"
    )

    args = parser.parse_args()

    # 验证本地路径
    local_path = Path(args.local_path).expanduser().resolve()
    if not local_path.exists():
        print(f"错误: 本地路径不存在: {local_path}")
        sys.exit(1)

    if not local_path.is_dir():
        print(f"错误: 路径不是文件夹: {local_path}")
        sys.exit(1)

    # 获取 token
    token = get_hf_token()

    # 创建 API 实例
    api = HfApi()

    try:
        # 创建仓库（如果不存在）
        print(f"正在创建/连接到仓库: {args.repo_id}")
        repo_url = api.create_repo(
            repo_id=args.repo_id,
            repo_type=args.repo_type,
            private=args.private,
            exist_ok=True,
            token=token
        )
        print(f"仓库地址: {repo_url}\n")

        # 上传文件夹
        print(f"开始上传文件夹: {local_path}")
        print(f"跟随符号链接: {not args.no_symlinks}\n")

        uploaded_count = upload_folder_recursive(
            api,
            repo_id=args.repo_id,
            local_path=str(local_path),
            token=token,
            repo_type=args.repo_type,
            follow_symlinks=not args.no_symlinks
        )

        print(f"\n✓ 上传完成! 共上传 {uploaded_count} 个文件")

    except Exception as e:
        print(f"✗ 上传失败: {e}")
        sys.exit(1)


if __name__ == "__main__":
    main()
