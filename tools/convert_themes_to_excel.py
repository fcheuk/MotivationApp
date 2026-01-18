#!/usr/bin/env python3
"""
将 wallpaper_themes.json 转换为 Excel 文件
"""

import json
import pandas as pd
from datetime import datetime
import os

def json_to_excel():
    # 获取脚本所在目录
    script_dir = os.path.dirname(os.path.abspath(__file__))
    project_root = os.path.dirname(script_dir)
    
    # JSON 文件路径
    json_path = os.path.join(project_root, 'MotivationApp', 'Resources', 'wallpaper_themes.json')
    
    # 读取 JSON 文件
    with open(json_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    # 转换主题数据
    themes_df = pd.DataFrame(data['themes'])
    themes_df = themes_df[['id', 'name', 'icon', 'colorHex', 'description', 'isPremium']]
    
    # 转换壁纸数据
    wallpapers_df = pd.DataFrame(data['wallpapers'])
    wallpapers_df = wallpapers_df[['id', 'themeId', 'name', 'imageName', 'isPremium']]
    
    # 生成输出文件名
    timestamp = datetime.now().strftime('%Y%m%d_%H%M%S')
    output_path = os.path.join(script_dir, f'wallpaper_themes_{timestamp}.xlsx')
    
    # 写入 Excel 文件（两个 sheet）
    with pd.ExcelWriter(output_path, engine='openpyxl') as writer:
        themes_df.to_excel(writer, sheet_name='themes', index=False)
        wallpapers_df.to_excel(writer, sheet_name='wallpapers', index=False)
    
    print(f'✅ Excel 文件已生成: {output_path}')
    print(f'   - themes: {len(themes_df)} 条')
    print(f'   - wallpapers: {len(wallpapers_df)} 条')

if __name__ == '__main__':
    json_to_excel()
