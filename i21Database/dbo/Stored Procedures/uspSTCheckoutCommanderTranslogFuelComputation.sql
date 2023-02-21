CREATE PROCEDURE [dbo].[uspSTCheckoutCommanderTranslogFuelComputation]
	@intCheckoutId											INT,
	@UDT_Translog StagingTransactionLogFuelComputation		READONLY
AS
BEGIN

DECLARE @intStoreId INT

SELECT	@intStoreId = intStoreId
FROM	dbo.tblSTCheckoutHeader 
WHERE	intCheckoutId = @intCheckoutId

INSERT INTO tblSTCheckoutFuelSalesByGradeAndPricePoint (intCheckoutId, intProductNumber, dblPrice, dblDollarsSold, dblGallonsSold, intItemUOMId, intConcurrencyId)
SELECT	@intCheckoutId,
		a.intProductNumber,
		a.dblPrice,
		a.dblDollarsSold,
		a.dblGallonsSold,
		UOM.intItemUOMId,
		1
FROM	@UDT_Translog a
JOIN dbo.tblSTPumpItem SPI 
	ON ISNULL(CAST(a.intProductNumber as NVARCHAR(10)), '') COLLATE Latin1_General_CI_AS IN (ISNULL(SPI.strRegisterFuelId1, ''), ISNULL(SPI.strRegisterFuelId2, ''))
JOIN dbo.tblICItemUOM UOM 
	ON UOM.intItemUOMId = SPI.intItemUOMId
JOIN dbo.tblSTStore S 
	ON S.intStoreId = SPI.intStoreId
WHERE S.intStoreId = @intStoreId AND 
	UOM.intItemUOMId IN (SELECT intItemUOMId FROM tblSTPumpItem WHERE intStoreId = @intStoreId) 
END