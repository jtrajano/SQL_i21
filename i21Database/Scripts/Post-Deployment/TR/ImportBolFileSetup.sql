DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL

-- BP Format
SET @LayoutTitle = 'TR - Electronic BOL Format'

IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	PRINT ('Deploying TR - Electronic BOL Format')

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
	VALUES (@FileHeaderId, 'Invoice Date', 0, 15, 1)

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
