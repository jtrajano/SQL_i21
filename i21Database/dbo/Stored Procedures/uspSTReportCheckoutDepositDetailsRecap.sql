CREATE PROCEDURE [dbo].[uspSTReportCheckoutDepositDetailsRecap]
		@intCheckoutId INT 
	
AS

BEGIN TRY
	
	DECLARE @ErrMsg NVARCHAR(MAX)
	
    select dblCash, dblCoin,strChecks,dblTotalDeposit, SUM(dblTotalDeposit) over() as Total 
	from tblSTCheckoutDeposits where intCheckoutId = @intCheckoutId


END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH