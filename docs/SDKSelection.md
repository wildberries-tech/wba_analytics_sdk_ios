# Выбор SDK для проекта

В проекте используются две версии SDK аналитики:

| Версия SDK | Назначение | Где использовать |
| --- | --- | --- |
| Внутренний SDK | SDK для внутренних продуктов и команд компании. Также может использоваться как базовый SDK на этапе разработки решений для внешних заказчиков. | Только внутренние проекты. |
| Публичный SDK | SDK для интеграции аналитики во внешние клиентские проекты. | Только внешние проекты. |

Основное правило: внутренний SDK не подключается во внешние проекты, а публичный SDK не используется во внутренних проектах.

Если решение для внешнего заказчика на раннем этапе разрабатывалось на базе внутреннего SDK, перед передачей заказчику или внешним релизом необходимо заменить его на публичный SDK.

Отдельный допустимый кейс: во внешнем продукте может быть подключен другой SDK, например Auth SDK или User ID SDK, внутри которого уже используется приватный SDK аналитики. Такая аналитика относится к внутренней реализации этого SDK и работает отдельно. При этом сам внешний продукт все равно должен подключать публичный SDK аналитики для своих событий.

```mermaid
%%{init: {"theme": "base", "themeVariables": {"fontFamily": "Inter, Arial, sans-serif", "primaryColor": "#F7F8FA", "primaryTextColor": "#1F2328", "primaryBorderColor": "#D0D7DE", "lineColor": "#667085", "secondaryColor": "#EEF4FF", "tertiaryColor": "#F6FEF9"}}}%%
flowchart LR
    start([Проект]) --> known{Тип проекта<br/>определен?}

    known -- Нет --> clarify[Уточнить назначение<br/>и владельца проекта]
    clarify --> known

    known -- Да --> projectType{Для кого<br/>проект?}

    subgraph internalPath[Внутренний сценарий]
        direction TB
        internal[Внутренний проект] --> internalSdk[Подключить<br/>внутренний SDK]
        internalSdk --> internalSetup[Настроить ресиверы,<br/>API-ключи и окружения]
        internalSetup --> internalRelease([Внутренний релиз])
    end

    subgraph externalPath[Внешний сценарий]
        direction TB
        external[Внешний продукт] --> externalProductAnalytics[Аналитика продукта]
        externalProductAnalytics --> publicSdk[Подключить<br/>публичный SDK]
        publicSdk --> externalSetup[Настроить ресиверы,<br/>API-ключи и окружения]

        external --> integratedSdk["Интегрированный SDK<br/>например Auth / User ID SDK"]
        integratedSdk --> privateAnalytics[Приватный SDK аналитики<br/>внутри интегрированного SDK]
        privateAnalytics --> isolated[Работает отдельно<br/>и не заменяет публичный SDK]

        externalSetup --> externalRelease([Передача заказчику<br/>или внешний релиз])
        isolated --> externalRelease
    end

    projectType -- Внутренний продукт --> internal
    projectType -- Внешний заказчик --> external

    baseDev[Разработка внешнего решения<br/>на базе внутреннего SDK] -. временно допустимо .-> migration[Заменить внутренний SDK<br/>на публичный SDK]
    migration -. обязательно до релиза .-> externalRelease

    internalSdk -. не использовать<br/>во внешних проектах .-> restriction1{{Запрещено}}
    publicSdk -. не использовать<br/>во внутренних проектах .-> restriction2{{Запрещено}}
    privateAnalytics -. не подключать напрямую<br/>как аналитику внешнего продукта .-> restriction3{{Запрещено}}

    classDef start fill:#111827,stroke:#111827,color:#FFFFFF;
    classDef decision fill:#FFF7ED,stroke:#FDBA74,color:#7C2D12;
    classDef internal fill:#EEF4FF,stroke:#84ADFF,color:#1849A9;
    classDef external fill:#ECFDF3,stroke:#75E0A7,color:#027A48;
    classDef embedded fill:#F0F9FF,stroke:#7DD3FC,color:#075985;
    classDef warning fill:#FEF3F2,stroke:#FDA29B,color:#B42318;
    classDef neutral fill:#F7F8FA,stroke:#D0D7DE,color:#344054;

    class start start;
    class known,projectType decision;
    class internal,internalSdk,internalSetup,internalRelease internal;
    class external,externalProductAnalytics,publicSdk,externalSetup,externalRelease external;
    class integratedSdk,privateAnalytics,isolated embedded;
    class baseDev,migration,restriction1,restriction2,restriction3 warning;
    class clarify neutral;
```

## Порядок использования

1. Определите тип проекта до подключения SDK.
2. Для внутреннего проекта подключите внутренний SDK.
3. Для внешнего проекта подключите публичный SDK.
4. Если внешний проект был начат на базе внутреннего SDK, замените его на публичный SDK до передачи заказчику или внешнего релиза.
5. Если внешний проект использует SDK со встроенной приватной аналитикой, например Auth SDK или User ID SDK, оставьте эту аналитику внутри такого SDK и не используйте ее как аналитику внешнего продукта.
6. После выбора SDK настройте ресиверы, API-ключи и окружения согласно инструкции подключения.
