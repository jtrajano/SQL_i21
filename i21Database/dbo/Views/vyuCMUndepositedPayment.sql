CREATE VIEW [dbo].vyuCMUndepositedPayment
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
,strBatchId = (SELECT TOP 1 strBatchId FROM vyuGLDetail WHERE intTransactionId = Undep.intSourceTransactionId AND strTransactionType = 'Receive Payments')
,SUBSTRING(Pay.strPaymentInfo,1,PATINDEX('% ending%',Pay.strPaymentInfo)) as strCardType
FROM tblCMUndepositedFund Undep
INNER JOIN tblEMEntity EM ON Undep.intCreatedUserId = EM.intEntityId
INNER JOIN tblSMCompanyLocation Loc ON Undep.intLocationId = Loc.intCompanyLocationId
LEFT JOIN tblSMPayment Pay ON Undep.intSourceTransactionId =  Pay.intTransactionId
WHERE
Undep.intUndepositedFundId NOT IN( 
	SELECT intUndepositedFundId 
	FROM tblCMBankTransactionDetail BTDtl
	INNER JOIN tblCMBankTransaction BT ON BTDtl.intTransactionId = BT.intTransactionId 
	WHERE BT.intBankAccountId = Undep.intBankAccountId AND BTDtl.intUndepositedFundId IS NOT NULL 
)