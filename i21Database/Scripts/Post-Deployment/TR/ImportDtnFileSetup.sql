DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL

SET @LayoutTitle = 'DTN Standard Outbound Invoice CSV Plus Header'

-- Header Format
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	PRINT ('Deploying - DTN Standard Outbound Invoice CSV Plus Header')

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

	-- DTN Transaction Number
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'DTN Transaction Number', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 1, 'tblTRImportDtnDetail', 'strDtnNo', 1, 1)

    -- Invoice Date
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Invoice Date', 0, 6, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 2, 'tblTRImportDtnDetail', 'dtmInvoiceDate', 1, 1)

    -- Seller Name
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Seller Name', 0, 8, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 3, 'tblTRImportDtnDetail', 'strSeller', 1, 1)

    -- Total Invoice Amount
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Invoice Amount', 0, 15, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 4, 'tblTRImportDtnDetail', 'dblInvoiceAmount', 1, 1)

	-- Terms Description
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Term Description', 0, 12, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 5, 'tblTRImportDtnDetail', 'strTerm', 1, 1)

	-- Invoice Number
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Invoice No', 0, 5, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 6, 'tblTRImportDtnDetail', 'strInvoiceNo', 1, 1)

	-- Due Date
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Due Date', 0, 14, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 7, 'tblTRImportDtnDetail', 'dtmDueDate', 1, 1)

END
GO

DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL

SET @LayoutTitle = 'DTN Standard Outbound Invoice CSV Plus Item'

-- Item Format
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	PRINT ('Deploying - DTN Standard Outbound Invoice CSV Plus Item')

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

	-- BOL NUMER
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'BOL Number', 0, 2, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 1, 'tblTRImportDtnDetail', 'strBillOfLading', 1, 1)

END
GO

DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL

SET @LayoutTitle = 'DTN Standard Outbound Invoice CSV Deferred Tax'

