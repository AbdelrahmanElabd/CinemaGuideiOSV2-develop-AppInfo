//
//  NotificationService.swift
//  CinemaGuideNotificationsService
//
//  Created by Hesham Haleem on 1/3/18.
//  Copyright © 2018 HeshamHaleem. All rights reserved.
//

import UserNotifications

class NotificationService: NetmeraNotificationServiceExtension {

    var contentHandler: ((UNNotificationContent) -> Void)?
    var bestAttemptContent: UNMutableNotificationContent?

    override func didReceive(_ request: UNNotificationRequest, withContentHandler contentHandler: @escaping (UNNotificationContent) -> Void) {
        super.didReceive(request, withContentHandler: contentHandler)
    }
    
    override func serviceExtensionTimeWillExpire() {
        super.serviceExtensionTimeWillExpire()
    }

}
