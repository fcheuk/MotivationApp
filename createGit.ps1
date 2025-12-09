# 创建 .gitignore 文件
Write-Host "正在创建 .gitignore 文件..." -ForegroundColor Yellow
$gitignoreContent = @"
# Xcode
xcuserdata/
*.xcscmblueprint
*.xccheckout
build/
DerivedData/
*.moved-aside
*.pbxuser
!default.pbxuser
*.mode1v3
!default.mode1v3
*.mode2v3
!default.mode2v3
*.perspectivev3
!default.perspectivev3
*.hmap
*.ipa
*.dSYM.zip
*.dSYM
timeline.xctimeline
playground.xcworkspace
.build/
Carthage/Build/
Dependencies/
.accio/
fastlane/report.xml
fastlane/Preview.html
fastlane/screenshots/**/*.png
fastlane/test_output
iOSInjectionProject/
.DS_Store
desktop.ini
Thumbs.db
.vscode/
"@

Set-Content -Path "$baseDir\../.gitignore" -Value $gitignoreContent -Encoding UTF8
Write-Host "✓ .gitignore 文件已创建" -ForegroundColor Green

Write-Host ""
Write-Host "=================================" -ForegroundColor Cyan
Write-Host "项目文件创建完成！" -ForegroundColor Green
Write-Host "=================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "下一步：关联 GitHub 仓库" -ForegroundColor Yellow
Write-Host "运行以下命令：" -ForegroundColor White
Write-Host ""
Write-Host "cd e:\work\fcheuk\motivation" -ForegroundColor Cyan
Write-Host "git init" -ForegroundColor Cyan
Write-Host "git add ." -ForegroundColor Cyan
Write-Host "git commit -m 'Initial commit: MotivationApp iOS project'" -ForegroundColor Cyan
Write-Host "git branch -M main" -ForegroundColor Cyan
Write-Host "git remote add origin https://github.com/fcheuk/MotivationApp.git" -ForegroundColor Cyan
Write-Host "git push -u origin main" -ForegroundColor Cyan
Write-Host ""
