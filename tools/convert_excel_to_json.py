#!/usr/bin/env python3
"""
将 Excel 文件转换为 wallpaper_themes.json
用于编辑 Excel 后重新生成 JSON 数据文件
"""

import json
import pandas as pd
import os
import sys

def excel_to_json(excel_path=None):
    # 获取脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    # 如果没有指定 Excel 文件，查找最新的
    if excel_path is None:
        excel_files = [f for f in os.listdir(script_dir) if f.startswith('wallpaper_themes_') and f.endswith('.xlsx')]
        if not excel_files:
            print('❌ 未找到 wallpaper_themes_*.xlsx 文件')
            print('   请先运行 convert_themes_to_excel.py 生成 Excel 文件')
            return
        excel_files.sort(reverse=True)
        excel_path = os.path.join(script_dir, excel_files[0])
    
    print(f'📖 读取 Excel 文件: {excel_path}')
    
    # 读取 Excel 文件
    themes_df = pd.read_excel(excel_path, sheet_name='themes')
    wallpapers_df = pd.read_excel(excel_path, sheet_name='wallpapers')
    
    # 转换为字典列表
    themes = themes_df.to_dict(orient='records')
    wallpapers = wallpapers_df.to_dict(orient='records')
    
    # 处理布尔值（Excel 可能读取为 True/False 或 1/0）
    for theme in themes:
        theme['isPremium'] = bool(theme.get('isPremium', False))
    
    for wallpaper in wallpapers:
        wallpaper['isPremium'] = bool(wallpaper.get('isPremium', False))
    
    # 构建 JSON 数据
    data = {
        'themes': themes,
        'wallpapers': wallpapers
    }
    
    # 输出 JSON 文件路径
    json_path = os.path.join(project_root, 'MotivationApp', 'Resources', 'wallpaper_themes.json')
    
    # 写入 JSON 文件
    with open(json_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)
    
    print(f'✅ JSON 文件已生成: {json_path}')
    print(f'   - themes: {len(themes)} 条')
    print(f'   - wallpapers: {len(wallpapers)} 条')

if __name__ == '__main__':
    excel_path = sys.argv[1] if len(sys.argv) > 1 else None
    excel_to_json(excel_path)
