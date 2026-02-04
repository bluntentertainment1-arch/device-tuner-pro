import UIKit
import UserMessagingPlatform

final class ConsentManager {

    static func requestConsent(
        from viewController: UIViewController,
        completion: @escaping () -> Void
    ) {
        let parameters = UMPRequestParameters()
        parameters.tagForUnderAgeOfConsent = false

        UMPConsentInformation.sharedInstance.requestConsentInfoUpdate(
            with: parameters
        ) { error in
            if let error {
                print("❌ Consent update error: \(error.localizedDescription)")
                completion()
                return
            }

            let status = UMPConsentInformation.sharedInstance.consentStatus

            if status == .required {
                UMPConsentForm.load { form, error in
                    if let error {
                        print("❌ Consent form load error: \(error.localizedDescription)")
                        completion()
                        return
                    }

                    form?.present(from: viewController) {
                        completion()
                    }
                }
            } else {
                // Consent not required or already obtained
                completion()
            }
        }
    }
}
