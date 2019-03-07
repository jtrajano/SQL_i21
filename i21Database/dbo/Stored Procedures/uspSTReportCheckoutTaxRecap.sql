CREATE PROCEDURE [dbo].[uspSTReportCheckoutTaxRecap]
	@intCheckoutId INT  
AS
BEGIN TRY
	
   DECLARE @ErrMsg NVARCHAR(MAX)
  
	SELECT 
		CheckTax.intCheckoutId
		, CheckTax.strTaxNo
		, SMTax.strTaxCode
		, CheckTax.dblTotalTax AS TotalTax
		, CheckTax.dblTaxableSales AS TaxableSales
		, CheckTax.dblTaxExemptSales AS TaxExemptSales
		, GLAccount.strAccountId
		, GLAccount.strDescription
	FROM tblSTCheckoutSalesTaxTotals CheckTax 
	INNER JOIN tblSTCheckoutHeader CH
		ON CheckTax.intCheckoutId = CH.intCheckoutId
	INNER JOIN tblSTStore ST
		ON CH.intStoreId = ST.intStoreId
	INNER JOIN tblSTStoreTaxTotals STTax
		ON ST.intStoreId = STTax.intStoreId
	INNER JOIN tblSMTaxCode SMTax
		ON STTax.intTaxCodeId = SMTax.intTaxCodeId
		AND CheckTax.strTaxNo = SMTax.strStoreTaxNumber
	LEFT JOIN tblGLAccount GLAccount 
		ON CheckTax.intSalesTaxAccount = GLAccount.intAccountId
	WHERE CheckTax.intCheckoutId = @intCheckoutId
		AND CheckTax.dblTotalTax IS NOT NULL
    
END TRY

BEGIN CATCH

	SET @ErrMsg = ERROR_MESSAGE()  
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')  
	--<?xml version="1.0" encoding="utf-16"?><xmlparam><filters><filter><fieldname>intCheckoutId</fieldname><condition>Equal To</condition><from>21</from><to /><join>And</join><begingroup /><endgroup /><datatype>Integer</datatype></filter></filters><options /></xmlparam>
END CATCH