--liquibase formatted sql

-- changeset Von:vyuICGetAddOnItem.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetAddOnItem]
AS

SELECT	ItemAddOn.intItemAddOnId
		,ItemAddOn.intItemId
		,Item.strItemNo
		,ItemAddOn.intAddOnItemId
		,strAddOnItemNo = AddOnComponent.strItemNo
		,strDescription = AddOnComponent.strDescription
		,ItemAddOn.dblQuantity
		,ItemAddOn.intItemUOMId
		,UOM.strUnitMeasure
		,ItemAddOn.ysnAutoAdd
		,ItemAddOn.dtmEffectivityDateFrom
		,ItemAddOn.dtmEffectivityDateTo
		,AddOnComponent.strType 
		,ItemAddOn.intConcurrencyId
FROM	tblICItemAddOn ItemAddOn
		LEFT JOIN tblICItem Item ON Item.intItemId = ItemAddOn.intItemId
		LEFT JOIN tblICItem AddOnComponent ON AddOnComponent.intItemId = ItemAddOn.intAddOnItemId
		LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemUOMId = ItemAddOn.intItemUOMId
		LEFT JOIN tblICUnitMeasure UOM ON UOM.intUnitMeasureId = ItemUOM.intUnitMeasureId



