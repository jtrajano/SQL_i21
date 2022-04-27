CREATE VIEW [dbo].[vyuICGetInventoryTradeFinance]
AS 

SELECT 
	tf.*
	, cl.strLocationName
	, bank.strBankName
	, bankAccount.strBankAccountNo
	, borrowingFacility.strBorrowingFacilityId
	, strLimit = limit.strBorrowingFacilityLimit
	, strSublimit = sublimit.strLimitDescription
	, strOverrideFacilityValuation = overrideFacilityValuation.strBankValuationRule
FROM 
	tblICInventoryTradeFinance tf
	LEFT JOIN tblSMCompanyLocation cl
		ON cl.intCompanyLocationId = tf.intLocationId
	LEFT JOIN tblCMBank bank 
		ON bank.intBankId = tf.intBankId
	LEFT JOIN vyuCMBankAccount bankAccount
		ON bankAccount.intBankAccountId = tf.intBankAccountId
	LEFT JOIN tblCMBorrowingFacility borrowingFacility
		ON borrowingFacility.intBorrowingFacilityId = tf.intBorrowingFacilityId
	LEFT JOIN tblCMBorrowingFacilityLimit limit 
		ON limit.intBorrowingFacilityLimitId = tf.intLimitTypeId
	LEFT JOIN tblCMBorrowingFacilityLimitDetail sublimit 
		ON sublimit.intBorrowingFacilityLimitDetailId = tf.intSublimitTypeId
	LEFT JOIN tblCMBankValuationRule overrideFacilityValuation
		ON overrideFacilityValuation.intBankValuationRuleId = tf.intOverrideFacilityValuation