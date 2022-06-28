CREATE VIEW vyuARGetScheduledPaymentMethods
AS
SELECT intScheduledPaymentMethodId	= SPM.intScheduledPaymentMethodId
	 , intEntityCardInfoId			= SPM.intEntityCardInfoId
	 , intBankAccountId				= SPM.intBankAccountId
	 , intEntityId					= SPM.intEntityId
	 , intDayOfMonth				= SPM.intDayOfMonth
	 , strPaymentMethodType			= SPM.strPaymentMethodType
	 , strBankAccountNo				= dbo.fnAESDecryptASym(BA.strBankAccountNo)
	 , strBankName					= B.strBankName
	 , strCardExpDate				= ECI.strCardExpDate
	 , strCardHolderName			= ECI.strCardHolderName
	 , strCardType					= ECI.strCardType
	 , strCreditCardNumber			= ECI.strCreditCardNumber
	 , dtmDateCreated				= ECI.dtmDateCreated
	 , ysnActive					= CASE WHEN SPM.intEntityCardInfoId IS NOT NULL THEN ECI.ysnActive ELSE CAST(1 AS BIT) END
	 , ysnAutoPay					= SPM.ysnAutoPay
	 , intConcurrencyId				= SPM.intConcurrencyId		
FROM tblARScheduledPaymentMethod SPM
LEFT JOIN tblEMEntityCardInformation ECI ON SPM.intEntityCardInfoId = ECI.intEntityCardInfoId AND ECI.strToken IS NOT NULL AND ECI.strCardExpDate != '01/00'
LEFT JOIN tblCMBankAccount BA ON SPM.intBankAccountId = BA.intBankAccountId
LEFT JOIN tblCMBank B ON BA.intBankId = B.intBankId