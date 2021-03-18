CREATE VIEW [dbo].[vyuGRRestApiCustomerStorageBalances]
AS
SELECT 
	  cs.intCustomerStorageId
	, cs.strStorageTicketNumber
	, e.strName strEntityName
	, e.intEntityId
	, e.strEntityNo
	, cs.intItemId
	, i.strItemNo
	, u.strUnitMeasure
	, sct.strTicketNumber
	, c.strCommodityCode strCommodity
	, st.strStorageTypeDescription
	, st.strStorageTypeCode
	, cs.intCompanyLocationId intLocationId
	, cl.strLocationName strLocation
	, cs.dblOpenBalance
	, cs.dblBasis
	, cs.dblCurrencyRate
	, cs.dblDiscountsDue
	, cs.dblDiscountsPaid
	, cs.dblFeesDue
	, cs.dblFeesPaid
	, cs.dblFreightDueRate
	, cs.dblGrossQuantity
	, cs.dblInsuranceRate
	, cs.dblOriginalBalance
	, cs.dblSettlementPrice
	, cs.dblStorageDue
	, cs.dblStoragePaid
	, cs.dblTotalPriceShrink
	, cs.dblTotalWeightShrink
	, cs.dtmLastStorageAccrueDate
	, cs.dtmDeliveryDate
	, cs.strDiscountComment
	, cs.intCurrencyId
	, cr.strCurrency
	, cs.ysnPrinted
	, cs.ysnTransferStorage
	, ds.strDeliverySheetNumber
	, shl.strLocationName strShipFromLocation
	, se.strName strShipFrom
	, sl.strDescription strStorageLocation
	, ssl.strSubLocationName strSubLocation
	, dds.strDiscountDescription strDiscountSchedule
FROM tblGRCustomerStorage cs
LEFT JOIN tblEMEntity e ON e.intEntityId = cs.intEntityId
LEFT JOIN tblICCommodity c ON c.intCommodityId = cs.intCommodityId
LEFT JOIN tblGRStorageType st ON st.intStorageScheduleTypeId = cs.intStorageTypeId
LEFT JOIN tblSMCompanyLocation cl ON cl.intCompanyLocationId = cs.intCompanyLocationId
LEFT JOIN tblSMCurrency cr ON cr.intCurrencyID = cs.intCurrencyId
LEFT JOIN tblICItem i ON i.intItemId = cs.intItemId
LEFT JOIN tblICItemUOM iu ON iu.intItemUOMId = cs.intItemUOMId
LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
LEFT JOIN tblSCDeliverySheet ds ON ds.intDeliverySheetId = cs.intDeliverySheetId
LEFT JOIN tblSMCompanyLocation shl ON shl.intCompanyLocationId = cs.intShipFromLocationId
LEFT JOIN tblEMEntity se ON se.intEntityId = cs.intShipFromEntityId
LEFT JOIN tblICStorageLocation sl ON sl.intStorageLocationId = cs.intStorageLocationId
LEFT JOIN tblSMCompanyLocationSubLocation ssl ON ssl.intCompanyLocationSubLocationId = cs.intCompanyLocationSubLocationId
LEFT JOIN tblGRDiscountSchedule dds ON dds.intDiscountScheduleId = cs.intDiscountScheduleId
LEFT JOIN tblSCTicket sct ON sct.intTicketId = cs.intTicketId
WHERE cs.dblOpenBalance > 0