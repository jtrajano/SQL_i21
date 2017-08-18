CREATE VIEW vyuLGLoadDetailForVoucher
AS
SELECT L.intLoadId
	,L.strLoadNumber
	,LD.intLoadDetailId
	,CH.strContractNumber
	,CH.intContractHeaderId
	,CD.intContractSeq
	,CD.intContractDetailId
	,CD.dblBalance
	,I.intItemId
	,I.strItemNo
	,I.strDescription AS strItemDescription
	,LD.dblQuantity
	,UM.strUnitMeasure AS strQtyUnitMeasure
	,LD.intItemUOMId AS intUnitMeasureId
	,IU.dblUnitQty
	,LD.dblGross
	,LD.dblTare
	,LD.dblNet
	,U.strUnitMeasure AS strWeightUnitMeasure
	,U.intUnitMeasureId as intWeightUnitMeasure
	,WeightUOM.dblUnitQty AS dblWeightUnitQty
	,E.strName AS strVendor
	,E.intEntityId as intEntityVendorId
	,dblCost = ISNULL(AD.dblSeqPrice, 0)
	,intCostUOMId = AD.intSeqPriceUOMId
	,strCostUOM = AD.strSeqPriceUOM
	,dblCostUnitQty = AD.dblCostUnitQty
	,intCurrencyId = ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId)
	,ysnSubCurrency = ISNULL(SubCurrency.ysnSubCurrency, 0)
	,intForexRateTypeId = CD.intRateTypeId
	,dblForexRate = CD.dblRate
	,SC.strCurrency
	,SubCurrency.strCurrency AS strSubCurrency
	,ISNULL(SubCurrency.intCent, 0) intCent
FROM tblLGLoad L
JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId
	AND L.intPurchaseSale = 1
	AND ISNULL(L.ysnPosted, 0) = 1
JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
JOIN tblICItemUOM IU ON IU.intItemUOMId = LD.intItemUOMId
JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
JOIN tblEMEntity E ON E.intEntityId = CH.intEntityId
JOIN tblICItem I ON I.intItemId = LD.intItemId
LEFT JOIN tblICUnitMeasure U ON U.intUnitMeasureId = L.intWeightUnitMeasureId
LEFT JOIN tblICItemUOM WeightUOM ON L.intItemId = LD.intItemId AND WeightUOM.intUnitMeasureId = L.intWeightUnitMeasureId
CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
		WHEN SC.intMainCurrencyId IS NOT NULL
			THEN CD.intCurrencyId
		ELSE NULL
		END
WHERE LD.intLoadDetailId NOT IN (SELECT ISNULL(intLoadDetailId, 0)
								 FROM tblAPBillDetail BD
								 JOIN tblAPBill B ON B.intBillId = BD.intBillId
								 WHERE ISNULL(B.intTransactionType, 0) = 2)