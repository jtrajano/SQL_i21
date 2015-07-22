CREATE VIEW [dbo].[vyuAPRptCheckRegister]
	AS 
	SELECT  tblCMBankTransaction.ysnCheckVoid,
		tblCMBankTransaction.ysnClr,
		'AP' AS strSystem,
                tblCMBankAccount.intBankId,
		tblCMBankTransactionType.strBankTransactionTypeName,
		dtmDateReconciled AS dtmClearedDate,
		ISNULL((SELECT SUM(dblDiscount) FROM tblAPPaymentDetail WHERE intPaymentId = tblAPPayment.intPaymentId),0) as dblDiscount,
		ISNULL(tblAPPayment.dblWithheld,0) AS dblWithheldAmount,
		ISNULL(tblCMBankTransaction.dblAmount,0) AS dblAmount,
		tblCMBankAccount.strCbkNo,
		tblCMBankTransaction.strMemo,
		tblCMBankTransaction.dtmDate,
		tblCMBankTransaction.strReferenceNo AS chkNo,
		tblCMBankTransaction.strPayee,
		(SELECT strBankName FROM tblCMBank WHERE intBankId = tblCMBankAccount.intBankId) as strBankName
	FROM dbo.tblCMBankTransaction tblCMBankTransaction 
	INNER JOIN tblCMBankTransactionType
	ON tblCMBankTransaction.intBankTransactionTypeId =  tblCMBankTransaction.intBankTransactionTypeId
	INNER JOIN tblCMBankAccount
	ON tblCMBankAccount.intBankAccountId =  tblCMBankTransaction.intBankAccountId
	INNER JOIN tblAPPayment
	ON tblCMBankTransaction.strTransactionId = tblAPPayment.strPaymentRecordNum
	where tblCMBankTransactionType.strBankTransactionTypeName = 'AP Payment'
