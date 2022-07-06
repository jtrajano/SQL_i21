CREATE VIEW [dbo].[vyuICGetInventoryReceiptItemLotQuality]
AS 

SELECT DISTINCT
	LotQuality.intInventoryReceiptItemLotId,
	strValue = CASE 
		WHEN LotQuality.intComponentMapId = ComponentPropertyMap.intComponentMapId
		THEN LotQuality.strValue
		ELSE NULL
	END,
	ComponentPropertyMap.intComponentMapId,
	ComponentPropertyMap.strComponent,
	ComponentPropertyMap.intPropertyId,
	ComponentPropertyMap.strPropertyName
FROM
	tblICInventoryReceiptItemLotQuality LotQuality
CROSS JOIN
	vyuQMComponentPropertyMap ComponentPropertyMap
WHERE NOT EXISTS
	(
	SELECT 
		* 
	FROM 
		tblICInventoryReceiptItemLotQuality 
	WHERE 
		strValue IS NOT NULL 
		AND 
		intComponentMapId = ComponentPropertyMap.intComponentMapId
		AND
		LotQuality.intComponentMapId != ComponentPropertyMap.intComponentMapId
		AND
		intInventoryReceiptItemLotId = LotQuality.intInventoryReceiptItemLotId
	)

GO 