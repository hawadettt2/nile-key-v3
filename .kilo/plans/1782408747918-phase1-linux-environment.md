# Phase 1: Linux Environment - Execution Plan

## الأهداف
1. إعداد بيئة WSL2 Ubuntu على Windows 11
2. تثبيت Frappe Bench v5 مع ERPNext v11 متوافق
3. استيراد مشروع nile-key-v3 الحالي
4. تشغيل بيئة التطوير القابلة لإعادة البناء

## القرارات المطلوبة

### 1. مسار المشروع في WSL
- **السؤال:** أين سيتم استضافة مشروع nile-key-v3 داخل WSL؟
- **التوصية:** `~/projects/nile-key-v3` (مسار موحد)

### 2. استراتيجية النسخ الاحتياطي
- **السؤال:** كيف سيتم حفظ النسخ الاحتياطية خارج Deep Freeze؟
- **التوصية:** 
  - Git pushes يومية للكود
  - MariaDB backups إلى Google Drive/OneDrive مشفر
  - حفظ ملفات الـ private/public files

### 3. اختيار النسخة
- **السؤال:** هل نبدأ بـ ERPNext v11 أم نتخطى مباشرة للـ v16؟
- **التوصية:** البدء بـ v11 أولاً لأن جميع DocTypes والـ hooks متوافقة

## خطوات التنفيذ المحددة

### الخطوة 1: تفعيل WSL2
```powershell
# كمسؤول PowerShell
wsl --install --no-distribution
# أعد تشغيل Windows ثم:
wsl --install -d Ubuntu-22.04
```

### الخطوة 2: تثبيت المتطلبات داخل Ubuntu
```bash
sudo apt update && sudo apt upgrade -y
sudo apt install -y \
  git curl wget build-essential \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
  libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev \
  libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  mariadb-server mariadb-client libmariadb-dev \
  redis-server redis-tools \
  wkhtmltopdf xvfb libfontconfig
```

### الخطوة 3: تثبيت Python 3.7.17
```bash
curl https://pyenv.run | bash
# أضف إلى ~/.bashrc
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
exec $SHELL

pyenv install 3.7.17
pyenv global 3.7.17
```

### الخطوة 4: تثبيت Node.js 10.24.1 و Yarn
```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
exec $SHELL

nvm install 10.24.1
nvm use 10.24.1
nvm alias default 10.24.1
npm install -g yarn@1.22.22
```

### الخطوة 5: تثبيت Bench
```bash
pip install --upgrade pip setuptools wheel
pip install "frappe-bench==5.14.1"
```

### الخطوة 6: إنشاء bench directory
```bash
mkdir -p ~/frappe
cd ~/frappe
bench init --frappe-branch version-11 --python "$HOME/.pyenv/versions/3.7.17/bin/python" nile-key-bench
```

### الخطوة 7: استيراد ERPNext المحلي
```bash
cd ~/frappe/nile-key-bench
bench get-app erpnext --branch version-11
```

### الخطوة 8: استيراد مشروع nile-key-v3
```bash
# استنسخ المشروع من Windows إلى WSL
mkdir -p ~/projects
# انسخ من \\wsl$\Ubuntu-22.04\home\projects\nile-key-v3

# استيراد nile_export داخل ERPNext
rsync -a --delete --exclude='.git' ~/projects/nile-key-v3/ apps/erpnext/
```

### الخطوة 9: إنشاء موقع التطوير
```bash
bench new-site nile-key.test \
  --mariadb-root-username nile-key \
  --mariadb-root-password 'secure-password' \
  --admin-password 'admin-password' \
  --install-app erpnext

bench --site nile-key.test set-config developer_mode 1
```

### الخطوة 10: تثبيت nile_export
```bash
cd ~/frappe/nile-key-bench
bench --site nile-key.test install-app nile_export
```

### الخطوة 11: تصدير البيانات إلى قاعدة البيانات
```bash
bench --site nile-key.test export-fixtures
bench --site nile-key.test migrate
```

## اختبار النجاح
- [ ] `bench start` يعمل
- [ ] `http://nile-key.test:8000` يفتح
- [ ] جميع 19 DocTypes موجودة في Module "nile_export"
- [ ] Workflows تعمل
- [ ] الاختباء (`run-tests`) تنجح

## مخاطر وتخفيض

| الخطر | التأثير | التخفيف |
|-------|---------|---------|
| Deep Freeze يمسح WSL | فقدان كل شيء | Git + backups مرتين يومياً |
| Python/Node غير متوافق | فشل البيئة | استخدم النسخ المحددة فقط |
| MariaDB/Redis محلي Windows | عدم استقرار | استخدم MariaDB/Redis داخل WSL |

## مرفقات
- DEVELOPMENT_SETUP.md موجود ومحدث
- scripts/*.sh موجود لكن قد تحتاج مراجعة