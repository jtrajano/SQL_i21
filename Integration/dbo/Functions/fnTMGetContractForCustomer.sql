GO
PRINT 'BEGIN CREATE fnTMGetContractPriceForCustomer'

GO
IF EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetContractPriceForCustomer]') AND type IN (N'FN'))
	DROP FUNCTION [dbo].[fnTMGetContractPriceForCustomer]
GO 

GO
IF EXISTS (SELECT TOP 1 1 FROM   sys.objects WHERE  object_id = OBJECT_ID(N'[dbo].[fnTMGetContractForCustomer]') AND type IN (N'FN'))
	DROP FUNCTION [dbo].[fnTMGetContractForCustomer]
GO 
IF (EXISTS(select top 1 1 from INFORMATION_SCHEMA.VIEWS where TABLE_NAME = 'vwcntmst'))
BEGIN 

	EXEC('
	CREATE FUNCTION [dbo].[fnTMGetContractForCustomer](@strCustomerNumber AS NVARCHAR(20))
	RETURNS NVARCHAR(20)
	AS
	BEGIN 

	DECLARE @returnValue NVARCHAR(20)

	SELECT TOP 1 
		 @returnValue = vwcnt_cnt_no
	FROM vwcntmst
	WHERE vwcnt_cus_no = @strCustomerNumber
		AND vwcnt_loc_no <> ''000''
		AND vwcnt_due_rev_dt >= DATEADD(dd, DATEDIFF(dd, 0, GETDATE()), 0)

	RETURN ISNULL(@returnValue,'''')
	END
	')
END
GO
PRINT 'END CREATE fnTMGetContractPriceForCustomer'

GO