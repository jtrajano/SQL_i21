CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTranslogFuelComputation]
	@intCheckoutId											INT,
	@UDT_Translog StagingTransactionLogFuelComputation		READONLY
AS
BEGIN

INSERT INTO tblSTCheckoutFuelSalesByGradeAndPricePoint (intCheckoutId, intProductNumber, dblPrice, dblDollarsSold, dblGallonsSold, intConcurrencyId)
SELECT	@intCheckoutId,
		a.intProductNumber,
		a.dblPrice,
		a.dblDollarsSold,
		a.dblGallonsSold,
		1
FROM	@UDT_Translog a

END