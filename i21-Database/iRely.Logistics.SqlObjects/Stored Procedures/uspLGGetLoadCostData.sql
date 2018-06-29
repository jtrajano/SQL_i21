CREATE PROCEDURE uspLGGetLoadCostData 
	@intLoadId INT
AS
BEGIN
	SELECT LC.*
		,C.strCurrency
		,E.strName AS strVendorName
		,L.strLoadNumber
		,UM.strUnitMeasure AS strUOM
		,I.strItemNo
		,B.strBillId
	FROM tblLGLoadCost LC
	JOIN tblEMEntity E ON E.intEntityId = LC.intVendorId
	JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
	LEFT JOIN tblICItemUOM IU ON IU.intItemUOMId = LC.intItemUOMId
	LEFT JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = IU.intUnitMeasureId
	LEFT JOIN tblICItem I ON I.intItemId = LC.intItemId
	LEFT JOIN tblSMCurrency C ON C.intCurrencyID = LC.intCurrencyId
	LEFT JOIN tblAPBill B ON B.intBillId = LC.intBillId
	WHERE L.intLoadId = @intLoadId
END