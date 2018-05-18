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
		 ,e.intCompanyLocationId
		 ,e.strLocationName
	from
		tblICItem a
		inner join tblICItemUOM b on b.intItemId = a.intItemId
		inner join tblICUnitMeasure c on c.intUnitMeasureId = b.intUnitMeasureId and c.intUnitMeasureId = 1
		inner join tblICItemLocation d on d.intItemId = a.intItemId
		inner join tblSMCompanyLocation e on e.intCompanyLocationId = d.intLocationId
