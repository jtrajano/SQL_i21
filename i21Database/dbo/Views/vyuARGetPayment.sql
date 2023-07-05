CREATE VIEW [dbo].[vyuARGetPayment]
AS 
SELECT intPaymentId						= P.intPaymentId
	 , intEntityCustomerId				= P.intEntityCustomerId
	 , intCurrencyId					= P.intCurrencyId
	 , intAccountId						= P.intAccountId
	 , intBankAccountId					= P.intBankAccountId
	 , dtmDatePaid						= P.dtmDatePaid
	 , intPaymentMethodId				= P.intPaymentMethodId
	 , intLocationId					= P.intLocationId
	 , dblAmountPaid					= P.dblAmountPaid
	 , dblBaseAmountPaid				= P.dblBaseAmountPaid
	 , dblUnappliedAmount				= P.dblUnappliedAmount
	 , dblBaseUnappliedAmount			= P.dblBaseUnappliedAmount
	 , dblOverpayment					= P.dblOverpayment
	 , dblBaseOverpayment				= P.dblBaseOverpayment
	 , dblBalance						= P.dblBalance
	 , dblExchangeRate					= P.dblExchangeRate
	 , strRecordNumber					= P.strRecordNumber
	 , strReceivePaymentType			= P.strReceivePaymentType
	 , strPaymentInfo					= P.strPaymentInfo
	 , strNotes							= P.strNotes
	 , ysnApplytoBudget					= P.ysnApplytoBudget
	 , ysnApplyOnAccount				= P.ysnApplyOnAccount
	 , ysnPosted						= P.ysnPosted
	 , ysnImportedFromOrigin			= P.ysnImportedFromOrigin
	 , ysnImportedAsPosted				= P.ysnImportedAsPosted
	 , intEntityId						= P.intEntityId
	 , intWriteOffAccountId				= NULLIF(P.intWriteOffAccountId, 0)
	 , intCurrencyExchangeRateTypeId	= P.intCurrencyExchangeRateTypeId
	 , strPaymentMethod					= PM.strPaymentMethod
	 , intEntityCardInfoId				= P.intEntityCardInfoId
	 , ysnProcessCreditCard				= P.ysnProcessCreditCard
	 , ysnProcessedToNSF				= P.ysnProcessedToNSF
	 , ysnInvoicePrepayment				= P.ysnInvoicePrepayment
	 , ysnShowAPTransaction				= P.ysnShowAPTransaction
	 , intConcurrencyId					= P.intConcurrencyId
	 , intCurrentStatus					= P.intCurrentStatus
	 , strCustomerName					= C.strName
	 , strCustomerNumber				= C.strCustomerNumber
	 , dblTotalAR						= C.dblARBalance
	 , dblCreditLimit					= C.dblCreditLimit
	 , ysnHasBudgetSetup				= C.ysnHasBudgetSetup
	 , strLocationName					= CL.strLocationName
	 , strCurrency						= CUR.strCurrency
	 , strBankAccountNo					= BA.strBankAccountNo
	 , strWriteOffAccountId				= GL.strAccountId
	 , strCurrencyExchangeRateType		= SERT.strCurrencyExchangeRateType
	 , strTransactionId					= BT.strTransactionId
	 , ysnExemptCreditCardFee			= C.ysnExemptCreditCardFee
	 , strCardType						= PM.strCardType
	 , dblConvenienceFee				= ISNULL(PM.dblConvenienceFee, 0)
	 , strConvenienceFeeType			= ISNULL(PM.strConvenienceFeeType, 'None')
	 , ysnIntraCompany					= P.ysnIntraCompany
	 , ysnScheduledPayment				= ISNULL(P.ysnScheduledPayment, 0)
	 , dtmScheduledPayment				= P.dtmScheduledPayment
	 , strCreditCardStatus				= P.strCreditCardStatus
	 , strCreditCardNote				= P.strCreditCardNote
	 , strAddress						= C.strAddress
	 , strZipCode						= C.strZipCode
FROM tblARPayment P WITH (NOLOCK)
INNER JOIN vyuARCustomerSearch C ON C.intEntityId = P.intEntityCustomerId
INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = P.intLocationId
INNER JOIN tblSMCurrency CUR ON CUR.intCurrencyID = P.intCurrencyId
LEFT JOIN vyuARPaymentMethodForReceivePayments PM ON (P.intPaymentMethodId <> 11 AND P.intPaymentMethodId = PM.intPaymentMethodID) 
												   OR (P.intPaymentMethodId = 11 AND PM.intEntityCardInfoId = P.intEntityCardInfoId)
LEFT JOIN tblGLAccount GL ON P.intWriteOffAccountId = GL.intAccountId
LEFT JOIN tblSMCurrencyExchangeRateType SERT ON SERT.intCurrencyExchangeRateTypeId = P.intCurrencyExchangeRateTypeId
LEFT JOIN vyuCMBankAccount BA ON BA.intBankAccountId = P.intBankAccountId
LEFT JOIN vyuARPaymentBankTransaction BT ON P.intPaymentId = BT.intPaymentId AND P.strRecordNumber = BT.strRecordNumber