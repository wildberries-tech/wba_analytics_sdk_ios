# WBMAnalytics

SDK для логирования событий в IOS-приложении. События последовательно группируются в батчи и отправляются на сервер. Поддерживается конфигурация для production и debug окружений. Ведется подсчет отправленных событий и батчей для контроля потери данных. До момента отправки события хранятся в CoreData. В случае отсутствия сети события будут отправлены при её появлении. 

## ⬇️ Install

SDK поставляется через SPM, для добавления в свой проект достаточно добавить в свой проект 

```
.package(url:"https://github.com/wildberries-tech/wba_analytics_sdk_ios.git",exact:  "3.5.7")
```

## 🚀 Launch in app

В приложении подразумевается один инстанс аналитики который может поддерживает несколько ресиверов

Для создания экземпляра WBAnalyticsReceiver необходимо передать несколько обязательных параметров в его инициализатор:
    
- **environment:** Окружение приложения, может быть .production или .test, при необходимости можно установить свой apiKey .custom("apiKey"). ([пример](https://gitlab.wildberries.ru/mobile/ios/analytics/-/blob/master/WBMAnalytics/WBMAnalyticsTestApp/AppDelegate.swift?ref_type%253Dheads#L31))
- **analyticsURL:** URL, на который будут отправляться аналитические данные.
- **isFirstLaunch:** Флаг, указывающий, является ли текущий запуск приложения первым.  (хранится где-то у вас допустим в UserDefaults [пример](https://gitlab.wildberries.ru/mobile/ios/analytics/-/blob/master/WBMAnalytics/WBMAnalyticsTestApp/AppDelegate.swift?ref_type%253Dheads#L30))
- **enableAttributionTracking:** Включение/выключение автоматической атрибуции трафика. 
- **loggingOptions:** Настройки логирования, включая уровень логирования и файловую запись. [Подробнее](.Docs/LoggingOptions.md)
- **networkTypeProvider:** Объект, предоставляющий информацию о текущем типе сети.
- **batchConfig:** Конфигурация пакетной отправки данных.

для каждого ресивера можно выставлять свои параметры и свои apiKey, после ресивер передается в единый инстанс. После инициализации нужно засетапить ресивер.

Пример инициализации ресивера:
```swift
let service = WBMAnalytics()

let apiKey = "<PUT API KEY HERE>"

let reciever1 = WBAnalyticsReceiver(
    apiKey: apiKey,
    isFirstLaunch: isFirstLaunch,
    loggingOptions: loggingOptions,
    networkTypeProvider: networkTypeProvider,
    batchConfig: BatchConfig()
)
reciever1.setup() // Важно сетапить перед использованием

let reciever2 = WBAnalyticsReceiver(
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
let reciever1 = WBAnalyticsReceiver(
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
public protocol WBAnalyticsDelegateProtocol: AnyObject {

    /// Called when WB Tracker found an attributed deeplink that can be handled by the client
    /// - Parameter link: URL
    func didResolveAttributedLink(_ link: URL)
}

```

Метод делегата didResolveAttributedLink вызовется только если в атрибуцированных данных будет найдена ссылка. 

### 6. Трекинг IDFA

```swift
service.setIDFA(<idfa>)
```

## 📝 F.A.Q

 - **Нужно ли вызвать trackEvent не в main queue?** 

Ответ: Нет. SDK самостоятельно оперирует очередью, вызывать можно из любого места.

 - **Как передавать токен пользователя**

Ответ: метод setUserToken сохраняет токен и передает в x-user-token в header'e запроса **(для всех ресиверов)**

- **Если пропадет связь, пользователь выйдет c приложения и тп. Дойдет ли событие аналитики**
 
Ответ: мы сохраняем  евенты в кордату и после отправляем их бачами, в случае если событие **не доходит** до сервера мы пытаемся отправить снова, остальные события ожидают. Посмотреть подробнее можно в BatchWorker.swift 
