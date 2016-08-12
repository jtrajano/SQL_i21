
PRINT N'BEGIN INVENTORY PATH from 16.01.x.x to 16.02.x.x'

-- Predeployment fix to clear all invalid Gross Net UOM in the Receipt Item
-- GrossNetUOM must be a "Weight" or "Volume" type. 
-- Otherwise, it should be null. 
IF EXISTS (SELECT * FROM sys.tables WHERE object_id = object_id('tblICInventoryReceiptItem'))
BEGIN	
	EXEC ('
		UPDATE	ri
		SET		intWeightUOMId = NULL 
		FROM	tblICInventoryReceiptItem ri INNER JOIN tblICItemUOM iu
					ON ri.intWeightUOMId = iu.intItemUOMId
				INNER JOIN tblICUnitMeasure um
					ON um.intUnitMeasureId = iu.intUnitMeasureId
		WHERE	NOT (um.strUnitType = ''Weight'' OR um.strUnitType = ''Volume'')	
	');
END