# Changelog

## [CURRENT](https://github.com/wildberries-tech/wba_analytics_sdk_ios/-/tree/master)

- Пакет `WBMAnalytics` переименован в `WildAnalyticsSDK`. Соответственно обновлены имя SPM-продукта/таргета, podspec, module name, импорт (`import WildAnalyticsSDK`), названия папок, файлов, схем Xcode, bundle identifiers и публичный класс-точка входа `WBMAnalytics` → `WildAnalyticsSDK`.
- Публичные типы переименованы: `WBMNetworkType` → `WildNetworkType`, `WBAnalyticsReceiver` → `WildAnalyticsReceiver`, `WBAnalyticsDelegateProtocol` → `WildAnalyticsDelegateProtocol`, `WBTracker` → `WildTracker`.
- Изменился runtime-идентификатор ресивера: `ru.wildberries.receiver_wbanalyticsreceiver` → `ru.wildberries.receiver_wildanalyticsreceiver` (если строка хардкодилась — заменить).
- Гайд по миграции: [docs/MigrationGuide_4.0.0.md](docs/MigrationGuide_4.0.0.md).
- Событие `heartbeat`: отправляется каждые 30 секунд, пока приложение на переднем плане
- Новый параметр `enableAutomaticEvents` в инициализаторе `WildAnalyticsReceiver` управляет отправкой всех автоматических событий SDK: `first_open`, `application_start` и `heartbeat`. **По умолчанию `false` — автоматические события не отправляются**; чтобы включить их, укажите `true`. Если ваш продукт будет интегрироваться в другой продукт, оставьте положение флага неизменным: при изменении у интегрируемых продуктов сбор аналитики может работать нестабильно. На `user_engagement` и на события с явным вызовом флаг не влияет
- В `meta` каждого батча добавлен ключ `enable_automatic_events` (`true` / `false`) — значение флага у интегратора
- Гайд по миграции на 4.0.3: [docs/MigrationGuide_4.0.3.md](docs/MigrationGuide_4.0.3.md).
- Событие `first_open` больше не зависит от клиентского флага `isFirstLaunch`
- Событие `application_start`: исправлена доставка, убран дубль на холодном старте, добавлен параметр `processor_name`
- Событие `dynamic_link_app_open`: добавлен параметр `referrerURL` и публичный метод `trackLaunchURL`

## [v3.4.4](https://github.com/wildberries-tech/wba_analytics_sdk_ios/-/tags/3.4.4)

- Переработан механизм отправки app_install

## [v3.4.3](https://github.com/wildberries-tech/wba_analytics_sdk_ios/-/tags/3.4.3)

- Первая версия публичного WBA iOS SDK

[Full Changelog](https://github.com/wildberries-tech/wba_analytics_sdk_ios/-/compare/1.0.0...3.4.4)
