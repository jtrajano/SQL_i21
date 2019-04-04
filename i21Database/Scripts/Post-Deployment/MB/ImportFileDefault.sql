-- DCC File Field Maaping

DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL

-- BP Format
SET @LayoutTitle = 'MB - Simmon Format'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	PRINT ('MB - Simmon Format')

	INSERT INTO tblSMImportFileHeader (strLayoutTitle
		, strFileType
		, strFieldDelimiter
		, ysnActive
		, intConcurrencyId)
	VALUES (@LayoutTitle
		, 'Delimiter'
		, 'Comma'
		, 1
		, 1)

	SET @FileHeaderId = SCOPE_IDENTITY()

	-- Customer ID
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Customer ID', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 1, 'tblMBImportMeterReadingDetail', 'intMeterCustomerId', 1, 1)

	-- Meter Number
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Meter Number', 0, 5, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 2, 'tblMBImportMeterReadingDetail', 'intMeterNumber', 1, 1)

	-- Transaction Date
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Transaction Date', 0, 6, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 3, 'tblMBImportMeterReadingDetail', 'dtmTransactionDate', 1, 1)

	-- Last Meter Reading
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Last Meter Reading', 0, 7, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 4, 'tblMBImportMeterReadingDetail', 'dblCurrentReading', 1, 1)

	-- Last Total Sales
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Last Total Sales', 0, 8, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 5, 'tblMBImportMeterReadingDetail', 'dblCurrentAmount', 1, 1)

END




