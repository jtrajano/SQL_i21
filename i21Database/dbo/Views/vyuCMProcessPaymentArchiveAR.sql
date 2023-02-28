CREATE VIEW [dbo].[vyuCMProcessPaymentArchiveAR] 
AS
SELECT 
CM.intTransactionId,
CM.ysnCheckToBePrinted,
CM.dtmDate,
strRecordNo = CM.strRecordNo,
strPayee = CM.strName,
strCheckNo = CM.strReferenceNo,
CM.intBankTransactionTypeId,
CM.dblAmount,
CM.intCurrencyId,
CM.dblExchangeRate,
dblForeignAmount = CM.dblAmount/ CASE WHEN CM.dblExchangeRate = 0 THEN 1 ELSE CM.dblExchangeRate END,
EM.intEntityId,
CM.ysnCommitted,
ysnEmailSent = CM.ysnNotified,
strEmailStatus = CM.strNotificationStatus,
strNotificationType = CASE WHEN EMC.intEntityId = NULL THEN 'Print' ELSE 'Email' END,
F.intBankFileGenerationLogId,
CM.intBankAccountId,
CM.strTransactionId,
F.strProcessType,
F.intBankFileFormatId,
F.dtmGenerated,
F.strFileName,
F.intBatchId,
F.strGroupName,
F.ysnSent,
F.dtmSent,
CM.ysnCheckVoid,
EMCL.strClass,
EMC.strEmailDistributionOption,
CM.ysnGenerated,
CM.intBankFileAuditId
FROM vyuCMACHFromCustomer  CM
JOIN vyuCMBankFileGenerationLog F  ON CM.intTransactionId = F.intTransactionId
LEFT JOIN tblEMEntity EM on EM.intEntityId = CM.intEntityId
LEFT JOIN tblEMEntityClass EMCL ON EMCL.intEntityClassId = EM.intEntityClassId
OUTER APPLY(
	SELECT TOP 1 intEntityId, strClass, strEmailDistributionOption FROM vyuEMEntityContact where ysnActive = 1 and intEntityId = CM.intEntityCustomerId

)EMC

