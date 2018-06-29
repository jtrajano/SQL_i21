CREATE VIEW [dbo].[vyuSTMarkUpDownItems]
AS
SELECT 
IP.strItemNo
,IP.strDescription
,IP.strUpcCode
,IP.strLongUPCCode
,IP.intItemId
,IP.intLocationId
,ST.intStoreId
,ST.intStoreNo
,IP.dblSalePrice 
FROM vyuICGetItemPricing IP
INNER JOIN tblICItem I ON IP.intItemId = I.intItemId
INNER JOIN tblSTStore ST ON IP.intLocationId = ST.intCompanyLocationId
INNER JOIN vyuICGetItemLocation GIL ON IP.intItemUOMId = GIL.intIssueUOMId
WHERE GIL.intItemLocationId = IP.intItemLocationId
AND I.strLotTracking = 'No'