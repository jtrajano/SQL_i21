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
 ,dblOpenBalance         = dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CS.intUnitMeasureId, CU.intUnitMeasureId, CS.dblOpenBalance) 
 ,dblFeesDue             = ISNULL(CS.dblFeesDue, 0)
 ,dblFeesPaid            = ISNULL(CS.dblFeesPaid, 0)
 ,dblFeesUnpaid          = (ISNULL(CS.dblFeesDue, 0) - ISNULL(CS.dblFeesPaid, 0))
 ,dblFeesTotal           =  dbo.fnCTConvertQuantityToTargetItemUOM(CS.intItemId, CS.intUnitMeasureId, CU.intUnitMeasureId, CS.dblOpenBalance)
							* (ISNULL(CS.dblFeesDue, 0) - ISNULL(CS.dblFeesPaid, 0))
FROM tblGRCustomerStorage CS
JOIN tblSCTicket SC ON SC.intTicketId=CS.intTicketId    
JOIN tblSMCompanyLocation LOC ON LOC.intCompanyLocationId = CS.intCompanyLocationId  
JOIN tblEMEntity E ON E.intEntityId = CS.intEntityId  
JOIN tblICCommodity COM ON COM.intCommodityId = CS.intCommodityId  
JOIN tblICItem Item ON Item.intItemId = CS.intItemId  
JOIN tblICCommodityUnitMeasure CU ON CU.intCommodityId = CS.intCommodityId AND CU.ysnStockUnit = 1  
WHERE ISNULL(CS.strStorageType, '') <> 'ITR' AND CS.dblOpenBalance >0 AND (ISNULL(CS.dblFeesDue, 0) - ISNULL(CS.dblFeesPaid, 0)) <> 0 
