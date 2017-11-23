//
//  Queue.swift
//  FlickerImages
//
//  Created by Abdurrahman Ibrahem Ghanem on 11/22/17.
//  Copyright © 2017 Abdurrahman Ibrahem Ghanem. All rights reserved.
//

import Foundation

public class Node<T> {
    
    var value: T
    var next: Node<T>?
    weak var previous: Node<T>?
    
    init(value: T) {
        self.value = value
    }
}

public class LinkedList<T> {
    fileprivate var head: Node<T>?
    private var tail: Node<T>?
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public var first: Node<T>? {
        return head
    }
    
    public var last: Node<T>? {
        return tail
    }
    
    public func append(value: T) {
        let newNode = Node(value: value)
        
        if let tailNode = tail {
            newNode.previous = tailNode
            tailNode.next = newNode
        } 
        else {
            head = newNode
        }
        
        tail = newNode
    }
    
    public func remove(node: Node<T>) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else { 
            head = next
        }
        next?.previous = prev
        
        if next == nil {
            tail = prev
        }
        
        node.previous = nil 
        node.next = nil
        
        return node.value
    }
    
    public func removeAll() {
        while(!isEmpty) {
            if let h = head {
                let _ = self.remove(node: h)
            }
        }
    }
}

public struct Queue<T> {
    
    fileprivate var list = LinkedList<T>()
    
    public var isEmpty: Bool {
        return list.isEmpty
    }
    
    public mutating func enqueue(_ element: T) {
        list.append(value: element)
    }
    
    public mutating func dequeue() -> T? {
        guard !list.isEmpty, let element = list.first else { return nil }
                
        return list.remove(node: element)
    }
    
    public func peek() -> T? {
        return list.first?.value
    }
    
    public func removeAll() {
        list.removeAll()
    }
}
