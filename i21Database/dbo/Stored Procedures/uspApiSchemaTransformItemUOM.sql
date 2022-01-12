CREATE PROCEDURE uspApiSchemaTransformItemUOM
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

--Check overwrite settings

DECLARE @ysnAllowOverwrite BIT = 0

SELECT @ysnAllowOverwrite = CAST(varPropertyValue AS BIT)
FROM tblApiSchemaTransformProperty
WHERE 
guiApiUniqueId = @guiApiUniqueId
AND
strPropertyName = 'Overwrite'

--Filter Item UOM imported

DECLARE @tblFilteredItemUOM TABLE(
	intKey INT NOT NULL,
    guiApiUniqueId UNIQUEIDENTIFIER NOT NULL,
    intRowNumber INT NULL,
	strItemNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblUnitQty NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strWeightUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strUPCCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strShortUPCCode NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	ysnIsStockUnit NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	ysnAllowPurchase NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	ysnAllowSale NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblLength NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblWidth NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblHeight NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strDimensionUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblWeight NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblVolume NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	strVolumeUOM NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	dblMaxQty NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)
INSERT INTO @tblFilteredItemUOM
(
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strUOM,
	dblUnitQty,
	strWeightUOM,
	strUPCCode,
	strShortUPCCode,
	ysnIsStockUnit,
	ysnAllowPurchase,
	ysnAllowSale,
	dblLength,
	dblWidth,
	dblHeight,
	strDimensionUOM,
	dblWeight,
	dblVolume,
	strVolumeUOM,
	dblMaxQty
)
SELECT 
	intKey,
    guiApiUniqueId,
    intRowNumber,
	strItemNo,
	strUOM,
	dblUnitQty,
	strWeightUOM,
	strUPCCode,
	strShortUPCCode,
	ysnIsStockUnit,
	ysnAllowPurchase,
	ysnAllowSale,
	dblLength,
	dblWidth,
	dblHeight,
	strDimensionUOM,
	dblWeight,
	dblVolume,
	strVolumeUOM,
	dblMaxQty
FROM
tblApiSchemaTransformItemUOM
WHERE guiApiUniqueId = @guiApiUniqueId;

--Create Error Table

DECLARE @tblErrorItemUOM TABLE(
	strItemNo NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	strFieldValue NVARCHAR(100) COLLATE Latin1_General_CI_AS,
	intRowNumber INT NULL,
	intErrorType INT
)
-- Error Types
-- 1 - Duplicate Import UOM 
-- 2 - Duplicate Import UPC 
-- 3 - Missing Item
-- 4 - Missing UOM
-- 5 - Invalid Stock Quantity
-- 6 - Existing UPC Code
-- 7 - Overwrite UOM Disabled
-- 8 - Overwrite UPC Disabled

--Validate Records

INSERT INTO @tblErrorItemUOM
(
	strItemNo, 
	strFieldValue, 
	intRowNumber, 
	intErrorType
)
SELECT -- Duplicate Import UOM
	strItemNo = DuplicateImportUOM.strItemNo,
	strFieldValue = DuplicateImportUOM.strUOM,
	intRowNumber = DuplicateImportUOM.intRowNumber,
	intErrorType = 1
FROM
(
	SELECT 
		strItemNo,
		strUOM,
		intRowNumber,
		RowNumber = ROW_NUMBER() OVER(PARTITION BY strItemNo, strUOM ORDER BY strItemNo, strUOM)
	FROM 
		@tblFilteredItemUOM
) AS DuplicateImportUOM
WHERE RowNumber > 1
UNION
SELECT -- Duplicate Import UPC
	strItemNo = DuplicateImportUPC.strItemNo,
	strFieldValue = DuplicateImportUPC.strUPCCode,
	intRowNumber = DuplicateImportUPC.intRowNumber,
	intErrorType = 2
