CREATE VIEW [dbo].[vyuGRGetUnpaidStorageFees]
AS
SELECT 
	intCustomerStorageId   = CS.intCustomerStorageId  
	,intEntityId		     = CS.intEntityId  
	,strName			     = E.strName  
	,intItemId			     = CS.intItemId  
	,strItemNo			     = Item.strItemNo  
	,intCompanyLocationId   = CS.intCompanyLocationId  
	,strLocationName		 = LOC.strLocationName  
	,strStorageTicketNumber = CS.strStorageTicketNumber  
	,dblOpenBalance         = ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(CS.intItemUOMId, ItemUOM.intItemUOMId, CS.dblOpenBalance),0)
	,dblFeesDue             = ISNULL(CS.dblFeesDue, 0)
	,dblFeesPaid            = ISNULL(CS.dblFeesPaid, 0)
	,dblFeesUnpaid          = (ISNULL(CS.dblFeesDue, 0) - ISNULL(CS.dblFeesPaid, 0))
	,dblFeesTotal           = ISNULL(dbo.fnCTConvertQtyToTargetItemUOM(CS.intItemUOMId, ItemUOM.intItemUOMId, CS.dblOpenBalance) * (ISNULL(CS.dblFeesDue, 0) - ISNULL(CS.dblFeesPaid, 0)),0)
FROM tblGRCustomerStorage CS 
JOIN tblSMCompanyLocation LOC 
	ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblEMEntity E 
	ON E.intEntityId = CS.intEntityId  
JOIN tblICCommodity COM 
	ON COM.intCommodityId = CS.intCommodityId  
JOIN tblICItem Item 
	ON Item.intItemId = CS.intItemId
JOIN tblICItemUOM ItemUOM
	ON ItemUOM.intItemId = Item.intItemId
		AND ItemUOM.ysnStockUnit = 1
WHERE CS.dblOpenBalance > 0 
	AND (ISNULL(CS.dblFeesDue, 0) - ISNULL(CS.dblFeesPaid, 0)) <> 0