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
	SELECT @FileHeaderId, 'Effective Date', 'YYYYMMDD', 7, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 2, 'tblTRRackPriceHeader', 'dtmEffectiveDateTime', 1, 2, 1

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Effective Time', 'HHMM', 8, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 3, 'tblTRRackPriceHeader', 'dtmEffectiveDateTime', 1, 3, 1

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Item Id', NULL, 5, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 4, 'tblTRRackPriceDetail', 'intItemId', 1, 4, 1

	INSERT INTO tblSMImportFileRecordMarker(intImportFileHeaderId, strRecordMarker, strFormat, intPosition, intConcurrencyId)
	SELECT @FileHeaderId, 'Vendor Price', 'Explicit Decimals', 9, 1
	SET @DetailId = SCOPE_IDENTITY()
	INSERT INTO tblSMImportFileColumnDetail(intImportFileHeaderId, intImportFileRecordMarkerId, intPosition, strTable, strColumnName, ysnActive, intLevel, intConcurrencyId)
	SELECT @FileHeaderId, @DetailId, 5, 'tblTRRackPriceDetail', 'dblVendorRack', 1, 5, 1
END