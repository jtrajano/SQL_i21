CREATE VIEW vyuCMBankStatementImportStd
AS
SELECT
strBankStatementImportId,
BSI.intBankStatementImportId,
BSI.dtmDate, 
BSI.strReferenceNo, 
BSI.dblWithdrawalAmount,
BSI.dblDepositAmount,
BSI.intImportStatus,
BankTrans.dblAmount, 
0 AS dblDiff,
'OK' AS strResult
FROM
tblCMBankStatementImport BSI 
cross APPLY(
	SELECT
	dblAmount
	FROM tblCMBankTransaction 
	WHERE intBankStatementImportId =BSI.intBankStatementImportId 
)BankTrans
WHERE intImportStatus = 1

UNION

SELECT
strBankStatementImportId,
BSI.intBankStatementImportId,
BSI.dtmDate, 
BSI.strReferenceNo, 
BSI.dblWithdrawalAmount,
BSI.dblDepositAmount,
BSI.intImportStatus,
BankTrans.dblAmount,
ABS(BSI.dblAmount) -  ABS(BankTrans.dblAmount) AS dblDiff,
CASE 
	WHEN BSI.dblWithdrawalAmount - BankTrans.dblAmount <> 0 THEN 'Difference Found' 
	ELSE 'Reference No not found'
END AS strResult
FROM
tblCMBankStatementImport BSI 
OUTER APPLY(
	SELECT
	dblAmount
	FROM tblCMBankTransaction CM join
	tblCMBankTransactionType T ON CM.intBankTransactionTypeId = T.intBankTransactionTypeId
	WHERE intBankAccountId =BSI.intBankAccountId 
	AND 
	REPLACE(LTRIM(REPLACE(ISNULL(BSI.strReferenceNo,'') , '0', ' ')), ' ', '0') =
	REPLACE(LTRIM(REPLACE(ISNULL(strReferenceNo,''), '0', ' ')), ' ', '0') 
	AND ysnClr = 0
	AND intBankStatementImportId IS NULL
	AND BSI.strDebitCredit =
	CASE WHEN T.intBankTransactionTypeId = 5 THEN
		CASE WHEN  dblAmount > 0 THEN 'C' ELSE 'D' END
	ELSE
		T.strDebitCredit
	END
)BankTrans
WHERE intImportStatus <> 1