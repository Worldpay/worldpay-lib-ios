# Use the --use-libraries switch when pushing or linting this podspec

Pod::Spec.new do |s|

  s.name         = 'Worldpay'
  s.version      = '1.6.0'
  s.summary      = 'Worldpay iOS Library'

  s.description  = <<-DESC
				The Worldpay iOS Library makes it easy to process credit card & apm payments direct from your app. The library allows you to create your own payment form while at the same time making it easy to meet the security guidelines of Visa, MasterCard and Amex (called "PCI compliance rules"). We also offer the possibility to save the token that has been created in order to prevent the user from re-entering the card details.
                   DESC

  s.homepage            = 'https://online.worldpay.com'
  s.author              = 'Worldpay'

  s.platform                = :ios, '9.0'
  s.source                  = { :git => 'https://github.com/driivz/worldpay-lib-ios.git',
                                :tag => s.version
                            }

  s.public_header_files     = 'Worldpay/Worldpay/APMController*.h', 'Worldpay/Worldpay/ThreeDSController.h', 'Worldpay/Worldpay/Worldpay.h', 'Worldpay/Worldpay/Worldpay+ApplePay.h', 'Worldpay/Worldpay/WorldpayAPMViewController.h', 'Worldpay/Worldpay/WorldpayCardViewController.h', 'Worldpay/Worldpay/UIImage+Worldpay.h', 'Worldpay/Worldpay/WorldpayConstants.h'
  s.source_files            = 'Worldpay/Worldpay/*.{h,m}'
  s.resources               = 'Worldpay/output/Worldpay/Include/WorldpayResources.bundle'
  s.requires_arc            = true
  s.weak_frameworks         = 'UIKit', 'Foundation', 'CoreGraphics'

  s.ios.dependency 'AFNetworking'
end
