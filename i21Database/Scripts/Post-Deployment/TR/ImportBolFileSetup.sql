DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL

-- BP Format
SET @LayoutTitle = 'TR - Electronic BOL – TPVision'
UPDATE tblSMImportFileHeader SET strLayoutTitle = @LayoutTitle WHERE strLayoutTitle = 'TR - Electronic BOL Format'

IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = 'TR - TPVision BOL Import')
BEGIN
	UPDATE tblSMImportFileHeader SET strLayoutTitle = 'TR - TPVision BOL Import' WHERE strLayoutTitle = 'TR - Electronic BOL – TPVision'
END

SET @LayoutTitle = 'TR - TPVision BOL Import'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	PRINT ('Deploying TR - TPVision BOL Import')

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

	-- TRUCK
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Truck', 0, 0, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 1, 'tblTRImportLoadDetail', 'strTruck', 1, 1)

	-- Terminal
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Terminal', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 2, 'tblTRImportLoadDetail', 'strTerminal', 1, 1)

	-- BOL Number
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Bill Of Lading', 0, 2, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 3, 'tblTRImportLoadDetail', 'strBillOfLading', 1, 1)

	-- Carrier
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Carrier', 0, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 4, 'tblTRImportLoadDetail', 'strCarrier', 1, 1)

	-- Driver
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Driver', 0, 5, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 5, 'tblTRImportLoadDetail', 'strDriver', 1, 1)

    -- Trailer
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Trailer', 0, 6, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 6, 'tblTRImportLoadDetail', 'strTrailer', 1, 1)

    -- Supplier
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Supplier', 0, 7, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 7, 'tblTRImportLoadDetail', 'strSupplier', 1, 1)

    -- Destination
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Destination', 0, 9, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 8, 'tblTRImportLoadDetail', 'strDestination', 1, 1)

    -- Pulled Date Time
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Pulled Date Time', 0, 10, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 9, 'tblTRImportLoadDetail', 'dtmPullDate', 1, 1)

     -- Pulled Product
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Pulled Product', 0, 11, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 10, 'tblTRImportLoadDetail', 'strPullProduct', 1, 1)

     -- Dropped Product
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Dropped Product', 0, 12, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 11, 'tblTRImportLoadDetail', 'strDropProduct', 1, 1)

    -- Dropped Gross Gallons
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Dropped Gross Gallons', 0, 13, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 12, 'tblTRImportLoadDetail', 'dblDropGross', 1, 1)

    -- Dropped Net Gallons
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Dropped Net Gallons', 0, 14, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 13, 'tblTRImportLoadDetail', 'dblDropNet', 1, 1)

    -- Invoice Date
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Invoice Date', 0, 10, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 14, 'tblTRImportLoadDetail', 'dtmInvoiceDate', 1, 1)

    -- Dropped Date Time
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Dropped Date Time', 0, 16, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 15, 'tblTRImportLoadDetail', 'dtmDropDate', 1, 1)

END
ELSE
BEGIN

	-- Update Invoice Date
	UPDATE FRM SET FRM.intPosition = 10
 	FROM tblSMImportFileRecordMarker FRM 
	INNER JOIN tblSMImportFileHeader FH ON FH.intImportFileHeaderId = FRM.intImportFileHeaderId
	WHERE FH.strLayoutTitle = @LayoutTitle 
	AND FRM.strRecordMarker = 'Invoice Date'

	-- Delete Dropped Date Time
	DELETE FCD FROM tblSMImportFileColumnDetail FCD 
	INNER JOIN tblSMImportFileHeader FH ON FH.intImportFileHeaderId = FCD.intImportFileHeaderId
	WHERE FH.strLayoutTitle = @LayoutTitle 
	AND FCD.strTable = 'tblTRImportLoadDetail'
	AND FCD.strColumnName = 'dtmDropDate'

	DELETE FRM FROM tblSMImportFileRecordMarker FRM 
	INNER JOIN tblSMImportFileHeader FH ON FH.intImportFileHeaderId = FRM.intImportFileHeaderId
	WHERE FH.strLayoutTitle = @LayoutTitle 
	AND FRM.strRecordMarker = 'Dropped Date Time'

END

GO

DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL

-- iRely Enterprise BoL Format
SET @LayoutTitle = 'TR - iRely Enterprise BOL Import'

IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	PRINT ('Deploying TR - iRely Enterprise BOL Import')

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

	-- Load Time
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Load Date Time', 1, 0, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 1, 'tblTRImportLoadDetail', 'dtmPullDate', 1, 1)

	-- Carrier
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Carrier', 1, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 2, 'tblTRImportLoadDetail', 'strCarrier', 1, 1)

	-- Driver
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Driver', 1, 2, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 3, 'tblTRImportLoadDetail', 'strDriver', 1, 1)

	-- Truck
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Truck', 1, 3, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 4, 'tblTRImportLoadDetail', 'strTruck', 1, 1)

  	-- Trailer
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Trailer', 1, 4, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 5, 'tblTRImportLoadDetail', 'strTrailer', 1, 1)

	-- Supplier
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Supplier', 1, 5, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 6, 'tblTRImportLoadDetail', 'strSupplier', 1, 1)

	-- BOL Number
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Bill Of Lading', 1, 6, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 7, 'tblTRImportLoadDetail', 'strBillOfLading', 1, 1)

	-- Pulled Product
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Pulled Item', 1, 7, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 8, 'tblTRImportLoadDetail', 'strPullProduct', 1, 1)

    -- Destination
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Destination', 1, 8, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 9, 'tblTRImportLoadDetail', 'strDestination', 1, 1)

	-- Delivery Date Time
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Delivery Date Time', 1, 9, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 10, 'tblTRImportLoadDetail', 'dtmInvoiceDate', 1, 1)

	-- Delivered Item
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Delivered Item', 1, 10, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 11, 'tblTRImportLoadDetail', 'strDropProduct', 1, 1)

    -- Gross
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Gross', 1, 11, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 12, 'tblTRImportLoadDetail', 'dblDropGross', 1, 1)

    -- Net
    INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Net', 1, 12, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 13, 'tblTRImportLoadDetail', 'dblDropNet', 1, 1)

    -- Customer PO Num
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Customer PO Num', 1, 13, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 14, 'tblTRImportLoadDetail', 'strPONumber', 1, 1)

END

GO

