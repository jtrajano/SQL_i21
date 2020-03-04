CREATE VIEW dbo.vyuICGetInvalidBundleItemUom
AS

SELECT b.intItemBundleId [intId], c.strItemNo [strParentItemNo], b.intItemId [intParentItemId], 
	d.strItemNo [strBundleItemNo], b.intBundleItemId, b.intItemUnitMeasureId [intItemUOMId], m.strUnitMeasure,
	ISNULL(r.intItemUOMId, s.intItemUOMId) [intAlternativeUOMId], ISNULL(rm.strUnitMeasure, sm.strUnitMeasure) [strAlternativeUnitMeasure]
FROM tblICItemBundle b
	INNER JOIN tblICItemUOM u ON u.intItemUOMId = b.intItemUnitMeasureId
	INNER JOIN tblICUnitMeasure m ON m.intUnitMeasureId = u.intUnitMeasureId
	LEFT OUTER JOIN tblICItemUOM t ON t.intItemId = b.intBundleItemId
		AND t.intItemUOMId = b.intItemUnitMeasureId
	INNER JOIN tblICItem c ON c.intItemId = b.intBundleItemId
	INNER JOIN tblICItem d ON d.intItemId = b.intItemId
	LEFT OUTER JOIN tblICItemUOM r ON r.intItemUOMId = dbo.fnGetMatchingItemUOMId(b.intBundleItemId, b.intItemUnitMeasureId)
	LEFT OUTER JOIN tblICUnitMeasure rm ON rm.intUnitMeasureId = r.intUnitMeasureId
	LEFT OUTER JOIN tblICItemUOM s ON s.intItemId = b.intBundleItemId
		AND s.ysnStockUnit = 1
	LEFT OUTER JOIN tblICUnitMeasure sm ON sm.intUnitMeasureId = s.intUnitMeasureId
WHERE t.intItemUOMId IS NULL