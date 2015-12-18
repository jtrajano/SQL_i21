-- Pre deployment fix for non-unique Commodity Codes prior to 15.4 builds
IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE name = 'tblICCommodity')
BEGIN

	EXEC ('
		UPDATE tblICCommodity
		SET strCommodityCode = strCommodityCode + CAST(intCommodityId AS NVARCHAR)
		WHERE strCommodityCode IN (
			SELECT strCommodityCode FROM tblICCommodity
			GROUP BY strCommodityCode
			HAVING COUNT(*) > 1
		)
	')

END

-- Pre deployment fix for non-unique UOMs prior to 15.4 builds
IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE name = 'tblICUnitMeasure')
BEGIN

	EXEC ('
		UPDATE tblICUnitMeasure
		SET strUnitMeasure = strUnitMeasure + CAST(intUnitMeasureId AS NVARCHAR)
		WHERE strUnitMeasure IN (
			SELECT strUnitMeasure FROM tblICUnitMeasure
			GROUP BY strUnitMeasure
			HAVING COUNT(*) > 1
		)
	')

END

-- Pre deployment fix for Tax Group Ids, transfer from detail to header
IF EXISTS(SELECT TOP 1 1 FROM sys.tables WHERE name = 'tblICInventoryReceiptItem')
BEGIN
	IF EXISTS (SELECT * FROM sys.columns WHERE name = 'intTaxGroupId' AND object_id = OBJECT_ID('tblICInventoryReceiptItem'))
	BEGIN
		IF NOT EXISTS(SELECT * FROM sys.columns WHERE name = 'intTaxGroupId' AND object_id = OBJECT_ID('tblICInventoryReceipt'))
		BEGIN
			EXEC ('
				ALTER TABLE tblICInventoryReceipt
				ADD intTaxGroupId INT
			')
		END

		EXEC ('
			UPDATE tblICInventoryReceipt
			SET tblICInventoryReceipt.intTaxGroupId = tblPatch.intTaxGroupId
			FROM (
				SELECT intInventoryReceiptId, intTaxGroupId = MAX(intTaxGroupId) FROM tblICInventoryReceiptItem
				GROUP BY intInventoryReceiptId
			) tblPatch WHERE tblPatch.intInventoryReceiptId = tblICInventoryReceipt.intInventoryReceiptId
		')
	END
END