# WildAnalyticsSDK

SDK для логирования событий в IOS-приложении. События последовательно группируются в батчи и отправляются на сервер. Поддерживается конфигурация для production и debug окружений. Ведется подсчет отправленных событий и батчей для контроля потери данных. До момента отправки события хранятся в CoreData. В случае отсутствия сети события будут отправлены при её появлении. 

## ⬇️ Install

SDK поставляется через SPM, для добавления в свой проект достаточно добавить в свой проект 

```
.package(url:"https://github.com/wildberries-tech/wba_analytics_sdk_ios.git",exact:  "4.0.2")
```

## 🚀 Launch in app

В приложении подразумевается один инстанс аналитики который может поддерживает несколько ресиверов

Для создания экземпляра WildAnalyticsReceiver необходимо передать несколько обязательных параметров в его инициализатор:
    
- **environment:** Окружение приложения, может быть .production или .test, при необходимости можно установить свой apiKey .custom("apiKey"). ([пример](https://gitlab.wildberries.ru/mobile/ios/analytics/-/blob/master/WBAnalyticsKit/WBAnalyticsKitTestApp/AppDelegate.swift?ref_type%253Dheads#L31))
- **analyticsURL:** URL, на который будут отправляться аналитические данные.
- **isFirstLaunch:** Флаг, указывающий, является ли текущий запуск приложения первым.  (хранится где-то у вас допустим в UserDefaults [пример](https://gitlab.wildberries.ru/mobile/ios/analytics/-/blob/master/WBAnalyticsKit/WBAnalyticsKitTestApp/AppDelegate.swift?ref_type%253Dheads#L30))
- **enableAttributionTracking:** Включение/выключение автоматической атрибуции трафика. 
- **loggingOptions:** Настройки логирования, включая уровень логирования и файловую запись. [Подробнее](.Docs/LoggingOptions.md)
- **networkTypeProvider:** Объект, предоставляющий информацию о текущем типе сети.
- **batchConfig:** Конфигурация пакетной отправки данных.
- **idfaConfig:** Конфигурация сбора рекламного идентификатора (IDFA). Необязательный параметр, по умолчанию `IDFAConfig()`. [Подробнее](#-idfa-device_ad_id)

для каждого ресивера можно выставлять свои параметры и свои apiKey, после ресивер передается в единый инстанс. После инициализации нужно засетапить ресивер.

Пример инициализации ресивера:
```swift
let service = WildAnalyticsSDK()

let apiKey = "<PUT API KEY HERE>"

let reciever1 = WildAnalyticsReceiver(
    apiKey: apiKey,
    isFirstLaunch: isFirstLaunch,
    loggingOptions: loggingOptions,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig()
)
reciever1.setup() // Важно сетапить перед использованием

let reciever2 = WildAnalyticsReceiver(
    apiKey: "TestKey",
    isFirstLaunch: isFirstLaunch,
    loggingOptions: LoggingOptions.default,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig()
)

service.registerReceiver(reciever1)
service.registerReceiver(reciever2)

return service
```

## 📱 IDFA (device_ad_id)

SDK самостоятельно читает рекламный идентификатор (IDFA) напрямую из ОС через фреймворк `AdSupport` и добавляет его в объект `meta` каждого батча под ключом `device_ad_id`.

- Перед чтением SDK проверяет статус **App Tracking Transparency**. SDK **не показывает** промт запроса разрешения — это зона ответственности приложения. `ATTrackingManager` используется только для получения статуса ответа пользователя.
- Если разрешение не получено (пользователь отказал **или ещё не ответил**), либо IDFA по какой-то причине недоступен, в `device_ad_id` отправляется **пустая строка**.

Поведение настраивается через `IDFAConfig`:

```swift
let reciever = WildAnalyticsReceiver(
    apiKey: apiKey,
    isFirstLaunch: isFirstLaunch,
    loggingOptions: loggingOptions,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig(),
    idfaConfig: IDFAConfig(
        isDisabled: false,        // true — полностью отключить сбор IDFA (всегда пустая строка)
        firstLaunchIDFADelay: 60  // на первом запуске отложить НАЧАЛО чтения IDFA на N секунд,
                                  // чтобы дать приложению запросить ATT, а пользователю — ответить.
                                  // События при этом отправляются как обычно — до истечения
                                  // задержки в device_ad_id уходит пустая строка. 0 — читать сразу.
    )
)
```

`AdSupport` и `AppTrackingTransparency` подключаются как weak-фреймворки. Приложение, которому сбор IDFA не нужен, может выставить `IDFAConfig(isDisabled: true)`.

> Не забудьте про требования App Store: при использовании IDFA приложение должно объявить причину доступа в `PrivacyInfo.xcprivacy` и, если показывает ATT-промт, добавить `NSUserTrackingUsageDescription` в `Info.plist`.

## 🧑‍💻 Log events

### 1. Логирование событий

Для логирования событий в приложении можно использовать метод trackEvent сервиса аналитики:
    
```swift
service.trackEvent(name: "EventName", parameters: [:])
```
Параметры События

- **name:** Имя события, которое будет логироваться.
- **parameters:** Словарь с дополнительными параметрами события. Ключами должны быть строки (String), а значениями — типы, которые могут быть сериализованы в JSON.         
Поддерживаемые типы для значений:

    - String
    - Int
    - Double
    - Bool
    - [String: Any] (вложенные словари) **где Any — поддерживаемый тип**
    - [Any] (массивы, **где Any — поддерживаемый тип**)
        
Пример логирования события с дополнительными параметрами:
```swift
let parameters: [String: Any] = [
    "user_id": 123,
    "screen_name": "MainScreen",
    "action": "button_click"
]

service.trackEvent(name: "UserInteraction", parameters: parameters)
```

### 2. Логирование user engagement


Каждые 30 секунд автоматически трекается "user_engagement" если появилась необходимость трекнуть руками. Можно использовать trackUserEngagement в качестве параметров передается UserEngagement

```swift
let userEngagement: UserEngagement = .init(screenName: "name", textSize: .large)
analytics.trackUserEngagement(userEngagement)
```
### 3. Кастомные параметры
Чтоб в каждом запросе отправлять свои кастомные параметры помимо основных, есть метод setCommonParameters(_ parameters: [String:Any]), положив в него нужные параметры они будут добавляться к каждому евенту (этого ресивера).
Примеры установки кастомного параметра:
```swift
reciever.setCommonParameters(["client_id": 123])
// или у конкретного ресивера 
service.setCommonParameters(["client_id": 123], reciever.identifier) 
```
**ВАЖНО:** повторное использование setCommonParameters перетирает сохраненные ранее параметры (если они были)


### 4.Трекать события с колбеком:
Если вам понадобилось узнать дошло ли ваше событие аналитики, есть метод trackEventWithCompletion, его можно использовать как для конкретного ресивера, так и для всех сразу.

**ВАЖНО:** событие отправляется единичным и не зависимо от всех остальных. Используйте только если уверены что нужно знать результат

Пример использование: 
``` swift
// 1
service.trackEventWithCompletion(name: "eventName", parameters: ["key":"123"], completion: { 
    print("result is success \($0))
})
// 2
service.trackEventWithCompletion(name: "eventName", parameters: ["key":"123"], receiverIdentifier: reciever.identifier, completion: { 
    print("result is success \($0))
})
```

### 5. Получение атрибуцированных данных

SDK поддерживает возможность получения атрибуцированных данных. Для этого нужно указать атрибут `enableAttributionTracking` = true при инициализации reciever, а также указать делегат:


```swift
let reciever1 = WildAnalyticsReceiver(
    apiKey: apiKey,
    isFirstLaunch: isFirstLaunch,
    enableAttributionTracking: true,
    loggingOptions: loggingOptions,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig(),
    delegate: self
)
```

Структура делегата:

```swift
public protocol WildAnalyticsDelegateProtocol: AnyObject {

    /// Called when WB Tracker found an attributed deeplink that can be handled by the client
    /// - Parameter link: URL
    func didResolveAttributedLink(_ link: URL)
}

```

Метод делегата didResolveAttributedLink вызовется только если в атрибуцированных данных будет найдена ссылка. 


## 📡 Системные события

### Отправляются SDK автоматически

Инициализация полностью на стороне SDK — настройки со стороны клиента не требуются.

| Событие | Триггер | Параметры |
|---|---|---|
| `heartbeat` | первая отправка — через 30 секунд после захода в приложение, далее каждые 30 секунд, пока приложение на переднем плане | нет |
| `first_open` | первое открытие приложения на устройстве пользователя, отдельно для каждого apiKey | нет |
| `application_start` | старт приложения или разворачивание из фона | см. таблицу ниже |

Параметры `application_start`:

| Параметр | Тип | Описание |
|---|---|---|
| `start_location` | string | Откуда открыто приложение: `background` — развёрнуто из фона, `foreground` — запущено с нуля, `unknown` — определить невозможно |
| `cpu` | number | Тактовая частота процессора, ГГц |
| `ram` | number | Объём оперативной памяти, ГБ |
| `processor_name` | string | Название процессора, например `A18 Pro` |

Параметр `isFirstLaunch` в инициализаторе ресивера больше не влияет на `first_open`: SDK
определяет первый запуск самостоятельно. Значение используется только для задержки чтения IDFA.

На устройствах, где SDK уже работал до появления этой версии, событие `first_open` отправлено
не будет — SDK видит следы предыдущего запуска и считает это миграцией, а не первым открытием.
Это осознанная защита от одномоментного всплеска `first_open` по всей действующей базе установок,
а не потеря данных: у таких пользователей `first_open` (или его аналог) уже был отправлен раньше,
до появления этого события в SDK.

### Отправляет клиент

Эти события SDK не формирует сам — их отправляет приложение. **События обязательны для корректной
атрибуции.**

`dynamic_link_app_open` — приложение открыто по ссылке:

| Параметр | Тип | Описание |
|---|---|---|
| `link` | string | URL, по которому было открыто приложение |
| `referrerURL` | string | Referrer ссылки, по которой было открыто приложение; опционально, отсутствует в событии если не передан |

```swift
service.trackLaunchURL(url, referrerURL: referrerURL)
```

`dynamic_push_app_open` — приложение открыто из пуш-уведомления:

| Параметр | Тип | Описание |
|---|---|---|
| `link` | string | Путь URL пуша |
| `push` | string | Текст пуша |

```swift
service.trackEvent(
    name: "dynamic_push_app_open",
    parameters: [
        "link": pushLink,
        "push": pushText
    ]
)
```

## 📝 F.A.Q

 - **Нужно ли вызвать trackEvent не в main queue?** 

Ответ: Нет. SDK самостоятельно оперирует очередью, вызывать можно из любого места.

 - **Как указать нужный api key** 

Ответ: у каждого ресивера есть environment параметр в инициализаторе .production/.test/.custom("YOU_API_KEY")

 - **Как передавать токен пользователя**

Ответ: метод setUserToken сохраняет токен и передает в x-user-token в header'e запроса **(для всех ресиверов)**

- **Если пропадет связь, пользователь выйдет c приложения и тп. Дойдет ли событие аналитики**
 
Ответ: мы сохраняем  евенты в кордату и после отправляем их бачами, в случае если событие **не доходит** до сервера мы пытаемся отправить снова, остальные события ожидают. Посмотреть подробнее можно в BatchWorker.swift 