FROM
(
	SELECT 
		strItemNo,
		strUPCCode,
		strShortUPCCode,
		intRowNumber,
		LongUpcRowNumber = ROW_NUMBER() OVER (PARTITION BY strUPCCode ORDER BY strUPCCode),
		ShortUpcRowNumber = ROW_NUMBER() OVER (PARTITION BY strShortUPCCode ORDER BY strShortUPCCode)
	FROM
		@tblFilteredItemUOM 
) AS DuplicateImportUPC
WHERE 
(LongUpcRowNumber > 1 AND strUPCCode IS NOT NULL)
OR
(ShortUpcRowNumber > 1 AND strShortUPCCode IS NOT NULL)
UNION
SELECT -- Missing Item
	strItemNo = FilteredItemUOM.strItemNo,
	strFieldValue = FilteredItemUOM.strItemNo,
	intRowNumber = FilteredItemUOM.intRowNumber,
	intErrorType = 3
FROM 
	@tblFilteredItemUOM FilteredItemUOM 
	LEFT JOIN tblICItem Item 
		ON RTRIM(LTRIM(Item.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(FilteredItemUOM.strItemNo) COLLATE Latin1_General_CI_AS	
WHERE
	Item.intItemId IS NULL
UNION
SELECT -- Missing UOM
	strItemNo = FilteredItemUOM.strItemNo,
	strFieldValue = FilteredItemUOM.strUOM,
	intRowNumber = FilteredItemUOM.intRowNumber,
	intErrorType = 4
FROM 
	@tblFilteredItemUOM FilteredItemUOM 
	LEFT JOIN tblICUnitMeasure UnitMeasure 
		ON RTRIM(LTRIM(UnitMeasure.strUnitMeasure)) COLLATE Latin1_General_CI_AS = LTRIM(FilteredItemUOM.strUOM) COLLATE Latin1_General_CI_AS
WHERE
	UnitMeasure.intUnitMeasureId IS NULL
UNION
SELECT -- Invalid Stock Quantity
	strItemNo = FilteredItemUOM.strItemNo,
	strFieldValue = FilteredItemUOM.strUOM,
	intRowNumber = FilteredItemUOM.intRowNumber,
	intErrorType = 5
FROM 
	@tblFilteredItemUOM FilteredItemUOM 
WHERE 
	FilteredItemUOM.ysnIsStockUnit = 1 AND 
	CONVERT(DECIMAL(38,20), FilteredItemUOM.dblUnitQty) <> 1
UNION
SELECT -- Existing UPC Code
	strItemNo = FilteredItemUOM.strItemNo,
	strFieldValue = COALESCE(CAST(LongUPC.intUpcCode AS NVARCHAR(100)), LongUPC.strUpcCode, ShortUPC.strUpcCode),
	intRowNumber = FilteredItemUOM.intRowNumber,
	intErrorType = 6
FROM 
	@tblFilteredItemUOM FilteredItemUOM
	INNER JOIN tblICItem Item 
		ON RTRIM(LTRIM(Item.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(FilteredItemUOM.strItemNo) COLLATE Latin1_General_CI_AS
	OUTER APPLY (
		SELECT TOP 1 intUpcCode, strUpcCode, intUnitMeasureId, intItemId
		FROM tblICItemUOM
		WHERE 
			intUpcCode = CASE 
							WHEN FilteredItemUOM.strUPCCode IS NOT NULL AND isnumeric(rtrim(ltrim(strUPCCode)))=(1) 
							AND NOT (FilteredItemUOM.strUPCCode like '%.%' OR FilteredItemUOM.strUPCCode like '%e%' OR FilteredItemUOM.strUPCCode like '%E%') 
								THEN CONVERT([bigint],rtrim(ltrim(FilteredItemUOM.strUPCCode)),0) 
							ELSE CONVERT([bigint],NULL,0) 
						END
	) LongUPC
	OUTER APPLY (
		SELECT TOP 1 ShortUPC.strUpcCode, ShortUPC.intUnitMeasureId, ShortUPC.intItemId
		FROM tblICItemUOM ShortUPC
		INNER JOIN tblICItem ItemUPC 
		ON ShortUPC.intItemId = ItemUPC.intItemId
		WHERE ItemUPC.strItemNo COLLATE Latin1_General_CI_AS = FilteredItemUOM.strItemNo COLLATE Latin1_General_CI_AS
	) ShortUPC
WHERE
(
	LongUPC.intUpcCode IS NOT NULL 
	AND 
	Item.intItemId <> LongUPC.intItemId
)
OR
(
	ShortUPC.strUpcCode IS NOT NULL 
	AND 
	Item.intItemId <> ShortUPC.intItemId
)
UNION
SELECT -- Overwrite UOM Disabled
	strItemNo = FilteredItemUOM.strItemNo,
	strFieldValue = FilteredItemUOM.strUOM,
	intRowNumber = FilteredItemUOM.intRowNumber,
	intErrorType = 7
FROM 
	@tblFilteredItemUOM FilteredItemUOM
	INNER JOIN vyuICItemUOM ItemUOM
		ON FilteredItemUOM.strItemNo = ItemUOM.strItemNo
		AND
		FilteredItemUOM.strUOM = ItemUOM.strUnitMeasure
		AND
		@ysnAllowOverwrite = 0
UNION
SELECT -- Overwrite UPC Disabled
	strItemNo = FilteredItemUOM.strItemNo,
	strFieldValue = FilteredItemUOM.strUPCCode,
	intRowNumber = FilteredItemUOM.intRowNumber,
	intErrorType = 8
FROM 
	@tblFilteredItemUOM FilteredItemUOM
	INNER JOIN vyuICItemUOM ItemUOM
		ON 
		(
			FilteredItemUOM.strItemNo = ItemUOM.strItemNo
			AND
			FilteredItemUOM.strShortUPCCode = ItemUOM.strUpcCode
			AND 
			FilteredItemUOM.strShortUPCCode IS NOT NULL
		)
		OR
		(
			FilteredItemUOM.strItemNo = ItemUOM.strItemNo
			AND
			FilteredItemUOM.strUPCCode = ItemUOM.strLongUPCCode
			AND 
			FilteredItemUOM.strUPCCode IS NOT NULL
		)
		AND
		@ysnAllowOverwrite = 0

--Log Warnings and Errors

INSERT INTO tblApiImportLogDetail 
(
	guiApiImportLogDetailId,
	guiApiImportLogId,
	strField,
	strValue,
	strLogLevel,
	strStatus,
	intRowNo,
	strMessage
)
SELECT
	guiApiImportLogDetailId = NEWID(),
	guiApiImportLogId = @guiLogId,
	strField = CASE
		WHEN ErrorItemUOM.intErrorType = 1
			THEN 'UOM'
		WHEN ErrorItemUOM.intErrorType = 2
			THEN 'UPC Code'
		WHEN ErrorItemUOM.intErrorType = 3
			THEN 'Item No'
		WHEN ErrorItemUOM.intErrorType = 4
			THEN 'UOM'
		WHEN ErrorItemUOM.intErrorType = 5
			THEN 'Unit Qty'
		WHEN ErrorItemUOM.intErrorType = 6
			THEN 'UPC Code'
		WHEN ErrorItemUOM.intErrorType = 7
			THEN 'UOM'
		ELSE 'UPC Code'
	END,
	strValue = ErrorItemUOM.strFieldValue,
	strLogLevel = CASE
		WHEN ErrorItemUOM.intErrorType = 1 OR ErrorItemUOM.intErrorType = 3 OR ErrorItemUOM.intErrorType = 4
			THEN 'Error'
		ELSE 'Warning'
	END,
	strStatus = CASE
		WHEN ErrorItemUOM.intErrorType = 1 OR ErrorItemUOM.intErrorType = 3 OR ErrorItemUOM.intErrorType = 4 OR ErrorItemUOM.intErrorType = 7 OR ErrorItemUOM.intErrorType = 8
			THEN 'Skipped'
		ELSE 'Success'
	END,
	intRowNo = ErrorItemUOM.intRowNumber,
	strMessage = CASE
		WHEN ErrorItemUOM.intErrorType = 1
			THEN 'Duplicate imported unit of measure: ' + ISNULL(ErrorItemUOM.strFieldValue, '') + ' on item: ' + ISNULL(ErrorItemUOM.strItemNo, '') + '.'
		WHEN ErrorItemUOM.intErrorType = 2
			THEN 'Duplicate imported UPC: ' + ISNULL(ErrorItemUOM.strFieldValue, '') + ' on item: ' + ISNULL(ErrorItemUOM.strItemNo, '') + '. Import will continue with empty UPC instead.'
		WHEN ErrorItemUOM.intErrorType = 3
			THEN 'Missing item: ' + ErrorItemUOM.strItemNo + '.'
		WHEN ErrorItemUOM.intErrorType = 4
			THEN 'Missing unit of measure: ' + ErrorItemUOM.strFieldValue + ' on item: ' + ErrorItemUOM.strItemNo + '.'
		WHEN ErrorItemUOM.intErrorType = 5
			THEN 'Unit quantity for stock unit: ' + ErrorItemUOM.strFieldValue + ' on item: ' + ErrorItemUOM.strItemNo + ' is greater than 1. Setting quantity to 1.'
		WHEN ErrorItemUOM.intErrorType = 6
			THEN 'UPC: ' + ErrorItemUOM.strFieldValue + ' on item: ' + ErrorItemUOM.strItemNo + ' already exists. Import will continue with empty UPC instead.'
		WHEN ErrorItemUOM.intErrorType = 7
			THEN 'Unit of measure: ' + ISNULL(ErrorItemUOM.strFieldValue, '') + ' on item: ' + ISNULL(ErrorItemUOM.strItemNo, '') + ' already exists and overwrite is not enabled.'
		ELSE 'UPC: ' + ISNULL(ErrorItemUOM.strFieldValue, '') + ' on item: ' + ISNULL(ErrorItemUOM.strItemNo, '') + ' already exists and overwrite is not enabled.'
	END
FROM @tblErrorItemUOM ErrorItemUOM
WHERE ErrorItemUOM.intErrorType IN(1, 2, 3, 4, 5, 6, 7, 8)

--Filter Item UOM to be removed

DELETE 
FilteredItemUOM
FROM 
	@tblFilteredItemUOM FilteredItemUOM
	INNER JOIN @tblErrorItemUOM ErrorItemUOM
		ON FilteredItemUOM.intRowNumber = ErrorItemUOM.intRowNumber
WHERE ErrorItemUOM.intErrorType IN(1, 3, 4, 7, 8)

--Update Item UOM with UPC warnings

UPDATE FilteredItemUOM 
SET 
FilteredItemUOM.strUPCCode = CASE  
	WHEN ErrorItemUOM.strFieldValue IS NOT NULL AND ErrorItemUOM.strFieldValue COLLATE Latin1_General_CI_AS = FilteredItemUOM.strUPCCode COLLATE Latin1_General_CI_AS
	THEN NULL
	ELSE FilteredItemUOM.strUPCCode
END,
FilteredItemUOM.strShortUPCCode = CASE  
	WHEN ErrorItemUOM.strFieldValue IS NOT NULL AND ErrorItemUOM.strFieldValue COLLATE Latin1_General_CI_AS = FilteredItemUOM.strShortUPCCode COLLATE Latin1_General_CI_AS
	THEN NULL
	ELSE FilteredItemUOM.strShortUPCCode
END
FROM 
	@tblFilteredItemUOM FilteredItemUOM
	INNER JOIN @tblErrorItemUOM ErrorItemUOM
		ON FilteredItemUOM.intRowNumber = ErrorItemUOM.intRowNumber
WHERE ErrorItemUOM.intErrorType IN(2, 6)

--Update Item UOM with stock unit warnings

UPDATE FilteredItemUOM 
SET 
FilteredItemUOM.dblUnitQty = 1
FROM 
	@tblFilteredItemUOM FilteredItemUOM
	INNER JOIN @tblErrorItemUOM ErrorItemUOM
		ON FilteredItemUOM.intRowNumber = ErrorItemUOM.intRowNumber
WHERE ErrorItemUOM.intErrorType = 5

DECLARE @intItemId INT 
DECLARE @intUnitMeasureId INT 
DECLARE @strLongUPCCode NVARCHAR(200)
DECLARE @strUpcCode NVARCHAR(200)
DECLARE @dblUnitQty NUMERIC(38, 20) 
DECLARE @dblHeight NUMERIC(38, 20) 
DECLARE @dblWidth NUMERIC(38, 20) 
DECLARE @dblLength NUMERIC(38, 20) 
DECLARE @dblMaxQty NUMERIC(38, 20) 
DECLARE @dblVolume NUMERIC(38, 20) 
DECLARE @dblWeight NUMERIC(38, 20) 
DECLARE @ysnStockUnit BIT 
DECLARE @ysnAllowPurchase BIT 
DECLARE @ysnAllowSale BIT

DECLARE uom_cursor CURSOR FOR 
SELECT
	intItemId = Item.intItemId,
	intUnitMeasureId = UnitMeasure.intUnitMeasureId,
	strLongUPCCode = FilteredItemUOM.strUPCCode,
	strUpcCode = FilteredItemUOM.strShortUPCCode,
	dblUnitQty = FilteredItemUOM.dblUnitQty,
	dblHeight = FilteredItemUOM.dblHeight,
	dblWidth = FilteredItemUOM.dblWidth,
	dblLength = FilteredItemUOM.dblLength,
	dblMaxQty = FilteredItemUOM.dblMaxQty,
	dblVolume = FilteredItemUOM.dblVolume,
	dblWeight = FilteredItemUOM.dblWeight,
	ysnStockUnit = ISNULL(Stock.ysnStockUnit, FilteredItemUOM.ysnIsStockUnit),
	ysnAllowPurchase = FilteredItemUOM.ysnAllowPurchase,
	ysnAllowSale = FilteredItemUOM.ysnAllowSale
FROM @tblFilteredItemUOM FilteredItemUOM
	INNER JOIN tblICItem Item ON RTRIM(LTRIM(Item.strItemNo)) COLLATE Latin1_General_CI_AS = LTRIM(FilteredItemUOM.strItemNo) COLLATE Latin1_General_CI_AS
	INNER JOIN tblICUnitMeasure UnitMeasure ON RTRIM(LTRIM(UnitMeasure.strUnitMeasure)) COLLATE Latin1_General_CI_AS = LTRIM(FilteredItemUOM.strUOM) COLLATE Latin1_General_CI_AS
	OUTER APPLY (
		SELECT TOP 1 CAST(0 AS BIT) ysnStockUnit
		FROM tblICItemUOM
		WHERE intUnitMeasureId = UnitMeasure.intUnitMeasureId
			AND intItemId = Item.intItemId
			AND ysnStockUnit = 1
	) Stock

OPEN uom_cursor  
FETCH NEXT FROM uom_cursor INTO 
	@intItemId,
	@intUnitMeasureId,
	@strLongUPCCode,
	@strUpcCode,
	@dblUnitQty,
	@dblHeight,
	@dblWidth,
	@dblLength,
	@dblMaxQty,
	@dblVolume,
	@dblWeight,
	@ysnStockUnit,
	@ysnAllowPurchase,
	@ysnAllowSale

WHILE @@FETCH_STATUS = 0  
BEGIN  
      
	
	UPDATE tblICItemUOM 
	SET 
		intItemId = @intItemId,
		intUnitMeasureId = @intUnitMeasureId,
		strLongUPCCode = @strLongUPCCode,
		strUpcCode = @strUpcCode,
		dblUnitQty = @dblUnitQty,
		dblHeight = @dblHeight,
		dblWidth = @dblWidth,
		dblLength = @dblLength,
		dblMaxQty = @dblMaxQty,
		dblVolume = @dblVolume,
		dblWeight = @dblWeight,
		ysnStockUnit = @ysnStockUnit,
		ysnAllowPurchase = @ysnAllowPurchase,
		ysnAllowSale = @ysnAllowSale,
		dtmDateModified = GETUTCDATE(),
		guiApiUniqueId = @guiApiUniqueId
	WHERE 
		(intUnitMeasureId = @intUnitMeasureId AND intItemId = @intItemId)
		OR
		(
			RTRIM(LTRIM(strLongUPCCode)) COLLATE Latin1_General_CI_AS = LTRIM(@strLongUPCCode) COLLATE Latin1_General_CI_AS 
			AND 
			@strLongUPCCode IS NOT NULL
			AND
			intItemId = @intItemId
		)
		OR
		(
			RTRIM(LTRIM(strUpcCode)) COLLATE Latin1_General_CI_AS = LTRIM(@strUpcCode) COLLATE Latin1_General_CI_AS 
			AND 
			@strUpcCode IS NOT NULL
			AND
			intItemId = @intItemId
		)
		AND
		@ysnAllowOverwrite = 1
	IF (@@ROWCOUNT > 0)
	BEGIN
		PRINT 'Row Updated'
		--SET @intRowsUpdated = @intRowsUpdated + 1
	END
	ELSE
	BEGIN
		INSERT INTO tblICItemUOM
		(
			intItemId, 
			intUnitMeasureId, 
			strLongUPCCode,
			strUpcCode,
			dblUnitQty,
			dblHeight,
			dblWidth,
			dblLength,
			dblMaxQty,
			dblVolume,
			dblWeight,
			ysnStockUnit,
			ysnAllowPurchase,
			ysnAllowSale,
			dtmDateCreated,
			guiApiUniqueId
		)
		SELECT 
			RowItem.intItemId, 
			RowItem.intUnitMeasureId, 
			RowItem.strLongUPCCode,
			RowItem.strUpcCode,
			RowItem.dblUnitQty,
			RowItem.dblHeight,
			RowItem.dblWidth,
			RowItem.dblLength,
			RowItem.dblMaxQty,
			RowItem.dblVolume,
			RowItem.dblWeight,
			RowItem.ysnStockUnit,
			RowItem.ysnAllowPurchase,
			RowItem.ysnAllowSale,
			GETUTCDATE(),
			@guiApiUniqueId
		FROM
		(
			SELECT
			intItemId = @intItemId,
			intUnitMeasureId = @intUnitMeasureId,
			strLongUPCCode = @strLongUPCCode,
			strUpcCode = @strUpcCode,
			dblUnitQty = @dblUnitQty,
			dblHeight = @dblHeight,
			dblWidth = @dblWidth,
			dblLength = @dblLength,
			dblMaxQty = @dblMaxQty,
			dblVolume = @dblVolume,
			dblWeight = @dblWeight,
			ysnStockUnit = @ysnStockUnit,
			ysnAllowPurchase = @ysnAllowPurchase,
			ysnAllowSale = @ysnAllowSale
		) AS RowItem
		LEFT JOIN 
		tblICItemUOM ItemUOM
		ON 
		RowItem.intItemId = ItemUOM.intItemId
		AND
		RowItem.intUnitMeasureId = ItemUOM.intUnitMeasureId
		LEFT JOIN 
		tblICItemUOM ItemLongUPC
		ON 
		RowItem.intItemId = ItemUOM.intItemId
		AND
		RowItem.strLongUPCCode = ItemUOM.strLongUPCCode
		AND
		RowItem.strLongUPCCode IS NOT NULL
		LEFT JOIN 
		tblICItemUOM ItemShortUPC
		ON 
		RowItem.intItemId = ItemUOM.intItemId
		AND
		RowItem.strUpcCode = ItemUOM.strUpcCode
		AND
		RowItem.strUpcCode IS NOT NULL
		WHERE
		ItemUOM.intItemUOMId IS NULL

		IF (@@ROWCOUNT > 0)
		BEGIN
			PRINT 'Row Inserted'
			--SET @intRowsImported = @intRowsImported + 1
		END
	END


	FETCH NEXT FROM uom_cursor INTO 
		@intItemId
		,@intUnitMeasureId
		,@strLongUPCCode
		,@strUpcCode
		,@dblUnitQty
		,@dblHeight
		,@dblWidth
		,@dblLength
		,@dblMaxQty
		,@dblVolume
		,@dblWeight
		,@ysnStockUnit
		,@ysnAllowPurchase
		,@ysnAllowSale
END 

CLOSE uom_cursor  
DEALLOCATE uom_cursor