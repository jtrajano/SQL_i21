

GO
CREATE PROCEDURE [dbo].[uspSTCheckoutPassportTLM]
@intCheckoutId Int
AS
BEGIN

	UPDATE  dbo.tblSTCheckoutSalesTaxTotals 
	SET dblTotalTax = chk.TaxCollectedAmount,
		dblTaxableSales = chk.TaxableSalesAmount,
		dblTaxExemptSales = chk.TaxExemptSalesAmount
	FROM #tempCheckoutInsert chk
	WHERE intCheckoutId = @intCheckoutId AND chk.TaxCollectedAmount <> 0 AND intTaxNo = 1


END
GO