-- Deferred Tax Format
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle) 
BEGIN
	PRINT ('Deploying - DTN Standard Outbound Invoice CSV Plus Deferred Tax')

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

	-- DEFERRED TAX 1
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 1', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 1, 'tblTRImportDtnDetail', 'dblDeferredAmt1', 1, 1)

	-- DEFERRED DATE 1
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 1', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 2, 'tblTRImportDtnDetail', 'dtmDeferredDate1', 1, 1)

	-- DEFERRED INVOICE 1
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 1', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 3, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo1', 1, 1)


	-- DEFERRED TAX 2
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 2', 0, 5, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 4, 'tblTRImportDtnDetail', 'dblDeferredAmt2', 1, 1)

	-- DEFERRED DATE 2
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 2', 0, 7, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 5, 'tblTRImportDtnDetail', 'dtmDeferredDate2', 1, 1)

	-- DEFERRED INVOICE 2
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 2', 0, 8, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 6, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo2', 1, 1)


	-- DEFERRED TAX 3
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 3', 0, 9, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 7, 'tblTRImportDtnDetail', 'dblDeferredAmt3', 1, 1)

	-- DEFERRED DATE 3
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 3', 0, 11, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 8, 'tblTRImportDtnDetail', 'dtmDeferredDate3', 1, 1)

	-- DEFERRED INVOICE 3
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 3', 0, 12, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 9, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo3', 1, 1)


	-- DEFERRED TAX 4
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 4', 0, 13, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 10, 'tblTRImportDtnDetail', 'dblDeferredAmt4', 1, 1)

	-- DEFERRED DATE 4
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 4', 0, 15, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 11, 'tblTRImportDtnDetail', 'dtmDeferredDate4', 1, 1)

	-- DEFERRED INVOICE 4
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 4', 0, 16, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 12, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo4', 1, 1)


	-- DEFERRED TAX 5
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 5', 0, 17, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 13, 'tblTRImportDtnDetail', 'dblDeferredAmt5', 1, 1)

	-- DEFERRED DATE 5
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 5', 0, 19, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 14, 'tblTRImportDtnDetail', 'dtmDeferredDate5', 1, 1)

	-- DEFERRED INVOICE 5
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 5', 0, 20, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 15, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo5', 1, 1)
	

	-- DEFERRED TAX 6
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 6', 0, 21, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 16, 'tblTRImportDtnDetail', 'dblDeferredAmt6', 1, 1)

	-- DEFERRED DATE 6
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 6', 0, 23, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 17, 'tblTRImportDtnDetail', 'dtmDeferredDate6', 1, 1)

	-- DEFERRED INVOICE 6
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 6', 0, 24, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 18, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo6', 1, 1)

	
	-- DEFERRED TAX 7
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 7', 0, 25, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 19, 'tblTRImportDtnDetail', 'dblDeferredAmt7', 1, 1)

	-- DEFERRED DATE 7
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 7', 0, 27, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 20, 'tblTRImportDtnDetail', 'dtmDeferredDate7', 1, 1)

	-- DEFERRED INVOICE 7
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 7', 0, 28, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 21, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo7', 1, 1)


	-- DEFERRED TAX 8
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 8', 0, 29, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 22, 'tblTRImportDtnDetail', 'dblDeferredAmt8', 1, 1)

	-- DEFERRED DATE 8
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 8', 0, 31, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 23, 'tblTRImportDtnDetail', 'dtmDeferredDate8', 1, 1)

	-- DEFERRED INVOICE 8
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 8', 0, 32, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 24, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo8', 1, 1)


	-- DEFERRED TAX 9
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 9', 0, 33, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 25, 'tblTRImportDtnDetail', 'dblDeferredAmt9', 1, 1)

	-- DEFERRED DATE 9
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 9', 0, 35, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 26, 'tblTRImportDtnDetail', 'dtmDeferredDate9', 1, 1)

	-- DEFERRED INVOICE 9
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 9', 0, 36, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 27, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo9', 1, 1)


	-- DEFERRED TAX 10
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 10', 0, 37, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 28, 'tblTRImportDtnDetail', 'dblDeferredAmt10', 1, 1)

	-- DEFERRED DATE 10
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 10', 0, 39, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 29, 'tblTRImportDtnDetail', 'dtmDeferredDate10', 1, 1)

	-- DEFERRED INVOICE 10
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 10', 0, 40, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 30, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo10', 1, 1)

END
GO


-- iRely Enterprise Vendor Invoice Import Format (Delete)
DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL

SET @LayoutTitle = 'iRely Enterprise Vendor Invoice Import Format'

IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	PRINT ('Deleting - ' + @LayoutTitle)

	SELECT @FileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader 
	WHERE strLayoutTitle = @LayoutTitle

	DELETE FROM tblTRDtnImportSetupDetail
	WHERE intImportFileHeaderId = @FileHeaderId

	DELETE FROM tblSMImportFileColumnDetail
	WHERE intImportFileHeaderId = @FileHeaderId

	DELETE FROM tblSMImportFileRecordMarker
	WHERE intImportFileHeaderId = @FileHeaderId

	DELETE FROM tblSMImportFileHeader
	WHERE intImportFileHeaderId = @FileHeaderId

END
GO


DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL

SET @LayoutTitle = 'iRely Enterprise Vendor Invoice Header'

-- iRely Enterprise Vendor Invoice Import Header
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	PRINT ('Deploying - iRely Enterprise Vendor Invoice Header')

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

	-- DTN Transaction Number
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Transaction Number', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 1, 'tblTRImportDtnDetail', 'strDtnNo', 1, 1)

    -- Vendor Name
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Vendor Name', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 2, 'tblTRImportDtnDetail', 'strSeller', 1, 1)

	-- Vendor Invoice Number
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Vendor Invoice Number', 0, 5, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 3, 'tblTRImportDtnDetail', 'strInvoiceNo', 1, 1)

	-- Vendor Invoice Date
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Vendor Invoice Date', 0, 6, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 4, 'tblTRImportDtnDetail', 'dtmInvoiceDate', 1, 1)

	-- Vendor Invoice Due Date
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Vendor Invoice Due Date', 0, 7, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 5, 'tblTRImportDtnDetail', 'dtmDueDate', 1, 1)

    -- Total Invoice Amount
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Total Invoice Amount', 0, 8, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 6, 'tblTRImportDtnDetail', 'dblInvoiceAmount', 1, 1)
END
GO

DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL

SET @LayoutTitle = 'iRely Enterprise Vendor Invoice Item'

-- iRely Enterprise Vendor Invoice Import Item
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	PRINT ('Deploying - iRely Enterprise Vendor Invoice Item')

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

	-- BOL NUMBER
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Bill of Lading', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 1, 'tblTRImportDtnDetail', 'strBillOfLading', 1, 1)

END
GO

DECLARE @LayoutTitle NVARCHAR(100)
	, @HeaderId INT = NULL

SET @LayoutTitle = 'iRely Enterprise Vendor Invoice Deferred Tax'
SET @HeaderId = (SELECT intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)

-- iRely Enterprise Vendor Invoice Import Deffered Tax (CORRECTION FOR DEFFERED TAX intPosition)
IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileRecordMarker WHERE strRecordMarker = 'Deferred Invoice No 10' AND intPosition = 40 AND intImportFileHeaderId = @HeaderId)
BEGIN
	UPDATE tblSMImportFileRecordMarker SET intPosition = 1 WHERE strRecordMarker = 'Deferred Tax Amount 1' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 3 WHERE strRecordMarker = 'Deferred Date 1' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 4 WHERE strRecordMarker = 'Deferred Invoice No 1' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 1 WHERE strRecordMarker = 'Deferred Tax Amount 2' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 3 WHERE strRecordMarker = 'Deferred Date 2' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 4 WHERE strRecordMarker = 'Deferred Invoice No 2' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 1 WHERE strRecordMarker = 'Deferred Tax Amount 3' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 3 WHERE strRecordMarker = 'Deferred Date 3' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 4 WHERE strRecordMarker = 'Deferred Invoice No 3' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 1 WHERE strRecordMarker = 'Deferred Tax Amount 4' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 3 WHERE strRecordMarker = 'Deferred Date 4' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 4 WHERE strRecordMarker = 'Deferred Invoice No 4' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 1 WHERE strRecordMarker = 'Deferred Tax Amount 5' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 3 WHERE strRecordMarker = 'Deferred Date 5' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 4 WHERE strRecordMarker = 'Deferred Invoice No 5' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 1 WHERE strRecordMarker = 'Deferred Tax Amount 6' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 3 WHERE strRecordMarker = 'Deferred Date 6' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 4 WHERE strRecordMarker = 'Deferred Invoice No 6' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 1 WHERE strRecordMarker = 'Deferred Tax Amount 7' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 3 WHERE strRecordMarker = 'Deferred Date 7' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 4 WHERE strRecordMarker = 'Deferred Invoice No 7' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 1 WHERE strRecordMarker = 'Deferred Tax Amount 8' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 3 WHERE strRecordMarker = 'Deferred Date 8' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 4 WHERE strRecordMarker = 'Deferred Invoice No 8' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 1 WHERE strRecordMarker = 'Deferred Tax Amount 9' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 3 WHERE strRecordMarker = 'Deferred Date 9' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 4 WHERE strRecordMarker = 'Deferred Invoice No 9' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 1 WHERE strRecordMarker = 'Deferred Tax Amount 10' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 3 WHERE strRecordMarker = 'Deferred Date 10' AND intImportFileHeaderId = @HeaderId
	UPDATE tblSMImportFileRecordMarker SET intPosition = 4 WHERE strRecordMarker = 'Deferred Invoice No 10' AND intImportFileHeaderId = @HeaderId
END
GO

DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL

