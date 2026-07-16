# Гайд по миграции с `WildAnalyticsSDK` 4.0.0 на 4.0.1

В версии 4.0.1 нет переименований пакета или публичных типов — обновление в основном аддитивное. Однако есть **два ломающих изменения**: убран метод `setIDFA(_:)` (SDK теперь сам читает IDFA из ОС) и изменилась строка `WildAnalyticsReceiver.identifier`. Формат событий и сетевой контракт совместимы, пендинговые батчи при апгрейде не теряются.

Что появилось нового:

- автоматический сбор IDFA (`device_ad_id`) с настройкой через `IDFAConfig`;
- кастомные заголовки запросов — `setCustomHeader(key:value:)` / `setCustomHeaders(_:)`;
- поддержка `URLSessionDelegate` (например, для SSL pinning) через параметр `sessionDelegate`.

## 1. Обновите зависимость

### Swift Package Manager

```diff
- .package(url: "https://github.com/wildberries-tech/wba_analytics_sdk_ios.git", exact: "4.0.0")
+ .package(url: "https://github.com/wildberries-tech/wba_analytics_sdk_ios.git", exact: "4.0.1")
```

### CocoaPods

```diff
- pod 'WildAnalyticsSDK', '~> 4.0.0'
+ pod 'WildAnalyticsSDK', '~> 4.0.1'
```

После правки `Podfile` выполните:
```bash
pod deintegrate && pod install
```

## 2. Ломающее изменение: убран `setIDFA(_:)`

Метод `setIDFA(_ idfa: @escaping () -> String)` удалён из `WildAnalyticsSDK`, `WildAnalyticsReceiver`, `WBAnalytics` и протокола `AnalyticsReceiver`. Код, который его вызывал, **перестанет компилироваться**.

Было:
```swift
service.setIDFA { ASIdentifierManager.shared().advertisingIdentifier.uuidString }
```

Стало — **ничего вызывать не нужно**. SDK самостоятельно читает рекламный идентификатор напрямую из ОС через `AdSupport` и кладёт его в объект `meta` каждого батча под ключом `device_ad_id`. Просто удалите вызовы `setIDFA`.

Важное про поведение:

- Перед чтением SDK проверяет статус **App Tracking Transparency**. SDK **не показывает** промт запроса разрешения — это ответственность приложения. `ATTrackingManager` используется только для чтения статуса ответа пользователя.
- Если разрешение не получено (пользователь отказал **или ещё не ответил**) либо IDFA недоступен, в `device_ad_id` уходит **пустая строка**.
- `AdSupport` и `AppTrackingTransparency` подключаются как weak-фреймворки.

> Требования App Store: при использовании IDFA приложение должно объявить причину доступа в `PrivacyInfo.xcprivacy` и, если показывает ATT-промт, добавить `NSUserTrackingUsageDescription` в `Info.plist`.

## 3. Новое: настройка сбора IDFA через `IDFAConfig`

Поведение сбора IDFA настраивается новым параметром `idfaConfig` в инициализаторе `WildAnalyticsReceiver` (по умолчанию `IDFAConfig()` — совместимо, менять ничего не обязательно):

```swift
let reciever = WildAnalyticsReceiver(
    apiKey: apiKey,
    isFirstLaunch: isFirstLaunch,
    enableAttributionTracking: true,
    loggingOptions: loggingOptions,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig(),
    idfaConfig: IDFAConfig(
        isDisabled: false,        // true — полностью отключить сбор IDFA (всегда пустая строка)
        firstLaunchIDFADelay: 60  // на первом запуске отложить НАЧАЛО чтения IDFA на N секунд,
                                  // чтобы дать приложению запросить ATT, а пользователю — ответить.
                                  // События при этом идут как обычно — до истечения задержки
                                  // в device_ad_id уходит пустая строка. 0 — читать сразу.
    ),
    delegate: self
)
```

