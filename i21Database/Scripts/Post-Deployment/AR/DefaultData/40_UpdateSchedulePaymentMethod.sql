PRINT '********************** BEGIN - Insert Scheduled Payment Methods **********************'
GO

INSERT INTO tblARScheduledPaymentMethod (
	   intEntityId
     , intEntityCardInfoId
	 , intBankAccountId
	 , strPaymentMethodType
	 , ysnAutoPay
     , intDayOfMonth
)
SELECT intEntityId				= ECI.intEntityId
     , intEntityCardInfoId		= ECI.intEntityCardInfoId
	 , intBankAccountId			= NULL
	 , strPaymentMethodType		= 'Credit Card'
	 , ysnAutoPay				= ECI.ysnAutoPay
     , intDayOfMonth			= ECI.intDayOfMonth
FROM tblEMEntityCardInformation ECI
LEFT JOIN tblARScheduledPaymentMethod SPM ON ECI.intEntityCardInfoId = SPM.intEntityCardInfoId
WHERE SPM.intScheduledPaymentMethodId IS NULL

PRINT ' ********************** END - Insert Scheduled Payment Methods  **********************'
GO