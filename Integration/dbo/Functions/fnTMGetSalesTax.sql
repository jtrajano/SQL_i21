GO
IF EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetSalesTax]') AND type IN (N'FN'))
	DROP FUNCTION [dbo].[fnTMGetSalesTax]
GO 

IF (EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwlclmst')
	AND EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwtaxmst')
)
EXEC('
CREATE FUNCTION [dbo].[fnTMGetSalesTax](
	@strItemNumber AS NVARCHAR(20)
	,@intTaxId INT)
RETURNS DECIMAL(18,6)
AS
BEGIN 

	DECLARE @returnValue DECIMAL(18,6)

	DECLARE @strTaxState NVARCHAR(5)
	DECLARE @strTaxLocale1 NVARCHAR(5)
	DECLARE @strTaxLocale2 NVARCHAR(5)

	SELECT TOP 1 
		 @strTaxState = vwlcl_tax_state
		 ,@strTaxLocale1 = vwlcl_tax_auth_id1
		 ,@strTaxLocale2 = vwlcl_tax_auth_id2
	FROM vwlclmst
	WHERE A4GLIdentity = @intTaxId 
	
	SELECT TOP 1 @returnValue = dblSalesTaxRate
	FROM vwtaxmst
	WHERE vwtax_itm_no = @strItemNumber 
		AND vwtax_state = @strTaxState
		AND vwtax_auth_id1 = @strTaxLocale1
		AND vwtax_auth_id2 = @strTaxLocale2
		AND dtmEffectiveDate <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
	ORDER BY dtmEffectiveDate ASC
	
	IF(@returnValue IS NULL)
	BEGIN
		SELECT TOP 1 @returnValue = dblSalesTaxRate
		FROM vwtaxmst
		WHERE vwtax_state = @strTaxState
			AND vwtax_auth_id1 = @strTaxLocale1
			AND vwtax_auth_id2 = @strTaxLocale2
			AND dtmEffectiveDate <= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)
			AND vwtax_itm_no = ''''
		ORDER BY dtmEffectiveDate ASC
	END
	
		
	RETURN ISNULL(@returnValue,0.0)
END
')
GO