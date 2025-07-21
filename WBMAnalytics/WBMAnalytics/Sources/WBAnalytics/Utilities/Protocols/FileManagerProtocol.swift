//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation
/// 'Закрывает' FileManager
public protocol FileManagerProtocol {
    /// Создаёт файл по указанному пути. Если файл уже есть - перезаписывает
    ///
    /// - Parameters:
    ///   - atPath: Путь к файлу для записи
    ///   - contents: Дата для записи в новый файл
    ///   - attributes: Атрибуты создаваемого файла.
    @discardableResult
    func createFile(atPath: String, contents: Data?, attributes: [FileAttributeKey: Any]?) -> Bool

    /// Создаёт директорию по указанному пути.
    ///
    /// - Parameters:
    ///   - atURL: Путь к директории для создания
    ///   - createIntermediates: -
    ///   - attributes: Атрибуты создаваемой директории.
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]?) throws

    /// Читает содержимое файла по указанному пути.
    ///
    /// - Parameter path: Путь к файлу для чтения.
    /// - Returns: Содержимое файла.
    /// Если в path передана директория, или в процессе чтения возникла ошибка, возвращает nil.
    func contents(atPath path: String) -> Data?

    /// Возвращает массив адресов для запрошенной директории в выбранном домене.
    ///
    /// - Parameters:
    ///   - directory: Директория для поиска
    ///   - domainMask: Домен файловой системы для поиска директории
    func urls(
        for directory: FileManager.SearchPathDirectory,
        in domainMask: FileManager.SearchPathDomainMask
    ) -> [URL]

    /// Возвращает логическое значение, указывающее, существует ли файл или каталог по указанному пути.
    ///
    /// - parameter path: Путь к файлу или каталогу. Если путь начинается с ~,
    /// его сначала нужно развернуть с помощью expandingTildeInPath;
    /// в противном случае этот метод возвращает false.
    /// - returns: true, если файл по указанному пути существует, или значение false,
    /// если файл не существует или его существование не может быть определено.
    func fileExists(atPath path: String) -> Bool

    /// Удаляет файл или каталог по указанному пути.
    ///
    /// - parameter path: Путь до файла или каталога для удаления.
    /// - returns: true, если элемент был успешно удален. Возвращает false, если произошла ошибка.
    func removeItem(atPath path: String) throws

    /// Удаляет файл или каталог по указанному пути.
    ///
    /// - parameter path: Путь до файла или каталога для удаления.
    /// - returns: true, если элемент был успешно удален. Возвращает false, если произошла ошибка.
    func removeItem(at path: URL) throws

    /// Перемещает файл или каталог по указанному пути
    /// - Parameters:
    ///   - srcURL: Изначальный путь до файлы или каталога
    ///   - dstURL: Конечный путь до файлы или каталога
    func moveItem(at srcURL: URL, to dstURL: URL) throws

    /// Копирует файл или каталог по указанному пути.
    ///
    /// - Parameters:
    ///   - srcURL: Изначальный путь до файла или каталога
    ///   - dstURL: Конечный путь до файла или каталога
    func copyItem(at srcURL: URL, to dstURL: URL) throws

    /// Возвращает URL для указанного каталога в указанной области поиска.
    ///
    /// - Parameters:
    ///   - directory: Каталог для поиска
    ///   - domain: Область поиска
    ///   - url: Относительный путь для поиска
    ///   - shouldCreate: Флаг, указывающий, нужно ли создавать каталог, если он не существует
    /// - Returns: URL для указанного каталога
    func url(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL?,
        create shouldCreate: Bool
    ) throws -> URL

    /// Возвращает атрибуты файла или каталога по указанному пути.
    ///
    /// - parameter path: Путь до файла или каталога
    /// - returns: Словарь атрибутов файла или каталога
    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey : Any]
}

extension FileManager: FileManagerProtocol { }
