CREATE PROCEDURE uspICImportOpeningBalancesFromStaging 
	@strIdentifier NVARCHAR(100)
	, @intDataSourceId INT = 2
AS

DECLARE 
	@row_inserted AS INT 
	,@row_errors AS INT 
	,@row_warnings AS INT 
	,@LogId AS INT

SELECT TOP 1 
	@LogId = l.intImportLogId 
	,@row_warnings = l.intTotalWarnings
FROM 
	tblICImportLog l
WHERE 
	l.strUniqueId = @strIdentifier

DELETE 
FROM 
	tblICImportStagingOpeningBalance 
WHERE 
	strImportIdentifier <> @strIdentifier

CREATE TABLE #tmp (
	  intId INT IDENTITY(1, 1) PRIMARY KEY
	, intItemId INT NULL
	, intLocationId INT NULL
	, dtmDate DATETIME NULL
	, intItemUOMId INT NULL
	, strDescription NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL
	, intOwnershipTypeId INT NULL
	, dblQuantity NUMERIC(38, 20) NULL
	, dblUnitCost NUMERIC(38, 20) NULL
	, dblNetWeight NUMERIC(38, 20) NULL
	, intLotId INT NULL
	, intStorageLocationId INT NULL
	, intStorageUnitId INT NULL
	, intWeightUOMId INT NULL
	, dtmDateCreated DATETIME NULL
	, intCreatedByUserId INT NULL
	, intCurrencyId INT NULL
	, intForexRateTypeId INT NULL
	, dblForexRate NUMERIC(38,20) NULL
	, strLotNumber NVARCHAR(200) COLLATE Latin1_General_CI_AS NULL

	, strLotAlias NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, strWarehouseRefNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, intLotStatus INT NULL
	, intOriginId INT NULL
	, strBOLNo NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strVessel NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, strMarkings NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, strNotes NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
	, intEntityVendorId INT NULL
	, strVendorLotNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, strGarden NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
	, dtmManufacturedDate DATETIME NULL
	, strContainerNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, strCondition NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, intSeasonCropYear INT NULL
	, intBookId INT NULL
	, intSubBookId INT NULL
	, strCertificate NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
	, intProducerId INT NULL
	, strTrackingNumber NVARCHAR(255) COLLATE Latin1_General_CI_AS NULL
	, strCargoNo NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL
)

