Create View vyuRKGetItemList
AS
SELECT strItemNo,intItemId,intCommodityId FROM tblICItem  WHERE strType <>'Other Charge' 