CREATE VIEW [dbo].[vyuCMProcessPaymentArchive] 
AS
SELECT 
CM.intTransactionId,
CM.ysnCheckToBePrinted,
CM.dtmDate,
strRecordNo = CM.strTransactionId,
strPayee = CASE WHEN CM.intPayeeId IS NULL THEN CM.strPayee ELSE EM.strName END,
strCheckNo = CM.strReferenceNo,
CM.intBankTransactionTypeId,
CM.dblAmount,
CM.intCurrencyId,
CM.dblExchangeRate,
dblForeignAmount = CM.dblAmount/ CASE WHEN CM.dblExchangeRate = 0 THEN 1 ELSE CM.dblExchangeRate END,
EM.intEntityId,
ysnCommitted =  CAST( CASE WHEN CM.dtmCheckPrinted IS NULL THEN 1 ELSE 0 END AS BIT),
CM.ysnEmailSent,
CM.strEmailStatus,
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
CM.dtmDateReconciled,
ysnReconciled = CAST( CASE WHEN CM.dtmDateReconciled = NULL THEN 0 ELSE 1 END AS BIT ),
CM.ysnCheckVoid,
EMCL.strClass,
EMC.strEmailDistributionOption,
CM.ysnPosted
FROM tblCMBankTransaction  CM
JOIN vyuCMBankFileGenerationLog F  ON CM.intTransactionId = F.intTransactionId
LEFT JOIN tblEMEntity EM on EM.intEntityId = CM.intPayeeId
LEFT JOIN tblEMEntityClass EMCL ON EMCL.intEntityClassId = EM.intEntityClassId
OUTER APPLY(
	SELECT intEntityId, strClass, strEmailDistributionOption FROM vyuEMEntityContact where ysnActive = 1 and intEntityId = CM.intPayeeId

)EMC

