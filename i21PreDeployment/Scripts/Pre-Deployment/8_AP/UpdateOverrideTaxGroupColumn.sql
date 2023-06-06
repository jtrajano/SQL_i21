--THIS WILL UPDATE THE tblAPBillDetail.ysnOverrideTaxGroup
GO

IF COL_LENGTH('tblAPBillDetail','ysnOverrideTaxGroup') IS NOT NULL
BEGIN
	UPDATE tblAPBillDetail SET ysnOverrideTaxGroup = 0 
	WHERE ysnOverrideTaxGroup IS NULL
END

GO