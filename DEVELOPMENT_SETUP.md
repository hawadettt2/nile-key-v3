# DEVELOPMENT_SETUP.md

## إعداد بيئة التطوير لمشروع ile-key-v3

هذه الوثيقة تشرح إعداد بيئة تطوير Frappe/ERPNext قابلة لإعادة البناء، مع مراعاة أن جهاز التطوير الحالي يعمل على Windows 11 مع Deep Freeze.

---

## 1. تحذير مهم

لا تعتمد على البيئة المحلية كمصدر وحيد. بسبب Deep Freeze، يجب الالتزام بـ:

```text
Git push بعد كل تغيير مهم
backup قاعدة بيانات بعد تغيير DocTypes/Permissions/Workflows
backup ملفات بعد رفع مرفقات
لا تضع أسراراً داخل Git
```

---

## 2. المتطلبات الأساسية

### Windows host

```text
Windows 11
Git for Windows
PowerShell
Internet connection
```

### Linux environment

الأفضل:

```text
WSL2 Ubuntu 22.04 أو 24.04
```

أو بديل:

```text
Docker Compose / frappe_docker
Cloud Dev Server
VM خارجية
```

---

## 3. إعداد WSL

من PowerShell كمسؤول:

```powershell
wsl --install --no-distribution
```

أعد تشغيل Windows قبل تثبيت Ubuntu إذا ظهر أن WSL يحتاج reboot.

بعد إعادة التشغيل:

```powershell
wsl --install -d Ubuntu --no-launch
```

داخل Ubuntu:

```bash
sudo apt update
sudo apt upgrade -y
```

### 3.1 فحص Windows host

من PowerShell داخل جذر المشروع:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\check-windows-env.ps1
```

يجب أن تكون النتيجة صحيحة تقريباً:

```text
hypervisor_present = True
virtualization_firmware_enabled = True
wsl_status = Default Version: 2
mariadb_127_0_0_1_3307 = True
redis_127_0_0_1_6379 = True
```

إذا ظهر:

```text
HyperVisorPresent is False
```

أو:

```text
WSL2 is unable to start since virtualization is not enabled
```

لا تستخدم WSL1 لتشغيل Frappe. فعّل Virtualization من BIOS/UEFI ثم تأكد من تشغيل:

```powershell
wsl --install --no-distribution
```

ثم أعد تشغيل Windows.

---

## 4. تثبيت المتطلبات

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

---

## 5. تثبيت Python

لـ ERPNext v11 الحالي:

```bash
curl https://pyenv.run | bash
```

```bash
cat >> ~/.bashrc <<'EOF'
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"
EOF

exec $SHELL
```

```bash
pyenv install 3.7.17
pyenv global 3.7.17
python --version
```

---

## 6. تثبيت Node.js و Yarn

```bash
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.7/install.sh | bash
exec $SHELL
```

```bash
nvm install 10.24.1
nvm use 10.24.1
nvm alias default 10.24.1
npm install -g yarn@1.22.22
```

---

## 7. تثبيت Bench

```bash
python -m pip install --upgrade pip setuptools wheel
pip install "frappe-bench==5.14.1"
bench --version
```

---

## 8. إنشاء bench

```bash
mkdir -p ~/frappe
cd ~/frappe

bench init \
  --frappe-branch version-11 \
  --python "$HOME/.pyenv/versions/3.7.17/bin/python" \
  nile-key-bench

cd ~/frappe/nile-key-bench
```

---

## 9. جلب ERPNext واستيراد المشروع

```bash
bench get-app erpnext --branch version-11
```

استورد نسخة المشروع الحالية:

```bash
rsync -a --delete --exclude='.git' ~/projects/nile-key-v3/ apps/erpnext/
bench setup requirements
bench build
```

---

## 10. إنشاء site

```bash
bench new-site nile-key.test \
  --mariadb-root-username nile-key \
  --mariadb-root-password 'PUT_STRONG_PASSWORD_HERE' \
  --admin-password 'PUT_ADMIN_PASSWORD_HERE' \
  --install-app erpnext
```

```bash
bench --site nile-key.test set-config developer_mode 1
bench --site nile-key.test set-config host_name "http://nile-key.test:8000"
```

أضف host:

```bash
echo "127.0.0.1 nile-key.test" | sudo tee -a /etc/hosts
```

---

## 11. تشغيل السيرفر

```bash
bench --site nile-key.test migrate --rebuild-website
bench --site nile-key.test clear-cache
bench start
```

افتح:

```text
http://nile-key.test:8000
```

---

## 12. أوامر يومية مفيدة

```bash
bench start
bench --site nile-key.test clear-cache
bench --site nile-key.test migrate
bench build
bench --site nile-key.test backup --with-files
bench --site nile-key.test doctor
```

---

## 13. التعامل مع Deep Freeze

قبل إغلاق الجهاز:

```text
[ ] git add/commit
[ ] git push
[ ] bench backup --with-files
[ ] نقل backup خارجياً
[ ] تحديث الوثائق إذا تغير قرار مهم
```

---

## 14. التحقق من البيئة

```bash
python --version
node --version
yarn --version
bench --version
redis-cli ping
mariadb -u nile-key -p -e "SELECT VERSION();"
```

---

## 15. ملاحظات

- لا تستخدم Python 3.14 مع ERPNext v11.
- لا تستخدم Node 24 مع ERPNext v11.
- لا تعتمد على MariaDB/Redis المحلية على Windows إلا للتجربة.
- البيئة النهائية الأفضل هي WSL/Docker/Cloud.
