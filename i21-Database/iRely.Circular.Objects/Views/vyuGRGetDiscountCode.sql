CREATE VIEW [dbo].[vyuGRGetDiscountCode]
AS 
SELECT 
intItemId
,strType
,strItemNo
,strShortName
,strDescription 
,ISNULL(intCommodityId,0) AS intCommodityId
,strStatus
,strCostType 
FROM vyuICGetCompactItem 
WHERE strType='Other Charge' 
AND strStatus='Active'