| Поле                   | Тип            | По умолчанию | Назначение                                                        |
|------------------------|----------------|--------------|-------------------------------------------------------------------|
| `isDisabled`           | `Bool`         | `false`      | `true` — SDK никогда не читает IDFA, `device_ad_id` всегда пустой  |
| `firstLaunchIDFADelay` | `TimeInterval` | `60`         | Задержка начала чтения IDFA на первом запуске (сек). `0` — сразу   |

Приложению, которому сбор IDFA не нужен, достаточно передать `IDFAConfig(isDisabled: true)`.

## 4. Новое: кастомные заголовки запросов

Добавлены методы для установки произвольных HTTP-заголовков, которые добавляются ко всем аналитическим запросам. Доступны на `WildAnalyticsSDK`, `WildAnalyticsReceiver` и в протоколе `AnalyticsReceiver`:

```swift
service.setCustomHeader(key: "X-My-Header", value: "value")
service.setCustomHeaders(["X-A": "1", "X-B": "2"])
```

## 5. Новое: `sessionDelegate` (SSL pinning и пр.)

В инициализатор `WildAnalyticsReceiver` добавлен необязательный параметр `sessionDelegate: URLSessionDelegate?` (по умолчанию `nil`). Он позволяет перехватывать authentication challenge сетевой сессии — например, для SSL pinning. Делегат прокидывается как в сессию отправки батчей, так и в сессию атрибуции.

```swift
let reciever = WildAnalyticsReceiver(
    apiKey: apiKey,
    isFirstLaunch: isFirstLaunch,
    enableAttributionTracking: true,
    loggingOptions: loggingOptions,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig(),
    sessionDelegate: myPinningDelegate,
    delegate: self
)
```

Если `sessionDelegate` не задан, используется поведение по умолчанию (`URLSession.shared` для атрибуции).

## 6. Ломающее изменение: идентификатор ресивера

Изменился префикс строки, которую возвращает `WildAnalyticsReceiver.identifier`:

| Версия | Значение `identifier`                              |
|--------|----------------------------------------------------|
| 4.0.0  | `ru.wildberries.receiver_wildanalyticsreceiver`    |
| 4.0.1  | `ru.wildanalytics.receiver_wildanalyticsreceiver`  |

Если вы передавали идентификатор как литерал (например, в `setCommonParameters`) — замените его на новое значение или, что предпочтительнее, читайте его из `reciever.identifier`:

```swift
service.setCommonParameters(["client_id": 123], reciever.identifier)
```

На сетевой контракт и формат событий это не влияет.

## 7. Что НЕ изменилось

- Формат событий, `meta`, `batch`, сетевой контракт и ключи параметров
- Имена пакета, продукта и публичных типов (`WildAnalyticsSDK`, `WildAnalyticsReceiver`, `WildTracker`, `WildNetworkType`, `WildAnalyticsDelegateProtocol`)
- Модели `BatchConfig`, `LoggingOptions`, `UserEngagement`
- Сигнатуры `registerReceiver`, `trackEvent`, `trackEventWithCompletion`, `setUserToken`, `setCommonParameters`, `trackUserEngagement` и др.
- Структура CoreData и UserDefaults (ключуются по `apiKey`) — пендинговые батчи при апгрейде сохраняются

## 8. Быстрый чек-лист

- [ ] Обновили версию пакета до `4.0.1` в `Package.swift` / `Podfile`
- [ ] Удалили все вызовы `setIDFA(_:)` — SDK читает IDFA сам
- [ ] При необходимости настроили сбор IDFA через `IDFAConfig` (`isDisabled` / `firstLaunchIDFADelay`)
- [ ] Проверили `PrivacyInfo.xcprivacy` и `NSUserTrackingUsageDescription`, если используете IDFA / ATT-промт
- [ ] Если хардкодили `ru.wildberries.receiver_wildanalyticsreceiver` — заменили на `ru.wildanalytics.receiver_wildanalyticsreceiver` (или читаете из `reciever.identifier`)
- [ ] (Опционально) Подключили кастомные заголовки через `setCustomHeader` / `setCustomHeaders`
- [ ] (Опционально) Передали `sessionDelegate` для SSL pinning
- [ ] Прогнали проект через сборку и тесты
