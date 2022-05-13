CREATE PROCEDURE uspApiSchemaTransformItemUOM
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

-- Retrieve Properties
DECLARE @OverwriteExisting BIT = 1

SELECT
    @OverwriteExisting = ISNULL(CAST(Overwrite AS BIT), 0)
FROM (
	SELECT tp.strPropertyName, tp.varPropertyValue
	FROM tblApiSchemaTransformProperty tp
	WHERE tp.guiApiUniqueId = @guiApiUniqueId
) AS Properties
PIVOT (
	MIN(varPropertyValue)
	FOR strPropertyName IN
	(
		Overwrite
	)
) AS PivotTable


-- Validations

-- Remove duplicate UOMs from file
;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strItemNo, sr.strUOM ORDER BY sr.strItemNo, sr.strUOM) AS RowNumber
   FROM tblApiSchemaTransformItemUOM sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND NULLIF(sr.strUOM, '') IS NOT NULL
   AND NULLIF(sr.strItemNo, '') IS NOT NULL
)
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'UOM'
    , strValue = sr.strUOM
    , strLogLevel = 'Error'
    , strStatus = 'Skipped'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The UOM ' + ISNULL(sr.strUOM, '') + ' for ' + ISNULL(sr.strItemNo, '') + ' in the file has duplicates.'
FROM cte sr
JOIN tblICUnitMeasure u ON u.strUnitMeasure = sr.strUOM
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND sr.RowNumber > 1;

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strItemNo, sr.strUOM ORDER BY sr.strItemNo, sr.strUOM) AS RowNumber
   FROM tblApiSchemaTransformItemUOM sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND NULLIF(sr.strUOM, '') IS NOT NULL
   AND NULLIF(sr.strItemNo, '') IS NOT NULL
)
DELETE FROM cte WHERE RowNumber > 1;

-- Set UPC Code of duplicates from file to NULL
;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strUPCCode ORDER BY sr.strUPCCode) AS RowNumber
   FROM tblApiSchemaTransformItemUOM sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND NULLIF(sr.strUPCCode, '') IS NOT NULL
)
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'UPC Code'
    , strValue = sr.strUPCCode
    , strLogLevel = 'Warning'
    , strStatus = 'Skipped'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The UPC Code ' + ISNULL(sr.strUPCCode, '') + ' in the file has duplicates.'
FROM cte sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND sr.RowNumber > 1

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strUPCCode ORDER BY sr.strUPCCode) AS RowNumber
   FROM tblApiSchemaTransformItemUOM sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND NULLIF(sr.strUPCCode, '') IS NOT NULL 
)
UPDATE cte
SET cte.strUPCCode = NULL
WHERE cte.RowNumber > 1;

-- Set Short UPC Code of duplicates from file to NULL
;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strShortUPCCode ORDER BY sr.strShortUPCCode) AS RowNumber
   FROM tblApiSchemaTransformItemUOM sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND NULLIF(sr.strShortUPCCode, '') IS NOT NULL
)
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Short UPC Code'
    , strValue = sr.strShortUPCCode
    , strLogLevel = 'Warning'
    , strStatus = 'Skipped'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Short UPC Code ' + ISNULL(sr.strShortUPCCode, '') + ' in the file has duplicates.'
FROM cte sr
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND sr.RowNumber > 1

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.strShortUPCCode ORDER BY sr.strShortUPCCode) AS RowNumber
   FROM tblApiSchemaTransformItemUOM sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND NULLIF(sr.strShortUPCCode, '') IS NOT NULL 
)
UPDATE cte
SET cte.strShortUPCCode = NULL
WHERE cte.RowNumber > 1;

