GO
	PRINT N'START FIX GL ACCOUNTS'

	UPDATE tblSMCompanyLocation SET intAPAccount = NULL WHERE intAPAccount NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intARAccount = NULL WHERE intARAccount NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intCashAccount = NULL WHERE intCashAccount NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intDepositAccount = NULL WHERE intDepositAccount NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intPurchaseAdvAccount = NULL WHERE intPurchaseAdvAccount NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intSalesAdvAcct = NULL WHERE intSalesAdvAcct NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intServiceCharges = NULL WHERE intServiceCharges NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intSalesDiscounts = NULL WHERE intSalesDiscounts NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intCashOverShort = NULL WHERE intCashOverShort NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intWriteOff = NULL WHERE intWriteOff NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intCreditCardFee = NULL WHERE intCreditCardFee NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intSalesAccount = NULL WHERE intSalesAccount NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intDiscountAccountId = NULL WHERE intDiscountAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intInterestAccountId = NULL WHERE intInterestAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intWithholdAccountId = NULL WHERE intWithholdAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intUndepositedFundsId = NULL WHERE intUndepositedFundsId NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intPrepaidAccountId = NULL WHERE intPrepaidAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intDeferredPayableId = NULL WHERE intDeferredPayableId NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intPettyCash = NULL WHERE intPettyCash NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intDeferredRevenueId = NULL WHERE intDeferredRevenueId NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intFreightAPAccount = NULL WHERE intFreightAPAccount NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intFreightExpenses = NULL WHERE intFreightExpenses NOT IN (SELECT intAccountId FROM tblGLAccount)
	UPDATE tblSMCompanyLocation SET intDeferredPayableInterestId = NULL WHERE intDeferredPayableInterestId NOT IN (SELECT intAccountId FROM tblGLAccount)
	
	PRINT N'END FIX GL ACCOUNTS'
GO