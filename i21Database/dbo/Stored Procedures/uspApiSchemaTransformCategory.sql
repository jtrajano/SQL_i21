CREATE PROCEDURE uspApiSchemaTransformCategory
	@guiApiUniqueId UNIQUEIDENTIFIER,
	@guiLogId UNIQUEIDENTIFIER
AS

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

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Line of Business') 
	, strValue = staging.strLineOfBusiness
	, strLogLevel = 'Warning'
	, strStatus = 'Failed'
	, intRowNo = staging.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Line of Business') + ' "' + staging.strLineOfBusiness + '" does not exist.'
	, strAction = 'Ignored'
FROM tblApiSchemaTransformCategory staging
LEFT JOIN tblSMLineOfBusiness lob ON lob.strLineOfBusiness = staging.strLineOfBusiness
WHERE staging.guiApiUniqueId = @guiApiUniqueId
	AND NULLIF(staging.strLineOfBusiness, '') IS NOT NULL
	AND lob.intLineOfBusinessId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
	  NEWID()
	, guiApiImportLogId = @guiLogId
	, strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Category Code') 
	, strValue = staging.strCategoryCode
	, strLogLevel = 'Error'
	, strStatus = 'Failed'
	, intRowNo = staging.intRowNumber
	, strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Category Code') + ' "' + staging.strCategoryCode + '" already exists.'
	, strAction = 'Skipped'
FROM tblApiSchemaTransformCategory staging
WHERE staging.guiApiUniqueId = @guiApiUniqueId
	AND ISNULL(@OverwriteExisting, 0) = 0
	AND EXISTS (
		SELECT TOP 1 1
		FROM tblICCategory c
		WHERE c.strCategoryCode = staging.strCategoryCode
	)

 ;WITH cte AS
 (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY staging.strCategoryCode ORDER BY staging.strCategoryCode) AS RowNumber
    FROM tblApiSchemaTransformCategory staging
    WHERE staging.guiApiUniqueId = @guiApiUniqueId
 )
 INSERT INTO tblApiImportLogDetail(guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
 SELECT
       NEWID()
     , guiApiImportLogId = @guiLogId
     , strField = dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Category Code')
     , strValue = sr.strCategoryCode
     , strLogLevel = 'Warning'
     , strStatus = 'Failed'
     , intRowNo = sr.intRowNumber
     , strMessage = 'The ' + dbo.fnApiSchemaTransformMapField(@guiApiUniqueId, 'Category Code') + ' "' + sr.strCategoryCode + '" has duplicate(s) in the file.'
     , strAction = 'Skipped'
 FROM cte sr
 WHERE sr.guiApiUniqueId = @guiApiUniqueId
   AND sr.RowNumber > 1

-- Remove duplicate categories in file
 ;WITH cte AS
 (
    SELECT *, ROW_NUMBER() OVER(PARTITION BY staging.strCategoryCode ORDER BY staging.strCategoryCode) AS RowNumber
    FROM tblApiSchemaTransformCategory staging
    WHERE staging.guiApiUniqueId = @guiApiUniqueId
 )
 DELETE FROM cte
 WHERE guiApiUniqueId = @guiApiUniqueId
   AND RowNumber > 1

-- Update existing categories when overwrite is allowed
UPDATE c
SET c.intLineOfBusinessId = lob.intLineOfBusinessId,
	c.strDescription = staging.strDescription,
	c.guiApiUniqueId = @guiApiUniqueId,
	c.intRowNumber = staging.intRowNumber,
	c.intConcurrencyId = ISNULL(c.intConcurrencyId, 0) + 1
FROM tblICCategory c
JOIN tblApiSchemaTransformCategory staging ON staging.strCategoryCode = c.strCategoryCode
LEFT JOIN tblSMLineOfBusiness lob ON lob.strLineOfBusiness = staging.strLineOfBusiness
WHERE staging.guiApiUniqueId = @guiApiUniqueId
	AND ISNULL(@OverwriteExisting, 0) = 1

-- Insert new categories
INSERT INTO tblICCategory (strCategoryCode, strDescription, intLineOfBusinessId, intConcurrencyId, guiApiUniqueId, intRowNumber)
SELECT staging.strCategoryCode, staging.strDescription, lob.intLineOfBusinessId, 1, @guiApiUniqueId, staging.intRowNumber
FROM tblApiSchemaTransformCategory staging
LEFT JOIN tblSMLineOfBusiness lob ON lob.strLineOfBusiness = staging.strLineOfBusiness
WHERE NOT EXISTS (
		SELECT TOP 1 1
		FROM tblICCategory c
		WHERE c.strCategoryCode = staging.strCategoryCode
	)
	AND staging.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Category'
    , strValue = c.strCategoryCode
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = c.intRowNumber
    , strMessage = 'The inventory category ' + c.strCategoryCode + ' was imported successfully.'
    , strAction = 'Create'
FROM tblICCategory c
WHERE c.guiApiUniqueId = @guiApiUniqueId
	AND c.intConcurrencyId = 1

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage, strAction)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Category'
    , strValue = c.strCategoryCode
    , strLogLevel = 'Info'
    , strStatus = 'Success'
    , intRowNo = c.intRowNumber
    , strMessage = 'The inventory category ' + c.strCategoryCode + ' was updated successfully.'
    , strAction = 'Update'
FROM tblICCategory c
WHERE c.guiApiUniqueId = @guiApiUniqueId
	AND c.intConcurrencyId > 1

UPDATE log
SET log.intTotalRowsImported = ISNULL(i.intCount, 0), 
	log.intTotalRecordsUpdated = ISNULL(u.intCount, 0)
FROM tblApiImportLog log
OUTER APPLY (
	SELECT COUNT(*) intCount
	FROM tblICCategory
	WHERE guiApiUniqueId = log.guiApiUniqueId
		AND intConcurrencyId = 1
) i
OUTER APPLY (
	SELECT COUNT(*) intCount
	FROM tblICCategory
	WHERE guiApiUniqueId = log.guiApiUniqueId
		AND intConcurrencyId > 1
) u
WHERE log.guiApiImportLogId = @guiLogId