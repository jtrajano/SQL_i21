CREATE VIEW [dbo].vwCMBankReconciliationReport
AS 

SELECT	dtmStatementDate				= Recon.dtmDateReconciled
		,strCbkNo						= BankAccnt.strCbkNo
		,strBankName					= Bank.strBankName
		,strAccountId					= GL.strAccountID
		,dblGLBalance					= [dbo].[fnCMGetBankGLBalance](Recon.intBankAccountId, Recon.dtmDateReconciled) 
		,dblBankAccountBalance			= [dbo].[fnCMGetBankBalance](Recon.intBankAccountId, Recon.dtmDateReconciled)
		,dblPriorReconEndingBalance		= Recon.dblStatementOpeningBalance
		,dblClearedPayments				= Recon.dblDebitCleared
		,dblClearedDeposits				= Recon.dblCreditCleared
		,dblBankStatementEndingBalance	= Recon.dblStatementEndingBalance
		,dblUnclearedPayments			= [dbo].[fnCMGetUnclearedPayments](Recon.intBankAccountId, Recon.dtmDateReconciled)
		,dblUnclearedDeposits			= [dbo].[fnCMGetUnclearedDeposits](Recon.intBankAccountId, Recon.dtmDateReconciled)
FROM	dbo.tblCMBankReconciliation Recon INNER JOIN dbo.tblCMBankAccount BankAccnt
			ON Recon.intBankAccountId = BankAccnt.intBankAccountId
		INNER JOIN dbo.tblCMBank Bank
			ON BankAccnt.intBankId = Bank.intBankId
		INNER JOIN dbo.tblGLAccount GL
			ON BankAccnt.intGLAccountId = GL.intAccountID