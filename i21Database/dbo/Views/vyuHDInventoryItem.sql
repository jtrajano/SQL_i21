CREATE VIEW [dbo].[vyuHDInventoryItem]
	AS
	select
		 intId = convert(int,ROW_NUMBER() over (order by a.intItemId))
		 ,a.intItemId
		 ,a.strItemNo
		 ,a.strDescription
		 ,a.strType
		 ,a.ysnBillable
		 ,a.ysnSupported
		 ,a.ysnDisplayInHelpdesk
		 ,b.intItemUOMId
		 ,c.intUnitMeasureId
		 ,c.strUnitMeasure
	from
		tblICItem a
		left join tblICItemUOM b on b.intItemId = a.intItemId
		left join tblICUnitMeasure c on c.intUnitMeasureId = b.intUnitMeasureId
