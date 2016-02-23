CREATE PROCEDURE [dbo].[uspSTCheckoutRadiantISM]
@intCheckoutId Int
AS
BEGIN

DECLARE @intStoreId Int
Select @intStoreId = intStoreId from dbo.tblSTCheckoutHeader Where intCheckoutId = @intCheckoutId

INSERT INTO dbo.tblSTCheckoutItemMovements
SELECT @intCheckoutId 
, UOM.intItemUOMId
, I.strDescription
, IL.intVendorId
, Chk.SalesQuantity
, Chk.ActualSalesPrice
, Chk.SalesAmount
, 0
from #tempCheckoutInsert Chk
JOIN dbo.tblICItemUOM UOM ON Chk.POSCode COLLATE Latin1_General_CI_AS = UOM.strUpcCode
JOIN dbo.tblICItem I ON I.intItemId = UOM.intItemId
JOIN dbo.tblICItemLocation IL ON IL.intItemId = I.intItemId
JOIN dbo.tblSMCompanyLocation CL ON CL.intCompanyLocationId = IL.intLocationId
JOIN dbo.tblSTStore S ON S.intCompanyLocationId = CL.intCompanyLocationId
WHERE S.intStoreId = @intStoreId

END
