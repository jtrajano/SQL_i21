--DELETE FROM tblSMImportFileHeader WHERE strLayoutTitle in ('Rack Price - Marathon', 'Rack Price - DTN')
----------------------------------------------------------------------------------------------------------
-- Default Data for tblSMImportFileHeader, tblSMImportFileRecordMarker, and tblSMImportFileColumnDetail --
----------------------------------------------------------------------------------------------------------
DECLARE @LayoutTitle NVARCHAR(100)
	, @FileHeaderId INT = NULL
	, @DetailId INT = NULL
	, @OldFileHeaderId INT = NULL


------------------------------------------------------------
-- Import File Headers for Transports - Import Rack Price --
------------------------------------------------------------

-- Marathon Rack Price Import
SET @LayoutTitle = 'Rack Price - Marathon'
IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = 'TR - Marathon Rack Price Import')
	BEGIN
		SELECT @FileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = 'TR - Marathon Rack Price Import'
		SELECT @OldFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Rack Price - Marathon'

		UPDATE tblTRImportRackPrice SET intFieldMappingId = @OldFileHeaderId WHERE intFieldMappingId = @FileHeaderId
		UPDATE tblTRCompanyPreference set intRackPriceImportFormatId = @OldFileHeaderId WHERE intRackPriceImportFormatId = @FileHeaderId
		UPDATE tblTRCompanyPreference set intRackPriceImportMappingId = @OldFileHeaderId WHERE intRackPriceImportMappingId = @FileHeaderId
		-- Delete duplicate file header and details
		DELETE FROM tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @FileHeaderId
		DELETE FROM tblSMImportFileRecordMarker WHERE intImportFileHeaderId = @FileHeaderId
		DELETE FROM tblSMImportFileHeader WHERE intImportFileHeaderId = @FileHeaderId
	END
	UPDATE tblSMImportFileHeader SET strLayoutTitle = 'TR - Marathon Rack Price Import' WHERE strLayoutTitle = @LayoutTitle
END

SET @LayoutTitle = 'TR - Marathon Rack Price Import'
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
	SELECT @FileHeaderId, 'Vendor Price', 'Explicit Decimals', 5, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 5, 'tblTRRackPriceDetail', 'dblVendorRack', 1, 4, 1
END
ELSE
BEGIN

    SELECT @FileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle 

	-- Vendor Price
	UPDATE tblSMImportFileRecordMarker SET intPosition = 5 WHERE intImportFileHeaderId = @FileHeaderId AND strRecordMarker = 'Vendor Price'

	UPDATE DETAIL SET DETAIL.intPosition = 5
	FROM tblSMImportFileColumnDetail DETAIL 
	INNER JOIN tblSMImportFileRecordMarker MARKER ON MARKER.intImportFileRecordMarkerId = DETAIL.intImportFileRecordMarkerId
	WHERE MARKER.intImportFileHeaderId = @FileHeaderId AND MARKER.strRecordMarker = 'Vendor Price'

END

-- Rack Price - DTN
SET @LayoutTitle = 'Rack Price - DTN'
IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = 'TR - DTN Rack Price Import')
	BEGIN
		SELECT @FileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = 'TR - DTN Rack Price Import'
		SELECT @OldFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Rack Price - DTN'

		UPDATE tblTRImportRackPrice SET intFieldMappingId = @OldFileHeaderId WHERE intFieldMappingId = @FileHeaderId
		UPDATE tblTRCompanyPreference set intRackPriceImportFormatId = @OldFileHeaderId WHERE intRackPriceImportFormatId = @FileHeaderId
		UPDATE tblTRCompanyPreference set intRackPriceImportMappingId = @OldFileHeaderId WHERE intRackPriceImportMappingId = @FileHeaderId
		-- Delete duplicate file header and details
		DELETE FROM tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @FileHeaderId
		DELETE FROM tblSMImportFileRecordMarker WHERE intImportFileHeaderId = @FileHeaderId
		DELETE FROM tblSMImportFileHeader WHERE intImportFileHeaderId = @FileHeaderId
	END
	UPDATE tblSMImportFileHeader SET strLayoutTitle = 'TR - DTN Rack Price Import' WHERE strLayoutTitle = @LayoutTitle
