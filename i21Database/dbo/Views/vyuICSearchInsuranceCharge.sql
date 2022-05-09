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
	,strStorageLocation = ISNULL(D.strSubLocationName,'')
	,strM2MBatch = E.strRecordName
	----Detail
	,strCompanyLocation = ISNULL(G.strLocationName,'')
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
OUTER APPLY (
	SELECT strSubLocationName = STUFF(
		(	SELECT 
				',' + strSubLocationName
			FROM tblSMCompanyLocationSubLocation
			WHERE intCompanyLocationSubLocationId IN (
				SELECT											
					Item
				FROM dbo.fnSplitString (ISNULL(A.strStorageLocationIds,''),',') AA
			)
			FOR XML PATH('')
		),1,1,'') 
)  D
	
LEFT JOIN vyuRKGetM2MHeader E
	ON A.intM2MBatchId = E.intM2MHeaderId
-----------------Detail
LEFT JOIN tblICInsuranceChargeDetail F
	ON A.intInsuranceChargeId = F.intInsuranceChargeId
OUTER APPLY (
	SELECT strLocationName = STUFF(
		(	SELECT 
				',' + BB.strLocationName
			FROM tblSMCompanyLocationSubLocation AA
			INNER JOIN tblSMCompanyLocation BB
				ON AA.intCompanyLocationId = BB.intCompanyLocationId
			WHERE AA.intCompanyLocationSubLocationId IN (
				SELECT											
					Item
				FROM dbo.fnSplitString (ISNULL(A.strStorageLocationIds,''),',') 
			)
			FOR XML PATH('')
		),1,1,'') 
) G
	
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
