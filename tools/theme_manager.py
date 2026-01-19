#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
主题和壁纸管理工具
用于可视化管理 Motivation App 的主题分类和壁纸数据
"""

import tkinter as tk
from tkinter import ttk, messagebox, colorchooser, filedialog
import json
import os
from datetime import datetime
import re

class ThemeManagerApp:
    def __init__(self, root):
        self.root = root
        self.root.title("Motivation 主题和壁纸管理工具")
        self.root.geometry("1200x800")
        
        # 数据存储
        self.categories = []
        self.wallpapers = []
        self.project_path = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
        
        # 加载现有数据
        self.load_data()
        
        # 创建界面
        self.create_widgets()
        
    def create_widgets(self):
        # 创建主容器
        main_container = ttk.PanedWindow(self.root, orient=tk.HORIZONTAL)
        main_container.pack(fill=tk.BOTH, expand=True, padx=10, pady=10)
        
        # 左侧：主题分类管理
        left_frame = ttk.Frame(main_container)
        main_container.add(left_frame, weight=1)
        
        # 右侧：壁纸管理
        right_frame = ttk.Frame(main_container)
        main_container.add(right_frame, weight=1)
        
        # 创建主题分类管理界面
        self.create_category_section(left_frame)
        
        # 创建壁纸管理界面
        self.create_wallpaper_section(right_frame)
        
        # 底部按钮
        self.create_bottom_buttons()
        
    def create_category_section(self, parent):
        # 标题
        title = ttk.Label(parent, text="主题分类管理", font=("Arial", 16, "bold"))
        title.pack(pady=10)
        
        # 按钮区域
        btn_frame = ttk.Frame(parent)
        btn_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Button(btn_frame, text="➕ 新增主题", command=self.add_category).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="✏️ 编辑主题", command=self.edit_category).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="🗑️ 删除主题", command=self.delete_category).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="🔄 重新加载", command=self.reload_from_swift).pack(side=tk.LEFT, padx=5)
        
        # 列表区域
        list_frame = ttk.Frame(parent)
        list_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        # 创建 Treeview
        columns = ("名称", "类型", "图标", "颜色", "标签")
        self.category_tree = ttk.Treeview(list_frame, columns=columns, show="headings", height=15)
        
        for col in columns:
            self.category_tree.heading(col, text=col)
            self.category_tree.column(col, width=100)
        
        # 滚动条
        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.category_tree.yview)
        self.category_tree.configure(yscrollcommand=scrollbar.set)
        
        self.category_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # 加载数据到列表
        self.refresh_category_list()
        
    def create_wallpaper_section(self, parent):
        # 标题
        title = ttk.Label(parent, text="壁纸管理", font=("Arial", 16, "bold"))
        title.pack(pady=10)
        
        # 按钮区域
        btn_frame = ttk.Frame(parent)
        btn_frame.pack(fill=tk.X, padx=10, pady=5)
        
        ttk.Button(btn_frame, text="➕ 新增壁纸", command=self.add_wallpaper).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="✏️ 编辑壁纸", command=self.edit_wallpaper).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="🗑️ 删除壁纸", command=self.delete_wallpaper).pack(side=tk.LEFT, padx=5)
        
        # 列表区域
        list_frame = ttk.Frame(parent)
        list_frame.pack(fill=tk.BOTH, expand=True, padx=10, pady=5)
        
        # 创建 Treeview
        columns = ("名称", "主题ID", "图片文件", "是否锁定")
        self.wallpaper_tree = ttk.Treeview(list_frame, columns=columns, show="headings", height=15)
        
        for col in columns:
            self.wallpaper_tree.heading(col, text=col)
            self.wallpaper_tree.column(col, width=100)
        
        # 滚动条
        scrollbar = ttk.Scrollbar(list_frame, orient=tk.VERTICAL, command=self.wallpaper_tree.yview)
        self.wallpaper_tree.configure(yscrollcommand=scrollbar.set)
        
        self.wallpaper_tree.pack(side=tk.LEFT, fill=tk.BOTH, expand=True)
        scrollbar.pack(side=tk.RIGHT, fill=tk.Y)
        
        # 加载数据到列表
        self.refresh_wallpaper_list()
        
    def create_bottom_buttons(self):
        bottom_frame = ttk.Frame(self.root)
        bottom_frame.pack(fill=tk.X, padx=10, pady=10)
        
        ttk.Button(bottom_frame, text="💾 保存数据", command=self.save_data).pack(side=tk.LEFT, padx=5)
        ttk.Button(bottom_frame, text="📤 导出 Swift 代码", command=self.export_swift_code).pack(side=tk.LEFT, padx=5)
        ttk.Button(bottom_frame, text="📁 打开项目目录", command=self.open_project_folder).pack(side=tk.LEFT, padx=5)
        
    def add_category(self):
        dialog = CategoryDialog(self.root, "新增主题分类")
        if dialog.result:
            self.categories.append(dialog.result)
            self.refresh_category_list()
            messagebox.showinfo("成功", "主题分类已添加")
            
    def edit_category(self):
        selection = self.category_tree.selection()
        if not selection:
            messagebox.showwarning("警告", "请先选择一个主题分类")
            return
            
        index = self.category_tree.index(selection[0])
        category = self.categories[index]
        
        dialog = CategoryDialog(self.root, "编辑主题分类", category)
        if dialog.result:
            self.categories[index] = dialog.result
            self.refresh_category_list()
            messagebox.showinfo("成功", "主题分类已更新")
            
    def delete_category(self):
        selection = self.category_tree.selection()
        if not selection:
            messagebox.showwarning("警告", "请先选择一个主题分类")
            return
            
        if messagebox.askyesno("确认", "确定要删除这个主题分类吗？"):
            index = self.category_tree.index(selection[0])
            del self.categories[index]
            self.refresh_category_list()
            messagebox.showinfo("成功", "主题分类已删除")
            
    def add_wallpaper(self):
        dialog = WallpaperDialog(self.root, "新增壁纸", self.categories)
        if dialog.result:
            self.wallpapers.append(dialog.result)
            self.refresh_wallpaper_list()
            messagebox.showinfo("成功", "壁纸已添加")
            
    def edit_wallpaper(self):
        selection = self.wallpaper_tree.selection()
        if not selection:
            messagebox.showwarning("警告", "请先选择一个壁纸")
            return
            
        index = self.wallpaper_tree.index(selection[0])
        wallpaper = self.wallpapers[index]
        
        dialog = WallpaperDialog(self.root, "编辑壁纸", self.categories, wallpaper)
        if dialog.result:
            self.wallpapers[index] = dialog.result
            self.refresh_wallpaper_list()
            messagebox.showinfo("成功", "壁纸已更新")
            
    def delete_wallpaper(self):
        selection = self.wallpaper_tree.selection()
        if not selection:
            messagebox.showwarning("警告", "请先选择一个壁纸")
            return
            
        if messagebox.askyesno("确认", "确定要删除这个壁纸吗？"):
            index = self.wallpaper_tree.index(selection[0])
            del self.wallpapers[index]
            self.refresh_wallpaper_list()
            messagebox.showinfo("成功", "壁纸已删除")
            
    def refresh_category_list(self):
        # 清空列表
        for item in self.category_tree.get_children():
            self.category_tree.delete(item)
            
        # 添加数据
        for cat in self.categories:
            self.category_tree.insert("", tk.END, values=(
                cat.get("name", ""),
                cat.get("type", ""),
                cat.get("icon", ""),
                cat.get("colorHex", ""),
                ", ".join(cat.get("tags", []))
            ))
            
    def refresh_wallpaper_list(self):
        # 清空列表
        for item in self.wallpaper_tree.get_children():
            self.wallpaper_tree.delete(item)
            
        # 添加数据
        for wp in self.wallpapers:
            self.wallpaper_tree.insert("", tk.END, values=(
                wp.get("name", ""),
                wp.get("themeId", ""),
                wp.get("imageName", ""),
                "是" if wp.get("isLocked", False) else "否"
            ))
            
    def load_data(self):
        """加载数据：优先从 JSON，否则从 Swift 文件解析"""
        data_file = os.path.join(self.project_path, "tools", "theme_data.json")
        if os.path.exists(data_file):
            try:
                with open(data_file, "r", encoding="utf-8") as f:
                    data = json.load(f)
                    self.categories = data.get("categories", [])
                    self.wallpapers = data.get("wallpapers", [])
                print(f"从 JSON 加载了 {len(self.categories)} 个主题和 {len(self.wallpapers)} 个壁纸")
                return
            except Exception as e:
                print(f"加载 JSON 数据失败: {str(e)}")
        
        # 如果 JSON 不存在，尝试从 Swift 文件解析
        print("JSON 文件不存在，尝试从 Swift 文件加载数据...")
        self.load_from_swift_files()
    
    def reload_from_swift(self):
        """重新从 Swift 文件加载数据"""
        if messagebox.askyesno("确认", "这将从 Swift 文件重新加载数据，当前未保存的更改将丢失。确定继续吗？"):
            self.load_from_swift_files()
            self.refresh_category_list()
            self.refresh_wallpaper_list()
            messagebox.showinfo("成功", f"已从 Swift 文件加载 {len(self.categories)} 个主题")
                
    def save_data(self):
        """保存到 JSON 文件"""
        data_file = os.path.join(self.project_path, "tools", "theme_data.json")
        os.makedirs(os.path.dirname(data_file), exist_ok=True)
        
        try:
            data = {
                "categories": self.categories,
                "wallpapers": self.wallpapers,
                "updated_at": datetime.now().isoformat()
            }
            with open(data_file, "w", encoding="utf-8") as f:
                json.dump(data, f, ensure_ascii=False, indent=2)
            messagebox.showinfo("成功", "数据已保存")
        except Exception as e:
            messagebox.showerror("错误", f"保存数据失败: {str(e)}")
    
    def load_from_swift_files(self):
        """从 Swift 源文件中解析主题和壁纸数据"""
        try:
            # 加载主题分类
            category_file = os.path.join(self.project_path, "MotivationApp", "Models", "Category.swift")
            if os.path.exists(category_file):
                self.categories = self.parse_categories_from_swift(category_file)
                print(f"从 Category.swift 加载了 {len(self.categories)} 个主题")
            else:
                print(f"未找到文件: {category_file}")
                    
        except Exception as e:
            print(f"从 Swift 文件加载数据时出错: {str(e)}")
            messagebox.showwarning("警告", f"无法从 Swift 文件加载数据: {str(e)}\n\n将从空数据开始")
    
    def parse_categories_from_swift(self, file_path):
        """解析 Category.swift 文件中的主题数据"""
        categories = []
        
        try:
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()
            
            # 查找 sampleCategories 数组
            pattern = r'static let sampleCategories.*?=\s*\[(.*?)\n    \]'
            match = re.search(pattern, content, re.DOTALL)
            
            if not match:
                print("未找到 sampleCategories 数组")
                return categories
            
            array_content = match.group(1)
            
            # 解析每个 Category 对象
            category_pattern = r'Category\((.*?)\n        \)(?=,|\s*$)'
            category_matches = re.finditer(category_pattern, array_content, re.DOTALL)
            
            for cat_match in category_matches:
                cat_content = cat_match.group(1)
                category = self.parse_category_object(cat_content)
                if category:
                    categories.append(category)
            
            print(f"成功解析 {len(categories)} 个主题分类")
            
        except Exception as e:
            print(f"解析 Category.swift 失败: {str(e)}")
            import traceback
            traceback.print_exc()
        
        return categories
    
    def parse_category_object(self, content):
        """解析单个 Category 对象"""
        category = {}
        
        try:
            # 解析各个字段
            patterns = {
                'name': r'name:\s*"([^"]+)"',
                'icon': r'icon:\s*"([^"]+)"',
                'colorHex': r'colorHex:\s*"([^"]+)"',
                'description': r'description:\s*"([^"]+)"',
                'imageName': r'imageName:\s*"([^"]+)"',
                'type': r'type:\s*\.(\w+)',
                'isNew': r'isNew:\s*(true|false)',
                'isFeatured': r'isFeatured:\s*(true|false)',
            }
            
            for key, pattern in patterns.items():
                match = re.search(pattern, content)
                if match:
                    value = match.group(1)
                    if key in ['isNew', 'isFeatured']:
                        category[key] = (value == 'true')
                    else:
                        category[key] = value
                else:
                    # 设置默认值
                    if key == 'imageName':
                        category[key] = ""
                    elif key == 'type':
                        category[key] = 'normal'
                    elif key in ['isNew', 'isFeatured']:
                        category[key] = False
            
            # 解析 tags 数组
            tags_match = re.search(r'tags:\s*\[([^\]]+)\]', content)
            if tags_match:
                tags_str = tags_match.group(1)
                tags = re.findall(r'"([^"]+)"', tags_str)
                category['tags'] = tags
            else:
                category['tags'] = []
            
            return category if category.get('name') else None
            
        except Exception as e:
            print(f"解析 Category 对象失败: {str(e)}")
            return None
            
    def export_swift_code(self):
        """生成并导出 Swift 代码"""
        swift_code = self.generate_swift_code()
        
        output_file = filedialog.asksaveasfilename(
            defaultextension=".swift",
            filetypes=[("Swift files", "*.swift"), ("All files", "*.*")],
            initialfile="GeneratedThemeData.swift"
        )
        
        if output_file:
            try:
                with open(output_file, "w", encoding="utf-8") as f:
                    f.write(swift_code)
                messagebox.showinfo("成功", f"Swift 代码已导出到:\n{output_file}")
            except Exception as e:
                messagebox.showerror("错误", f"导出失败: {str(e)}")
                
    def generate_swift_code(self):
        """生成 Swift 代码"""
        # 生成主题分类的 Swift 代码
        categories_code = "    static let sampleCategories: [Category] = [\n"
        for cat in self.categories:
            tags_str = ', '.join([f'"{tag}"' for tag in cat.get('tags', [])])
            categories_code += f"""        Category(
            name: "{cat.get('name', '')}",
            icon: "{cat.get('icon', '')}",
            colorHex: "{cat.get('colorHex', '')}",
            description: "{cat.get('description', '')}",
            imageName: "{cat.get('imageName', '')}",
            type: .{cat.get('type', 'normal')},
            isNew: {str(cat.get('isNew', False)).lower()},
            isFeatured: {str(cat.get('isFeatured', False)).lower()},
            tags: [{tags_str}]
        ),\n"""
        categories_code += "    ]\n"
        
        # 完整的 Swift 文件
        swift_code = f"""//
