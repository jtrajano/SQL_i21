CREATE VIEW [dbo].[vyuGRGetStorageDetail]
AS
SELECT
	a.intCustomerStorageId
	,a.intCompanyLocationId	
	,c.strLocationName [Loc]
	,a.dtmDeliveryDate [Delivery Date]
	,a.strStorageTicketNumber [Ticket]
	,a.intEntityId
	,E.strName [Customer]
	,a.strDPARecieptNumber [Receipt]
	,(a.dblDiscountsDue-a.dblDiscountsPaid) [Disc Due]
	,(a.dblStorageDue-a.dblStoragePaid)   [Storage Due]
	,a.dblOpenBalance  [Balance]
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
	,intCommodityUnitMeasureId as intCommodityUnitMeasureId
	,i.intItemId as intItemId 
FROM tblGRCustomerStorage a
JOIN tblGRStorageType b ON b.intStorageScheduleTypeId = a.intStorageTypeId
JOIN tblICItem i on i.intItemId=a.intItemId
JOIN tblICItemUOM iuom on i.intItemId=iuom.intItemId and ysnStockUnit=1
JOIN tblICCommodityUnitMeasure ium on ium.intCommodityId=i.intCommodityId AND iuom.intUnitMeasureId=ium.intUnitMeasureId 
LEFT JOIN tblGRStorageScheduleRule c1 on c1.intStorageScheduleRuleId=a.intStorageScheduleId  
JOIN tblSMCompanyLocation c ON c.intCompanyLocationId=a.intCompanyLocationId
JOIN tblEntity E ON E.intEntityId=a.intEntityId
JOIN tblICCommodity CM ON CM.intCommodityId=a.intCommodityId
Where ISNULL(a.strStorageType,'') <> 'ITR'
