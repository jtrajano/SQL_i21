CREATE VIEW [dbo].[vyuCMUndepositedPayment]
AS 
SELECT 
Undep.intUndepositedFundId
,Undep.intBankAccountId
,Undep.strSourceTransactionId
,Undep.intSourceTransactionId
,Undep.intLocationId
,Loc.strLocationName
,Undep.dtmDate
,Undep.strName
,Undep.dblAmount
,Undep.strSourceSystem
,Undep.strPaymentMethod
,Undep.intBankDepositId
,Undep.intCreatedUserId
,EM.strName as strUserName
,Undep.dtmCreated
,Undep.intCurrencyId
,strBatchId = (SELECT TOP 1 strBatchId FROM vyuGLDetail WHERE strTransactionId = Undep.strSourceTransactionId AND strTransactionType = 'Receive Payments')
,Pay.strCardType
,Undep.strPaymentSource
,Undep.strEODNumber
,Undep.strEODDrawer 
,Undep.ysnEODComplete 
FROM tblCMUndepositedFund Undep
INNER JOIN tblEMEntity EM ON Undep.intCreatedUserId = EM.intEntityId
INNER JOIN tblSMCompanyLocation Loc ON Undep.intLocationId = Loc.intCompanyLocationId
LEFT JOIN tblSMPayment Pay ON Undep.strSourceTransactionId =  Pay.strTransactionNo
WHERE
Undep.intUndepositedFundId NOT IN( 
	SELECT intUndepositedFundId 
	FROM tblCMBankTransactionDetail BTDtl
	INNER JOIN tblCMBankTransaction BT ON BTDtl.intTransactionId = BT.intTransactionId 
	WHERE BTDtl.intUndepositedFundId IS NOT NULL 
)
AND
Undep.dblAmount <> 0

GO