-- Validate the company location 
IF @LogId IS NOT NULL 
BEGIN 
	-- Log Invalid company locations
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		,strType
		,intRecordNo
		,strField
		,strValue
		,strMessage
		,strStatus
		,strAction
		,intConcurrencyId
	)
	SELECT 		
		intImportLogId = @LogId
		,strType = 'Error'
		,intRecordNo = a.intRecordNo
		,strField = 'Location No'
		,strValue = a.strLocationNo
		,strMessage = 'The company location no: ''' + a.strLocationNo + ''' does not exists.' 
		,strStatus = 'Failed'
		,strAction = 'Import Failed.'
		,intConcurrencyId = 1
	FROM
		(
			SELECT 
				a.* 
				,intRecordNo = CAST(ROW_NUMBER() OVER (ORDER BY intImportStagingOpeningBalanceId) AS INT)
			FROM tblICImportStagingOpeningBalance a 
		) a
		LEFT JOIN tblSMCompanyLocation c 
			ON c.strLocationNumber = a.strLocationNo 
			OR c.strLocationName = a.strLocationNo
	WHERE 
		c.intCompanyLocationId IS NULL 

	SET @row_errors = @@ROWCOUNT
END

-- Validate the item no. 
IF @LogId IS NOT NULL 
BEGIN 
	-- Log Invalid company locations
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		,strType
		,intRecordNo
		,strField
		,strValue
		,strMessage
		,strStatus
		,strAction
		,intConcurrencyId
	)
	SELECT 		
		intImportLogId = @LogId
		,strType = 'Error'
		,intRecordNo = a.intRecordNo
		,strField = 'Item No'
		,strValue = a.strLocationNo
		,strMessage = 'The item no: ''' + a.strItemNo + ''' does not exists.' 
		,strStatus = 'Failed'
		,strAction = 'Import Failed.'
		,intConcurrencyId = 1
	FROM 		
		(
			SELECT 
				a.* 
				,intRecordNo = CAST(ROW_NUMBER() OVER (ORDER BY intImportStagingOpeningBalanceId) AS INT)
			FROM tblICImportStagingOpeningBalance a 
		) a
		LEFT JOIN tblICItem i
			ON a.strItemNo = i.strItemNo 
	WHERE 
		i.intItemId IS NULL

	SET @row_errors = ISNULL(@row_errors, 0) + @@ROWCOUNT
END

-- Validate the UOM
IF @LogId IS NOT NULL 
BEGIN 
	-- Log Invalid UOM
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		,strType
		,intRecordNo
		,strField
		,strValue
		,strMessage
		,strStatus
		,strAction
		,intConcurrencyId
	)
	SELECT 		
		intImportLogId = @LogId
		,strType = 'Error'
		,intRecordNo = a.intRecordNo
		,strField = 'UOM'
		,strValue = a.strUOM
		,strMessage = 'The UOM for ''' + a.strItemNo + ''' does not exists.' 
		,strStatus = 'Failed'
		,strAction = 'Import Failed.'
		,intConcurrencyId = 1
	FROM 		
		(
			SELECT 
				a.* 
				,intRecordNo = CAST(ROW_NUMBER() OVER (ORDER BY intImportStagingOpeningBalanceId) AS INT)
			FROM tblICImportStagingOpeningBalance a 
		) a
		OUTER APPLY (
			SELECT TOP 1
				i.intItemId
				,u.intUnitMeasureId
				,i.strItemNo
			FROM 
				tblICItem i	LEFT JOIN tblICItemUOM iu
					ON iu.intItemId = i.intItemId
				LEFT JOIN tblICUnitMeasure u
					ON u.intUnitMeasureId = iu.intUnitMeasureId					
			WHERE
				i.strItemNo = a.strItemNo 
				AND u.strUnitMeasure = a.strUOM
		) b	
	WHERE 
		b.intUnitMeasureId IS NULL 
		AND b.intItemId IS NOT NULL 	

	SET @row_errors = ISNULL(@row_errors, 0) + @@ROWCOUNT
END

-- Validate the Weight UOM
IF @LogId IS NOT NULL 
BEGIN 
	-- Log Invalid Weight UOM
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		,strType
		,intRecordNo
		,strField
		,strValue
		,strMessage
		,strStatus
		,strAction
		,intConcurrencyId
	)
	SELECT 		
		intImportLogId = @LogId
		,strType = 'Error'
		,intRecordNo = a.intRecordNo
		,strField = 'Weight UOM'
		,strValue = a.strWeightUOM
		,strMessage = 'The Weight UOM for ''' + a.strItemNo + ''' does not exists.' 
		,strStatus = 'Failed'
		,strAction = 'Import Failed.'
		,intConcurrencyId = 1
	FROM 		
		(
			SELECT 
				a.* 
				,intRecordNo = CAST(ROW_NUMBER() OVER (ORDER BY intImportStagingOpeningBalanceId) AS INT)
			FROM tblICImportStagingOpeningBalance a 
		) a
		OUTER APPLY (
			SELECT TOP 1
				i.intItemId
				,u.intUnitMeasureId
				,i.strItemNo
			FROM 
				tblICItem i	LEFT JOIN tblICItemUOM iu
					ON iu.intItemId = i.intItemId
				LEFT JOIN tblICUnitMeasure u
					ON u.intUnitMeasureId = iu.intUnitMeasureId					
			WHERE
				i.strItemNo = a.strItemNo 
				AND u.strUnitMeasure = a.strWeightUOM
		) b	
	WHERE 
		b.intUnitMeasureId IS NULL 
		AND b.intItemId IS NOT NULL 	
		AND NULLIF(RTRIM(LTRIM(a.strWeightUOM)), '') IS NOT NULL 

	SET @row_errors = ISNULL(@row_errors, 0) + @@ROWCOUNT
END

-- Validate the Currency
IF @LogId IS NOT NULL 
BEGIN 
	-- Log Invalid currency
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		,strType
		,intRecordNo
		,strField
		,strValue
		,strMessage
		,strStatus
		,strAction
		,intConcurrencyId
	)
	SELECT 		
		intImportLogId = @LogId
		,strType = 'Error'
		,intRecordNo = a.intRecordNo
		,strField = 'Currency'
		,strValue = a.strCurrency
		,strMessage = 'The Currency for ''' + a.strItemNo + ''' is invalid.' 
		,strStatus = 'Failed'
		,strAction = 'Import Failed.'
		,intConcurrencyId = 1
	FROM 		
		(
			SELECT 
				a.* 
				,intRecordNo = CAST(ROW_NUMBER() OVER (ORDER BY intImportStagingOpeningBalanceId) AS INT)
			FROM tblICImportStagingOpeningBalance a 
		) a		
		OUTER APPLY (
			SELECT TOP 1 
				c.intCurrencyID
			FROM 
				tblSMCurrency c
			WHERE c.strCurrency = a.strCurrency
		) c
	WHERE 
		a.strCurrency IS NOT NULL 
		AND c.intCurrencyID IS NULL 

	SET @row_errors = ISNULL(@row_errors, 0) + @@ROWCOUNT
END


-- Validate the Forex Rate
IF @LogId IS NOT NULL 
BEGIN 
	-- Log Invalid forex rate
	INSERT INTO tblICImportLogDetail(
		intImportLogId
		,strType
		,intRecordNo
		,strField
		,strValue
		,strMessage
		,strStatus
		,strAction
		,intConcurrencyId
	)
	SELECT 		
		intImportLogId = @LogId
		,strType = 'Error'
		,intRecordNo = a.intRecordNo
		,strField = 'Forex Rate'
		,strValue = a.strCurrency
		,strMessage = 'The Forex Rate for ''' + a.strItemNo + ''' is invalid.' 
		,strStatus = 'Failed'
		,strAction = 'Import Failed.'
		,intConcurrencyId = 1
	FROM 		
		(
			SELECT 
				a.* 
				,intRecordNo = CAST(ROW_NUMBER() OVER (ORDER BY intImportStagingOpeningBalanceId) AS INT)
			FROM tblICImportStagingOpeningBalance a 
		) a		
		OUTER APPLY (
			SELECT TOP 1 
				c.intCurrencyID
			FROM 
				tblSMCurrency c
			WHERE c.strCurrency = a.strCurrency
		) c
	WHERE 
		a.strCurrency IS NOT NULL 
		AND c.intCurrencyID IS NOT NULL 
		AND ISNULL(a.dblForexRate, 0) = 0 

	SET @row_errors = ISNULL(@row_errors, 0) + @@ROWCOUNT
END


IF ISNULL(@row_errors, 0) <> 0 GOTO _exit_with_error; 

;WITH cte AS
(
	SELECT 
		*
		, ROW_NUMBER() OVER(PARTITION BY strLocationNo, dtmDate, strItemNo ORDER BY strLocationNo, dtmDate, strItemNo) AS RowNumber
	FROM 
		tblICImportStagingOpeningBalance
	WHERE 
		strImportIdentifier = @strIdentifier
)
DELETE FROM cte WHERE RowNumber > 1;

DECLARE @intDefaultForexRatype AS INT
DECLARE @intFunctionalCurrencyId AS INT = dbo.fnSMGetDefaultCurrency('FUNCTIONAL')
SELECT TOP 1 @intDefaultForexRatype = intInventoryRateTypeId FROM tblSMMultiCurrency; 

INSERT INTO #tmp (
	  intItemId
	, intLocationId
	, dtmDate
	, intItemUOMId
	, strDescription
	, intOwnershipTypeId
	, dblQuantity
	, dblUnitCost
	, dblNetWeight
	, intLotId
	, intStorageLocationId
	, intStorageUnitId
	, intWeightUOMId
	, dtmDateCreated
	, intCreatedByUserId
	, intCurrencyId 
	, intForexRateTypeId 
	, dblForexRate 
	, strLotNumber
	, strLotAlias 
	, strWarehouseRefNo 
	, intLotStatus 
	, intOriginId 
	, strBOLNo 
	, strVessel 
	, strMarkings 
	, strNotes 
	, intEntityVendorId 
	, strVendorLotNo 
	, strGarden 
	, dtmManufacturedDate 
	, strContainerNo 
	, strCondition 
	, intSeasonCropYear 
	, intBookId 
	, intSubBookId 
	, strCertificate 
	, intProducerId 
	, strTrackingNumber 
	, strCargoNo 
)
SELECT
	  i.intItemId
	, il.intLocationId
	, x.dtmDate
	, iu.intItemUOMId
	, x.strDescription
	, CASE WHEN ISNULL(x.strOwnershipType, 'Own') = 'Own' THEN 1 ELSE 2 END
	, ISNULL(x.dblQuantity, 0)
	, ISNULL(x.dblUnitCost, 0)
	, ISNULL(x.dblNetWeight, 0)
	, lot.intLotId
	, sl.intCompanyLocationSubLocationId
	, su.intStorageLocationId
	, iuw.intItemUOMId
	, x.dtmDateCreated
	, x.intCreatedByUserId
	, intCurrencyId = currency.intCurrencyID
	, intForexRateTypeId = ISNULL(rateType.intCurrencyExchangeRateTypeId, @intDefaultForexRatype) 
	, dblForexRate = x.dblForexRate
	, strLotNumber = x.strLotNumber
	, strLotAlias = x.strLotAlias
	, strWarehouseRefNo = x.strWarehouseRefNo
	, intLotStatus = ISNULL(lotStatus.intLotStatusId, 1) 
	, intOriginId = origin.intCommodityAttributeId
	, strBOLNo = x.strBook
	, strVessel = x.strVessel
	, strMarkings = x.strMarkings
	, strNotes = x.strNotes
	, intEntityVendorId = vendor.intEntityId
	, strVendorLotNo = x.strVendorLotNo
	, strGarden = x.strGarden
	, dtmManufacturedDate = x.dtmManufacturedDate
	, strContainerNo = x.strContainerNo
	, strCondition = x.strCondition
	, intSeasonCropYear = cropYear.intCropYearId
	, intBookId = book.intBookId
	, intSubBookId = subBook.intSubBookId
	, strCertificate = x.strCertificate
	, intProducerId = producer.intEntityId
	, strTrackingNumber = x.strTrackingNumber
	, strCargoNo = x.strCargoNo

FROM 
	tblICImportStagingOpeningBalance x INNER JOIN tblICItem i 
		ON RTRIM(LTRIM(i.strItemNo)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strItemNo)) COLLATE Latin1_General_CI_AS
	INNER JOIN tblICUnitMeasure u 
		ON RTRIM(LTRIM(u.strUnitMeasure)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strUOM)) COLLATE Latin1_General_CI_AS
	INNER JOIN tblICItemUOM iu 
		ON iu.intItemId = i.intItemId AND iu.intUnitMeasureId = u.intUnitMeasureId
	LEFT JOIN tblICUnitMeasure uw 
		ON RTRIM(LTRIM(uw.strUnitMeasure)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strWeightUOM)) COLLATE Latin1_General_CI_AS
	LEFT JOIN tblICItemUOM iuw 
		ON iuw.intItemId = i.intItemId AND iuw.intUnitMeasureId = uw.intUnitMeasureId
	INNER JOIN tblSMCompanyLocation c 
		ON RTRIM(LTRIM(c.strLocationNumber)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strLocationNo)) COLLATE Latin1_General_CI_AS
		OR RTRIM(LTRIM(c.strLocationName)) COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strLocationNo)) COLLATE Latin1_General_CI_AS
	INNER JOIN tblICItemLocation il 
		ON il.intItemId = i.intItemId 
		AND il.intLocationId = c.intCompanyLocationId
	LEFT JOIN tblICLot lot 
		ON lot.strLotNumber COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strLotNumber)) COLLATE Latin1_General_CI_AS
	LEFT JOIN tblSMCompanyLocationSubLocation sl 
		ON sl.strSubLocationName COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strStorageLocation)) COLLATE Latin1_General_CI_AS
	LEFT JOIN tblICStorageLocation su 
		ON su.strName COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strStorageUnit)) COLLATE Latin1_General_CI_AS
		OR su.strDescription COLLATE Latin1_General_CI_AS = RTRIM(LTRIM(x.strStorageUnit)) COLLATE Latin1_General_CI_AS
	LEFT JOIN tblSMCurrency currency
		ON currency.strCurrency = x.strCurrency COLLATE Latin1_General_CI_AS
	LEFT JOIN tblSMCurrencyExchangeRateType rateType
		ON rateType.strCurrencyExchangeRateType = x.strForexRateType COLLATE Latin1_General_CI_AS
	LEFT JOIN tblICLotStatus lotStatus
		ON lotStatus.strSecondaryStatus = x.strLotStatus
	LEFT JOIN tblICCommodityAttribute origin
		ON origin.strDescription = x.strOrigin
		AND origin.intCommodityId = i.intCommodityId
		AND origin.strType = 'Origin'
	LEFT JOIN tblAPVendor vendor 
		ON vendor.strVendorId = x.strVendor
	LEFT JOIN tblCTCropYear cropYear
		ON cropYear.strCropYear = x.strCropYear
	LEFT JOIN tblCTBook book 
		ON book.strBook = x.strBook
	LEFT JOIN tblCTSubBook subBook
		ON subBook.strSubBook = x.strSubBook
	LEFT JOIN tblEMEntity producer
		ON producer.strName = x.strProducer
WHERE 
	x.strImportIdentifier = @strIdentifier

DECLARE @Adjustments TABLE(
	intId INT
	, intLocationId INT
	, dtmDate DATETIME
	, strDescription NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
	, intUserId INT
	, dtmDateCreated DATETIME
)

-- Create the possible number of header records. 
BEGIN 
	;WITH headers (intId)
	AS
	(
		SELECT MIN(intId) intId
		FROM #tmp
		GROUP BY intLocationId, dtmDate
	)
	INSERT INTO @Adjustments (
		intId
		, intLocationId
		, dtmDate
		, strDescription
		, intUserId
		, dtmDateCreated
	)
	SELECT 
		h.intId
		, t.intLocationId
		, t.dtmDate
		, t.strDescription
		, t.intCreatedByUserId
		, t.dtmDateCreated
	FROM 
		#tmp t INNER JOIN headers h 
			ON h.intId = t.intId
END 


DECLARE @intId INT
DECLARE @intLocationId INT
DECLARE @dtmDate DATETIME
DECLARE @strDescription NVARCHAR(1000)
DECLARE @intUserId INT
DECLARE @dtmDateCreated DATETIME

DECLARE @intAdjustmentId INT
DECLARE @strAdjustmentNo NVARCHAR(100)

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT intId, intLocationId, dtmDate, strDescription, intUserId, dtmDateCreated FROM @Adjustments
OPEN cur
FETCH NEXT FROM cur INTO 
	@intId
	, @intLocationId
	, @dtmDate
	, @strDescription
	, @intUserId
	, @dtmDateCreated

WHILE @@FETCH_STATUS = 0
BEGIN
	EXEC dbo.uspSMGetStartingNumber 30, @strAdjustmentNo OUTPUT, @intLocationId
	
	INSERT INTO tblICInventoryAdjustment(
		strAdjustmentNo
		, intLocationId
		, intAdjustmentType
		, dtmAdjustmentDate
		, strDescription
		, intCreatedByUserId
		, dtmDateCreated
		, strDataSource
	)
	VALUES(
		@strAdjustmentNo
		, @intLocationId
		, 10 /*Opening Inventory*/
		, @dtmDate
		, @strDescription
		, @intUserId
		, @dtmDateCreated
		, 'Import CSV'
	)
	
	SET @intAdjustmentId = SCOPE_IDENTITY()

	INSERT INTO tblICInventoryAdjustmentDetail(
		intInventoryAdjustmentId 
		,intItemId
		,dblNewQuantity
		,intNewItemUOMId
		,dblNewCost
		,intNewWeightUOMId
		,dblNewWeight
		,intNewLotId
		,intOwnershipType
		,intNewSubLocationId
		,intNewStorageLocationId
		,intCreatedByUserId 
		,dtmDateCreated
		, intCurrencyId
		, intForexRateTypeId
		, dblForexRate
		, strNewLotNumber
		, strLotAlias 
		, strWarehouseRefNo 
		, intNewLotStatusId 
		, intOriginId 
		, strBOLNo 
		, strVessel 
		, strMarkings 
		, strNotes 
		, intEntityVendorId 
		, strVendorLotNo 
		, strGarden 
		, dtmManufacturedDate 
		, strContainerNo 
		, strCondition 
		, intSeasonCropYear 
		, intBookId 
		, intSubBookId 
		, strCertificate 
		, intProducerId 
		, strTrackingNumber 
		, strCargoNo 
	)
	SELECT
		@intAdjustmentId
		,t.intItemId
		,t.dblQuantity
		,t.intItemUOMId
		,t.dblUnitCost
		,t.intWeightUOMId
		,t.dblNetWeight
		,t.intLotId
		,t.intOwnershipTypeId
		,t.intStorageLocationId
		,t.intStorageUnitId
		,@intUserId
		,@dtmDateCreated
		, intCurrencyId
		, intForexRateTypeId
		, dblForexRate
		, strLotNumber
		, strLotAlias 
		, strWarehouseRefNo 
		, intLotStatus 
		, intOriginId 
		, strBOLNo 
		, strVessel 
		, strMarkings 
		, strNotes 
		, intEntityVendorId 
		, strVendorLotNo 
		, strGarden 
		, dtmManufacturedDate 
		, strContainerNo 
		, strCondition 
		, intSeasonCropYear 
		, intBookId 
		, intSubBookId 
		, strCertificate 
		, intProducerId 
		, strTrackingNumber 
		, strCargoNo 

	FROM 
		#tmp t
	WHERE 
		t.dtmDate = @dtmDate
		AND t.intLocationId = @intLocationId

	SET @row_inserted = ISNULL(@row_inserted, 0) + @@ROWCOUNT

	FETCH NEXT FROM cur INTO 
		@intId
		, @intLocationId
		, @dtmDate
		, @strDescription
		, @intUserId
		, @dtmDateCreated
END

CLOSE cur
DEALLOCATE cur

_exit_with_error:
_clean_up: 

DELETE 
FROM 
	tblICImportStagingOpeningBalance 
WHERE 
	strImportIdentifier = @strIdentifier
	
-- Logs 
BEGIN 
	INSERT INTO tblICImportLogFromStaging (
		[strUniqueId] 
		,[intRowsImported] 
		,[intTotalErrors]
		,[intTotalWarnings]
	)
	SELECT
		@strIdentifier
		,intRowsImported = ISNULL(@row_inserted, 0)
		,intTotalErrors = ISNULL(@row_errors, 0) 
		,intTotalWarnings = ISNULL(@row_warnings, 0)
END
