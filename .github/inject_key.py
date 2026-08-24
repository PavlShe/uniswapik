"""Подставляет ключ Arbiscan из переменной окружения в собранную страницу.

Ключ читается только из окружения — так он не попадает ни в аргументы команды,
ни в логи сборки, ни в git.
"""
import os
import pathlib
import sys

PLACEHOLDER = "__ARBISCAN_KEY__"

key = os.environ.get("KEY", "").strip()
if not key:
    print("::warning::секрет ARBISCAN_KEY не задан — страница собрана без ключа")
    sys.exit(0)

page = pathlib.Path("index.html")
text = page.read_text(encoding="utf-8")
if PLACEHOLDER not in text:
    print("::error::заполнитель не найден в index.html")
    sys.exit(1)

page.write_text(text.replace(PLACEHOLDER, key), encoding="utf-8")
print("ключ подставлен, вхождений:", text.count(PLACEHOLDER))
