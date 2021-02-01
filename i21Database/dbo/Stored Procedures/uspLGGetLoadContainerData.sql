CREATE PROCEDURE uspLGGetLoadContainerData
	@intLoadId INT
AS
BEGIN
	SELECT LC.*
		,UOM.strUnitMeasure AS strUnitMeasure
		,LCWU.strUnitMeasure AS strWeightUnitMeasure
		,CU.strCurrency AS strStaticValueCurrency
		,ACU.strCurrency AS strAmountCurrency
		,dblUnMatchedQty = CAST(NULL AS NUMERIC(18, 6))
		,dblWeightPerUnit = UOMF.dblUnitQty / UOMT.dblUnitQty
	FROM tblLGLoad L
	JOIN tblLGLoadDetail LD ON L.intLoadId = LD.intLoadId AND L.intLoadId = @intLoadId
	JOIN tblLGLoadDetailContainerLink LDCL ON LDCL.intLoadDetailId = LD.intLoadDetailId
	JOIN tblLGLoadContainer LC ON LDCL.intLoadContainerId = LC.intLoadContainerId
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
END