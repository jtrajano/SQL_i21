CREATE VIEW [dbo].[vyuICSearchStorageCharge]
	AS

SELECT
	A.[intStorageChargeId]
	,A.[dtmBillDateUTC] 
	,A.[intStorageLocationId] 
	,A.[intCompanyLocationId]
	,A.[intCommodityId]
	,A.[intStorageRateId] 
	,A.[strStorageChargeNumber]
	,A.[intCurrencyId]
	,A.[strDescription]
	,A.[intConcurrencyId] 
	,A.ysnPosted
	,strStorageLocation = B.strSubLocationName
	,strCompanyLocation = C.strLocationName
	,strCommodity = D.strCommodityCode
	,strCurrency = E.strCurrency
	,strPlanNo = F.strPlanNo
	------------------Detail
	,G.strTransactionId
	,G.dtmStartDateUTC
	,G.dtmEndDateUTC
	,G.dtmLastBillDateUTC
	,G.dblReceivedQuantity
	,G.dblDeliveredQuantity
	,G.dblGross
	,G.dblNet
	,G.dblNumberOfDays
	,G.dblChargeQuantity
	,G.dblRate
	,G.dblStorageCharge
	,G.dtmTransactionDateUTC
    ,G.dtmLastFreeWarehouseDateUTC
    ,G.dtmLastFreeOutboundDateUTC
    ,G.dblCustomerCharge
    ,G.dblCustomerNoOfDays
	,G.strRateType
	,H.strItemNo
	,I.strLotNumber
	,strItemUOM = L.strUnitMeasure
	,strWeightUOMId = N.strUnitMeasure
	,strChargeItemNo = O.strItemNo
	,Q.strBillId
	,G.intStorageChargeDetailId
	,Q.intBillId
FROM tblICStorageCharge A
LEFT JOIN tblSMCompanyLocationSubLocation B
	ON A.intStorageLocationId = B.intCompanyLocationSubLocationId
LEFT JOIN tblSMCompanyLocation C
	ON A.intCompanyLocationId = C.intCompanyLocationId
LEFT JOIN tblICCommodity D	
	ON A.intCommodityId = D.intCommodityId
LEFT JOIN tblSMCurrency E	
	ON A.intCurrencyId = E.intCurrencyID
LEFT JOIN tblICStorageRate F
	ON A.intStorageRateId = F.intStorageRateId
LEFT JOIN  tblICStorageChargeDetail G
	ON A.intStorageChargeId = G.intStorageChargeId
LEFT JOIN tblICItem H	
	ON G.intItemId = H.intItemId
LEFT JOIN tblICLot I
	ON G.intLotId = I.intLotId
LEFT JOIn tblSMCompanyLocationSubLocation J
	ON A.intStorageLocationId = J.intCompanyLocationSubLocationId
LEFT JOIN tblICItemUOM K
	ON G.intItemUOMId = K.intItemUOMId
LEFT JOIN tblICUnitMeasure L
	ON K.intUnitMeasureId = L.intUnitMeasureId
LEFT JOIN tblICItemUOM M
	ON G.intWeightUOMId = M.intItemUOMId
LEFT JOIN tblICUnitMeasure N
	ON M.intUnitMeasureId = N.intUnitMeasureId
LEFT JOIN tblICItem O
	ON G.intItemChargeId = O.intItemId
LEFT JOIN tblAPBillDetail P
	ON G.intStorageChargeDetailId = P.intStorageChargeId
LEFT JOIN tblAPBill Q
	ON P.intBillId = Q.intBillId


