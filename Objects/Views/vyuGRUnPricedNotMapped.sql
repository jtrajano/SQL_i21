CREATE VIEW [dbo].[vyuGRUnPricedNotMapped]
AS
SELECT    
 intUnPricedId		  = S.intUnPricedId
,intItemId			  = S.intItemId
,strItemNo			  = Item.strItemNo
,intCompanyLocationId = S.intCompanyLocationId
,strLocationName	  = L.strLocationName
,intUnitMeasureId	  = S.intUnitMeasureId
,strUnitMeasure		  = UnitMeasure.strUnitMeasure  
FROM tblGRUnPriced S
JOIN tblICItem Item ON Item.intItemId = S.intItemId
JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = S.intCompanyLocationId
JOIN tblICUnitMeasure UnitMeasure ON UnitMeasure.intUnitMeasureId=S.intUnitMeasureId
