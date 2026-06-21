# RECOVERY_RUNBOOK.md

## دليل الاستعادة التشغيلية لمشروع ile-key-v3

**الغرض:** استعادة بيئة تطوير Frappe/ERPNext فوراً بعد أي فقدان للبيئة المحلية بسبب Deep Freeze أو فشل الجهاز أو حذف WSL/MariaDB/Redis/Bench.

**المستودع الرسمي:**

```text
https://github.com/hawadettt2/nile-key-v3.git
```

**الوثيقة الاستراتيجية الأم:**

```text
MASTER_ROADMAP.md
```

---

## 0. المبدأ الحاسم

على جهاز Windows 11 المحمي بـ Deep Freeze:

> أي شيء غير موجود في GitHub أو Backup خارجي موثوق يعتبر مفقوداً.

لذلك يجب الالتزام بالآتي:

```text
الكود والوثائق        -> GitHub
قاعدة البيانات       -> backup خارجي مشفر
الملفات والمرفقات     -> backup خارجي مشفر
كلمات المرور والمفاتيح -> Secrets Manager أو ملف محمي خارج Git
```

لا تضع أبداً داخل Git:

```text
.env
site_config.json الحقيقي
كلمات مرور MariaDB
كلمات مرور Administrator
مفاتيح API
مفاتيح Supabase
مفاتيح SMTP
مفاتيح Payment Gateway
نسخ database production غير مشفرة
```

---

## 1. الاستعادة السريعة من الصفر

### 1.1 تثبيت WSL/Ubuntu

من PowerShell كمسؤول:

```powershell
wsl --install -d Ubuntu
```

بعد التثبيت، افتح Ubuntu وأنشئ مستخدم Linux غير root، ثم حدّث الحزم:

```bash
sudo apt update
sudo apt upgrade -y
```

### 1.2 تثبيت المتطلبات الأساسية

```bash
sudo apt install -y \
  git curl wget build-essential \
  libssl-dev zlib1g-dev libbz2-dev libreadline-dev \
  libsqlite3-dev llvm libncursesw5-dev xz-utils tk-dev \
  libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev \
  mariadb-server mariadb-client libmariadb-dev \
  redis-server redis-tools \
  wkhtmltopdf xvfb libfontconfig
```

### 1.3 تثبيت Python

لـ ERPNext v11 الحالي استخدم Python 3.7.17.

```bash
curl https://pyenv.run | bash
```

أضف pyenv إلى shell:

```bash
cat >> ~/.bashrc <<'EOF'
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF

exec $SHELL
```

ثبّت Python:

```bash
pyenv install 3.7.17
pyenv global 3.7.17
python --version
```

### 1.4 تثبيت Node.js

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
exec $SHELL

nvm install 10.24.1
nvm use 10.24.1
nvm alias default 10.24.1
npm install -g yarn@1.22.22
```

### 1.5 تثبيت Bench

```bash
python -m pip install --upgrade pip setuptools wheel
pip install "frappe-bench==5.14.1"
bench --version
```

---

## 2. تجهيز MariaDB و Redis

### 2.1 MariaDB

```bash
sudo systemctl enable mariadb
sudo systemctl start mariadb
sudo mariadb-secure-installation
```

أنشئ مستخدم تطوير مخصص، مثال:

```bash
sudo mariadb -u root
```

داخل MariaDB:

```sql
CREATE USER IF NOT EXISTS 'nile-key'@'localhost'
IDENTIFIED BY 'PUT_STRONG_PASSWORD_HERE';

GRANT ALL PRIVILEGES ON *.* TO 'nile-key'@'localhost'
WITH GRANT OPTION;

FLUSH PRIVILEGES;
EXIT;
```

### 2.2 Redis

```bash
sudo systemctl enable redis-server
sudo systemctl start redis-server
redis-cli ping
```

المتوقع:

```text
PONG
```

---

## 3. استنساخ المستودع

```bash
mkdir -p ~/projects
cd ~/projects

git clone https://github.com/hawadettt2/nile-key-v3.git
cd nile-key-v3
```

تحقق من الوثائق الأساسية:

```text
README.md
MASTER_ROADMAP.md
RECOVERY_RUNBOOK.md
```

---

## 4. إنشاء Bench واستيراد تطبيق ERPNext الحالي

### 4.1 إنشاء bench

```bash
mkdir -p ~/frappe
cd ~/frappe

bench init \
  --frappe-branch version-11 \
  --python "$HOME/.pyenv/versions/3.7.17/bin/python" \
  nile-key-bench

cd ~/frappe/nile-key-bench
```

### 4.2 جلب ERPNext الأساسي

```bash
bench get-app erpnext --branch version-11
```

### 4.3 استبدال `apps/erpnext` بنسخة المشروع

من داخل bench:

```bash
rsync -a --delete --exclude='.git' ~/projects/nile-key-v3/ apps/erpnext/
bench setup requirements
bench build
```

إذا ظهرت أخطاء توافق مكتبات حديثة:

```bash
bench pip install \
  "click==7.1.2" \
  "Werkzeug==0.16.1" \
  "Jinja2==2.11.3" \
  "MarkupSafe==2.0.1" \
  "itsdangerous==1.1.0" \
  "urllib3==1.26.18"

bench build
```

---

## 5. إنشاء Site جديد بدون بيانات

```bash
bench new-site nile-key.test \
  --mariadb-root-username nile-key \
  --mariadb-root-password 'PUT_STRONG_PASSWORD_HERE' \
  --admin-password 'PUT_ADMIN_PASSWORD_HERE' \
  --install-app erpnext