-- Duplicate stock units
;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.ysnIsStockUnit ORDER BY sr.ysnIsStockUnit) AS RowNumber
   FROM tblApiSchemaTransformItemUOM sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND sr.ysnIsStockUnit = 1
)
INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Is Stock Unit'
    , strValue = sr.ysnIsStockUnit
    , strLogLevel = 'Warning'
    , strStatus = 'Skipped'
    , intRowNo = sr.intRowNumber
    , strMessage = 'Duplicated stock units for ' + ISNULL(sr.strItemNo, '') + ' found in the file.'
FROM cte sr
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
WHERE sr.guiApiUniqueId = @guiApiUniqueId
	AND sr.RowNumber > 1
	AND sr.ysnIsStockUnit = 1

;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY sr.ysnIsStockUnit ORDER BY sr.ysnIsStockUnit) AS RowNumber
   FROM tblApiSchemaTransformItemUOM sr
   WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND sr.ysnIsStockUnit = 1
)
UPDATE cte
SET cte.ysnIsStockUnit = 0
WHERE cte.RowNumber > 1;

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item No'
    , strValue = sr.strItemNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Item No ' + ISNULL(sr.strItemNo, '') + ' does not exist.'
FROM tblApiSchemaTransformItemUOM sr
LEFT JOIN tblICItem i ON i.strItemNo = sr.strItemNo
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND i.intItemId IS NULL
AND NULLIF(sr.strItemNo, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'UOM'
    , strValue = sr.strUOM
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The UOM ' + ISNULL(sr.strUOM, '') + ' does not exist.'
FROM tblApiSchemaTransformItemUOM sr
LEFT JOIN tblICUnitMeasure i ON i.strUnitMeasure = sr.strUOM
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND i.intUnitMeasureId IS NULL
AND NULLIF(sr.strUOM, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Weight UOM'
    , strValue = sr.strWeightUOM
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Weight UOM ' + ISNULL(sr.strWeightUOM, '') + ' does not exist.'
FROM tblApiSchemaTransformItemUOM sr
LEFT JOIN tblICUnitMeasure i ON i.strUnitMeasure = sr.strWeightUOM
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND i.intUnitMeasureId IS NULL
AND NULLIF(sr.strWeightUOM, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'UOM'
    , strValue = sr.strUOM
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The UOM ' + ISNULL(sr.strUOM, '') + ' already exists in ' + ISNULL(sr.strItemNo, '') + '.'
FROM tblApiSchemaTransformItemUOM sr
JOIN tblICUnitMeasure u ON u.strUnitMeasure = sr.strUOM
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
CROSS APPLY (
	SELECT TOP 1 1 intCount
	FROM tblICItemUOM xui
	JOIN tblICItem xi ON xi.intItemId = xui.intItemId
	JOIN tblICUnitMeasure xu ON xu.intUnitMeasureId = xui.intUnitMeasureId
	WHERE xi.intItemId = i.intItemId
		AND xu.intUnitMeasureId = u.intUnitMeasureId
) ex
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND u.intUnitMeasureId IS NOT NULL
AND i.intItemId IS NOT NULL
AND ex.intCount IS NOT NULL
AND NULLIF(sr.strUOM, '') IS NOT NULL
AND @OverwriteExisting = 0

-- Existing UPC Code
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'UPC Code'
    , strValue = sr.strUPCCode
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The UPC Code ' + ISNULL(sr.strUPCCode, '') + ' already exists in ' + ISNULL(sr.strItemNo, '') + '.'
FROM tblApiSchemaTransformItemUOM sr
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
CROSS APPLY (
	SELECT TOP 1 1 intCount
	FROM tblICItemUOM xui
	WHERE xui.strLongUPCCode = sr.strUPCCode
		AND (@OverwriteExisting = 0 OR (@OverwriteExisting = 1 AND EXISTS(
			SELECT TOP 1 1
			FROM tblICUnitMeasure u
			JOIN tblICItemUOM xx ON xx.intItemId = i.intItemId
				AND xx.intUnitMeasureId = u.intUnitMeasureId
			WHERE u.strUnitMeasure != sr.strUOM
				AND xx.strLongUPCCode = sr.strUPCCode
		)))
) ex
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND i.intItemId IS NOT NULL
AND ex.intCount IS NOT NULL
AND NULLIF(sr.strUPCCode, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Short UPC Code'
    , strValue = sr.strUPCCode
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sr.intRowNumber
    , strMessage = 'The Short UPC Code ' + ISNULL(sr.strShortUPCCode, '') + ' already exists in ' + ISNULL(sr.strItemNo, '') + '.'
FROM tblApiSchemaTransformItemUOM sr
JOIN tblICItem i ON i.strItemNo = sr.strItemNo
CROSS APPLY (
	SELECT TOP 1 1 intCount
	FROM tblICItemUOM xui
	WHERE xui.strUpcCode = sr.strShortUPCCode
		AND (@OverwriteExisting = 0 OR (@OverwriteExisting = 1 AND EXISTS(
			SELECT TOP 1 1
			FROM tblICUnitMeasure u
			JOIN tblICItemUOM xx ON xx.intItemId = i.intItemId
				AND xx.intUnitMeasureId = u.intUnitMeasureId
			WHERE u.strUnitMeasure != sr.strUOM
				AND xx.strUpcCode = sr.strShortUPCCode
		)))
) ex
WHERE sr.guiApiUniqueId = @guiApiUniqueId
AND i.intItemId IS NOT NULL
AND ex.intCount IS NOT NULL
AND NULLIF(sr.strShortUPCCode, '') IS NOT NULL

-- Update EXISTING
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item UOM'
    , strValue = ux.strUOM
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = ux.intRowNumber
    , strMessage = 'The UOM ' + ISNULL(ux.strUOM, '') + ' for ' + ISNULL(ux.strItemNo, '') + ' was updated.'
FROM tblICItemUOM iu
JOIN tblICItem i ON i.intItemId = iu.intItemId
JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
JOIN tblApiSchemaTransformItemUOM ux ON ux.strUOM = u.strUnitMeasure
   AND ux.strItemNo = i.strItemNo
WHERE ux.guiApiUniqueId = @guiApiUniqueId
   AND iu.intItemUOMId IS NOT NULL
   AND @OverwriteExisting = 1
   AND NOT EXISTS(
		SELECT TOP 1 1
		FROM tblICUnitMeasure u
		JOIN tblICItemUOM xx ON xx.intItemId = i.intItemId
			AND xx.intUnitMeasureId = u.intUnitMeasureId
		WHERE u.strUnitMeasure != ux.strUOM
			AND (xx.strLongUPCCode = ux.strUPCCode OR xx.strUpcCode = ux.strShortUPCCode)
	)

UPDATE iu
SET
     iu.dblUnitQty = ux.dblUnitQty
   , iu.dblHeight = ux.dblHeight
   , iu.dblWidth = ux.dblWidth
   , iu.dblLength = ux.dblLength
   , iu.dblMaxQty = ux.dblMaxQty
   , iu.dblVolume = ux.dblVolume
   , iu.dblWeight = ux.dblWeight
   , iu.ysnStockUnit = ux.ysnIsStockUnit
   , iu.ysnAllowPurchase = ux.ysnAllowPurchase
   , iu.ysnAllowSale = ux.ysnAllowSale
   , iu.dtmDateModified = GETUTCDATE()
   , iu.strLongUPCCode = ux.strUPCCode
   , iu.intRowNumber = ux.intRowNumber
   , iu.guiApiUniqueId = @guiApiUniqueId
FROM tblICItemUOM iu
JOIN tblICItem i ON i.intItemId = iu.intItemId
JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
JOIN tblApiSchemaTransformItemUOM ux ON ux.strUOM = u.strUnitMeasure
   AND ux.strItemNo = i.strItemNo
WHERE ux.guiApiUniqueId = @guiApiUniqueId
   AND @OverwriteExisting = 1
   AND NOT EXISTS(
		SELECT TOP 1 1
		FROM tblICUnitMeasure u
		JOIN tblICItemUOM xx ON xx.intUnitMeasureId = u.intUnitMeasureId
		WHERE u.strUnitMeasure != ux.strUOM
			AND (xx.strLongUPCCode = ux.strUPCCode OR xx.strUpcCode = ux.strShortUPCCode)
	)

-- Insert new UOMs
INSERT INTO tblICItemUOM
(
	intItemId, 
	intUnitMeasureId, 
	strLongUPCCode,
	strUpcCode,
	-- intCheckDigit,
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
	guiApiUniqueId,
	intRowNumber
)
SELECT
	i.intItemId
	, u.intUnitMeasureId
	, ux.strUPCCode
	, ux.strShortUPCCode
	-- , dbo.fnICCalculateCheckDigit(ux.strUPCCode)
	, ux.dblUnitQty
	, ux.dblHeight
	, ux.dblWidth
	, ux.dblLength
	, ux.dblMaxQty
	, ux.dblVolume
	, ux.dblWeight
	, ux.ysnIsStockUnit
	, ux.ysnAllowPurchase
	, ux.ysnAllowSale
	, GETUTCDATE()
	, @guiApiUniqueId
	, ux.intRowNumber
FROM tblApiSchemaTransformItemUOM ux
JOIN tblICItem i ON i.strItemNo = ux.strItemNo
JOIN tblICUnitMeasure u ON u.strUnitMeasure = ux.strUOM
OUTER APPLY (
	SELECT TOP 1 1 intCount
	FROM tblICItemUOM xui
	JOIN tblICItem xi ON xi.intItemId = xui.intItemId
	JOIN tblICUnitMeasure xu ON xu.intUnitMeasureId = xui.intUnitMeasureId
	WHERE xi.intItemId = i.intItemId
		AND xu.intUnitMeasureId = u.intUnitMeasureId
) ex
WHERE ux.guiApiUniqueId = @guiApiUniqueId
	AND ex.intCount IS NULL
	AND NOT EXISTS(
		SELECT TOP 1 1
		FROM tblICUnitMeasure u
		JOIN tblICItemUOM xx ON xx.intUnitMeasureId = u.intUnitMeasureId
		WHERE u.strUnitMeasure != ux.strUOM
			AND (xx.strLongUPCCode = ux.strUPCCode OR xx.strUpcCode = ux.strShortUPCCode)
	)
-- Global cleanup
UPDATE tblICItemUOM SET ysnStockUnit = 0 WHERE dblUnitQty <> 1 AND ysnStockUnit = 1
UPDATE tblICItemUOM SET ysnStockUnit = 1 WHERE ysnStockUnit = 0 AND dblUnitQty = 1

-- Remove duplicate stock unit
;WITH cte AS
(
   SELECT *, ROW_NUMBER() OVER(PARTITION BY intItemId ORDER BY intItemId, ysnStockUnit) AS RowNumber
   FROM tblICItemUOM
   WHERE ysnStockUnit = 1
)
UPDATE cte SET ysnStockUnit = 0 WHERE RowNumber > 1;

-- Log successful imports
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Item UOM'
    , strValue = u.strUnitMeasure
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = iu.intRowNumber
    , strMessage = 'The Item UOM ' + ISNULL(u.strUnitMeasure, '') + ' was imported successfully to ' +
		ISNULL(i.strItemNo, '') + '.'
FROM tblICItemUOM iu
JOIN tblICItem i ON i.intItemId = iu.intItemId
JOIN tblICUnitMeasure u ON u.intUnitMeasureId = iu.intUnitMeasureId
WHERE iu.guiApiUniqueId = @guiApiUniqueId

UPDATE log
SET log.intTotalRowsImported = r.intCount
FROM tblApiImportLog log
CROSS APPLY (
	SELECT COUNT(*) intCount
	FROM tblICItemUOM
	WHERE guiApiUniqueId = log.guiApiUniqueId
) r
WHERE log.guiApiImportLogId = @guiLogId