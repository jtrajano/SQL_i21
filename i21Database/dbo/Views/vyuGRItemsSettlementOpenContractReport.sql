CREATE VIEW [dbo].[vyuGRItemsSettlementOpenContractReport]
AS
SELECT --CD.intItemId
		Item.strItemNo AS ItemName
		, dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId,
				(
				SELECT intItemUOMId 
				FROM tblICItemUOM 
				WHERE intItemId = CD.intItemId 
						AND ysnStockUOM = 1
				),
				SUM(CD.dblBalance)) 
			AS Amount
		 , CTT.strContractType AS PivotColumn
		 , (
			SELECT strUnitMeasure 
			FROM tblICUnitMeasure UM
			LEFT JOIN tblICItemUOM ItemUOM ON
				UM.intUnitMeasureId = ItemUOM.intUnitMeasureId
			WHERE ItemUOM.intItemId = CD.intItemId
				AND ItemUOM.ysnStockUOM = 1
			) AS UnitMeasure
		, CH.intEntityId
FROM tblCTContractDetail CD
JOIN tblCTContractHeader CH ON
	CD.intContractHeaderId = CH.intContractHeaderId
LEFT JOIN tblCTPricingType PT ON
	CD.intPricingTypeId = PT.intPricingTypeId
LEFT JOIN tblCTContractType CTT ON
	CH.intContractTypeId = CTT.intContractTypeId
LEFT JOIN tblICItem Item ON
	CD.intItemId = Item.intItemId 
LEFT JOIN tblICItemUOM ItemUOM ON 
	Item.intItemId = ItemUOM.intItemId 
	AND CD.intItemUOMId = ItemUOM.intItemUOMId
LEFT JOIN tblICUnitMeasure UM ON ItemUOM.intUnitMeasureId = UM.intUnitMeasureId
WHERE PT.strPricingType IN ('Priced','Basis','HTA')
	AND CD.dblBalance > 0
	AND Item.ysnUseWeighScales = 1
GROUP BY CD.intItemId
		, Item.strItemNo
		, CD.intItemUOMId
		, CTT.strContractType
		, CD.dblBalance
		, CH.intEntityId

GO


