--liquibase formatted sql

-- changeset Von:vyuICGetAddOnComponentStock.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetAddOnComponentStock]
	AS
SELECT	intParentKey = CAST(ROW_NUMBER() OVER(ORDER BY ItemAddOn.intAddOnItemId, ItemAddOn.intAddOnItemId, ItemAddOnComponent.intLocationId) AS INT),
		ItemAddOn.intAddOnItemId,
		intParentItemAddOnId = ItemHeader.intItemId,
		strParentItemAddOn = ItemHeader.strItemNo,
		strParentItemAddOnDesc = ItemHeader.strDescription,
		intAddOnItemUOMId = ItemAddOn.intItemUOMId,
		dblAddOnItemUOMId = ItemAddOnUOM.dblUnitQty,
		strAddOnItemUOM = aoUOM.strUnitMeasure,
		intAddOnComponent = ItemAddOn.intItemAddOnId,
		dblAddOnComponentQty = ItemAddOn.dblQuantity,
		ItemAddOnComponent.*
FROM tblICItemAddOn ItemAddOn
INNER JOIN tblICItem ItemAddOnDetail ON ItemAddOnDetail.intItemId = ItemAddOn.intAddOnItemId
INNER JOIN tblICItem ItemHeader ON ItemHeader.intItemId = ItemAddOn.intItemId
LEFT JOIN (
	tblICItemUOM ItemAddOnUOM INNER JOIN tblICUnitMeasure aoUOM
		ON ItemAddOnUOM.intUnitMeasureId = aoUOM.intUnitMeasureId
) ON ItemAddOnUOM.intItemUOMId = ItemAddOn.intItemUOMId
INNER JOIN vyuICGetItemStock ItemAddOnComponent ON ItemAddOnComponent.intItemId = ItemAddOn.intAddOnItemId



