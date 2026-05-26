# Гайд по миграции с `WBMAnalytics` 3.5.7 на `WildAnalyticsSDK` 4.0.0

В версии 4.0.0 пакет был переименован: `WBMAnalytics` → `WildAnalyticsSDK`. Бизнес-логика, формат событий, конфигурация батчей, работа с CoreData и сетевой контракт не менялись — миграция сводится к переименованию импорта, продукта пакета и нескольких публичных типов.

## 1. Обновите зависимость

### Swift Package Manager

Было:
```swift
.package(url: "https://github.com/wildberries-tech/wba_analytics_sdk_ios.git", exact: "3.5.7")
```

Стало:
```swift
.package(url: "https://github.com/wildberries-tech/wba_analytics_sdk_ios.git", exact: "4.0.0")
```

И в зависимостях таргета:

```diff
- .product(name: "WBMAnalytics", package: "wba_analytics_sdk_ios")
+ .product(name: "WildAnalyticsSDK", package: "wba_analytics_sdk_ios")
```

### CocoaPods

```diff
- pod 'WBMAnalytics', '~> 3.5.7'
+ pod 'WildAnalyticsSDK', '~> 4.0.0'
```

После правки `Podfile` выполните:
```bash
pod deintegrate && pod install
```

## 2. Поменяйте импорт

Во всех файлах, где используется SDK:

```diff
- import WBMAnalytics
+ import WildAnalyticsSDK
```

## 3. Переименуйте точку входа

Главный класс-фасад был переименован:

```diff
- let service = WBMAnalytics()
+ let service = WildAnalyticsSDK()
```

Никаких изменений в сигнатурах методов (`registerReceiver`, `trackEvent`, `trackEventWithCompletion`, `setUserToken`, `setIDFA`, `setCommonParameters`, `trackUserEngagement` и т. д.) нет — достаточно заменить только имя типа.

## 4. Переименуйте публичные типы

Вместе с пакетом переименованы все публичные типы с префиксами `WBM` и `WB`:

| Старое имя (3.5.7)            | Новое имя (4.0.0)              |
|-------------------------------|--------------------------------|
| `WBMAnalytics`                | `WildAnalyticsSDK`             |
| `WBMNetworkType`              | `WildNetworkType`              |
| `WBAnalyticsReceiver`         | `WildAnalyticsReceiver`        |
| `WBAnalyticsDelegateProtocol` | `WildAnalyticsDelegateProtocol`|
| `WBTracker`                   | `WildTracker`                  |

### Пример: создание ресивера

Было:
```swift
let reciever = WBAnalyticsReceiver(
    apiKey: apiKey,
    isFirstLaunch: isFirstLaunch,
    enableAttributionTracking: true,
    loggingOptions: loggingOptions,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig(),
    delegate: self
)
```

Стало:
```swift
let reciever = WildAnalyticsReceiver(
    apiKey: apiKey,
    isFirstLaunch: isFirstLaunch,
    enableAttributionTracking: true,
    loggingOptions: loggingOptions,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig(),
    delegate: self
)
```

### Пример: делегат атрибуции

Было:
```swift
extension AppDelegate: WBAnalyticsDelegateProtocol {
    func didResolveAttributedLink(_ link: URL) { ... }
}
```

Стало:
```swift
extension AppDelegate: WildAnalyticsDelegateProtocol {
    func didResolveAttributedLink(_ link: URL) { ... }
}
```

### `WildNetworkType`

```diff
- let type: WBMNetworkType = provider.currentNetworkType
+ let type: WildNetworkType = provider.currentNetworkType
```

Кейсы (`wifi`, `cellular`, `none` и т. д.) и их строковые значения остались прежними — сериализация событий не ломается.

## 5. Идентификатор ресивера

Из-за переименования класса изменилась строка, которую возвращает `WildAnalyticsReceiver.identifier` (она формируется из имени типа):

| Версия | Значение `identifier`                            |
|--------|--------------------------------------------------|
| 3.5.7  | `ru.wildberries.receiver_wbanalyticsreceiver`    |
| 4.0.0  | `ru.wildberries.receiver_wildanalyticsreceiver`  |

Если вы передавали идентификатор как литерал — замените его на новое значение или, что предпочтительнее, читайте его из `reciever.identifier`:

```swift
service.setCommonParameters(["client_id": 123], reciever.identifier)
```

На сетевой контракт и формат событий это не влияет.

## 6. Что НЕ изменилось

Эти имена остались как есть:

- `BatchConfig`, `LoggingOptions`, `UserEngagement` и другие модели данных
- Внутреннее имя класса `WBAnalytics` (не входит в публичный API)
- Сетевой контракт, формат `meta` и `batch`, ключи параметров
- Структура CoreData и UserDefaults, которые ключуются по `apiKey`, — пендинговые батчи не теряются при апгрейде

## 7. Быстрый чек-лист

- [ ] Обновили версию пакета до `4.0.0` в `Package.swift` / `Podfile`
- [ ] Заменили `import WBMAnalytics` на `import WildAnalyticsSDK` во всём проекте
- [ ] Заменили `WBMAnalytics()` на `WildAnalyticsSDK()` в местах создания инстанса
- [ ] Переименовали `WBAnalyticsReceiver` → `WildAnalyticsReceiver`
- [ ] Переименовали `WBAnalyticsDelegateProtocol` → `WildAnalyticsDelegateProtocol`
- [ ] Переименовали `WBTracker` → `WildTracker` (если ссылались на него явно)
- [ ] Заменили `WBMNetworkType` → `WildNetworkType`
- [ ] Если хардкодили `receiver_wbanalyticsreceiver` — заменили на актуальное значение
- [ ] Прогнали проект через сборку и тесты

## 8. Полезные `sed`-команды

Из корня репозитория вашего проекта (BSD sed, macOS):

```bash
# Импорт и точка входа
grep -rl --include='*.swift' 'WBMAnalytics' . | xargs sed -i '' 's/WBMAnalytics/WildAnalyticsSDK/g'

# Остальные публичные типы (важен порядок: длинные имена раньше коротких)
grep -rl --include='*.swift' . | xargs sed -i '' \
  -e 's/WBAnalyticsDelegateProtocol/WildAnalyticsDelegateProtocol/g' \
  -e 's/WBAnalyticsReceiver/WildAnalyticsReceiver/g' \
  -e 's/WBMNetworkType/WildNetworkType/g' \
  -e 's/WBTracker/WildTracker/g'
```

После замены — пересоберите проект и убедитесь, что тесты проходят.
