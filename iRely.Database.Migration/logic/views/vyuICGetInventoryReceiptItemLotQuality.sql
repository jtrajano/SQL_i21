--liquibase formatted sql

-- changeset Von:vyuICGetInventoryReceiptItemLotQuality.sql.1 runOnChange:true splitStatements:false
-- comment: RK-1234

CREATE OR ALTER VIEW [dbo].[vyuICGetInventoryReceiptItemLotQuality]
AS 

SELECT DISTINCT
	LotQuality.intInventoryReceiptItemLotId,
	strValue = CASE 
		WHEN LotQuality.intComponentMapId = ComponentPropertyMap.intComponentMapId
		THEN LotQuality.strValue
		ELSE NULL
	END COLLATE Latin1_General_CI_AS,
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



