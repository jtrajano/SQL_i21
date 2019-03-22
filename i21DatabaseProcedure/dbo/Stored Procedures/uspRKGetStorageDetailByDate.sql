CREATE PROC [dbo].[uspRKGetStorageDetailByDate]
	@intCommodityId int,
	@dtmToDate datetime=null
AS

SELECT ROW_NUMBER() OVER (PARTITION BY a.intCustomerStorageId ORDER BY a.intCustomerStorageId DESC) intRowNum, 
	a.intCustomerStorageId,
	a.intCompanyLocationId	
	,c.strLocationName [Loc]
	,CONVERT(DATETIME,CONVERT(VARCHAR(10),a.dtmDeliveryDate ,110),110) [Delivery Date]
	,a.strStorageTicketNumber [Ticket]
	,a.intEntityId
	,E.strName [Customer]
	,a.strDPARecieptNumber [Receipt]
	,a.dblDiscountsDue [Disc Due]
	,a.dblStorageDue   [Storage Due]
	,(case when gh.strType ='Reduced By Inventory Shipment' then -gh.dblUnits else gh.dblUnits   end) [Balance]
	,a.intStorageTypeId
	,b.strStorageTypeDescription [Storage Type]
	,a.intCommodityId
	,CM.strCommodityCode [Commodity Code]
	,CM.strDescription   [Commodity Description]
	,b.strOwnedPhysicalStock
	,b.ysnReceiptedStorage
	,b.ysnDPOwnedType
	,b.ysnGrainBankType
	,b.ysnActive ysnCustomerStorage 
	,a.strCustomerReference  
 	,a.dtmLastStorageAccrueDate  
 	,c1.strScheduleId
	,i.strItemNo
	,c.strLocationName
	,ium.intCommodityUnitMeasureId as intCommodityUnitMeasureId
	,i.intItemId as intItemId
FROM tblGRStorageHistory gh
JOIN tblGRCustomerStorage a  on gh.intCustomerStorageId=a.intCustomerStorageId
JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
JOIN tblICItem i on i.intItemId=a.intItemId
JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
LEFT JOIN tblGRStorageScheduleRule c1 on c1.intStorageScheduleRuleId=a.intStorageScheduleId  
JOIN tblSMCompanyLocation c ON c.intCompanyLocationId=a.intCompanyLocationId
JOIN tblEMEntity E ON E.intEntityId=a.intEntityId
JOIN tblICCommodity CM ON CM.intCommodityId=a.intCommodityId
WHERE ISNULL(a.strStorageType,'') <> 'ITR'  and isnull(a.intDeliverySheetId,0) =0 
and convert(DATETIME, CONVERT(VARCHAR(10), dtmDistributionDate, 110), 110) <= convert(datetime,@dtmToDate) 
and a.intCommodityId=case when isnull(@intCommodityId,0)=0 then a.intCommodityId else @intCommodityId end