GO
PRINT N'*** BEGIN - INSERT DEFAULT DATA IN tblPATImportOriginFlag ***'
GO

MERGE
INTO	[dbo].[tblPATImportOriginFlag]
WITH	(HOLDLOCK)
AS		ImportOriginFlag
USING (
	SELECT	intImportOriginLogId = 1,
			strImportType = 'Patronage Category',
			ysnIsImported = CAST(0 AS BIT),
			intImportCount = 0
	UNION ALL
	SELECT	intImportOriginLogId = 2,
			strImportType = 'Company Preference',
			ysnIsImported = CAST(0 AS BIT),
			intImportCount = 0
	UNION ALL
	SELECT	intImportOriginLogId = 3,
			strImportType = 'Stock Classification',
			ysnIsImported = CAST(0 AS BIT),
			intImportCount = 0
	UNION ALL
	SELECT	intImportOriginLogId = 4,
			strImportType = 'Refund Rate',
			ysnIsImported = CAST(0 AS BIT),
			intImportCount = 0
	UNION ALL
	SELECT	intImportOriginLogId = 5,
			strImportType = 'Estate/Corporation',
			ysnIsImported = CAST(0 AS BIT),
			intImportCount = 0
	UNION ALL
	SELECT	intImportOriginLogId = 6,
			strImportType = 'Stock Details',
			ysnIsImported = CAST(0 AS BIT),
			intImportCount = 0
	UNION ALL
	SELECT	intImportOriginLogId = 7,
			strImportType = 'Volume Details',
			ysnIsImported = CAST(0 AS BIT),
			intImportCount = 0
	UNION ALL
	SELECT	intImportOriginLogId = 8,
			strImportType = 'Equity Details',
			ysnIsImported = CAST(0 AS BIT),
			intImportCount = 0
) AS ImportOriginFlagDefaults
	ON ImportOriginFlag.intImportOriginLogId = ImportOriginFlagDefaults.intImportOriginLogId
WHEN NOT MATCHED THEN
	INSERT (
			intImportOriginLogId, 
			strImportType, 
			ysnIsImported, 
			intImportCount
	)
	VALUES (
			ImportOriginFlagDefaults.intImportOriginLogId,
			ImportOriginFlagDefaults.strImportType,
			ImportOriginFlagDefaults.ysnIsImported,
			ImportOriginFlagDefaults.intImportCount
	)
;
GO
PRINT N'*** END - INSERT DEFAULT DATA IN tblPATImportOriginFlag  ***'
GO