END


SET @LayoutTitle = 'TR - DTN Rack Price Import'
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
GO

-- Rack Price - iRely Enterprise
DECLARE @LayoutTitle NVARCHAR(100)
, @FileHeaderId INT = NULL
, @DetailId INT = NULL
, @OldFileHeaderId INT = NULL

SET @LayoutTitle = 'Rack Price - iRely Enterprise'
IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	IF EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = 'TR - iRely Enterprise Rack Price Import')
	BEGIN
		SELECT @FileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = 'TR - iRely Enterprise Rack Price Import'
		SELECT @OldFileHeaderId = intImportFileHeaderId FROM tblSMImportFileHeader WHERE strLayoutTitle = 'Rack Price - iRely Enterprise'

		UPDATE tblTRImportRackPrice SET intFieldMappingId = @OldFileHeaderId WHERE intFieldMappingId = @FileHeaderId
		UPDATE tblTRCompanyPreference set intRackPriceImportFormatId = @OldFileHeaderId WHERE intRackPriceImportFormatId = @FileHeaderId
		UPDATE tblTRCompanyPreference set intRackPriceImportMappingId = @OldFileHeaderId WHERE intRackPriceImportMappingId = @FileHeaderId
		-- Delete duplicate file header and details
		DELETE FROM tblSMImportFileColumnDetail WHERE intImportFileHeaderId = @FileHeaderId
		DELETE FROM tblSMImportFileRecordMarker WHERE intImportFileHeaderId = @FileHeaderId
		DELETE FROM tblSMImportFileHeader WHERE intImportFileHeaderId = @FileHeaderId
	END
	UPDATE tblSMImportFileHeader SET strLayoutTitle = 'TR - iRely Enterprise Rack Price Import' WHERE strLayoutTitle = @LayoutTitle
END

SET @LayoutTitle = 'TR - iRely Enterprise Rack Price Import'
IF NOT EXISTS (SELECT TOP 1 1 FROM tblSMImportFileHeader WHERE strLayoutTitle = @LayoutTitle)
BEGIN
	PRINT ('Deploying - TR - iRely Enterprise Rack Price Import')

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

	-- Supplier Name
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Supplier Name', 0, 0, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 1, 'tblTRImportRackPriceDetail', 'strSupplierName', 1, 1)

	-- Supplier Location
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Supply Point', 0, 1, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 2, 'tblTRImportRackPriceDetail', 'intSupplyPointId', 1, 1)

	-- Product Description
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Product Description', 0, 5, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 3, 'tblTRImportRackPriceDetail', 'intItemId', 1, 1)

	-- Effective Date
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId, strFormat) 
	VALUES (@FileHeaderId, 'Efftive Date', 0, 7, 1, 'YYYYMMDD')

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 4, 'tblTRImportRackPriceDetail', 'dtmEffectiveDateTime', 1, 1)

	-- Effective Time
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId, strFormat) 
	VALUES (@FileHeaderId, 'Efftive Time', 0, 8, 1, 'HHMM')

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 5, 'tblTRImportRackPriceDetail', 'dtmEffectiveDateTime', 1, 1)

	-- Rack Price
	INSERT INTO tblSMImportFileRecordMarker (intImportFileHeaderId, strRecordMarker, intRowsToSkip, intPosition, intConcurrencyId) 
	VALUES (@FileHeaderId, 'Rack Price', 0, 9, 1)

	SET @DetailId = SCOPE_IDENTITY()

	INSERT INTO tblSMImportFileColumnDetail (intImportFileHeaderId, intImportFileRecordMarkerId, intLevel, strTable, strColumnName, ysnActive, intConcurrencyId)
	VALUES (@FileHeaderId, @DetailId, 6, 'tblTRImportRackPriceDetail', 'dblVendorRack', 1, 1)

END
GO