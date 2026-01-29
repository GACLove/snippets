import torch
from safetensors.torch import load_file
import os
import argparse
from collections import Counter


def format_size(num_bytes):
    for unit in ["B", "KB", "MB", "GB"]:
        if num_bytes < 1024:
            return f"{num_bytes:.2f} {unit}"
        num_bytes /= 1024


def inspect_model():
    parser = argparse.ArgumentParser(description="深度权重分析工具")
    parser.add_argument("file", help="模型路径")
    parser.add_argument(
        "--stat", action="store_true", help="启用数值统计(均值/极值/检查NaN)"
    )
    args = parser.parse_args()

    if not os.path.exists(args.file):
        return

    # 加载
    ext = os.path.splitext(args.file)[-1]
    state_dict = (
        load_file(args.file)
        if ext == ".safetensors"
        else torch.load(args.file, map_location="cpu", weights_only=True)
    )

    total_params = 0
    total_bytes = 0
    dtype_counts = Counter()

    print(f"\n🔍 正在分析: {args.file}")
    print(f"{'-' * 80}")
    print(f"{'Key':<50} | {'Shape':<15} | {'Dtype':<10}")
    print(f"{'-' * 80}")

    for k, v in state_dict.items():
        num_params = v.numel()
        total_params += num_params
        total_bytes += num_params * v.element_size()
        dtype_counts[str(v.dtype)] += 1

        # 基础打印
        shape_str = str(list(v.shape))
        print(f"{k[:50]:<50} | {shape_str:<15} | {str(v.dtype):<10}")

        # 数值统计 (可选)
        if args.stat:
            v_float = v.float()
            is_nan = torch.isnan(v_float).any().item()
            print(
                f"   └─ [STAT] Max: {v_float.max():.4f} | Min: {v_float.min():.4f} | Mean: {v_float.mean():.4f} | HasNaN: {is_nan}"
            )

    print(f"{'-' * 80}")
    print(f"📊 汇总报告:")
    print(f"   - 总参数量: {total_params / 1e6:.2f} M (百万)")
    print(f"   - 显存占用: 约 {format_size(total_bytes)}")
    print(f"   - 类型分布: {dict(dtype_counts)}")

    if any("int" in d.lower() for d in dtype_counts.keys()):
        print("   - 注意: 检测到量化权重。")


if __name__ == "__main__":
    inspect_model()
