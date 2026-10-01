#!/bin/bash

# Путь к файлу tagVersion.swift относительно текущей директории
TAG_VERSION_FILE="./WildAnalyticsSDK/WildAnalyticsSDK/Sources/WBAnalytics/Models/Tag.swift"
echo "Путь к TAG_VERSION_FILE: $TAG_VERSION_FILE"

# Проверка существования файла
if [ -f "$TAG_VERSION_FILE" ]; then
    echo "Файл $TAG_VERSION_FILE существует."
else
    echo "Файл $TAG_VERSION_FILE не найден. Проверьте путь."
    exit 1  # Завершение скрипта с ошибкой
fi

# Получение новой версии из файла Tag.swift
version=$(grep -o -E '[0-9]+\.[0-9]+\.[0-9]+' "$TAG_VERSION_FILE")
