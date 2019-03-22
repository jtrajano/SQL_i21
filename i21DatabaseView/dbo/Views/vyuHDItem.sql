CREATE VIEW [dbo].[vyuHDItem]
	AS
		select
			intId = cast(ROW_NUMBER() over (order by item.intItemId) as int),
			item.intItemId, item.strItemNo, item.strDescription, item.strType, item.strStatus,
			intCompanyLocationId = null, strLocationName = null, strLocationNumber = null, strLocationType = null,
			uom.intUnitMeasureId, uom.strUnitMeasure, uom.strSymbol, uom.strUnitType, itemUOM.intItemUOMId
		from
			tblICItem item
			left outer join tblICItemUOM itemUOM on itemUOM.intItemId = item.intItemId
			left outer join tblICUnitMeasure uom on uom.intUnitMeasureId = itemUOM.intUnitMeasureId

		/*
		select
			intId = cast(ROW_NUMBER() over (order by item.intItemId) as int),
			item.intItemId, item.strItemNo, item.strDescription, item.strType, item.strStatus,
			comLoc.intCompanyLocationId, comLoc.strLocationName, comLoc.strLocationNumber, comLoc.strLocationType,
			uom.intUnitMeasureId, uom.strUnitMeasure, uom.strSymbol, uom.strUnitType, itemUOM.intItemUOMId
		from
			tblICItem item
			left outer join tblICItemLocation itemLoc on itemLoc.intItemId = item.intItemId
			left outer join tblSMCompanyLocation comLoc on comLoc.intCompanyLocationId = itemLoc.intLocationId
			left outer join tblICItemUOM itemUOM on itemUOM.intItemId = item.intItemId
			left outer join tblICUnitMeasure uom on uom.intUnitMeasureId = itemUOM.intUnitMeasureId
		*/
