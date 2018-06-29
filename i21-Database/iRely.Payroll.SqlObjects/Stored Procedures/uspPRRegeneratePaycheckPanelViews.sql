CREATE PROCEDURE uspPRRegeneratePaycheckPanelViews
AS
DECLARE @cols NVARCHAR(MAX)

/* Regenerate Paycheck Tax Panel View */

IF EXISTS(SELECT TOP 1 1 FROM tblPRTypeTax)
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vyuPRPaycheckTaxPanel') 
	BEGIN 
		EXEC ('DROP VIEW vyuPRPaycheckTaxPanel');
	END

	SELECT @cols = STUFF((SELECT DISTINCT ',[' + LTRIM(RTRIM(strTax)) +']' FROM tblPRTypeTax FOR XML PATH('')),1,1,'')
	EXEC (
	N'CREATE VIEW vyuPRPaycheckTaxPanel
	AS
	SELECT * FROM 
		(SELECT DISTINCT
			EmployeeName = strFirstName + '' '' + strMiddleName + '' '' + strLastName 
			,CheckNo = PCheck.strPaycheckId
			,PayDate = PCheck.dtmPayDate
			,TaxTotal = PTax.dblTotal
			,TaxCode = TType.strTax
			,CheckTotal = PCheck.dblGross
			,CheckNet = PCheck.dblNetPayTotal
		 FROM 
			tblPRPaycheck PCheck
			INNER JOIN tblPRPaycheckTax PTax ON PCheck.intPaycheckId = PTax.intPaycheckId
			INNER JOIN tblPRTypeTax TType ON PTax.intTypeTaxId = TType.intTypeTaxId
			INNER JOIN tblPREmployee E ON E.intEntityId = PCheck.intEntityEmployeeId) AS s 
		PIVOT
		(
		SUM(TaxTotal)
		FOR TaxCode IN (' + @cols + ')
		) AS pvt
	')
END

/* Regenerate Paycheck Earning Panel View */
IF EXISTS(SELECT TOP 1 1 FROM tblPRTypeEarning)
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vyuPRPaycheckEarningPanel') 
	BEGIN 
		EXEC ('DROP VIEW vyuPRPaycheckEarningPanel');
	END

	SELECT @cols = STUFF((SELECT DISTINCT ',[' + LTRIM(RTRIM(strEarning)) +']' FROM tblPRTypeEarning FOR XML PATH('')),1,1,'')
	EXEC (
	N'CREATE VIEW vyuPRPaycheckEarningPanel
	AS
	SELECT * FROM 
		(SELECT DISTINCT
			EmployeeName = strFirstName + '' '' + strMiddleName + '' '' + strLastName 
			,CheckNo = PCheck.strPaycheckId
			,PayDate = PCheck.dtmPayDate
			,EarningTotal = PTax.dblTotal
			,EarningCode = TType.strEarning 
			,CheckTotal = PCheck.dblGross
			,CheckNet = PCheck.dblNetPayTotal
		FROM 
			tblPRPaycheck PCheck
			INNER JOIN tblPRPaycheckEarning PTax ON PCheck.intPaycheckId = PTax.intPaycheckId
			INNER JOIN tblPRTypeEarning TType ON PTax.intTypeEarningId = TType.intTypeEarningId
			INNER JOIN tblPREmployee E ON E.intEntityId = PCheck.intEntityEmployeeId
		) AS s
		PIVOT
		(	SUM(EarningTotal)
			FOR EarningCode IN (' + @cols + ')
		) AS pvt
	')
END

/* Regenerate Paycheck Deduction Panel View */
IF EXISTS(SELECT TOP 1 1 FROM tblPRTypeDeduction)
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM INFORMATION_SCHEMA.VIEWS WHERE TABLE_NAME = 'vyuPRPaycheckDeductionPanel') 
	BEGIN 
		EXEC ('DROP VIEW vyuPRPaycheckDeductionPanel');
	END

	SELECT @cols = STUFF((SELECT DISTINCT ',[' + LTRIM(RTRIM(strDeduction)) +']' FROM tblPRTypeDeduction FOR XML PATH('')),1,1,'')
	EXEC (
	N'CREATE VIEW vyuPRPaycheckDeductionPanel
	AS
	SELECT * FROM 
		(SELECT DISTINCT
			EmployeeName = strFirstName + '' '' + strMiddleName + '' '' + strLastName 
			,CheckNo = PCheck.strPaycheckId
			,PayDate = PCheck.dtmPayDate
			,DeductionTotal = PTax.dblTotal
			,DeductionCode = TType.strDeduction 
			,CheckTotal = PCheck.dblGross
			,CheckNet = PCheck.dblNetPayTotal
		FROM 
		tblPRPaycheck PCheck
		INNER JOIN tblPRPaycheckDeduction PTax ON PCheck.intPaycheckId = PTax.intPaycheckId
		INNER JOIN tblPRTypeDeduction TType ON PTax.intTypeDeductionId = TType.intTypeDeductionId
		INNER JOIN tblPREmployee E ON E.intEntityId = PCheck.intEntityEmployeeId
		) AS s
		PIVOT
		(	SUM(DeductionTotal)
			FOR DeductionCode IN (' + @cols + ')
		)as pvt 
	')
END

GO