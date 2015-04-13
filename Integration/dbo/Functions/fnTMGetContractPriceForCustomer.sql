GO
IF EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetContractPriceForCustomer]') AND type IN (N'FN'))
	DROP FUNCTION [dbo].[fnTMGetContractPriceForCustomer]
GO 
IF (EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcntmst'))
BEGIN 

	EXEC('
	CREATE FUNCTION [dbo].[fnTMGetContractPriceForCustomer](@strCustomerNumber AS NVARCHAR(20))
	RETURNS DECIMAL(18,6)
	AS
	BEGIN 

	DECLARE @returnValue DECIMAL(18,6)

	SELECT TOP 1 
		 @returnValue = CASE WHEN vwcnt_ppd_yndm = ''D'' THEN 0.0 ELSE ISNULL(vwcnt_un_prc,0.0)END
	FROM vwcntmst
	WHERE vwcnt_cus_no = @strCustomerNumber
		AND vwcnt_loc_no <> ''000''
		AND vwcnt_due_rev_dt >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)

	RETURN @returnValue
	END
	')
END
GO