CREATE VIEW [dbo].[vyuSTShiftPhysicalPreload]
AS
SELECT DISTINCT
	intCheckoutId
	, intCheckoutShiftPhysicalPreviewId
	, p.intItemId AS intItemId
	, p.intItemLocationId AS intItemLocationId
	, p.intItemUOMId AS intItemUOMId
	, p.intCountGroupId
	, dblQtyReceived 
	, dblQtySold 
	, dblSystemCount 
	
	--Equivalent fields
	, c.strCountGroup
	, I.strItemNo AS strItemNo
	, I.strDescription AS strDescription
	, cat.strCategoryCode AS strCategoryName
	, UM.strUnitMeasure AS strUnitMeasure
	, p.intLocationId
	, p.dtmCheckoutDate

	, intConcurrencyId = p.intConcurrencyId
FROM tblSTCheckoutShiftPhysicalPreview p
LEFT JOIN tblICCountGroup c
	ON p.intCountGroupId = c.intCountGroupId
LEFT JOIN tblICItem I
	ON I.intItemId = p.intItemId
LEFT JOIN tblICCategory cat
	ON I.intCategoryId = cat.intCategoryId
LEFT JOIN tblICItemUOM UOM
	ON p.intItemUOMId = UOM.intItemUOMId
LEFT JOIN tblICUnitMeasure UM
	ON UOM.intUnitMeasureId = UM.intUnitMeasureId