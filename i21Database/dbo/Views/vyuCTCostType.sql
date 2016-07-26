CREATE VIEW [dbo].[vyuCTCostType]
	
AS 

SELECT	Item.intItemId,
			Item.strItemNo,
			Item.strDescription,
			Item.strType,
			Item.strStatus,
			Item.ysnAccrue,
			Item.ysnMTM,
			Item.ysnPrice,
			Item.strCostMethod,
			Item.intOnCostTypeId,
			OnCostType.strItemNo AS strOnCostType,
			Item.dblAmount,
			Item.intCostUOMId,
			CostUOM.strUnitMeasure AS strCostUOM,
			CostItemUOM.intUnitMeasureId AS intCostUnitMeasureId,
			Item.strCostType
			
	FROM	tblICItem Item																			LEFT
	JOIN	tblICItem OnCostType		ON	OnCostType.intItemId		=	Item.intOnCostTypeId	LEFT
	JOIN	tblICItemUOM CostItemUOM	ON	CostItemUOM.intItemUOMId	=	Item.intCostUOMId		LEFT
	JOIN	tblICUnitMeasure CostUOM	ON	CostUOM.intUnitMeasureId	=	CostItemUOM.intUnitMeasureId
	WHERE	Item.strType	=	'Other Charge' 
	AND		Item.strStatus	=	'Active'