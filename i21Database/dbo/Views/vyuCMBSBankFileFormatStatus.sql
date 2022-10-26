
CREATE VIEW vyuCMBSBankFileFormatStatus
AS
SELECT intBankFileFormatId 'BankFileFormatId'
	, FileFormatName
	, ysnSystemGenerated
	,[tblCMBankTransaction.dblAmount] 'Amount'
	,[tblCMBankTransaction.dblWithdrawalAmount] 'Debit'
	,[tblCMBankTransaction.dblDepositAmount] 'Credit'
	,[Cleared Date] 'ClearDate'
	,[tblCMBankTransaction.strReferenceNo] 'CheckNumber'
	,[tblCMBankAccount.strBankAccountNo] 'BankAccountNo'
	,[Bank Description] 'BankDescription'
FROM
(
SELECT A.intBankFileFormatId,A.strName FileFormatName ,  A.strName, B.strFieldName, ysnSystemGenerated from tblCMBankFileFormat A
LEFT JOIN
tblCMBankFileFormatDetail B ON A.intBankFileFormatId = B.intBankFileFormatId
WHERE A.intBankFileType = 3
) AS sourceTable
PIVOT 
(
	count( strName ) 
	FOR strFieldName IN (
	[tblCMBankTransaction.dblAmount]
	,[tblCMBankTransaction.dblWithdrawalAmount]
	,[tblCMBankTransaction.dblDepositAmount]
	,[Cleared Date]
	,[tblCMBankTransaction.strReferenceNo]
	,[tblCMBankAccount.strBankAccountNo]
	,[Bank Description]
	)	
) AS PivotTable





