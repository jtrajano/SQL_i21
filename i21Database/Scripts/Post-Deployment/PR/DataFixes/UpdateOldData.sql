/***********************
* UPDATING OLD DATA
************************/

/*
* Employee Workers Compensation 
* 1. Change Rate Type from "Amount" to "Per Dollar"
* 2..
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRWorkersCompensation'))
BEGIN
	EXEC ('
	UPDATE tblPRWorkersCompensation 
		SET strCalculationType = ''Per Dollar''
	WHERE strCalculationType IS NULL OR strCalculationType = ''Amount''
	')
END

/*
* Deduction Types
* 1. Remove Expense Account from Deduction Types that are Paid By Employee
* 2...
*/

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRTypeDeduction'))
BEGIN
	EXEC ('UPDATE tblPRTypeDeduction SET intExpenseAccountId = NULL WHERE strPaidBy = ''Employee'' AND intExpenseAccountId IS NOT NULL')
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRTemplateDeduction'))
BEGIN
	EXEC ('UPDATE tblPRTemplateDeduction SET intExpenseAccountId = NULL WHERE strPaidBy = ''Employee'' AND intExpenseAccountId IS NOT NULL')
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPREmployeeDeduction'))
BEGIN
	EXEC ('UPDATE tblPREmployeeDeduction SET intExpenseAccountId = NULL WHERE strPaidBy = ''Employee'' AND intExpenseAccountId IS NOT NULL')
END

IF EXISTS(SELECT * FROM sys.tables WHERE object_id = object_id('tblPRPaycheckDeduction'))
BEGIN
	EXEC ('UPDATE tblPRPaycheckDeduction SET intExpenseAccountId = NULL WHERE strPaidBy = ''Employee'' AND intExpenseAccountId IS NOT NULL')
END