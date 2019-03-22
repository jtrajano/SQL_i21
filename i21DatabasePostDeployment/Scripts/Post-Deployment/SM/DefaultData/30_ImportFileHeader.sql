--DELETE FROM tblSMImportFileHeader WHERE strLayoutTitle in ('Rack Price - Marathon', 'Rack Price - DTN')
----------------------------------------------------------------------------------------------------------
-- Default Data for tblSMImportFileHeader, tblSMImportFileRecordMarker, and tblSMImportFileColumnDetail --
----------------------------------------------------------------------------------------------------------
DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL


------------------------------------------------------------
-- Import File Headers for Transports - Import Rack Price --
------------------------------------------------------------

-- Rack Price - Marathon
SET @LayoutTitle = 'Rack Price - Marathon'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	INSERT INTO tblSMImportFileHeader(strLayoutTitle
		, strFileType
		, strFieldDelimiter
		, ysnActive
		, intConcurrencyId)
	SELECT @LayoutTitle
		, 'Delimiter'
		, 'Comma'
		, 1
		, 1

	SET @FileHeaderId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Supply Point', NULL, 1, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 1, 'tblTRRackPriceHeader', 'intSupplyPointId', 1, 1, 1

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Effective Date', 'MM/DD/YYYY', 2, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 2, 'tblTRRackPriceHeader', 'dtmEffectiveDateTime', 1, 2, 1

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Item Id', NULL, 3, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 3, 'tblTRRackPriceDetail', 'intItemId', 1, 3, 1

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Vendor Price', 'Explicit Decimals', 4, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 4, 'tblTRRackPriceDetail', 'dblVendorRack', 1, 4, 1
END