SET @LayoutTitle = 'iRely Enterprise Vendor Invoice Deferred Tax'
-- iRely Enterprise Vendor Invoice Import Deffered Tax
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	PRINT ('Deploying - iRely Enterprise Vendor Invoice Deferred Tax')

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

	-- DEFERRED TAX 1
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 1', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 1, 'tblTRImportDtnDetail', 'dblDeferredAmt1', 1, 1)

	-- DEFERRED DATE 1
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 1', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 2, 'tblTRImportDtnDetail', 'dtmDeferredDate1', 1, 1)

	-- DEFERRED INVOICE 1
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 1', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 3, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo1', 1, 1)


	-- DEFERRED TAX 2
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 2', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 4, 'tblTRImportDtnDetail', 'dblDeferredAmt2', 1, 1)

	-- DEFERRED DATE 2
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 2', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 5, 'tblTRImportDtnDetail', 'dtmDeferredDate2', 1, 1)

	-- DEFERRED INVOICE 2
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 2', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 6, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo2', 1, 1)


	-- DEFERRED TAX 3
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 3', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 7, 'tblTRImportDtnDetail', 'dblDeferredAmt3', 1, 1)

	-- DEFERRED DATE 3
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 3', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 8, 'tblTRImportDtnDetail', 'dtmDeferredDate3', 1, 1)

	-- DEFERRED INVOICE 3
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 3', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 9, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo3', 1, 1)


	-- DEFERRED TAX 4
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 4', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 10, 'tblTRImportDtnDetail', 'dblDeferredAmt4', 1, 1)

	-- DEFERRED DATE 4
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 4', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 11, 'tblTRImportDtnDetail', 'dtmDeferredDate4', 1, 1)

	-- DEFERRED INVOICE 4
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 4', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 12, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo4', 1, 1)


	-- DEFERRED TAX 5
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 5', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 13, 'tblTRImportDtnDetail', 'dblDeferredAmt5', 1, 1)

	-- DEFERRED DATE 5
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 5', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 14, 'tblTRImportDtnDetail', 'dtmDeferredDate5', 1, 1)

	-- DEFERRED INVOICE 5
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 5', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 15, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo5', 1, 1)
	

	-- DEFERRED TAX 6
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 6', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 16, 'tblTRImportDtnDetail', 'dblDeferredAmt6', 1, 1)

	-- DEFERRED DATE 6
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 6', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 17, 'tblTRImportDtnDetail', 'dtmDeferredDate6', 1, 1)

	-- DEFERRED INVOICE 6
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 6', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 18, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo6', 1, 1)

	
	-- DEFERRED TAX 7
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 7', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 19, 'tblTRImportDtnDetail', 'dblDeferredAmt7', 1, 1)

	-- DEFERRED DATE 7
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 7', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 20, 'tblTRImportDtnDetail', 'dtmDeferredDate7', 1, 1)

	-- DEFERRED INVOICE 7
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 7', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 21, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo7', 1, 1)


	-- DEFERRED TAX 8
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 8', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 22, 'tblTRImportDtnDetail', 'dblDeferredAmt8', 1, 1)

	-- DEFERRED DATE 8
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 8', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 23, 'tblTRImportDtnDetail', 'dtmDeferredDate8', 1, 1)

	-- DEFERRED INVOICE 8
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 8', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 24, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo8', 1, 1)


	-- DEFERRED TAX 9
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 9', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 25, 'tblTRImportDtnDetail', 'dblDeferredAmt9', 1, 1)

	-- DEFERRED DATE 9
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 9', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 26, 'tblTRImportDtnDetail', 'dtmDeferredDate9', 1, 1)

	-- DEFERRED INVOICE 9
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 9', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 27, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo9', 1, 1)


	-- DEFERRED TAX 10
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Tax Amount 10', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 28, 'tblTRImportDtnDetail', 'dblDeferredAmt10', 1, 1)

	-- DEFERRED DATE 10
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Date 10', 0, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 29, 'tblTRImportDtnDetail', 'dtmDeferredDate10', 1, 1)

	-- DEFERRED INVOICE 10
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Deferred Invoice No 10', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 30, 'tblTRImportDtnDetail', 'strDeferredInvoiceNo10', 1, 1)

END
GO