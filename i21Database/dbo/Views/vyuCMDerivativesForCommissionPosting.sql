CREATE VIEW [dbo].[vyuCMDerivativesForCommissionPosting]
AS 
SELECT 
	A.*
	,BA.intBankAccountId
	,strBankAccountNo = ISNULL(dbo.fnAESDecryptASym(BA.strBankAccountNo),strBankAccountNo) COLLATE Latin1_General_CI_AS
FROM vyuCMRKDerivativesForCommissionPosting A
INNER JOIN tblCMBankAccount BA
	ON BA.intBrokerageAccountId = A.intBrokerageAccountId
