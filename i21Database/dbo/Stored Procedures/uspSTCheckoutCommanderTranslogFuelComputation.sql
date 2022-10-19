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
JOIN dbo.tblICItemLocation IL 
	ON ISNULL(CAST(a.intProductNumber as NVARCHAR(10)), '') COLLATE Latin1_General_CI_AS IN (ISNULL(IL.strPassportFuelId1, ''), ISNULL(IL.strPassportFuelId2, ''), ISNULL(IL.strPassportFuelId3, ''))
JOIN dbo.tblICItem I 
	ON I.intItemId = IL.intItemId
JOIN dbo.tblICItemUOM UOM 
	ON UOM.intItemId = I.intItemId
JOIN dbo.tblSMCompanyLocation CL 
	ON CL.intCompanyLocationId = IL.intLocationId
JOIN dbo.tblSTStore S 
	ON S.intCompanyLocationId = CL.intCompanyLocationId
WHERE S.intStoreId = @intStoreId AND 
	UOM.intItemUOMId IN (SELECT intItemUOMId FROM tblSTPumpItem WHERE intStoreId = @intStoreId) 


END