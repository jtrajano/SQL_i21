GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vyuTMLeaseCode')
	DROP VIEW vyuTMLeaseCode

GO

IF EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwlclmst')
BEGIN
	EXEC('
		CREATE VIEW vyuTMLeaseCode
		AS
		SELECT
			A.*
			,strTaxState = ISNULL(B.vwlcl_tax_state COLLATE Latin1_General_CI_AS,'''') 
			,strTaxLocale1 = ISNULL(B.vwlcl_tax_auth_id1 COLLATE Latin1_General_CI_AS,'''')
			,strTaxLocale2 =  ISNULL(B.vwlcl_tax_auth_id2 COLLATE Latin1_General_CI_AS ,'''')
		FROM dbo.tblTMLeaseCode A
		LEFT JOIN vwlclmst B
			ON A.intTaxIndicatorId = B.A4GLIdentity
		')
END	
GO	