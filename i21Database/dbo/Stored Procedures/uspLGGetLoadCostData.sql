CREATE PROCEDURE uspLGGetLoadCostData 
	@intLoadId INT
AS
BEGIN
	SELECT 
		LC.intLoadCostId
		,LC.intConcurrencyId
		,LC.intLoadId
		,LC.intItemId
		,LC.intVendorId
		,LC.strEntityType
		,LC.strCostMethod
		,LC.intCurrencyId
		,LC.dblRate
		,LC.dblAmount
		,LC.dblFX
		,LC.intItemUOMId
		,LC.ysnAccrue
		,LC.ysnMTM
		,LC.ysnPrice
		,B.intBillId
		,LC.intLoadCostRefId
		,LC.ysnInventoryCost
		,LC.intContractDetailId
		,C.strCurrency
		,E.strName AS strVendorName
		,L.strLoadNumber
		,UM.strUnitMeasure AS strUOM
		,I.strItemNo
		,B.strBillId
		,I.intOnCostTypeId
	FROM tblLGLoadCost LC
	JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
	LEFT JOIN tblEMEntity E ON E.intEntityId = LC.intVendorId
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LC.intItemUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICItem I ON I.intItemId = LC.intItemId
	LEFT JOIN tblSMCurrency C ON C.intCurrencyID = LC.intCurrencyId
	OUTER APPLY (
			SELECT TOP 1
				B.intBillId,
				B.strBillId,
				B.intTransactionType
			FROM tblAPBill B
			INNER JOIN tblAPBillDetail BD ON BD.intBillId = B.intBillId
			WHERE BD.intLoadShipmentCostId = LC.intLoadCostId
			ORDER BY B.intBillId DESC
		) B
	WHERE ((B.intTransactionType IS NOT NULL AND B.intTransactionType = 1) OR (B.intTransactionType IS NULL)) AND L.intLoadId = @intLoadId
END