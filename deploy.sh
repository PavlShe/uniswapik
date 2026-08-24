#!/bin/bash
# Публикация Mini App на GitHub Pages. Токен вводится скрыто и никуда не пишется,
# кроме локального ~/.gh_token с правами 600.
set -e
cd "$(dirname "$0")"
REPO="${1:-uniswapik}"

echo "== 1/5 авторизация =="
if gh auth status >/dev/null 2>&1; then
  echo "   gh уже авторизован"
else
  python3 -c "
import getpass,os,subprocess,sys
t=getpass.getpass('   токен GitHub (ввод скрыт): ').strip()
if not t: sys.exit('   пусто, отмена')
p=os.path.expanduser('~/.gh_token'); open(p,'w').write(t); os.chmod(p,0o600)
r=subprocess.run(['gh','auth','login','--with-token'],input=t,text=True,capture_output=True)
print('   ' + (r.stderr.strip() or 'авторизован'))
sys.exit(r.returncode)"
fi
OWNER=$(gh api user --jq .login)
echo "   аккаунт: $OWNER"

echo "== 2/5 репозиторий =="
git branch -M main 2>/dev/null || true
if gh repo view "$OWNER/$REPO" >/dev/null 2>&1; then
  echo "   $REPO уже существует, использую его"
  git remote remove origin 2>/dev/null || true
  git remote add origin "https://github.com/$OWNER/$REPO.git"
else
  gh repo create "$REPO" --public --source=. --disable-issues --disable-wiki
  echo "   создан $OWNER/$REPO"
fi

echo "== 3/5 пуш =="
git add -A
git -c user.email="${OWNER}@users.noreply.github.com" -c user.name="$OWNER" \
    commit -qm "Telegram Mini App" 2>/dev/null || echo "   нечего коммитить"
git push -u origin main 2>&1 | tail -2

echo "== 4/5 включаю Pages =="
gh api -X POST "repos/$OWNER/$REPO/pages" \
   -f "source[branch]=main" -f "source[path]=/" >/dev/null 2>&1 \
   && echo "   включено" \
   || echo "   уже включено или включится после сборки"

echo "== 5/5 жду сборку =="
URL="https://$OWNER.github.io/$REPO/"
for i in $(seq 1 40); do
  CODE=$(curl -s -o /dev/null -w '%{http_code}' "$URL" --max-time 10 || echo 000)
  if [ "$CODE" = "200" ]; then echo "   страница отвечает 200"; break; fi
  printf "   попытка %s: HTTP %s\n" "$i" "$CODE"; sleep 15
done

echo
echo "ГОТОВО: $URL"
echo "Скажите Клоду этот адрес — он проверит страницу и привяжет кнопку к боту."
