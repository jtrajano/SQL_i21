CREATE VIEW vyuLGLoadDetailForVoucher
AS
SELECT L.intLoadId
	,L.strLoadNumber
	,LD.intLoadDetailId
	,CH.strContractNumber
	,CH.intContractHeaderId
	,CD.intContractSeq
	,I.intItemId
	,I.strItemNo
	,I.strDescription AS strItemDescription
	,LD.dblQuantity
	,UM.strUnitMeasure AS strQtyUnitMeasure
	,LD.dblGross
	,LD.dblTare
	,LD.dblNet
	,U.strUnitMeasure AS strWeightUnitMeasure
	,U.intUnitMeasureId as intWeightUnitMeasure
	,E.strName AS strVendor
	,E.intEntityId as intEntityVendorId
	,dblCost = ISNULL(AD.dblSeqPrice, 0)
	,intCostUOMId = AD.intSeqPriceUOMId
	,strCostUOM = AD.strSeqPriceUOM
	,intCurrencyId = ISNULL(SC.intMainCurrencyId, AD.intSeqCurrencyId)
	,ysnSubCurrency = ISNULL(SubCurrency.ysnSubCurrency, 0)
	,intForexRateTypeId = CD.intRateTypeId
	,dblForexRate = CD.dblRate
	,ISNULL(MSC.strCurrency,SC.strCurrency) AS strCurrency
	,SubCurrency.strCurrency AS strSubCurrency
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
CROSS APPLY dbo.fnCTGetAdditionalColumnForDetailView(CD.intContractDetailId) AD
LEFT JOIN tblSMCurrency SC ON SC.intCurrencyID = AD.intSeqCurrencyId
LEFT JOIN tblSMCurrency MSC ON MSC.intCurrencyID = SC.intMainCurrencyId
LEFT JOIN tblSMCurrency SubCurrency ON SubCurrency.intCurrencyID = CASE 
		WHEN SC.intMainCurrencyId IS NOT NULL
			THEN AD.intSeqCurrencyId
		ELSE NULL
		END
WHERE LD.intLoadDetailId NOT IN (
		SELECT ISNULL(intLoadDetailId, 0)
		FROM tblAPBillDetail BD
		JOIN tblAPBill B ON B.intBillId = BD.intBillId
		WHERE ISNULL(B.intTransactionType, 0) = 2
		)