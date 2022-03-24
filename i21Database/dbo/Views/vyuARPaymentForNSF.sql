CREATE VIEW [dbo].[vyuARPaymentForNSF]
AS
SELECT intTransactionId		= P.intPaymentId
	 , intEntityCustomerId	= P.intEntityCustomerId
	 , intCurrencyId		= P.intCurrencyId
	 , intCompanyLocationId	= P.intLocationId
	 , intAccountId			= P.intAccountId
	 , strTransactionNumber	= P.strRecordNumber	 
	 , strCustomerName		= LTRIM(RTRIM(E.strName))	 
	 , strPaymentInfo		= P.strPaymentInfo
	 , strTransactionType	= 'Payment' COLLATE Latin1_General_CI_AS
	 , dblAmountPaid		= P.dblAmountPaid
	 , dblUnappliedAmount	= P.dblUnappliedAmount
	 , dtmDatePaid			= P.dtmDatePaid
	 , ysnInvoicePrepayment	= P.ysnInvoicePrepayment
FROM dbo.tblARPayment P WITH (NOLOCK)
INNER JOIN dbo.tblEMEntity E WITH (NOLOCK) ON P.intEntityCustomerId = E.intEntityId
INNER JOIN dbo.tblSMPaymentMethod SM WITH (NOLOCK) ON P.intPaymentMethodId = SM.intPaymentMethodID
INNER JOIN dbo.tblCMUndepositedFund UF WITH (NOLOCK) ON P.intPaymentId = UF.intSourceTransactionId
											        AND P.strRecordNumber = UF.strSourceTransactionId
INNER JOIN dbo.tblCMBankTransactionDetail BTD WITH (NOLOCK) ON UF.intUndepositedFundId = BTD.intUndepositedFundId
INNER JOIN dbo.tblCMBankTransaction BT WITH (NOLOCK) ON BTD.intTransactionId = BT.intTransactionId 
WHERE P.ysnProcessedToNSF = 0
  AND P.ysnPosted = 1
    AND SM.strPaymentMethod IN ('Check', 'eCheck', 'ACH', 'Manual Credit Card', 'Credit Card')
  AND BT.ysnPosted = 1

UNION ALL

SELECT intTransactionId		= I.intInvoiceId
	 , intEntityCustomerId	= I.intEntityCustomerId
	 , intCurrencyId		= I.intCurrencyId
	 , intCompanyLocationId	= I.intCompanyLocationId
	 , intAccountId			= I.intAccountId
	 , strTransactionNumber	= I.strInvoiceNumber	 
	 , strCustomerName		= LTRIM(RTRIM(E.strName))	 
	 , strPaymentInfo		= I.strPaymentInfo
	 , strTransactionType	= 'Cash' COLLATE Latin1_General_CI_AS
	 , dblAmountPaid		= I.dblInvoiceTotal
	 , dblUnappliedAmount	= 0.000000
	 , dtmDatePaid			= I.dtmPostDate
	 , ysnInvoicePrepayment	= CAST(0 AS BIT)
FROM dbo.tblARInvoice I WITH (NOLOCK)
INNER JOIN dbo.tblEMEntity E WITH (NOLOCK) ON I.intEntityCustomerId = E.intEntityId
INNER JOIN dbo.tblSMPaymentMethod SM WITH (NOLOCK) ON I.intPaymentMethodId = SM.intPaymentMethodID
INNER JOIN dbo.tblCMUndepositedFund UF WITH (NOLOCK) ON I.intInvoiceId = UF.intSourceTransactionId
											        AND I.strInvoiceNumber = UF.strSourceTransactionId
INNER JOIN dbo.tblCMBankTransactionDetail BTD WITH (NOLOCK) ON UF.intUndepositedFundId = BTD.intUndepositedFundId
INNER JOIN dbo.tblCMBankTransaction BT WITH (NOLOCK) ON BTD.intTransactionId = BT.intTransactionId 
WHERE I.ysnProcessedToNSF = 0
  AND I.ysnPosted = 1
  AND I.intPaymentMethodId IS NOT NULL
  AND I.strTransactionType = 'Cash'
  AND SM.strPaymentMethod IN ('Check', 'eCheck', 'ACH', 'Manual Credit Card', 'Credit Card')
  AND BT.ysnPosted = 1