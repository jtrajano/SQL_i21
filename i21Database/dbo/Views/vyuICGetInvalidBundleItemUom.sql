CREATE VIEW dbo.vyuICGetInvalidBundleItemUom
AS

SELECT c.strItemNo [strParentItemNo], b.intItemId [intParentItemId], d.strItemNo [strBundleItemNo], b.intBundleItemId, b.intItemUnitMeasureId, m.strUnitMeasure
FROM tblICItemBundle b
	INNER JOIN tblICItemUOM u ON u.intItemUOMId = b.intItemUnitMeasureId
	INNER JOIN tblICUnitMeasure m ON m.intUnitMeasureId = u.intUnitMeasureId
	LEFT OUTER JOIN tblICItemUOM t ON t.intItemId = b.intBundleItemId
		AND t.intItemUOMId = b.intItemUnitMeasureId
	INNER JOIN tblICItem c ON c.intItemId = b.intBundleItemId
	INNER JOIN tblICItem d ON d.intItemId = b.intItemId
WHERE t.intItemUOMId IS NULL