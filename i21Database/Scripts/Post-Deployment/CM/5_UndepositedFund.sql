GO
PRINT('Begin cleaning up Undeposited Funds table')
GO
-- Clean up tblCMUndepositedFund
BEGIN TRY
	DELETE FROM tblCMBankTransactionDetail 	WHERE dblDebit = 0 AND dblCredit = 0 
	DELETE FROM tblCMUndepositedFund WHERE dblAmount = 0
END TRY
BEGIN CATCH
	PRINT ERROR_MESSAGE()
END CATCH

GO
PRINT('Finished cleaning up Undeposited Funds table')

PRINT('Begin updating Undeposited table')
GO

DELETE Undep
FROM tblCMUndepositedFund Undep
INNER JOIN tblARPayment Pay
ON Pay.strRecordNumber = Undep.strSourceTransactionId
WHERE Pay.intPaymentMethodId = 9 -- REMOVE CF INVOICE

;WITH AR AS(
	SELECT strRecordNumber strTransactionId
		, PAYMENT.intCurrencyId
		, strPaymentSource		= CASE WHEN POSEOD.strEODNo IS NULL THEN 'Manual Entry' ELSE 'POS' END COLLATE Latin1_General_CI_AS
		, strEODNumber			= POSEOD.strEODNo
		, strDrawerName			= POSDRAWER.strPOSDrawerName
		, ysnCompleted			= POSEOD.ysnClosed 
	FROM tblARPayment PAYMENT
	INNER JOIN tblARPaymentDetail PAYMENTDETAILS ON PAYMENT.intPaymentId = PAYMENTDETAILS.intPaymentId
	LEFT OUTER JOIN tblARPOS POS ON PAYMENTDETAILS.intInvoiceId = POS.intInvoiceId
	LEFT OUTER JOIN tblARPOSLog POSLOG ON POS.intPOSLogId = POSLOG.intPOSLogId
	LEFT OUTER JOIN tblARPOSEndOfDay POSEOD ON POSLOG.intPOSEndOfDayId = POSEOD.intPOSEndOfDayId
	LEFT OUTER JOIN tblSMCompanyLocationPOSDrawer POSDRAWER ON POSEOD.intCompanyLocationPOSDrawerId = POSDRAWER.intCompanyLocationPOSDrawerId
	UNION
	SELECT strInvoiceNumber strTransactionId
		, intCurrencyId
		, strPaymentSource		= NULL
		, strEODNumber			= NULL
		, strDrawerName			= NULL
		, ysnCompleted			= 0 
	
	FROM tblARInvoice UNION
	SELECT strEODNo strTransactionId, intCurrencyId
		, strPaymentSource		= 'POS' COLLATE Latin1_General_CI_AS
		, strEODNumber			= EOD.strEODNo
		, strDrawerName			= DRAWER.strPOSDrawerName
		, ysnCompleted			= ysnClosed
	
	FROM tblARPOSEndOfDay EOD INNER JOIN
	tblSMCompanyLocationPOSDrawer DRAWER
	ON EOD.intCompanyLocationPOSDrawerId = DRAWER.intCompanyLocationPOSDrawerId
)
UPDATE Undep
SET intCurrencyId = AR.intCurrencyId
, strPaymentSource			= AR.strPaymentSource
, strEODNumber				= AR.strEODNumber
, strEODDrawer			= AR.strDrawerName
, ysnEODComplete		=	AR.ysnCompleted
FROM  tblCMUndepositedFund Undep
LEFT JOIN AR on AR.strTransactionId = Undep.strSourceTransactionId

GO
PRINT('Finished updating Undeposited Table')
GO


