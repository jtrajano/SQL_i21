CREATE VIEW [dbo].[vyuSTPromotionSalesList]
AS
SELECT SL.*
     , ST.intStoreNo 
     , ST.intCompanyLocationId 
FROM tblSTPromotionSalesList SL
INNER JOIN tblSTStore ST
	ON SL.intStoreId = ST.intStoreId


