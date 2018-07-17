IF(EXISTS(SELECT 1 FROM INFORMATION_SCHEMA.TABLES WHERE TABLE_NAME = 'tblICInventoryReceiptItem'))
BEGIN
	EXEC(N'UPDATE ri
		SET ri.intWeightUOMId = NULL
		FROM [tblICInventoryReceiptItem] ri
			INNER JOIN tblICItemUOM uom ON uom.intItemUOMId = ri.intWeightUOMId
			INNER JOIN tblICUnitMeasure u ON u.intUnitMeasureId = uom.intUnitMeasureId
			INNER JOIN tblICInventoryReceipt r ON r.intInventoryReceiptId = ri.intInventoryReceiptId
		WHERE NOT (u.strUnitType = ''Weight'' OR u.strUnitType = ''Volume'')
			AND (((ri.dblOpenReceive - ri.dblNet) = 0)
			AND ri.intUnitMeasureId = ri.intWeightUOMId)'
	)
END