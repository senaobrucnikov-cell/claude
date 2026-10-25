# Coin Collector — игра для Roblox

Простая стартовая игра на Luau: собирай монеты на арене, трать их в магазине на ускорение.

## Запуск

1. Установите [Rojo](https://rojo.space) и плагин Rojo для Roblox Studio.
2. Откройте Roblox Studio, создайте пустой Baseplate-плейс и удалите стандартный Baseplate.
3. В папке проекта выполните `rojo serve`, в Studio нажмите **Rojo → Connect**.
4. Нажмите **Play**.

Или соберите файл места: `rojo build -o CoinCollector.rbxlx`.

## Структура

- `src/shared/Config.lua` — настройки баланса (размер арены, цены, скорость).
- `src/server/Main.server.lua` — арена, монеты, магазин, `leaderstats`.
- `src/client/HUD.client.lua` — счётчик монет и уведомления.

## Идеи для развития

- Сохранение прогресса через `DataStoreService`.
- Раунды с таймером и победителем.
- Новые товары в магазине (прыжок, питомцы), редкие монеты.
