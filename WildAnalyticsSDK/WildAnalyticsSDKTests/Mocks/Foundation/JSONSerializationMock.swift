//
//  Copyright © 2024 Wildberries LLC. All rights reserved.
//

import Foundation

public final class JSONSerializationMock: JSONSerialization {
    // MARK: - reset

    /// Должно вызываться в tearDown
    public static func reset() {
        // data
        dataWasCalled = 0
        dataReceivedArguments = nil
        dataStub = Data()
        dataErrorStub = nil

        // jsonObject
        jsonObjectWasCalled = 0
        jsonObjectReceivedArguments = nil
        jsonObjectStub = []
        jsonObjectErrorStub = nil
    }

    // MARK: - data

    public private(set) static var dataWasCalled = 0
    public private(set) static var dataReceivedArguments: (
        withJSONObject: Any,
        options: JSONSerialization.WritingOptions
    )?
    public static var dataStub = Data()
    public static var dataErrorStub: Error?

    override public static func data(
        withJSONObject obj: Any,
        options opt: JSONSerialization.WritingOptions
    ) throws -> Data {
        dataWasCalled += 1
        dataReceivedArguments = (obj, opt)

        if let error = dataErrorStub { throw error }

        return dataStub
    }

    // MARK: - jsonObject

    public private(set) static var jsonObjectWasCalled = 0
    public private(set) static var jsonObjectReceivedArguments: (
        data: Data,
        opt: JSONSerialization.ReadingOptions
    )?
    public static var jsonObjectStub: Any = []
    public static var jsonObjectErrorStub: Error?

    override public static func jsonObject(
        with data: Data,
        options opt: JSONSerialization.ReadingOptions
    ) throws -> Any {
        jsonObjectWasCalled += 1
        jsonObjectReceivedArguments = (data, opt)
        if let error = jsonObjectErrorStub { throw error }
        return jsonObjectStub
    }
}
