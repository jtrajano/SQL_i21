CREATE PROCEDURE [dbo].[uspSTReportCheckoutTaxRecap]
	@intCheckoutId INT  
	
AS
BEGIN TRY
	
   DECLARE @ErrMsg NVARCHAR(MAX)
  
	SELECT 
		A.intCheckoutId
		, A.strTaxNo
		, A.dblTotalTax AS TotalTax
		, A.dblTaxableSales AS TaxableSales
		, A.dblTaxExemptSales AS TaxExemptSales
		, B.strAccountId
		, B.strDescription
	FROM tblSTCheckoutSalesTaxTotals A 
	LEFT JOIN tblGLAccount B 
		ON A.intSalesTaxAccount = B.intAccountId
	WHERE A.intCheckoutId = @intCheckoutId
		AND A.dblTotalTax IS NOT NULL
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH