#!/usr/bin/env python3
"""
扫描 Wallpapers 目录结构，自动生成 wallpaper_themes.json 和 theme.json

目录结构：
Wallpapers/
├── 01_季节/
│   ├── theme.json (可选，会自动生成)
│   ├── 冬日雪景.jpg
│   └── 秋日暖阳.png
├── 02_风景/
│   ├── 雪山日出.jpg
│   └── ...
└── ...

目录命名规则：序号_主题名
壁纸命名规则：壁纸名.扩展名 (支持 jpg, jpeg, png, webp)
付费标记：文件名以 $ 开头表示付费壁纸，如 $春日星空.jpg

使用方法：
python3 scan_wallpapers.py
"""

import json
import os
import re
from pathlib import Path

# 支持的图片格式
IMAGE_EXTENSIONS = {'.jpg', '.jpeg', '.png', '.webp'}

# 默认主题配置（根据主题名自动匹配图标和颜色）
DEFAULT_THEME_CONFIG = {
    '季节': {'icon': 'leaf.fill', 'colorHex': '#FF9500', 'description': '四季更迭，感受自然之美'},
    '风景': {'icon': 'mountain.2.fill', 'colorHex': '#34C759', 'description': '壮丽山河，心旷神怡'},
    '美食': {'icon': 'fork.knife', 'colorHex': '#FF3B30', 'description': '色香味俱全，治愈你的心'},
    '城市': {'icon': 'building.2.fill', 'colorHex': '#5856D6', 'description': '都市霓虹，繁华夜景'},
    '动物': {'icon': 'pawprint.fill', 'colorHex': '#AF52DE', 'description': '可爱萌宠，治愈心灵'},
    '花卉': {'icon': 'camera.macro', 'colorHex': '#E91E63', 'description': '花开四季，芬芳满园'},
    '海洋': {'icon': 'water.waves', 'colorHex': '#00BCD4', 'description': '碧海蓝天，心旷神怡'},
    '星空': {'icon': 'star.fill', 'colorHex': '#3F51B5', 'description': '璀璨星河，浩瀚宇宙'},
}

# 默认配置
DEFAULT_CONFIG = {'icon': 'photo', 'colorHex': '#007AFF', 'description': ''}

def generate_uuid(prefix: int, index: int) -> str:
    """生成格式化的 UUID"""
    return f"{prefix:0>8}-0000-0000-0000-{index:0>12}"

def parse_theme_dir_name(dir_name: str) -> tuple:
    """解析目录名，返回 (序号, 主题名, 是否付费)"""
    # 格式：序号_主题名 或 序号_$主题名（付费）
    match = re.match(r'^(\d+)_(\$?)(.+)$', dir_name)
    if match:
        return int(match.group(1)), match.group(3), match.group(2) == '$'
    return 0, dir_name, False

def parse_wallpaper_file_name(file_name: str) -> tuple:
    """解析壁纸文件名，返回 (壁纸名, 是否付费)"""
    stem = Path(file_name).stem
    if stem.startswith('$'):
        return stem[1:], True
    return stem, False

def scan_images_in_dir(theme_dir: Path) -> list:
    """扫描目录中的图片文件"""
    images = []
    for f in sorted(theme_dir.iterdir()):
        if f.is_file() and f.suffix.lower() in IMAGE_EXTENSIONS:
            name, is_premium = parse_wallpaper_file_name(f.name)
            images.append({
                'name': name,
                'file': f.stem.lstrip('$'),  # 去掉 $ 前缀作为资源名
                'isPremium': is_premium
            })
    return images

def scan_wallpapers():
    # 获取路径
    script_dir = Path(__file__).parent
    project_root = script_dir.parent
    wallpapers_dir = script_dir / 'Wallpapers'
    output_path = project_root / 'MotivationApp' / 'Resources' / 'wallpaper_themes.json'
    
    if not wallpapers_dir.exists():
        print(f'❌ 目录不存在: {wallpapers_dir}')
        return
    
    themes = []
    wallpapers = []
    
    # 扫描主题目录（按目录名排序）
    theme_dirs = sorted([d for d in wallpapers_dir.iterdir() if d.is_dir()])
    
    for theme_dir in theme_dirs:
        # 解析目录名
        theme_index, theme_name, theme_is_premium = parse_theme_dir_name(theme_dir.name)
        if theme_index == 0:
            print(f'⚠️ 跳过目录 {theme_dir.name}：目录名格式不正确（应为 序号_主题名）')
            continue
        
        theme_json_path = theme_dir / 'theme.json'
        
        # 扫描目录中的图片
        scanned_images = scan_images_in_dir(theme_dir)
        
        # 读取或生成主题配置
        if theme_json_path.exists():
            with open(theme_json_path, 'r', encoding='utf-8') as f:
                theme_config = json.load(f)
        else:
            # 自动生成 theme.json
            default = DEFAULT_THEME_CONFIG.get(theme_name, DEFAULT_CONFIG)
            theme_config = {
                'name': theme_name,
                'icon': default['icon'],
                'colorHex': default['colorHex'],
                'description': default['description'],
                'isPremium': theme_is_premium,
                'wallpapers': scanned_images
            }
            # 保存生成的 theme.json
            with open(theme_json_path, 'w', encoding='utf-8') as f:
                json.dump(theme_config, f, ensure_ascii=False, indent=2)
            print(f'📝 已生成: {theme_json_path}')
        
        # 如果 theme.json 中没有 wallpapers 或为空，使用扫描到的图片
        wallpaper_configs = theme_config.get('wallpapers', [])
        if not wallpaper_configs and scanned_images:
            wallpaper_configs = scanned_images
            # 更新 theme.json
            theme_config['wallpapers'] = wallpaper_configs
            with open(theme_json_path, 'w', encoding='utf-8') as f:
                json.dump(theme_config, f, ensure_ascii=False, indent=2)
            print(f'📝 已更新壁纸列表: {theme_json_path}')
        
        # 生成主题 ID
        theme_id = generate_uuid(theme_index, 1)
        
        # 构建主题数据
        theme = {
            'id': theme_id,
            'name': theme_config.get('name', theme_name),
            'icon': theme_config.get('icon', 'photo'),
            'colorHex': theme_config.get('colorHex', '#007AFF'),
            'description': theme_config.get('description', ''),
            'isPremium': theme_config.get('isPremium', theme_is_premium)
        }
        themes.append(theme)
        
        # 处理壁纸
        for wp_index, wp_config in enumerate(wallpaper_configs, start=1):
            wallpaper_id = generate_uuid(theme_index * 10, wp_index)
            
            wallpaper = {
                'id': wallpaper_id,
                'themeId': theme_id,
                'name': wp_config.get('name', f'壁纸{wp_index}'),
                'imageName': wp_config.get('file', ''),
                'isPremium': wp_config.get('isPremium', False)
            }
            wallpapers.append(wallpaper)
        
        print(f'✅ {theme_dir.name}: {len(wallpaper_configs)} 张壁纸')
    
    # 生成输出
    output_data = {
        'themes': themes,
        'wallpapers': wallpapers
    }
    
    # 写入文件
    with open(output_path, 'w', encoding='utf-8') as f:
        json.dump(output_data, f, ensure_ascii=False, indent=2)
    
    print(f'\n📦 已生成: {output_path}')
    print(f'   - 主题: {len(themes)} 个')
    print(f'   - 壁纸: {len(wallpapers)} 张')

if __name__ == '__main__':
    scan_wallpapers()
