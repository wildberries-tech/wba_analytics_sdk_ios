//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation
/// 'Wraps' FileManager
public protocol FileManagerProtocol {
    /// Creates a file at the given path. If the file already exists, overwrites it.
    ///
    /// - Parameters:
    ///   - atPath: Path to the file to write.
    ///   - contents: Data to write into the new file.
    ///   - attributes: Attributes of the file being created.
    @discardableResult
    func createFile(atPath: String, contents: Data?, attributes: [FileAttributeKey: Any]?) -> Bool

    /// Creates a directory at the given path.
    ///
    /// - Parameters:
    ///   - atURL: Path to the directory to create.
    ///   - createIntermediates: -
    ///   - attributes: Attributes of the directory being created.
    func createDirectory(at url: URL, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey: Any]?) throws

    /// Reads the contents of the file at the given path.
    ///
    /// - Parameter path: Path to the file to read.
    /// - Returns: The file's contents.
    /// Returns nil if a directory is passed in path, or if an error occurs while reading.
    func contents(atPath path: String) -> Data?

    /// Returns an array of URLs for the requested directory in the chosen domain.
    ///
    /// - Parameters:
    ///   - directory: The directory to search for.
    ///   - domainMask: The file system domain to search the directory in.
    func urls(
        for directory: FileManager.SearchPathDirectory,
        in domainMask: FileManager.SearchPathDomainMask
    ) -> [URL]

    /// Returns a boolean value indicating whether a file or directory exists at the given path.
    ///
    /// - parameter path: Path to the file or directory. If the path starts with ~,
    /// it must first be expanded using expandingTildeInPath;
    /// otherwise this method returns false.
    /// - returns: true if a file exists at the given path, or false
    /// if the file doesn't exist or its existence can't be determined.
    func fileExists(atPath path: String) -> Bool

    /// Removes the file or directory at the given path.
    ///
    /// - parameter path: Path to the file or directory to remove.
    /// - returns: true if the item was removed successfully. Returns false if an error occurred.
    func removeItem(atPath path: String) throws

    /// Removes the file or directory at the given path.
    ///
    /// - parameter path: Path to the file or directory to remove.
    /// - returns: true if the item was removed successfully. Returns false if an error occurred.
    func removeItem(at path: URL) throws

    /// Moves the file or directory at the given path.
    /// - Parameters:
    ///   - srcURL: Source path of the file or directory.
    ///   - dstURL: Destination path of the file or directory.
    func moveItem(at srcURL: URL, to dstURL: URL) throws

    /// Copies the file or directory at the given path.
    ///
    /// - Parameters:
    ///   - srcURL: Source path of the file or directory.
    ///   - dstURL: Destination path of the file or directory.
    func copyItem(at srcURL: URL, to dstURL: URL) throws

    /// Returns the URL for the given directory in the given search scope.
    ///
    /// - Parameters:
    ///   - directory: The directory to search for.
    ///   - domain: The search scope.
    ///   - url: The relative path to search for.
    ///   - shouldCreate: Flag indicating whether to create the directory if it doesn't exist.
    /// - Returns: The URL for the given directory.
    func url(
        for directory: FileManager.SearchPathDirectory,
        in domain: FileManager.SearchPathDomainMask,
        appropriateFor url: URL?,
        create shouldCreate: Bool
    ) throws -> URL

    /// Returns the attributes of the file or directory at the given path.
    ///
    /// - parameter path: Path to the file or directory.
    /// - returns: A dictionary of the file's or directory's attributes.
    func attributesOfItem(atPath path: String) throws -> [FileAttributeKey : Any]
}

extension FileManager: FileManagerProtocol { }
