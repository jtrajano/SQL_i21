CREATE VIEW [dbo].[vyuSTPromotionSalesList]
AS
SELECT SL.*
     , ST.intStoreNo 
FROM tblSTPromotionSalesList SL
INNER JOIN tblSTStore ST
	ON SL.intStoreId = ST.intStoreId