CREATE PROCEDURE uspICImportReceiptItemLotQualityFromStaging 
	@strIdentifier NVARCHAR(100), 
	@ysnAllowOverwrite BIT = 0,
	@intDataSourceId INT = 2
AS

DELETE FROM tblICImportStagingReceiptItemLotQuality WHERE strImportIdentifier <> @strIdentifier

DECLARE @tblItemLotQualityLogs TABLE(intImportStagingReceiptItemLotQualityId INT, strColumnName NVARCHAR(200), strColumnValue NVARCHAR(200), strLogType NVARCHAR(200), strLogMessage NVARCHAR(MAX))

INSERT INTO @tblItemLotQualityLogs 
(
	intImportStagingReceiptItemLotQualityId,
	strColumnName,
	strColumnValue,
	strLogType,
	strLogMessage
)
SELECT
	ReceiptItemLotQuality.intImportStagingReceiptItemLotQualityId,
	'Component',
	ReceiptItemLotQuality.strComponent,
	'Error',
	'Invalid component: ' + ReceiptItemLotQuality.strComponent + '.'
FROM
	tblICImportStagingReceiptItemLotQuality ReceiptItemLotQuality
LEFT JOIN
	vyuQMComponentPropertyMap ComponentPropertyMap
    ON
        ReceiptItemLotQuality.strComponent = ComponentPropertyMap.strComponent
WHERE
    ComponentPropertyMap.intComponentMapId IS NULL
	AND
	ReceiptItemLotQuality.strImportIdentifier = @strIdentifier

DECLARE @tblOutput TABLE(strAction NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL)

;MERGE INTO tblICInventoryReceiptItemLotQuality AS TARGET
USING
(
	SELECT
		  intInventoryReceiptItemLotId = ReceiptItemLotQuality.intInventoryReceiptItemLotId,
		  intComponentMapId = ComponentPropertyMap.intComponentMapId,
		  strValue = ReceiptItemLotQuality.strValue
	FROM 
		tblICImportStagingReceiptItemLotQuality ReceiptItemLotQuality
	INNER JOIN
		vyuQMComponentPropertyMap ComponentPropertyMap
		ON
			ReceiptItemLotQuality.strComponent = ComponentPropertyMap.strComponent
	WHERE
		ReceiptItemLotQuality.strImportIdentifier = @strIdentifier
) AS SOURCE 
	ON 
		TARGET.intInventoryReceiptItemLotId = SOURCE.intInventoryReceiptItemLotId
		AND
		TARGET.intComponentMapId = SOURCE.intComponentMapId
WHEN MATCHED AND @ysnAllowOverwrite = 1 THEN
	UPDATE SET
		strValue = SOURCE.strValue,
		dtmDateModified = GETUTCDATE()
WHEN NOT MATCHED THEN
	INSERT
	(
		intInventoryReceiptItemLotId,
		intComponentMapId,
		strValue,
		dtmDateCreated
	)
	VALUES
	(
		intInventoryReceiptItemLotId,
		intComponentMapId,
		strValue,
		GETUTCDATE()
	)
	OUTPUT $action INTO @tblOutput;

-- Logs 
BEGIN 

	INSERT INTO tblICImportLogFromStaging (
		[strUniqueId] 
		,[intRowsImported] 
		,[intRowsUpdated] 
		,[intRowsSkipped]
		,[intTotalWarnings]
		,[intTotalErrors]
	)
	SELECT
		@strIdentifier,
		intRowsImported = (SELECT COUNT(*) FROM @tblOutput WHERE strAction = 'INSERT'),
		intRowsUpdated = (SELECT COUNT(*) FROM @tblOutput WHERE strAction = 'UPDATE'),
		intRowsSkipped = (SELECT COUNT(*) - (SELECT COUNT(*) FROM @tblOutput WHERE strAction = 'INSERT') - 
			(SELECT COUNT(*) FROM @tblOutput WHERE strAction = 'UPDATE') 
			FROM tblICImportStagingReceiptItemLotQuality WHERE strImportIdentifier = @strIdentifier),
		intTotalWarnings = (SELECT COUNT(*) FROM @tblItemLotQualityLogs WHERE strLogType = 'Warning'),
		intTotalErrors = (SELECT COUNT(*) FROM @tblItemLotQualityLogs WHERE strLogType = 'Error')

	INSERT INTO tblICImportLogDetailFromStaging(
		strUniqueId,
		strField,
		strAction,
		strValue,
		strMessage,
		strStatus,
		strType,
		intConcurrencyId
	)
	SELECT 
		@strIdentifier,
		strColumnName,
		CASE
			WHEN strLogType = 'Error'
			THEN 'Import Failed.'
			ELSE 'Import Finished'
		END,
		strColumnValue,
		strLogMessage,
		CASE
			WHEN strLogType = 'Error'
			THEN 'Failed.'
			ELSE 'Skipped'
		END,
		CASE
			WHEN strLogType = 'Error'
			THEN 'Error'
			ELSE 'Warning'
		END,
		1
	FROM 
		@tblItemLotQualityLogs
END