CREATE VIEW dbo.vyuGRCustomerStorage
AS
SELECT 
	  CS.intCustomerStorageId
	, CS.intEntityId
	, CS.intTicketId
	, CS.strStorageTicketNumber
	, CS.intStorageTypeId
	, CS.intCommodityId
	, CS.intCompanyLocationId
	, CS.intStorageScheduleId
	, CS.strDPARecieptNumber
	, CS.strCustomerReference
	, CS.dblOriginalBalance
	, CS.dblOpenBalance
	, CS.dtmDeliveryDate
	, CS.strDiscountComment
	, CS.dblInsuranceRate
	, CS.dblStorageDue
	, CS.dblStoragePaid
	, CS.dblFeesDue
	, CS.dblFeesPaid
	, CS.dblDiscountsDue
	, CS.dblDiscountsPaid
	, CS.intDiscountScheduleId
	, CS.intCurrencyId
	, CS.intItemId
	, CS.intCompanyLocationSubLocationId
	, CS.intStorageLocationId
	, CS.dblTotalPriceShrink
	, CS.dblTotalWeightShrink
	, CS.dtmZeroBalanceDate
	, CS.dtmLastStorageAccrueDate
	, CS.strOriginState
	, CS.strInsuranceState
	, CS.dblFreightDueRate
	, CS.intUnitMeasureId
	, CS.intItemUOMId
	, CS.ysnPrinted
	, CS.dblCurrencyRate
	, CS.intConcurrencyId
	, EM.strName
	, ST.strStorageTypeDescription
	, ICI.strItemNo
	, CL.strLocationName
	, CLSL.strSubLocationName
	, DS.strDiscountDescription
	, SSR.strScheduleId
	, UOM.strUnitMeasure
	, SL.strName strStorageLocation
	, CS.strStorageType
	, ysnDeliverySheetPosted = ISNULL(DeliverySheet.ysnPost,1)
FROM tblGRCustomerStorage CS
INNER JOIN tblSMCompanyLocation CL
	ON CS.intCompanyLocationId = CL.intCompanyLocationId
LEFT JOIN tblGRStorageScheduleRule SSR
	ON CS.intStorageScheduleId = SSR.intStorageScheduleRuleId
LEFT JOIN tblICStorageLocation SL
	ON CS.intStorageLocationId = SL.intStorageLocationId
LEFT JOIN tblICUnitMeasure UOM
	ON CS.intUnitMeasureId = UOM.intUnitMeasureId
LEFT JOIN tblEMEntity EM
	ON CS.intEntityId = EM.intEntityId
LEFT JOIN tblGRStorageType ST
	ON CS.intStorageTypeId = ST.intStorageScheduleTypeId
LEFT JOIN tblICItem ICI
	ON CS.intItemId = ICI.intItemId
LEFT JOIN tblSMCompanyLocationSubLocation CLSL
	ON CS.intCompanyLocationSubLocationId = CLSL.intCompanyLocationSubLocationId
LEFT JOIN tblGRDiscountSchedule DS
	ON CS.intDiscountScheduleId = DS.intDiscountScheduleId
LEFT JOIN tblSCDeliverySheet DeliverySheet
	ON DeliverySheet.intDeliverySheetId = CS.intDeliverySheetId