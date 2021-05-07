CREATE PROCEDURE uspICUpdateImportLog 
	@strIdentifier NVARCHAR(100)
AS

DECLARE @intImportLogId AS INT 

SELECT 
	@intImportLogId = l.intImportLogId
FROM 
	tblICImportLog l
WHERE	
	l.strUniqueId = @strIdentifier

-- Log the Detail
INSERT INTO tblICImportLogDetail (
	intImportLogId
	, intRecordNo
	, strField
	, strAction
	, strValue
	, strMessage
	, strStatus
	, strType
	, intConcurrencyId
)
SELECT 
	intImportLogId = @intImportLogId
	, s.intRecordNo
	, s.strField
	, s.strAction
	, s.strValue
	, s.strMessage
	, s.strStatus
	, s.strType
	, s.intConcurrencyId
FROM
	tblICImportLogDetailFromStaging s
WHERE
	s.strUniqueId = @strIdentifier
	AND @intImportLogId IS NOT NULL 

-- Update the Log Figures
UPDATE l
SET 
	l.intRowsImported = ISNULL(l.intRowsImported, 0) + ISNULL(s.intRowsImported, 0)
	,l.intRowsUpdated = ISNULL(l.intRowsUpdated, 0) + ISNULL(s.intRowsUpdated, 0)
	,l.intRowsSkipped = ISNULL(l.intRowsSkipped, 0) + ISNULL(s.intRowsSkipped, 0)
	,l.intTotalErrors = ISNULL(l.intTotalErrors, 0) + ISNULL(errors.intErrors, 0) 
	,l.intTotalWarnings = ISNULL(l.intTotalWarnings, 0) + ISNULL(s.intTotalWarnings, 0) 
FROM 
	tblICImportLogFromStaging s INNER JOIN tblICImportLog l
		ON s.strUniqueId = l.strUniqueId
	OUTER APPLY (
		SELECT 
			intErrors = COUNT(d.intImportLogDetailId) 
		FROM 
			tblICImportLog l INNER JOIN tblICImportLogDetail d 
				ON d.intImportLogId = l.intImportLogId
		WHERE 
			l.strUniqueId = @strIdentifier
			AND d.strType = 'Error'	
	) errors 
WHERE	
	s.strUniqueId = @strIdentifier

