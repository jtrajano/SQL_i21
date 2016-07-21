CREATE PROCEDURE [dbo].[uspSTReportCheckoutTaxRecap]
	@intCheckoutId INT  
	
AS

BEGIN TRY
	
   DECLARE @ErrMsg NVARCHAR(MAX)
  
   select A.intCheckoutId
    ,A.dblTotalTax As TotalTax
	,A.dblTaxableSales as TaxableSales
	,A.dblTaxExemptSales as TaxExemptSales
	,B.strAccountId
	,B.strDescription
   from tblSTCheckoutSalesTaxTotals A 
   LEFT JOIN tblGLAccount B ON A.intSalesTaxAccount = B.intAccountId
   where A.intCheckoutId = @intCheckoutId
   and A.dblTotalTax is not NULL 
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH