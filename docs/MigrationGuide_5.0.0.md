# Гайд по миграции с `WildAnalyticsSDK` 4.x на `WBASDK` 5.0.0

В версии 5.0.0 пакет переименован: `WildAnalyticsSDK` → `WBASDK`, публичные типы получили префикс `WBA`. Помимо переименования, в 5.0.0 вошли изменения API из основной ветки SDK (см. раздел 6).

## 1. Обновите зависимость

### Swift Package Manager

```diff
- .package(url: "https://github.com/wildberries-tech/wba_analytics_sdk_ios.git", exact: "4.0.4")
+ .package(url: "https://github.com/wildberries-tech/wba_analytics_sdk_ios.git", exact: "5.0.0")
```

И в зависимостях таргета:

```diff
- .product(name: "WildAnalyticsSDK", package: "wba_analytics_sdk_ios")
+ .product(name: "WBASDK", package: "wba_analytics_sdk_ios")
```

### CocoaPods

```diff
- pod 'WildAnalyticsSDK', '~> 4.0.4'
+ pod 'WBASDK', '~> 5.0.0'
```

После правки `Podfile` выполните:
```bash
pod deintegrate && pod install
```

## 2. Поменяйте импорт

```diff
- import WildAnalyticsSDK
+ import WBASDK
```

## 3. Переименуйте публичные типы

| Старое имя (4.x)                | Новое имя (5.0.0)      |
|---------------------------------|------------------------|
| `WildAnalyticsSDK`              | `WBASDK`               |
| `WildAnalyticsReceiver`         | `WBAReceiver`          |
| `WildAnalyticsDelegateProtocol` | `WBADelegateProtocol`  |
| `WildNetworkType`               | `WBANetworkType`       |

Сигнатуры методов фасада и ресивера не изменились, кроме перечисленных в разделе 6.

```diff
- let service = WildAnalyticsSDK()
- let reciever = WildAnalyticsReceiver(apiKey: apiKey, ...)
+ let service = WBASDK()
+ let reciever = WBAReceiver(apiKey: apiKey, ...)
```

```diff
- extension AppDelegate: WildAnalyticsDelegateProtocol {
+ extension AppDelegate: WBADelegateProtocol {
      func didResolveAttributedLink(_ link: URL) { ... }
  }
```

Кейсы `WBANetworkType` и их строковые значения остались прежними.

## 4. Идентификатор ресивера

| Версия | Значение `identifier`                               |
|--------|-----------------------------------------------------|
| 4.x    | `ru.wildanalytics.receiver_wildanalyticsreceiver`   |
| 5.0.0  | `ru.wba.receiver_wbareceiver`                       |

Если идентификатор передавался литералом — замените его или читайте из `reciever.identifier`.

## 5. Что НЕ изменилось

- Сетевой контракт, формат `meta` и `batch`, ключи параметров.
- Данные на устройстве: CoreData-хранилище батчей и ключи UserDefaults (в т.ч. признак существующей установки) остались прежними, поэтому пендинговые батчи не теряются, а `first_open` повторно не отправляется.

## 6. Изменения API в 5.0.0

- `setSessionValue(_ value: UInt64?)` и `setOnSessionValueUpdated(_ handler: @escaping (UInt64?) -> Void)` вместо `String?`. `session_value` в событиях теперь число.
- `UserEngagement(scaleFactor:)` принимает `CGFloat?` вместо `String?`.
- `BatchConfig` получил публичный инициализатор `init(sendingDelay:size:sendingTimerTimeout:requestTimeout:)`.
- `WBASDK` и ресиверы потокобезопасны и соответствуют `Sendable`.

## 7. Полезные `sed`-команды

Из корня репозитория вашего проекта (BSD sed, macOS). Порядок важен: длинные имена раньше коротких.

```bash
grep -rl --include='*.swift' 'Wild' . | xargs sed -i '' \
  -e 's/WildAnalyticsDelegateProtocol/WBADelegateProtocol/g' \
  -e 's/WildAnalyticsReceiver/WBAReceiver/g' \
  -e 's/WildNetworkType/WBANetworkType/g' \
  -e 's/WildAnalyticsSDK/WBASDK/g'
```

После замены пересоберите проект и прогоните тесты.
