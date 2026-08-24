# Uniswap v3 позиция — Telegram Mini App

Статическая страница: читает Arbitrum напрямую из браузера, бэкенда нет.
Показывает цену, размер пула, вашу позицию, её состав, комиссии и валовые
комиссии по ширине диапазона.

## Публикация на GitHub Pages

```bash
git init && git add -A && git commit -m "mini app"
git branch -M main
git remote add origin https://github.com/ВАШ_ЛОГИН/uniswapik.git
git push -u origin main
```

Затем в репозитории: **Settings → Pages → Source: Deploy from a branch →
Branch: main, папка / (root) → Save**. Через минуту адрес будет такой:

```
https://ВАШ_ЛОГИН.github.io/uniswapik/
```

## Подключение к боту

Кнопка меню в Telegram (замените адрес на свой):

```bash
curl -s -X POST "https://api.telegram.org/bot<ТОКЕН>/setChatMenuButton" \
  -H 'Content-Type: application/json' -d '{
    "menu_button": {"type":"web_app","text":"Позиция",
      "web_app":{"url":"https://ВАШ_ЛОГИН.github.io/uniswapik/"}}}'
```

После этого слева от поля ввода появится кнопка «Позиция».

## Другой кошелёк

Адрес берётся из параметра `?a=0x...`, иначе из localStorage, иначе по умолчанию.

```
https://ВАШ_ЛОГИН.github.io/uniswapik/?a=0xВашАдрес
```

## Что внутри

| Блок | Откуда данные |
|---|---|
| Цена, тик | `slot0()` пула |
| Размер пула | балансы обоих токенов на контракте пула |
| Активная ликвидность | `liquidity()`, переведена в доллары для полосы ±0,5% |
| Позиция | `balanceOf` + `tokenOfOwnerByIndex` + `positions` менеджера |
| Комиссии | статический вызов `collect` — цепочка не меняется |
| Оборот | события `Swap` за последние 2 часа |

RPC: `arb1.arbitrum.io` с переключением на `arbitrum-one.publicnode.com`.
`1rpc.io` не подходит — не отдаёт CORS браузеру.

## Ограничения

Комиссии показаны **валовые**, до потерь на конверсии и газа. Чистый результат
с симуляцией считает бот командой `/apr` — в браузере это слишком тяжело.

Приложение только читает. Подписи транзакций здесь нет: MetaMask не внедряет
`window.ethereum` в webview Telegram, для подписи нужен WalletConnect.
