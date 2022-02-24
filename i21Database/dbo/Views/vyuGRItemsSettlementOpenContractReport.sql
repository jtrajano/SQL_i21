CREATE VIEW [dbo].[vyuGRItemsSettlementOpenContractReport]
AS
SELECT A.ItemName	 
	 , PivotColumn = CONVERT(NVARCHAR,A.PivotColumn)
	 , CONVERT(NVARCHAR, CONVERT(DECIMAL(18,2), ISNULL(SUM(A.Amount),0))) COLLATE Latin1_General_CI_AS as Amount
	 , A.UnitMeasure
	 , A.intEntityId
	 , PivotColumnId = CASE 
						WHEN A.PivotColumn = 'Purchase' THEN 111
						ELSE 222
					  END
FROM (
	SELECT 
		ItemName = Item.strItemNo
		, PivotColumn = CT.strContractType
		, Amount = dbo.fnCTConvertQtyToTargetItemUOM(CD.intItemUOMId, ItemUOM.intItemUOMId, CD.dblBalance)
		, UnitMeasure = UOM.strUnitMeasure
		, CH.intEntityId
	FROM tblCTContractDetail CD
	JOIN tblCTContractHeader CH
		ON CH.intContractHeaderId = CD.intContractHeaderId
	JOIN tblCTPricingType PT
		ON PT.intPricingTypeId = CD.intPricingTypeId
	JOIN tblCTContractType CT
		ON CT.intContractTypeId = CH.intContractTypeId
	LEFT JOIN tblICItem Item 
		ON Item.intItemId = CD.intItemId
	LEFT JOIN tblICItemUOM ItemUOM
		ON ItemUOM.intItemId = Item.intItemId
			AND ItemUOM.ysnStockUnit = 1
	LEFT JOIN tblICUnitMeasure UOM
		ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId
	WHERE CD.dblBalance > 0
		AND Item.ysnUseWeighScales = 1
		AND CD.intContractStatusId NOT IN (2,3,6)
		AND CD.intPricingTypeId <> 5 --DO NOT INCLUDE OPEN DP CONTRACTS (GRN-2370)
) A
GROUP BY A.intEntityId
		,A.ItemName
		,A.PivotColumn
		,A.UnitMeasure
GO
