CREATE VIEW [dbo].[vyuCMBankFileGenerationLog] 
AS
SELECT 
intBankFileGenerationLogId,
intBankAccountId,
intTransactionId,
strTransactionId,
strProcessType,
intBankFileFormatId,
dtmGenerated,
strFileName,
ysnSent,
dtmSent,
intEntityId,
intBatchId = CASE WHEN f.intBatchId = 0 THEN 1e9 ELSE f.intBatchId END,
strGroupName =CASE WHEN f.intBatchId = 0 THEN f.strFileName ELSE 
  'Batch Log ID : ' + CAST(f.intBatchId AS NVARCHAR(10)) +  ' - ' + CONVERT(VARCHAR(11), dtmGenerated, 101)  + ' - ' + strFileName
END,
intConcurrencyId
FROM tblCMBankFileGenerationLog f