//  GeneratedThemeData.swift
//  MotivationApp
//
//  Auto-generated on {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
//

import Foundation
import SwiftUI

// MARK: - Category Sample Data
extension Category {{
{categories_code}
}}
"""
        return swift_code
        
    def open_project_folder(self):
        """打开项目文件夹"""
        import subprocess
        import platform
        
        try:
            if platform.system() == "Windows":
                os.startfile(self.project_path)
            elif platform.system() == "Darwin":  # macOS
                subprocess.run(["open", self.project_path])
            else:  # Linux
                subprocess.run(["xdg-open", self.project_path])
        except Exception as e:
            messagebox.showerror("错误", f"无法打开文件夹: {str(e)}")


class CategoryDialog:
    def __init__(self, parent, title, data=None):
        self.result = None
        self.dialog = tk.Toplevel(parent)
        self.dialog.title(title)
        self.dialog.geometry("500x600")
        self.dialog.transient(parent)
        self.dialog.grab_set()
        
        self.data = data or {}
        self.create_form()
        self.dialog.wait_window()
        
    def create_form(self):
        frame = ttk.Frame(self.dialog, padding=20)
        frame.pack(fill=tk.BOTH, expand=True)
        
        # 名称
        ttk.Label(frame, text="名称:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.name_var = tk.StringVar(value=self.data.get("name", ""))
        ttk.Entry(frame, textvariable=self.name_var, width=40).grid(row=0, column=1, pady=5)
        
        # 图标
        ttk.Label(frame, text="图标 (SF Symbol):").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.icon_var = tk.StringVar(value=self.data.get("icon", ""))
        ttk.Entry(frame, textvariable=self.icon_var, width=40).grid(row=1, column=1, pady=5)
        
        # 颜色
        ttk.Label(frame, text="颜色 (Hex):").grid(row=2, column=0, sticky=tk.W, pady=5)
        color_frame = ttk.Frame(frame)
        color_frame.grid(row=2, column=1, pady=5, sticky=tk.W)
        self.color_var = tk.StringVar(value=self.data.get("colorHex", "#FF6B6B"))
        ttk.Entry(color_frame, textvariable=self.color_var, width=30).pack(side=tk.LEFT)
        ttk.Button(color_frame, text="选择", command=self.choose_color).pack(side=tk.LEFT, padx=5)
        
        # 描述
        ttk.Label(frame, text="描述:").grid(row=3, column=0, sticky=tk.W, pady=5)
        self.desc_var = tk.StringVar(value=self.data.get("description", ""))
        ttk.Entry(frame, textvariable=self.desc_var, width=40).grid(row=3, column=1, pady=5)
        
        # 图片名称
        ttk.Label(frame, text="图片名称:").grid(row=4, column=0, sticky=tk.W, pady=5)
        self.image_var = tk.StringVar(value=self.data.get("imageName", ""))
        ttk.Entry(frame, textvariable=self.image_var, width=40).grid(row=4, column=1, pady=5)
        
        # 类型
        ttk.Label(frame, text="类型:").grid(row=5, column=0, sticky=tk.W, pady=5)
        self.type_var = tk.StringVar(value=self.data.get("type", "normal"))
        type_combo = ttk.Combobox(frame, textvariable=self.type_var, 
                                  values=["normal", "combined", "seasonal"], width=37)
        type_combo.grid(row=5, column=1, pady=5)
        
        # 是否新主题
        self.is_new_var = tk.BooleanVar(value=self.data.get("isNew", False))
        ttk.Checkbutton(frame, text="新主题", variable=self.is_new_var).grid(row=6, column=1, sticky=tk.W, pady=5)
        
        # 是否推荐
        self.is_featured_var = tk.BooleanVar(value=self.data.get("isFeatured", False))
        ttk.Checkbutton(frame, text="推荐主题", variable=self.is_featured_var).grid(row=7, column=1, sticky=tk.W, pady=5)
        
        # 标签
        ttk.Label(frame, text="标签 (逗号分隔):").grid(row=8, column=0, sticky=tk.W, pady=5)
        self.tags_var = tk.StringVar(value=", ".join(self.data.get("tags", [])))
        ttk.Entry(frame, textvariable=self.tags_var, width=40).grid(row=8, column=1, pady=5)
        
        # 按钮
        btn_frame = ttk.Frame(frame)
        btn_frame.grid(row=9, column=0, columnspan=2, pady=20)
        ttk.Button(btn_frame, text="确定", command=self.on_ok).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="取消", command=self.dialog.destroy).pack(side=tk.LEFT, padx=5)
        
    def choose_color(self):
        color = colorchooser.askcolor(title="选择颜色")
        if color[1]:
            self.color_var.set(color[1].upper())
            
    def on_ok(self):
        if not self.name_var.get():
            messagebox.showwarning("警告", "请输入名称")
            return
            
        tags = [tag.strip() for tag in self.tags_var.get().split(",") if tag.strip()]
        
        self.result = {
            "name": self.name_var.get(),
            "icon": self.icon_var.get(),
            "colorHex": self.color_var.get(),
            "description": self.desc_var.get(),
            "imageName": self.image_var.get(),
            "type": self.type_var.get(),
            "isNew": self.is_new_var.get(),
            "isFeatured": self.is_featured_var.get(),
            "tags": tags
        }
        
        self.dialog.destroy()


class WallpaperDialog:
    def __init__(self, parent, title, categories, data=None):
        self.result = None
        self.dialog = tk.Toplevel(parent)
        self.dialog.title(title)
        self.dialog.geometry("500x400")
        self.dialog.transient(parent)
        self.dialog.grab_set()
        
        self.data = data or {}
        self.categories = categories
        self.create_form()
        self.dialog.wait_window()
        
    def create_form(self):
        frame = ttk.Frame(self.dialog, padding=20)
        frame.pack(fill=tk.BOTH, expand=True)
        
        # 名称
        ttk.Label(frame, text="名称:").grid(row=0, column=0, sticky=tk.W, pady=5)
        self.name_var = tk.StringVar(value=self.data.get("name", ""))
        ttk.Entry(frame, textvariable=self.name_var, width=40).grid(row=0, column=1, pady=5)
        
        # 主题ID
        ttk.Label(frame, text="关联主题:").grid(row=1, column=0, sticky=tk.W, pady=5)
        self.theme_var = tk.StringVar(value=self.data.get("themeId", ""))
        theme_names = [cat.get("name", "") for cat in self.categories]
        theme_combo = ttk.Combobox(frame, textvariable=self.theme_var, values=theme_names, width=37)
        theme_combo.grid(row=1, column=1, pady=5)
        
        # 图片文件
        ttk.Label(frame, text="图片文件名:").grid(row=2, column=0, sticky=tk.W, pady=5)
        image_frame = ttk.Frame(frame)
        image_frame.grid(row=2, column=1, pady=5, sticky=tk.W)
        self.image_var = tk.StringVar(value=self.data.get("imageName", ""))
        ttk.Entry(image_frame, textvariable=self.image_var, width=30).pack(side=tk.LEFT)
        ttk.Button(image_frame, text="浏览", command=self.browse_image).pack(side=tk.LEFT, padx=5)
        
        # 是否锁定
        self.is_locked_var = tk.BooleanVar(value=self.data.get("isLocked", False))
        ttk.Checkbutton(frame, text="需要解锁", variable=self.is_locked_var).grid(row=3, column=1, sticky=tk.W, pady=5)
        
        # 按钮
        btn_frame = ttk.Frame(frame)
        btn_frame.grid(row=4, column=0, columnspan=2, pady=20)
        ttk.Button(btn_frame, text="确定", command=self.on_ok).pack(side=tk.LEFT, padx=5)
        ttk.Button(btn_frame, text="取消", command=self.dialog.destroy).pack(side=tk.LEFT, padx=5)
        
    def browse_image(self):
        filename = filedialog.askopenfilename(
            title="选择图片",
            filetypes=[("Image files", "*.jpg *.jpeg *.png"), ("All files", "*.*")]
        )
        if filename:
            basename = os.path.splitext(os.path.basename(filename))[0]
            self.image_var.set(basename)
            
    def on_ok(self):
        if not self.name_var.get():
            messagebox.showwarning("警告", "请输入名称")
            return
            
        self.result = {
            "name": self.name_var.get(),
            "themeId": self.theme_var.get(),
            "imageName": self.image_var.get(),
            "isLocked": self.is_locked_var.get()
        }
        
        self.dialog.destroy()


def main():
    root = tk.Tk()
    app = ThemeManagerApp(root)
    root.mainloop()


if __name__ == "__main__":
    main()
