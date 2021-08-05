CREATE VIEW [dbo].[vyuSTPromotionItemList]
AS
SELECT IL.*
     , ST.intStoreNo 
     , ST.intCompanyLocationId 
FROM tblSTPromotionItemList IL
INNER JOIN tblSTStore ST
	ON IL.intStoreId = ST.intStoreId