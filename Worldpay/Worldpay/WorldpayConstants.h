//
//  WorldpayConstants.h
//  Worldpay
//
//  Created by Vitalii Parovishnyk on 2/15/19.
//  Copyright © 2019 Worldpay. All rights reserved.
//

#ifndef WorldpayConstants_h
#define WorldpayConstants_h

typedef NS_ENUM(NSUInteger, WorldpayValidationType) {
    WorldpayValidationTypeBasic,
    WorldpayValidationTypeAdvanced,
    
    WorldpayValidationTypeCount
};

typedef NS_ENUM(NSUInteger, WorldpayCardType) {
    WorldpayCardType_unknown = 0,
    WorldpayCardType_electron,
    WorldpayCardType_maestro,
    WorldpayCardType_dankort,
    WorldpayCardType_interpayment,
    WorldpayCardType_unionpay,
    WorldpayCardType_visa,
    WorldpayCardType_visa_checkout,
    WorldpayCardType_mastercard,
    WorldpayCardType_amex,
    WorldpayCardType_diners,
    WorldpayCardType_discover,
    WorldpayCardType_jcb,
    WorldpayCardType_laser,
    WorldpayCardType_masterpass,
    
    WorldpayCardType_Count
};

#endif /* WorldpayConstants_h */
