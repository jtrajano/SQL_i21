CREATE VIEW  [dbo].[vyuICGetInsuranceChargeDetail]
AS



SELECT
	A.intInsuranceChargeDetailId
	,A.intInsuranceChargeId
	,A.intStorageLocationId
	,A.dblQuantity
	,A.dblWeight
	,A.intWeightUOMId
	,A.dblInventoryValue 
	,A.dblM2MValue
	,A.strRateType
	,A.dblRate
	,A.strAppliedTo
	,A.intCurrencyId
	,A.intRateUOMId
	,A.intQuantityUOMId
	,A.intInsuranceRateDetailId
	,A.dblAmount
	,A.intInsurerId
	,A.dtmLastCargoInsuranceDate
	,A.intChargeItemId
	,A.intLotId
	,A.intConcurrencyId
	,strStorageLocation = C.strSubLocationName
	,strCompanyLocation = D.strLocationName
	,strCurrency = E.strCurrency
	,strWeightUOM = G.strUnitMeasure
	,strRateUOM = I.strUnitMeasure
	,strQuantityUOM = K.strUnitMeasure
	,strInsurerName = L.strName
	,O.strContractNumber
	,N.intContractSeq
	,R.strReceiptNumber
	,M.strLotNumber
	,T.strPolicyNumber
FROM tblICInsuranceChargeDetail A
LEFT JOIN tblSMCompanyLocationSubLocation C
	ON A.intStorageLocationId = C.intCompanyLocationSubLocationId
LEFT JOIN tblSMCompanyLocation D
	ON C.intCompanyLocationId = D.intCompanyLocationId
LEFT JOIN tblSMCurrency E	
	ON A.intCurrencyId = E.intCurrencyID
LEFT JOIN tblICItemUOM F
	ON A.intWeightUOMId = F.intItemUOMId
LEFT JOIN tblICUnitMeasure G
	ON F.intUnitMeasureId = G.intUnitMeasureId
LEFT JOIN tblICItemUOM H
	ON A.intRateUOMId = H.intItemUOMId
LEFT JOIN tblICUnitMeasure I
	ON H.intUnitMeasureId = I.intUnitMeasureId
LEFT JOIN tblICItemUOM J
	ON A.intQuantityUOMId = J.intItemUOMId
LEFT JOIN tblICUnitMeasure K
	ON K.intUnitMeasureId = J.intUnitMeasureId
LEFT JOIN tblEMEntity L
	ON A.intInsurerId = L.intEntityId
LEFT JOIN tblICLot M
	ON A.intLotId = M.intLotId
LEFT JOIN tblCTContractDetail N
	ON M.intContractDetailId = N.intContractDetailId
LEFT JOIN tblCTContractHeader O
	ON N.intContractHeaderId = N.intContractHeaderId
LEFT JOIN tblICInventoryReceiptItemLot P
	ON A.intInventoryReceiptItemLotId = P.intInventoryReceiptItemLotId
LEFT JOIN tblICInventoryReceiptItem Q
	ON P.intInventoryReceiptItemId = Q.intInventoryReceiptItemId
LEFT JOIN tblICInventoryReceipt R
	ON Q.intInventoryReceiptId = R.intInventoryReceiptId
LEFT JOIN tblICInsuranceRateDetail S
	ON A.intInsuranceRateDetailId = S.intInsuranceRateDetailId
LEFT JOIN tblICInsuranceRate T
	ON S.intInsuranceRateId = T.intInsuranceRateId