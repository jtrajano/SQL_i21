CREATE VIEW [dbo].[vyuICSearchInsuranceCharge]
AS


SELECT
	A.intInsuranceChargeId
	,A.dtmChargeDateUTC
	,A.strChargeNo
	,A.ysnPosted
	,A.intConcurrencyId
	,strCommodity = C.strCommodityCode
	,strInsurerName = B.strName
	,strStorageLocation = D.strSubLocationName
	,strM2MBatch = E.strRecordName
	----Detail
	,strCompanyLocation = G.strLocationName
	,F.dblQuantity
	,strQuantityUOM = K.strUnitMeasure
	,F.dblWeight
	,strWeightUOM = K.strUnitMeasure
	,F.dblInventoryValue 
	,F.dblM2MValue
	,F.dtmLastCargoInsuranceDate
	,F.dblRate
	,strCurrency = E.strCurrency
	,strRateUOM = I.strUnitMeasure
	,F.dblAmount
	,M.intBillId
	,M.strBillId
FROM tblICInsuranceCharge A
LEFT JOIN tblEMEntity B
	ON A.intInsurerId = B.intEntityId
LEFT JOIN tblICCommodity C
	ON A.intCommodityId = C.intCommodityId
LEFT JOIN tblSMCompanyLocationSubLocation D
	ON A.intStorageLocationId = D.intCompanyLocationSubLocationId
LEFT JOIN vyuRKGetM2MHeader E
	ON A.intM2MBatchId = E.intM2MHeaderId
-----------------Detail
INNER JOIN tblICInsuranceChargeDetail F
	ON A.intInsuranceChargeId = F.intInsuranceChargeId
LEFT JOIN tblSMCompanyLocation G
	ON G.intCompanyLocationId = D.intCompanyLocationId
LEFT JOIN tblICItemUOM H
	ON F.intQuantityUOMId = H.intItemUOMId
LEFT JOIN tblICUnitMeasure I
	ON H.intUnitMeasureId = I.intUnitMeasureId
LEFT JOIN tblICItemUOM J
	ON F.intRateUOMId = J.intItemUOMId
LEFT JOIN tblICUnitMeasure K
	ON H.intUnitMeasureId = K.intUnitMeasureId
LEFT JOIN tblAPBillDetail L
	ON F.intInsuranceChargeDetailId = L.intInsuranceChargeDetailId
LEFT JOIN tblAPBill M
	ON L.intBillId = M.intBillId
