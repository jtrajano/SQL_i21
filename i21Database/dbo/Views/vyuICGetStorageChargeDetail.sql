CREATE VIEW [dbo].[vyuICGetStorageChargeDetail]
AS



SELECT
	A.[intStorageChargeDetailId]
	,A.[intStorageChargeId]
	,A.intItemId
	,A.intItemChargeId
	,A.intLotId
	,A.intTransactionTypeId
	,A.intTransactionId
	,A.strTransactionId
	,A.dtmStartDateUTC
	,A.dtmEndDateUTC
	,A.dtmLastBillDateUTC
	,A.dblReceivedQuantity
	,A.dblDeliveredQuantity
	,A.intItemUOMId
	,A.intItemChargeUOMId
	,A.dblGross
	,A.dblNet
	,A.intWeightUOMId
	,A.dblNumberOfDays
	,A.dblChargeQuantity
	,A.dblRate
	,A.intRateUOMId
	,A.dblStorageCharge
	,A.intTransactionDetailId
	,A.intStorageLocationId
	,A.intInventoryStockMovementId
	,A.dtmTransactionDateUTC
    ,A.dtmLastFreeWarehouseDateUTC
    ,A.dtmLastFreeOutboundDateUTC
    ,A.dblCustomerCharge
    ,A.dblCustomerNoOfDays
	,A.strRateType
	,A.intConcurrencyId
	,A.intInventoryStockMovementIdUsed
	,A.intTotalAccumulatedDays
	----Details from other table
	,C.strItemNo
	,strItemDescription = C.strDescription
	,D.strLotNumber
	,D.strLotAlias
	,D.strWarrantNo
	,strStorageLocation = E.strSubLocationName
	,strItemUOM = G.strUnitMeasure
	,strWeightUOMId = I.strUnitMeasure
	,strChargeItemNo = J.strItemNo
FROM tblICStorageChargeDetail A
INNER JOIN tblICStorageCharge B
	ON A.intStorageChargeId = B.intStorageChargeId
INNER JOIN tblICItem C	
	ON A.intItemId = C.intItemId
LEFT JOIN tblICLot D
	ON A.intLotId = D.intLotId
LEFT JOIn tblSMCompanyLocationSubLocation E
	ON B.intStorageLocationId = E.intCompanyLocationSubLocationId
LEFT JOIN tblICItemUOM F
	ON A.intItemUOMId = F.intItemUOMId
LEFT JOIN tblICUnitMeasure G
	ON F.intUnitMeasureId = G.intUnitMeasureId
LEFT JOIN tblICItemUOM H
	ON A.intWeightUOMId = H.intItemUOMId
LEFT JOIN tblICUnitMeasure I
	ON H.intUnitMeasureId = I.intUnitMeasureId
LEFT JOIN tblICItem J
	ON A.intItemChargeId = J.intItemId


GO