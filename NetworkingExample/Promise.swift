//
//  Promise.swift
//  NetworkingExample
//
//  Created by Gualtiero Frigerio on 12/04/2019.
//  Copyright © 2019 Gualtiero Frigerio. All rights reserved.
//

import Foundation

enum PromiseReturn<T> {
    case value(T)
    case error(Error)
}

class Promise<T> {
    private var callbacks = [(PromiseReturn<T>) -> Void]()
    private var result:PromiseReturn<T>? {
        didSet {
            if let res = result {
                for callback in callbacks {
                    callback(res)
                }
            }
        }
    }
    
    func observe(callback: @escaping (PromiseReturn<T>) -> Void) {
        callbacks.append(callback)
        if let result = result {
            callback(result)
        }
    }
    
    func reject(error:Error) {
        result = .error(error)
    }
    
    func resolve(value:T) {
        result = .value(value)
    }
    
    func then<P>(_ block:@escaping(T) -> Promise<P>) -> Promise<P> {
        let thenPromise = Promise<P>()
        observe { currentPromiseReturn in
            switch currentPromiseReturn {
            case .value(let val):
                let promise = block(val)
                promise.observe { result in
                    switch result {
                    case .value(let value):
                        thenPromise.resolve(value: value)
                    case .error(let err):
                        thenPromise.reject(error: err)
                    }
                }
            case .error(let err):
                thenPromise.reject(error: err)
            }
        }
        return thenPromise
    }
}
