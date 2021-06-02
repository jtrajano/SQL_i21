CREATE PROCEDURE uspLGGetLoadContainerData
	@intLoadId INT
AS
BEGIN
	SELECT LC.*
		,UOM.strUnitMeasure AS strUnitMeasure
		,LCWU.strUnitMeasure AS strWeightUnitMeasure
		,CU.strCurrency AS strStaticValueCurrency
		,ACU.strCurrency AS strAmountCurrency
		,dblUnMatchedQty = ISNULL(LC.dblQuantity, 0) - ISNULL(LinkTotal.dblLinkQty, 0)
		,dblWeightPerUnit = UOMF.dblUnitQty / UOMT.dblUnitQty
	FROM tblLGLoadContainer LC
	JOIN tblLGLoad L ON L.intLoadId = LC.intLoadId
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND L.intLoadId = @intLoadId
	LEFT JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
	LEFT JOIN tblICUnitMeasure LCWU ON LCWU.intUnitMeasureId = LC.intWeightUnitMeasureId
	LEFT JOIN tblICUnitMeasure LCIU ON LCIU.intUnitMeasureId = LC.intUnitMeasureId
	LEFT JOIN tblICItem Item ON Item.intItemId = LD.intItemId
	LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = LD.intItemUOMId
	LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	LEFT JOIN tblSMCurrency CU ON CU.intCurrencyID = LC.intStaticValueCurrencyId
	LEFT JOIN tblSMCurrency ACU ON ACU.intCurrencyID = LC.intAmountCurrencyId
	OUTER APPLY (SELECT TOP 1 dblUnitQty FROM tblICItemUOM WHERE intItemUOMId = LD.intItemUOMId) UOMF
	OUTER APPLY (SELECT TOP 1 dblUnitQty FROM tblICItemUOM 
					WHERE intItemId = LD.intItemId AND intUnitMeasureId = L.intWeightUnitMeasureId) UOMT
	OUTER APPLY (SELECT dblLinkQty = SUM(dblQuantity) 
				FROM tblLGLoadDetailContainerLink WHERE intLoadContainerId = LC.intLoadContainerId) LinkTotal
END