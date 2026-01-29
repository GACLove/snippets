#!/usr/bin/env python3


"""
Query the CUDA devices available on the system.
https://docs.nvidia.com/cuda/cuda-programming-guide/05-appendices/compute-capabilities.html
https://developer.nvidia.com/cuda/gpus

"""

import torch


def detailed_device_query():
    if not torch.cuda.is_available():
        print("CUDA 不可用")
        return

    for i in range(torch.cuda.device_count()):
        p = torch.cuda.get_device_properties(i)

        print(f"--- Device {i}: {p.name} ---")

        # 1. 基础硬件指标
        print(f"  计算能力 (Capability):         {p.major}.{p.minor}")
        print(f"  流处理器数量 (SM Count):      {p.multi_processor_count}")
        print(f"  显存总量 (Total Global Mem):  {p.total_memory / 1024**2:.2f} MB")

        # 2. 修正后的属性访问
        # 注意：使用 max_threads_per_multi_processor 或类似官方命名的属性
        # 如果需要获取 deviceQuery 中的 'Max threads per block'，通常在属性中定义如下：
        try:
            # 尝试通过 dir(p) 匹配出的标准字段
            print(
                f"  每个块最大线程 (Max Threads/Block): 1024"
            )  # 大多数现代显卡固定为 1024
            print(
                f"  每个SM最大线程 (Max Threads/SM):   {p.max_threads_per_multi_processor}"
            )
        except AttributeError:
            pass

        # 3. 核心计算 (H100 基于 Hopper 架构)
        # cuda_cores = get_cuda_cores(p.major, p.minor, p.multi_processor_count)
        # print(f"  估计 CUDA 核心总数:            {cuda_cores}")

        # 4. 显存动态状态
        print(
            f"  当前已分配显存:                {torch.cuda.memory_allocated(i) / 1024**2:.2f} MB"
        )
        print(
            f"  当前保留显存 (Reserved):       {torch.cuda.memory_reserved(i) / 1024**2:.2f} MB"
        )

        # 5. 版本环境
        print(f"  PyTorch 依赖 CUDA 版本:       {torch.version.cuda}")
        print("-" * 40 + "\n")


# def get_cuda_cores(major, minor, sm_count):
#     # Hopper (9.0) 每个 SM 包含 128 个 FP32 单元
#     range_map = {
#         (9, 0): 128, (8, 9): 128, (8, 6): 128, (8, 0): 64,
#         (7, 5): 64, (7, 0): 64, (6, 1): 128, (6, 0): 64
#     }
#     cores_per_sm = range_map.get((major, minor), 128)
#     return cores_per_sm * sm_count

if __name__ == "__main__":
    detailed_device_query()