-- Rack Price - DTN
SET @LayoutTitle = 'Rack Price - DTN'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	INSERT INTO tblSMImportFileHeader(strLayoutTitle
		, strFileType
		, strFieldDelimiter
		, ysnActive
		, intConcurrencyId)
	SELECT @LayoutTitle
		, 'Delimiter'
		, 'Comma'
		, 1
		, 1

	SET @FileHeaderId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Supply Point', NULL, 1, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 1, 'tblTRRackPriceHeader', 'intSupplyPointId', 1, 1, 1
		
	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Supplier Name', NULL, 0, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 2, 'tblTRImportRackPriceDetail', 'strSupplierName', 1, 2, 1

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Effective Date', 'YYYYMMDD', 7, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 3, 'tblTRRackPriceHeader', 'dtmEffectiveDateTime', 1, 3, 1

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Effective Time', 'HHMM', 8, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 4, 'tblTRRackPriceHeader', 'dtmEffectiveDateTime', 1, 4, 1

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Item Id', NULL, 5, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 5, 'tblTRRackPriceDetail', 'intItemId', 1, 5, 1

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Vendor Price', 'Explicit Decimals', 9, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 6, 'tblTRRackPriceDetail', 'dblVendorRack', 1, 6, 1
END
ELSE
BEGIN
	DECLARE @importFileRecordMarkerId INT

	SELECT @FileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle
	
	UPDATE tblSMImportFileHeader
	SET strLayoutTitle = @LayoutTitle
		, strFileType = 'Delimiter'
		, strFieldDelimiter = 'Comma'
	WHERE intImportFileHeaderId = @FileHeaderId
	
	-- Temporarily Update levels to eliminate duplicates
	UPDATE tblSMImportFileColumnDetail
	SET intLevel = intImportFileColumnDetailId
	WHERE intImportFileHeaderId = @FileHeaderId

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileRecordMarker WHERE strRecordMarker = 'Supply Point' AND intImportFileHeaderId = @FileHeaderId)
	BEGIN
		INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
		SELECT @FileHeaderId, 'Supply Point', NULL, 1, 1
		SET @DetailId = SCOPE_IDENTITY()

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @FileHeaderId AND intLevel = 1)
		BEGIN			
			INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
			SELECT @FileHeaderId, @DetailId, 1, 'tblTRRackPriceHeader', 'intSupplyPointId', 1, 1, 1
		END
	END
	ELSE
	BEGIN

		SELECT TOP 1 @importFileRecordMarkerId = intImportFileRecordMarkerId
		FROM tblSMImportFileRecordMarker
		WHERE intImportFileHeaderId = @FileHeaderId
			AND strRecordMarker = 'Supply Point'

		UPDATE tblSMImportFileRecordMarker
		SET strFormat = NULL
			, intPosition = 1
		WHERE intImportFileRecordMarkerId = @importFileRecordMarkerId

		UPDATE tblSMImportFileColumnDetail
		SET intPosition = 1
			, intLevel = 1
		WHERE intImportFileHeaderId = @FileHeaderId
			AND intImportFileRecordMarkerId = @importFileRecordMarkerId
	END
	
	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileRecordMarker WHERE strRecordMarker = 'Supplier Name' AND intImportFileHeaderId = @FileHeaderId)
	BEGIN
		INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
		SELECT @FileHeaderId, 'Supplier Name', NULL, 0, 1
		SET @DetailId = SCOPE_IDENTITY()

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @FileHeaderId AND intLevel = 2)
		BEGIN	
			INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
			SELECT @FileHeaderId, @DetailId, 2, 'tblTRImportRackPriceDetail', 'strSupplierName', 1, 2, 1
		END
	END
	ELSE
	BEGIN

		SELECT TOP 1 @importFileRecordMarkerId = intImportFileRecordMarkerId
		FROM tblSMImportFileRecordMarker
		WHERE intImportFileHeaderId = @FileHeaderId
			AND strRecordMarker = 'Supplier Name'

		UPDATE tblSMImportFileRecordMarker
		SET strFormat = NULL
			, intPosition = 0
		WHERE intImportFileRecordMarkerId = @importFileRecordMarkerId

		UPDATE tblSMImportFileColumnDetail
		SET intPosition = 2
			, intLevel = 2
		WHERE intImportFileHeaderId = @FileHeaderId
			AND intImportFileRecordMarkerId = @importFileRecordMarkerId
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileRecordMarker WHERE strRecordMarker = 'Effective Date' AND intImportFileHeaderId = @FileHeaderId)
	BEGIN
		INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
		SELECT @FileHeaderId, 'Effective Date', 'YYYYMMDD', 7, 1
		SET @DetailId = SCOPE_IDENTITY()

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @FileHeaderId AND intLevel = 3)
		BEGIN
			INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
			SELECT @FileHeaderId, @DetailId, 3, 'tblTRRackPriceHeader', 'dtmEffectiveDateTime', 1, 3, 1
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @importFileRecordMarkerId = intImportFileRecordMarkerId
		FROM tblSMImportFileRecordMarker
		WHERE intImportFileHeaderId = @FileHeaderId
			AND strRecordMarker = 'Effective Date'

		UPDATE tblSMImportFileRecordMarker
		SET strFormat = 'YYYYMMDD'
			, intPosition = 7
		WHERE intImportFileRecordMarkerId = @importFileRecordMarkerId

		UPDATE tblSMImportFileColumnDetail
		SET intPosition = 3
			, intLevel = 3
		WHERE intImportFileHeaderId = @FileHeaderId
			AND intImportFileRecordMarkerId = @importFileRecordMarkerId
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileRecordMarker WHERE strRecordMarker = 'Effective Time' AND intImportFileHeaderId = @FileHeaderId)
	BEGIN
		INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
		SELECT @FileHeaderId, 'Effective Time', 'HHMM', 8, 1
		SET @DetailId = SCOPE_IDENTITY()

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @FileHeaderId AND intLevel = 4)
		BEGIN
			INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
			SELECT @FileHeaderId, @DetailId, 4, 'tblTRRackPriceHeader', 'dtmEffectiveDateTime', 1, 4, 1
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @importFileRecordMarkerId = intImportFileRecordMarkerId
		FROM tblSMImportFileRecordMarker
		WHERE intImportFileHeaderId = @FileHeaderId
			AND strRecordMarker = 'Effective Time'

		UPDATE tblSMImportFileRecordMarker
		SET strFormat = 'HHMM'
			, intPosition = 8
		WHERE intImportFileRecordMarkerId = @importFileRecordMarkerId

		UPDATE tblSMImportFileColumnDetail
		SET intPosition = 4
			, intLevel = 4
		WHERE intImportFileHeaderId = @FileHeaderId
			AND intImportFileRecordMarkerId = @importFileRecordMarkerId
	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileRecordMarker WHERE strRecordMarker = 'Item Id' AND intImportFileHeaderId = @FileHeaderId)
	BEGIN
		INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
		SELECT @FileHeaderId, 'Item Id', NULL, 5, 1
		SET @DetailId = SCOPE_IDENTITY()
			
		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @FileHeaderId AND intLevel = 5)
		BEGIN
			INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
			SELECT @FileHeaderId, @DetailId, 5, 'tblTRRackPriceDetail', 'intItemId', 1, 5, 1
		END
	END
	ELSE
	BEGIN
		SELECT TOP 1 @importFileRecordMarkerId = intImportFileRecordMarkerId
		FROM tblSMImportFileRecordMarker
		WHERE intImportFileHeaderId = @FileHeaderId
			AND strRecordMarker = 'Item Id'

		UPDATE tblSMImportFileRecordMarker
		SET strFormat = NULL
			, intPosition = 5
		WHERE intImportFileRecordMarkerId = @importFileRecordMarkerId

		UPDATE tblSMImportFileColumnDetail
		SET intPosition = 5
			, intLevel = 5
		WHERE intImportFileHeaderId = @FileHeaderId
			AND intImportFileRecordMarkerId = @importFileRecordMarkerId

	END

	IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileRecordMarker WHERE strRecordMarker = 'Vendor Price' AND intImportFileHeaderId = @FileHeaderId)
	BEGIN
		INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
		SELECT @FileHeaderId, 'Vendor Price', 'Explicit Decimals', 9, 1
		SET @DetailId = SCOPE_IDENTITY()

		IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @FileHeaderId AND intLevel = 6)
		BEGIN	
			INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
			SELECT @FileHeaderId, @DetailId, 6, 'tblTRRackPriceDetail', 'dblVendorRack', 1, 6, 1
		END
	END
	ELSE
	BEGIN

		SELECT TOP 1 @importFileRecordMarkerId = intImportFileRecordMarkerId
		FROM tblSMImportFileRecordMarker
		WHERE intImportFileHeaderId = @FileHeaderId
			AND strRecordMarker = 'Vendor Price'

		UPDATE tblSMImportFileRecordMarker
		SET strFormat = 'Explicit Decimals'
			, intPosition = 9
		WHERE intImportFileRecordMarkerId = @importFileRecordMarkerId

		UPDATE tblSMImportFileColumnDetail
		SET intPosition = 6
			, intLevel = 6
		WHERE intImportFileHeaderId = @FileHeaderId
			AND intImportFileRecordMarkerId = @importFileRecordMarkerId
	END
END