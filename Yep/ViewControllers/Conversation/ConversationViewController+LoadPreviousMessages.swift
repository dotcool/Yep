//
//  ConversationViewController+LoadPreviousMessages.swift
//  Yep
//
//  Created by NIX on 16/6/28.
//  Copyright © 2016年 Catch Inc. All rights reserved.
//

import Foundation
import YepKit
import YepNetworking

extension ConversationViewController {

    func tryLoadPreviousMessages(completion: () -> Void) {

        if isLoadingPreviousMessages {
            completion()
            return
        }

        isLoadingPreviousMessages = true

        println("tryLoadPreviousMessages")

        if displayedMessagesRange.location == 0 {

            if let recipient = recipient {

                let timeDirection: TimeDirection
                var invalidMessageIDSet: Set<String>?
                if let (message, headInvalidMessageIDSet) = firstValidMessageInMessageResults(messages) {
                    let maxMessageID = message.messageID
                    timeDirection = .Past(maxMessageID: maxMessageID)
                    invalidMessageIDSet = headInvalidMessageIDSet
                } else {
                    timeDirection = .None
                }

                messagesFromRecipient(recipient, withTimeDirection: timeDirection, failureHandler: { reason, errorMessage in
                    defaultFailureHandler(reason: reason, errorMessage: errorMessage)

                    SafeDispatch.async {
                        completion()
                    }

                }, completion: { _messageIDs, noMore in
                    println("@ messagesFromRecipient: \(_messageIDs.count)")

                    var messageIDs: [String] = []
                    if let invalidMessageIDSet = invalidMessageIDSet {
                        for messageID in _messageIDs {
                            if !invalidMessageIDSet.contains(messageID) {
                                messageIDs.append(messageID)
                            }
                        }
                    } else {
                        messageIDs = _messageIDs
                    }
                    println("# messagesFromRecipient: \(messageIDs.count)")

                    SafeDispatch.async { [weak self] in

                        if case .Past = timeDirection {
                            self?.noMorePreviousMessages = noMore
                        }

                        tryPostNewMessagesReceivedNotificationWithMessageIDs(messageIDs, messageAge: timeDirection.messageAge)
                        //self?.fayeRecievedNewMessages(messageIDs, messageAgeRawValue: timeDirection.messageAge.rawValue)

                        self?.isLoadingPreviousMessages = false
                        completion()
                    }
                })
            }

        } else {

            var newMessagesCount = self.messagesBunchCount

            if (self.displayedMessagesRange.location - newMessagesCount) < 0 {
                newMessagesCount = self.displayedMessagesRange.location
            }

            if newMessagesCount > 0 {
                self.displayedMessagesRange.location -= newMessagesCount
                self.displayedMessagesRange.length += newMessagesCount

                self.lastTimeMessagesCount = self.messages.count // 同样需要纪录它

                var indexPaths = [NSIndexPath]()
                for i in 0..<newMessagesCount {
                    let indexPath = NSIndexPath(forItem: Int(i), inSection: Section.Message.rawValue)
                    indexPaths.append(indexPath)
                }

                let bottomOffset = self.conversationCollectionView.contentSize.height - self.conversationCollectionView.contentOffset.y

                CATransaction.begin()
                CATransaction.setDisableActions(true)

                self.conversationCollectionView.performBatchUpdates({ [weak self] in
                    self?.conversationCollectionView.insertItemsAtIndexPaths(indexPaths)

                }, completion: { [weak self] finished in
                    if let strongSelf = self {
                        var contentOffset = strongSelf.conversationCollectionView.contentOffset
                        contentOffset.y = strongSelf.conversationCollectionView.contentSize.height - bottomOffset

                        strongSelf.conversationCollectionView.setContentOffset(contentOffset, animated: false)
                        
                        CATransaction.commit()
                        
                        // 上面的 CATransaction 保证了 CollectionView 在插入后不闪动

                        self?.isLoadingPreviousMessages = false
                        completion()
                    }
                })
            }
        }
    }
}

