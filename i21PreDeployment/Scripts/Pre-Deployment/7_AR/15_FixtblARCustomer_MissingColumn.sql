PRINT '********************** BEGIN - CHECK FOR MISSING COLUMNS IN tblARCustomer **********************'
GO

IF(EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblARCustomer'))
BEGIN
	IF(NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblARCustomer' AND COLUMN_NAME = N'ysnExemptCreditCardFee'))
	BEGIN
		ALTER TABLE tblARCustomer ADD ysnExemptCreditCardFee BIT NOT NULL DEFAULT(0);
	END

	IF(NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblARCustomer' AND COLUMN_NAME = N'intInterCompanyId'))
	BEGIN
		ALTER TABLE tblARCustomer ADD intInterCompanyId INT NULL;
	END

	IF(NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblARCustomer' AND COLUMN_NAME = N'dblHighestDueAR'))
	BEGIN
		ALTER TABLE tblARCustomer ADD dblHighestDueAR NUMERIC(18,6);
	END

	IF(NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblARCustomer' AND COLUMN_NAME = N'dblHighestAR'))
	BEGIN
		ALTER TABLE tblARCustomer ADD dblHighestAR NUMERIC(18,6);
	END

	IF(NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblARCustomer' AND COLUMN_NAME = N'dtmHighestARDate'))
	BEGIN
		ALTER TABLE tblARCustomer ADD dtmHighestARDate DATETIME;
	END

	IF(NOT EXISTS(SELECT * FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = N'tblARCustomer' AND COLUMN_NAME = N'dtmHighestDueARDate'))
	BEGIN
		ALTER TABLE tblARCustomer ADD dtmHighestDueARDate DATETIME;
	END
END

PRINT ' ********************** END - CHECK FOR MISSING COLUMNS IN tblARCustomer  **********************'
GO