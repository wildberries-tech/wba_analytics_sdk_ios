# Гайд по миграции с `WildAnalyticsSDK` 4.0.2 на 4.0.3

В версии 4.0.3 нет переименований пакета, публичных типов и ломающих изменений сигнатур — **код, собиравшийся на 4.0.2, соберётся на 4.0.3 без правок**. Все изменения поведенческие: SDK начинает сам отправлять новое периодическое событие, перестаёт зависеть от клиентского флага `isFirstLaunch` при определении первого запуска и получает единый выключатель автоматических событий.

Что важно знать до обновления:

- появилось событие **`heartbeat`** — по умолчанию оно **включено** и добавляет примерно 2 события в минуту на активного пользователя;
- появился параметр **`enableAutomaticEvents`** (по умолчанию `true`), который отключает все автоматические события разом;
- **`isFirstLaunch` больше не влияет на `first_open`** — SDK определяет первый запуск самостоятельно;
- у `application_start` исправлена доставка и добавлен параметр `processor_name`;
- у `dynamic_link_app_open` появился параметр `referrerURL` и публичный метод `trackLaunchURL`.

## 1. Обновите зависимость

### Swift Package Manager

```diff
- .package(url: "https://github.com/wildberries-tech/wba_analytics_sdk_ios.git", exact: "4.0.2")
+ .package(url: "https://github.com/wildberries-tech/wba_analytics_sdk_ios.git", exact: "4.0.3")
```

### CocoaPods

```diff
- pod 'WildAnalyticsSDK', '~> 4.0.2'
+ pod 'WildAnalyticsSDK', '~> 4.0.3'
```

После правки `Podfile` выполните:
```bash
pod deintegrate && pod install
```

## 2. Главное: решите, нужны ли вам автоматические события

К автоматическим относятся три события, которые SDK отправляет сам, без вызовов с вашей стороны:

| Событие | Триггер | Параметры |
|---|---|---|
| `heartbeat` | первая отправка — через 30 секунд после захода в приложение, далее каждые 30 секунд, пока приложение на переднем плане | нет |
| `first_open` | первое открытие приложения на устройстве пользователя, отдельно для каждого `apiKey` | нет |
| `application_start` | старт приложения или разворачивание из фона | `start_location`, `cpu`, `ram`, `processor_name` |

Всё это управляется одним новым параметром инициализатора `WildAnalyticsReceiver`:

```swift
let reciever = WildAnalyticsReceiver(
    apiKey: apiKey,
    isFirstLaunch: isFirstLaunch,
    enableAttributionTracking: true,
    enableAutomaticEvents: true,   // по умолчанию true — можно не указывать
    loggingOptions: loggingOptions,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig(),
    delegate: self
)
```

### Если ваш продукт — приложение

Ничего делать не нужно: параметр можно не указывать, автоматические события работают из коробки.

Учтите только рост трафика событий из-за `heartbeat`: одно событие каждые 30 секунд, пока приложение на переднем плане. Настройки батчинга (`BatchConfig`) при этом не меняются — события уходят обычным пайплайном вместе с остальными.

### Если ваш продукт — SDK, встраиваемый в другой продукт

> ⚠️ **Поставьте `enableAutomaticEvents: false`.**

```swift
let reciever = WildAnalyticsReceiver(
    apiKey: apiKey,
    isFirstLaunch: isFirstLaunch,
    enableAttributionTracking: true,
    enableAutomaticEvents: false,
    loggingOptions: loggingOptions,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig(),
    delegate: self
)
```

Автоматические события описывают жизненный цикл приложения, а встроенный SDK им не управляет: внутри чужого приложения они не описывают ничью сессию и только удваивают трафик событий у хоста.

### На что флаг НЕ влияет

- `user_engagement` — собирается и отправляется как обычно;
- события с явным вызовом: `trackEvent`, `trackEventWithCompletion`, `trackUserEngagement`, `trackLaunchURL`;
- батчинг, ретраи, `meta`, `session_value`, кастомные заголовки, атрибуция.

### Что будет с `first_open`, если выключить автособытия

Событие не теряется и не «сгорает»: при `enableAutomaticEvents: false` SDK не помечает `first_open` отправленным. Если позже вы включите автоматические события, `first_open` уйдёт при следующем запуске.

## 3. Поведение: `isFirstLaunch` больше не влияет на `first_open`

Параметр `isFirstLaunch` остался в инициализаторе (сигнатура не изменилась), но **на событие `first_open` он больше не влияет** — SDK определяет первый запуск сам, отдельно для каждого `apiKey`. Значение по-прежнему используется только для задержки чтения IDFA на первом запуске (`IDFAConfig.firstLaunchIDFADelay`).

```swift
// Продолжает работать, но на first_open больше не влияет
isFirstLaunch: isFirstLaunch
```

Отдельно про устройства, где SDK уже работал до этой версии: `first_open` на них повторно **не** отправляется — SDK распознаёт их по ключу предыдущих версий и считает, что событие уже было отправлено.

## 4. Поведение: `application_start`

- Исправлена доставка: событие идёт общим пайплайном (`addEvent`) — батчится, персистится и ретраится вместе с остальными событиями, собственных ретраев у трекера больше нет.
- Убран дубль на холодном старте.
- Добавлен параметр `processor_name` (например, `A18 Pro`).

Со стороны интегратора действий не требуется.

## 5. Новое: `referrerURL` и `trackLaunchURL`

У события `dynamic_link_app_open` появился параметр `referrerURL`, а вместе с ним — публичный метод для отправки:

```swift
// всем зарегистрированным ресиверам
service.trackLaunchURL(url, referrerURL: referrerURL)

// конкретному ресиверу
service.trackLaunchURL(url, referrerURL: referrerURL, receiverIdentifier: reciever.identifier)
```

`referrerURL` необязателен (`nil` по умолчанию). Метод аддитивный — существующий код менять не нужно.

## 6. Что НЕ изменилось

- Формат событий, `meta`, `batch`, сетевой контракт и ключи параметров
- Имена пакета, продукта и публичных типов (`WildAnalyticsSDK`, `WildAnalyticsReceiver`, `WildTracker`, `WildNetworkType`, `WildAnalyticsDelegateProtocol`)
- Строка `WildAnalyticsReceiver.identifier` — `ru.wildanalytics.receiver_wildanalyticsreceiver`, как в 4.0.1–4.0.2
- Модели `BatchConfig`, `LoggingOptions`, `UserEngagement`, `IDFAConfig`
- Сигнатуры `registerReceiver`, `trackEvent`, `trackEventWithCompletion`, `setUserToken`, `setCommonParameters`, `trackUserEngagement`, `setCustomHeader(s)` и др.
- Структура CoreData и UserDefaults (ключуются по `apiKey`) — пендинговые батчи при апгрейде сохраняются

## 7. Быстрый чек-лист

- [ ] Обновили версию пакета до `4.0.3` в `Package.swift` / `Podfile`
- [ ] Решили, нужны ли автоматические события: приложение — оставить как есть, встраиваемый SDK — `enableAutomaticEvents: false`
- [ ] Заложили рост трафика событий из-за `heartbeat`, если автособытия включены
- [ ] Проверили, что не полагались на `isFirstLaunch` как на триггер `first_open`
- [ ] (Опционально) Начали передавать `referrerURL` через `trackLaunchURL`
- [ ] Прогнали проект через сборку и тесты