bench --site nile-key.test set-config developer_mode 1
bench --site nile-key.test set-config host_name "http://nile-key.test:8000"
```

أضف host محلياً:

```bash
echo "127.0.0.1 nile-key.test" | sudo tee -a /etc/hosts
```

شغّل migration:

```bash
bench --site nile-key.test migrate --rebuild-website
bench --site nile-key.test clear-cache
bench --site nile-key.test enable-scheduler
```

شغّل السيرفر:

```bash
bench start
```

افتح:

```text
http://nile-key.test:8000
```

---

## 6. استعادة Backup كامل

إذا كان لديك backup من:

```text
database.sql.gz
public-files.tar
private-files.tar
site_config.json
```

انسخها إلى مكان معروف داخل WSL، مثلاً:

```bash
mkdir -p ~/backups/nile-key
```

ثم:

```bash
cd ~/frappe/nile-key-bench

bench --site nile-key.test \
  --force restore ~/backups/nile-key/database.sql.gz \
  --with-public-files ~/backups/nile-key/public-files.tar \
  --with-private-files ~/backups/nile-key/private-files.tar
```

بعد الاستعادة:

```bash
bench --site nile-key.test migrate
bench --site nile-key.test clear-cache
bench build
bench start
```

---

## 7. استعادة site_config.json

إذا استعدت `site_config.json`، ضعه هنا:

```text
sites/nile-key.test/site_config.json
```

تأكد من عدم وجود أسرار غير ضرورية داخله.

ثم:

```bash
bench --site nile-key.test clear-cache
```

---

## 8. استعادة fixtures والتخصيصات

إذا كان backup يحتوي على fixtures أو تم تصديرها سابقاً:

```bash
bench --site nile-key.test export-fixtures
```

ثم راجع الملفات داخل:

```text
apps/erpnext/erpnext/fixtures/
```

أو داخل custom app لاحقاً:

```text
apps/nile_export/nile_export/fixtures/
```

---

## 9. التحقق من الاستعادة

### 9.1 فحص الخدمات

```bash
mariadb -u nile-key -p -e "SELECT VERSION();"
redis-cli ping
bench --version
python --version
node --version
yarn --version
```

### 9.2 فحص bench

```bash
cd ~/frappe/nile-key-bench

bench --site nile-key.test list-apps
bench --site nile-key.test doctor
bench --site nile-key.test clear-cache
```

### 9.3 فحص HTTP

```bash
curl -I http://nile-key.test:8000/
curl -I http://nile-key.test:8000/login
curl -I http://nile-key.test:8000/desk
```

---

## 10. بروتوكول backup اليومي

بعد أي تغيير مهم في DocTypes أو Permissions أو Workflows أو Site Settings:

```bash
cd ~/frappe/nile-key-bench

bench --site nile-key.test backup --with-files
```

انقل النسخة الاحتياطية فوراً إلى مكان خارجي غير متأثر بـ Deep Freeze:

```text
S3 / MinIO
Google Drive مشفر
OneDrive مشفر
قرص خارجي
خادم تطوير بعيد
GitHub Release خاص فقط إذا كانت البيانات غير حساسة أو مشفرة
```

---

## 11. بروتوكول قبل أي تجربة تحديث

قبل أي upgrade أو migration خطير:

```bash
bench --site nile-key.test backup --with-files
bench --site nile-key.test export-fixtures
```

ثم احفظ النسخة خارجياً.

لا تبدأ الترقية قبل التأكد من أن restore مجرّب.

---

## 12. خطة التحديث المستقبلية

المشروع الحالي ERPNext `11.1.49`.

الاتجاه الاستراتيجي:

```text
ERPNext/Frappe v16 أو أحدث إصدار مستقر مدعوم
+ custom app باسم nile_export
+ Next.js للبوابة العامة
+ MariaDB/Redis/Bench حديثة
+ CI/CD
+ automated backups
```

لا ترقّ الإنتاج مباشرة من v11 إلى v16 دون:

```text
staging site
full backup
restore test
migration rehearsal
permission audit
UI smoke test
integration test
rollback plan
```

---

## 13. استعادة مختصرة جداً عند الطوارئ

```bash
# 1. clone
git clone https://github.com/hawadettt2/nile-key-v3.git
cd nile-key-v3

# 2. read docs
less MASTER_ROADMAP.md
less RECOVERY_RUNBOOK.md

# 3. install WSL packages
sudo apt update
sudo apt install -y git curl wget build-essential mariadb-server redis-server wkhtmltopdf

# 4. install bench dependencies manually as per sections above
# 5. create bench
# 6. copy repo into apps/erpnext
# 7. create site
# 8. restore backup
# 9. bench start
```

---

## 14. قائمة تحقق نهائية

```text
[ ] GitHub clone ناجح
[ ] Python مناسب للإصدار المستهدف
[ ] Node.js مناسب للإصدار المستهدف
[ ] MariaDB يعمل
[ ] Redis يعمل
[ ] bench مثبت
[ ] apps/erpnext يحتوي على نسخة المشروع
[ ] site تم إنشاؤه
[ ] backup تم استرداده
[ ] migrate نجح
[ ] build نجح
[ ] bench start يعمل
[ ] login يعمل
[ ] desk يعمل
[ ] لا توجد أسرار داخل Git
[ ] backup جديد تم أخذه بعد الاستعادة
```

---

## 15. ملاحظات تشغيلية مهمة

- لا تعتمد على Windows local كمصدر وحيد.
- لا تعتمد على MariaDB/Redis المحليتين إن لم تكونا داخل WSL/Docker/Cloud.
- لا تبدأ تطوير ميزات جديدة قبل وجود backup قابل للاستعادة.
- لا تعدّل ERPNext core مباشرة في النظام النهائي.
- انقل التخصيصات إلى custom app.
- اجعل كل قرار معماري موثقاً في `MASTER_ROADMAP.md` أو `ARCHITECTURE_DECISIONS.md`.
