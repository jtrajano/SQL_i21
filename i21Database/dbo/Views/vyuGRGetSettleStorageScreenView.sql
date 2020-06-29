CREATE VIEW [dbo].[vyuGRGetSettleStorageScreenView]
AS     
SELECT 
	 SS.intSettleStorageId
	,SS.intEntityId
	,E.strName AS strEntityName  
	,SS.intCompanyLocationId
	,L.strLocationName
	,SS.intItemId
	,Item.strItemNo
	,SS.dblSpotUnits
	,SS.dblFuturesPrice
	,SS.dblFuturesBasis
	,SS.dblCashPrice
	,SS.strStorageAdjustment
	,SS.dtmCalculateStorageThrough
	,SS.dblAdjustPerUnit
	,SS.dblStorageDue
	,SS.strStorageTicket
	,SS.dblSelectedUnits
	,SS.dblUnpaidUnits
	,SS.dblSettleUnits
	,SS.dblDiscountsDue
	,SS.dblNetSettlement
	,SS.ysnPosted
	,SS.intCommodityId
	,SS.intCommodityStockUomId
	,SS.intCreatedUserId	
	,SS.dtmCreated	
	,SS.intItemUOMId
	,UOM.strUnitMeasure
	,SS.intConcurrencyId
	,ysnBillIsPaid	= dbo.fnGRCheckBillPaymentOfSettleStorage(SS.intSettleStorageId)
FROM tblGRSettleStorage SS
JOIN tblEMEntity E 
	ON E.intEntityId = SS.intEntityId
LEFT JOIN tblSMCompanyLocation L 
	ON L.intCompanyLocationId= SS.intCompanyLocationId  
JOIN tblICItem Item 
	ON Item.intItemId = SS.intItemId
JOIN tblICItemUOM ItemUOM 
	ON ISNULL(SS.intItemUOMId, SS.intCommodityStockUomId) = ItemUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure UOM 
	ON ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
--select