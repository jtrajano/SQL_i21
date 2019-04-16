CREATE VIEW vyuSTPromotionItemList
AS
SELECT IL.*
     , ST.intStoreNo 
FROM tblSTPromotionItemList IL
INNER JOIN tblSTStore ST
	ON IL.intStoreId = ST.intStoreId