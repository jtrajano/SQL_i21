CREATE PROCEDURE uspQMImportInitialBuy @intImportLogId INT
AS
BEGIN TRY
	DECLARE @strBatchId NVARCHAR(50)
	 ,@intPlantId INT 
	 ,@strPlantCode NVARCHAR(50)
	 ,@strBatchNo NVARCHAR(50)
	,@intFromLocationCodeId INT
	,@intDestinationStorageLocationId INT

	DECLARE
		@ysnSuccess BIT
		,@strErrorMessage NVARCHAR(MAX)

	BEGIN TRANSACTION

	-- Validate Foreign Key Fields
	UPDATE IMP
	SET strLogResult = 'Incorrect Field(s): ' + REVERSE(SUBSTRING(REVERSE(MSG.strLogMessage), charindex(',', reverse(MSG.strLogMessage)) + 1, len(MSG.strLogMessage)))
		,ysnSuccess = 0
		,ysnProcessed = 1
	FROM tblQMImportCatalogue IMP
	-- Buyer1 Quantity UOM
	LEFT JOIN tblICUnitMeasure B1QUOM ON B1QUOM.strSymbol = IMP.strB1QtyUOM
	-- Buyer1 Price UOM
	LEFT JOIN tblICUnitMeasure B1PUOM ON B1PUOM.strSymbol = IMP.strB1PriceUOM
	-- Buyer2 Quantity UOM
	LEFT JOIN tblICUnitMeasure B2QUOM ON B2QUOM.strSymbol = IMP.strB2QtyUOM
	-- Buyer2 Price UOM
	LEFT JOIN tblICUnitMeasure B2PUOM ON B2PUOM.strSymbol = IMP.strB2PriceUOM
	-- Buyer3 Quantity UOM
	LEFT JOIN tblICUnitMeasure B3QUOM ON B3QUOM.strSymbol = IMP.strB3QtyUOM
	-- Buyer3 Price UOM
	LEFT JOIN tblICUnitMeasure B3PUOM ON B3PUOM.strSymbol = IMP.strB3PriceUOM
	-- Buyer4 Quantity UOM
	LEFT JOIN tblICUnitMeasure B4QUOM ON B4QUOM.strSymbol = IMP.strB4QtyUOM
	-- Buyer4 Price UOM
	LEFT JOIN tblICUnitMeasure B4PUOM ON B4PUOM.strSymbol = IMP.strB4PriceUOM
	-- Buyer5 Quantity UOM
	LEFT JOIN tblICUnitMeasure B5QUOM ON B5QUOM.strSymbol = IMP.strB5QtyUOM
	-- Buyer5 Price UOM
	LEFT JOIN tblICUnitMeasure B5PUOM ON B5PUOM.strSymbol = IMP.strB5PriceUOM
	-- Buyer2 Code
	LEFT JOIN vyuEMSearchEntityBuyer B2CODE ON B2CODE.strName = IMP.strB2Code
	-- Buyer3 Code
	LEFT JOIN vyuEMSearchEntityBuyer B3CODE ON B3CODE.strName = IMP.strB3Code
	-- Buyer4 Code
	LEFT JOIN vyuEMSearchEntityBuyer B4CODE ON B4CODE.strName = IMP.strB4Code
	-- Buyer5 Code
	LEFT JOIN vyuEMSearchEntityBuyer B5CODE ON B5CODE.strName = IMP.strB5Code
	-- Buyer1 Company Code
	LEFT JOIN tblSMPurchasingGroup COMPANY_CODE ON COMPANY_CODE.strName = IMP.strB1CompanyCode
	-- Buyer1 Group Number
	LEFT JOIN tblCTBook BOOK ON (BOOK.strBook = IMP.strB1GroupNumber OR BOOK.strBookDescription = IMP.strB1GroupNumber)
	-- Currency
	LEFT JOIN tblSMCurrency CURRENCY ON CURRENCY.strCurrency = IMP.strCurrency
	-- Strategy
	LEFT JOIN tblCTSubBook STRATEGY ON IMP.strStrategy IS NOT NULL
		AND STRATEGY.strSubBook = IMP.strStrategy
		AND STRATEGY.intBookId = BOOK.intBookId
	-- From Location Code
	LEFT JOIN tblSMCity FROM_LOC_CODE ON FROM_LOC_CODE.strCity = IMP.strFromLocationCode
	-- Receiving Storage Location
	LEFT JOIN (
		tblSMCompanyLocationSubLocation RSL INNER JOIN tblSMCompanyLocation TBO2 ON TBO2.intCompanyLocationId = RSL.intCompanyLocationId
		) ON IMP.strReceivingStorageLocation IS NOT NULL
		AND RSL.strSubLocationName = IMP.strReceivingStorageLocation
		AND TBO2.strLocationName = IMP.strBuyingCenter
	
	-- Format log message
	OUTER APPLY (
		SELECT strLogMessage = CASE 
				WHEN (
						B1QUOM.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strB1QtyUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.dblB1QtyBought, 0) <> 0
						AND ISNULL(IMP.strB1QtyUOM, '') = ''
						)
					THEN 'BUYER1 QTY UOM, '
				ELSE ''
				END + CASE 
				WHEN (
						B1PUOM.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strB1PriceUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.dblB1Price, 0) <> 0
						AND ISNULL(IMP.strB1PriceUOM, '') = ''
						)
					THEN 'BUYER1 PRICE UOM, '
				ELSE ''
				END + CASE 
				WHEN (
						B2CODE.intEntityId IS NULL
						AND ISNULL(IMP.strB2Code, '') <> ''
						)
					THEN 'BUYER2 CODE, '
				ELSE ''
				END + CASE 
				WHEN (
						B2QUOM.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strB2QtyUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.dblB2QtyBought, 0) <> 0
						AND ISNULL(IMP.strB2QtyUOM, '') = ''
						)
					THEN 'BUYER2 QTY UOM, '
				ELSE ''
				END + CASE 
				WHEN (
						B2PUOM.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strB2PriceUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.dblB2Price, 0) <> 0
						AND ISNULL(IMP.strB2PriceUOM, '') = ''
						)
					THEN 'BUYER2 PRICE UOM, '
				ELSE ''
				END + CASE 
				WHEN (
						B3CODE.intEntityId IS NULL
						AND ISNULL(IMP.strB3Code, '') <> ''
						)
					THEN 'BUYER3 CODE, '
				ELSE ''
				END + CASE 
				WHEN (
						B3QUOM.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strB3QtyUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.dblB3QtyBought, 0) <> 0
						AND ISNULL(IMP.strB3QtyUOM, '') = ''
						)
					THEN 'BUYER3 QTY UOM, '
				ELSE ''
				END + CASE 
				WHEN (
						B3PUOM.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strB3PriceUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.dblB3Price, 0) <> 0
						AND ISNULL(IMP.strB3PriceUOM, '') = ''
						)
					THEN 'BUYER3 PRICE UOM, '
				ELSE ''
				END + CASE 
				WHEN (
						B4CODE.intEntityId IS NULL
						AND ISNULL(IMP.strB4Code, '') <> ''
						)
					THEN 'BUYER4 CODE, '
				ELSE ''
				END + CASE 
				WHEN (
						B4QUOM.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strB4QtyUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.dblB4QtyBought, 0) <> 0
						AND ISNULL(IMP.strB4QtyUOM, '') = ''
						)
					THEN 'BUYER4 QTY UOM, '
				ELSE ''
				END + CASE 
				WHEN (
						B4PUOM.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strB4PriceUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.dblB4Price, 0) <> 0
						AND ISNULL(IMP.strB4PriceUOM, '') = ''
						)
					THEN 'BUYER4 PRICE UOM, '
				ELSE ''
				END + CASE 
				WHEN (
						B5CODE.intEntityId IS NULL
						AND ISNULL(IMP.strB5Code, '') <> ''
						)
					THEN 'BUYER5 CODE, '
				ELSE ''
				END + CASE 
				WHEN (
						B5QUOM.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strB5QtyUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.dblB5QtyBought, 0) <> 0
						AND ISNULL(IMP.strB5QtyUOM, '') = ''
						)
					THEN 'BUYER5 QTY UOM, '
				ELSE ''
				END + CASE 
				WHEN (
						B5PUOM.intUnitMeasureId IS NULL
						AND ISNULL(IMP.strB5PriceUOM, '') <> ''
						)
					OR (
						ISNULL(IMP.dblB5Price, 0) <> 0
						AND ISNULL(IMP.strB5PriceUOM, '') = ''
						)
					THEN 'BUYER5 PRICE UOM, '
				ELSE ''
				END + CASE 
				WHEN (
						BOOK.intBookId IS NULL
						--AND ISNULL(IMP.strB1GroupNumber, '') <> ''
						)
					THEN 'BUYER1 GROUP NUMBER, '
				ELSE ''
				END + CASE 
				WHEN (
						COMPANY_CODE.intPurchasingGroupId IS NULL
						AND ISNULL(IMP.strB1CompanyCode, '') <> ''
						)
					THEN 'BUYER1 COMPANY CODE, '
				ELSE ''
				END + CASE 
				WHEN (
						CURRENCY.intConcurrencyId IS NULL
						--AND ISNULL(IMP.strCurrency, '') <> ''
						)
					THEN 'CURRENCY, '
				ELSE ''
				END+ CASE 
				WHEN (
						FROM_LOC_CODE.intCityId IS NULL
						)
					THEN 'FROM LOCATION CODE, '
				ELSE ''
				END +CASE 
				WHEN (
						RSL.intCompanyLocationSubLocationId IS NULL
						)
					THEN 'RECEIVING STORAGE LOCATION, '
				ELSE ''
				END
		) MSG
	WHERE IMP.intImportLogId = @intImportLogId
		AND IMP.ysnSuccess = 1
		AND (
			((
				B1QUOM.intUnitMeasureId IS NULL
				AND ISNULL(IMP.strB1QtyUOM, '') <> ''
				)
				OR (
				ISNULL(IMP.dblB1QtyBought, 0) <> 0
				AND ISNULL(IMP.strB1QtyUOM, '') = ''
				))
			OR ((
				B1PUOM.intUnitMeasureId IS NULL
				AND ISNULL(IMP.strB1PriceUOM, '') <> ''
				)
				OR (
					ISNULL(IMP.dblB1Price, 0) <> 0
					AND ISNULL(IMP.strB1PriceUOM, '') = ''
				))
			OR (
				B2CODE.intEntityId IS NULL
				AND ISNULL(IMP.strB2Code, '') <> ''
				)
			OR ((
				B2QUOM.intUnitMeasureId IS NULL
				AND ISNULL(IMP.strB2QtyUOM, '') <> ''
				)
				OR (
				ISNULL(IMP.dblB2QtyBought, 0) <> 0
				AND ISNULL(IMP.strB2QtyUOM, '') = ''
				))
			OR ((
				B2PUOM.intUnitMeasureId IS NULL
				AND ISNULL(IMP.strB2PriceUOM, '') <> ''
				)
				OR (
					ISNULL(IMP.dblB2Price, 0) <> 0
					AND ISNULL(IMP.strB2PriceUOM, '') = ''
				))
			OR (
				B3CODE.intEntityId IS NULL
				AND ISNULL(IMP.strB3Code, '') <> ''
				)
			OR ((
				B3QUOM.intUnitMeasureId IS NULL
				AND ISNULL(IMP.strB3QtyUOM, '') <> ''
				)
				OR (
				ISNULL(IMP.dblB3QtyBought, 0) <> 0
				AND ISNULL(IMP.strB3QtyUOM, '') = ''
				))
			OR ((
				B3PUOM.intUnitMeasureId IS NULL
				AND ISNULL(IMP.strB3PriceUOM, '') <> ''
				)
				OR (
					ISNULL(IMP.dblB3Price, 0) <> 0
					AND ISNULL(IMP.strB3PriceUOM, '') = ''
				))
			OR (
				B4CODE.intEntityId IS NULL
				AND ISNULL(IMP.strB4Code, '') <> ''
				)
			OR ((
				B4QUOM.intUnitMeasureId IS NULL
				AND ISNULL(IMP.strB4QtyUOM, '') <> ''
				)
				OR (
				ISNULL(IMP.dblB4QtyBought, 0) <> 0
				AND ISNULL(IMP.strB4QtyUOM, '') = ''
				))
			OR ((
				B4PUOM.intUnitMeasureId IS NULL
				AND ISNULL(IMP.strB4PriceUOM, '') <> ''
				)
				OR (
					ISNULL(IMP.dblB4Price, 0) <> 0
					AND ISNULL(IMP.strB4PriceUOM, '') = ''
				))
			OR (
				B5CODE.intEntityId IS NULL
				AND ISNULL(IMP.strB5Code, '') <> ''
				)
			OR ((
				B5QUOM.intUnitMeasureId IS NULL
				AND ISNULL(IMP.strB5QtyUOM, '') <> ''
				)
				OR (
				ISNULL(IMP.dblB5QtyBought, 0) <> 0
				AND ISNULL(IMP.strB5QtyUOM, '') = ''
				))
			OR ((
				B5PUOM.intUnitMeasureId IS NULL
				AND ISNULL(IMP.strB5PriceUOM, '') <> ''
				)
				OR (
					ISNULL(IMP.dblB5Price, 0) <> 0
					AND ISNULL(IMP.strB5PriceUOM, '') = ''
				))
			OR (
				COMPANY_CODE.intPurchasingGroupId IS NULL
				AND ISNULL(IMP.strB1CompanyCode, '') <> ''
				)
			OR (
				BOOK.intBookId IS NULL
				--AND ISNULL(IMP.strB1GroupNumber, '') <> ''
				)
			OR (
				CURRENCY.intCurrencyID IS NULL
				--AND ISNULL(IMP.strCurrency, '') <> ''
				)
			OR (
				STRATEGY.intSubBookId IS NULL
				AND ISNULL(IMP.strStrategy, '') <> ''
				)
				OR FROM_LOC_CODE.intCityId IS NULL
				OR RSL.intCompanyLocationSubLocationId IS NULL
				
			)

	EXECUTE uspQMImportValidationTastingScore @intImportLogId;

	-- End Validation   
	DECLARE @intImportCatalogueId INT
		,@intSampleId INT
		,@intEntityUserId INT
		,@intPurchasingGroupId INT
		,@strPurchasingGroup NVARCHAR(150)
		,@intBookId INT
		,@strBook NVARCHAR(100)
		,@intCurrencyId INT
		,@strCurrency NVARCHAR(50)
		,@ysnBought BIT
		,@intSubBookId INT
		,@strBuyingOrderNumber NVARCHAR(50)
		-- B1
		,@dblB1QtyBought NUMERIC(18, 6)
		,@intB1QtyUOMId INT
		,@dblB1Price NUMERIC(18, 6)
		,@intB1PriceUOMId INT
		-- B2
		,@intBuyer2Id INT
		,@dblB2QtyBought NUMERIC(18, 6)
		,@intB2QtyUOMId INT
		,@dblB2Price NUMERIC(18, 6)
		,@intB2PriceUOMId INT
		-- B3
		,@intBuyer3Id INT
		,@dblB3QtyBought NUMERIC(18, 6)
		,@intB3QtyUOMId INT
		,@dblB3Price NUMERIC(18, 6)
		,@intB3PriceUOMId INT
		-- B4
		,@intBuyer4Id INT
		,@dblB4QtyBought NUMERIC(18, 6)
		,@intB4QtyUOMId INT
		,@dblB4Price NUMERIC(18, 6)
		,@intB4PriceUOMId INT
		-- B5
		,@intBuyer5Id INT
		,@dblB5QtyBought NUMERIC(18, 6)
		,@intB5QtyUOMId INT
		,@dblB5Price NUMERIC(18, 6)
		,@intB5PriceUOMId INT

		,@intETAPOL INT
		,@intStockDate INT
		,@dtmStock Datetime
		,@dtmShippingDate Datetime
		,@dtmCurrentDate DATETIME

	DECLARE @MFBatchTableType MFBatchTableType
	-- Loop through each valid import detail
	DECLARE @C AS CURSOR;

	SET @C = CURSOR FAST_FORWARD
	FOR

	SELECT intImportCatalogueId = IMP.intImportCatalogueId
		,intSampleId = S.intSampleId
		,intEntityUserId = IL.intEntityId
		,intPurchasingGroupId = COMPANY_CODE.intPurchasingGroupId
		,strPurchasingGroup = COMPANY_CODE.strName
		,intBookId = BOOK.intBookId
		,strBook = BOOK.strBook
		,intCurrencyId = CURRENCY.intCurrencyID
		,strCurrency = CURRENCY.strCurrency
		,ysnBought = IMP.ysnBought
		,intSubBookId = STRATEGY.intSubBookId
		,strBuyingOrderNumber = IMP.strBuyingOrderNumber
		-- B1
		,dblB1QtyBought = IMP.dblB1QtyBought
		,intB1QtyUOMId = B1QUOM.intUnitMeasureId
		,dblB1Price = IMP.dblB1Price
		,intB1PriceUOMId = B1PUOM.intUnitMeasureId
		-- B2
		,intBuyer2Id = B2CODE.intEntityId
		,dblB2QtyBought = IMP.dblB2QtyBought
		,intB2QtyUOMId = B2QUOM.intUnitMeasureId
		,dblB2Price = IMP.dblB2Price
		,intB2PriceUOMId = B2PUOM.intUnitMeasureId
		-- B3
		,intBuyer3Id = B3CODE.intEntityId
		,dblB3QtyBought = IMP.dblB3QtyBought
		,intB3QtyUOMId = B3QUOM.intUnitMeasureId
		,dblB3Price = IMP.dblB3Price
		,intB3PriceUOMId = B3PUOM.intUnitMeasureId
		-- B4
		,intBuyer4Id = B4CODE.intEntityId
		,dblB4QtyBought = IMP.dblB4QtyBought
		,intB4QtyUOMId = B4QUOM.intUnitMeasureId
		,dblB4Price = IMP.dblB4Price
		,intB4PriceUOMId = B4PUOM.intUnitMeasureId
		-- B5
		,intBuyer5Id = B5CODE.intEntityId
		,dblB5QtyBought = IMP.dblB5QtyBought
		,intB5QtyUOMId = B5QUOM.intUnitMeasureId
		,dblB5Price = IMP.dblB5Price
		,intB5PriceUOMId = B5PUOM.intUnitMeasureId
		,strPlantCode=CL.strOregonFacilityNumber
		,intFromLocationCodeId = FROM_LOC_CODE.intCityId
		,intStorageLocationId = RSL.intCompanyLocationSubLocationId
	FROM tblQMSample S
	INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
	INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
	INNER JOIN (
		tblEMEntity E INNER JOIN tblAPVendor V ON V.intEntityId = E.intEntityId
		) ON V.intEntityId = S.intEntityId
	INNER JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
	INNER JOIN (
		tblQMImportCatalogue IMP
		INNER JOIN tblQMImportLog IL ON IL.intImportLogId = IMP.intImportLogId
		-- Buyer1 Quantity UOM
		LEFT JOIN tblICUnitMeasure B1QUOM ON B1QUOM.strSymbol = IMP.strB1QtyUOM
		-- Buyer1 Price UOM
		LEFT JOIN tblICUnitMeasure B1PUOM ON B1PUOM.strSymbol = IMP.strB1PriceUOM
		-- Buyer2 Quantity UOM
		LEFT JOIN tblICUnitMeasure B2QUOM ON B2QUOM.strSymbol = IMP.strB2QtyUOM
		-- Buyer2 Price UOM
		LEFT JOIN tblICUnitMeasure B2PUOM ON B2PUOM.strSymbol = IMP.strB2PriceUOM
		-- Buyer3 Quantity UOM
		LEFT JOIN tblICUnitMeasure B3QUOM ON B3QUOM.strSymbol = IMP.strB3QtyUOM
		-- Buyer3 Price UOM
		LEFT JOIN tblICUnitMeasure B3PUOM ON B3PUOM.strSymbol = IMP.strB3PriceUOM
		-- Buyer4 Quantity UOM
		LEFT JOIN tblICUnitMeasure B4QUOM ON B4QUOM.strSymbol = IMP.strB4QtyUOM
		-- Buyer4 Price UOM
		LEFT JOIN tblICUnitMeasure B4PUOM ON B4PUOM.strSymbol = IMP.strB4PriceUOM
		-- Buyer5 Quantity UOM
		LEFT JOIN tblICUnitMeasure B5QUOM ON B5QUOM.strSymbol = IMP.strB5QtyUOM
		-- Buyer5 Price UOM
		LEFT JOIN tblICUnitMeasure B5PUOM ON B5PUOM.strSymbol = IMP.strB5PriceUOM
		-- Buyer2 Code
		LEFT JOIN vyuEMSearchEntityBuyer B2CODE ON B2CODE.strName = IMP.strB2Code
		-- Buyer3 Code
		LEFT JOIN vyuEMSearchEntityBuyer B3CODE ON B3CODE.strName = IMP.strB3Code
		-- Buyer4 Code
		LEFT JOIN vyuEMSearchEntityBuyer B4CODE ON B4CODE.strName = IMP.strB4Code
		-- Buyer5 Code
		LEFT JOIN vyuEMSearchEntityBuyer B5CODE ON B5CODE.strName = IMP.strB5Code
		-- Buyer1 Company Code
		LEFT JOIN tblSMPurchasingGroup COMPANY_CODE ON COMPANY_CODE.strName = IMP.strB1CompanyCode
		-- Buyer1 Group Number
		LEFT JOIN tblCTBook BOOK ON (BOOK.strBook = IMP.strB1GroupNumber OR BOOK.strBookDescription = IMP.strB1GroupNumber)
		-- Currency
		LEFT JOIN tblSMCurrency CURRENCY ON CURRENCY.strCurrency = IMP.strCurrency
		-- Strategy
		LEFT JOIN tblCTSubBook STRATEGY ON IMP.strStrategy IS NOT NULL
			AND STRATEGY.strSubBook = IMP.strStrategy
			AND STRATEGY.intBookId = BOOK.intBookId
		-- From Location Code
		LEFT JOIN tblSMCity FROM_LOC_CODE ON FROM_LOC_CODE.strCity = IMP.strFromLocationCode
		-- Receiving Storage Location
		LEFT JOIN (
		tblSMCompanyLocationSubLocation RSL INNER JOIN tblSMCompanyLocation TBO2 ON TBO2.intCompanyLocationId = RSL.intCompanyLocationId
		) ON IMP.strReceivingStorageLocation IS NOT NULL
		AND RSL.strSubLocationName = IMP.strReceivingStorageLocation
		AND TBO2.strLocationName = IMP.strBuyingCenter
		) ON SY.strSaleYear = IMP.strSaleYear
		AND CL.strLocationName = IMP.strBuyingCenter
		AND S.strSaleNumber = IMP.strSaleNumber
		AND CT.strCatalogueType = IMP.strCatalogueType
		AND E.strName = IMP.strSupplier
		AND S.strRepresentLotNumber = IMP.strLotNumber
	WHERE IMP.intImportLogId = @intImportLogId
		AND IMP.ysnSuccess = 1

	OPEN @C

	FETCH NEXT
	FROM @C
	INTO @intImportCatalogueId
		,@intSampleId
		,@intEntityUserId
		,@intPurchasingGroupId
		,@strPurchasingGroup
		,@intBookId
		,@strBook
		,@intCurrencyId
		,@strCurrency
		,@ysnBought
		,@intSubBookId
		,@strBuyingOrderNumber
		-- B1
		,@dblB1QtyBought
		,@intB1QtyUOMId
		,@dblB1Price
		,@intB1PriceUOMId
		-- B2
		,@intBuyer2Id
		,@dblB2QtyBought
		,@intB2QtyUOMId
		,@dblB2Price
		,@intB2PriceUOMId
		-- B3
		,@intBuyer3Id
		,@dblB3QtyBought
		,@intB3QtyUOMId
		,@dblB3Price
		,@intB3PriceUOMId
		-- B4
		,@intBuyer4Id
		,@dblB4QtyBought
		,@intB4QtyUOMId
		,@dblB4Price
		,@intB4PriceUOMId
		-- B5
		,@intBuyer5Id
		,@dblB5QtyBought
		,@intB5QtyUOMId
		,@dblB5Price
		,@intB5PriceUOMId
		,@strPlantCode
		,@intFromLocationCodeId 
		,@intDestinationStorageLocationId 
	
	WHILE @@FETCH_STATUS = 0
	BEGIN
		Select @strBatchNo=NULL
		SELECT TOP 1 @intPlantId = CL.intCompanyLocationId ,@strBatchNo=strBatchNo 
		FROM dbo.tblQMSample S WITH (NOLOCK)  
		JOIN dbo.tblCTBook B WITH (NOLOCK) ON B.intBookId = @intBookId 
		AND S.intSampleId = @intSampleId  
		JOIN dbo.tblSMCompanyLocation CL WITH (NOLOCK) ON CL.strLocationName = B.strBook
		
		IF @strBatchNo IS NOT NULL
		BEGIN
			-- Delete batch in MU only
			EXEC uspMFDeleteBatch
				@strBatchId = @strBatchNo
				,@intLocationId = @intPlantId
				,@ysnSuccess = @ysnSuccess OUTPUT
				,@strErrorMessage = @strErrorMessage OUTPUT

			IF @ysnSuccess = 0
			BEGIN
				UPDATE tblQMImportCatalogue
				SET ysnProcessed = 1, ysnSuccess = 0, strLogResult = @strErrorMessage
				WHERE intImportCatalogueId = @intImportCatalogueId

				GOTO CONT
			END
		END

		EXEC uspQMGenerateSampleCatalogueImportAuditLog
			@intSampleId  = @intSampleId
			,@intUserEntityId = @intEntityUserId
			,@strRemarks = 'Updated from Initial Buy Import'
			,@ysnCreate = 0
			,@ysnBeforeUpdate = 1

		UPDATE S
		SET intConcurrencyId = S.intConcurrencyId + 1
			,intCurrencyId = @intCurrencyId
			,intPurchaseGroupId = @intPurchasingGroupId
			,intBookId = @intBookId
			,ysnBought = @ysnBought
			,intSubBookId = @intSubBookId
			,strBuyingOrderNo = @strBuyingOrderNumber
			-- Initial Buy
			-- B1
			,dblB1QtyBought = @dblB1QtyBought
			,intB1QtyUOMId = @intB1QtyUOMId
			,dblB1Price = @dblB1Price
			,intB1PriceUOMId = @intB1PriceUOMId
			-- B2
			,intBuyer2Id = @intBuyer2Id
			,dblB2QtyBought = @dblB2QtyBought
			,intB2QtyUOMId = @intB2QtyUOMId
			,dblB2Price = @dblB2Price
			,intB2PriceUOMId = @intB2PriceUOMId
			-- B3
			,intBuyer3Id = @intBuyer3Id
			,dblB3QtyBought = @dblB3QtyBought
			,intB3QtyUOMId = @intB3QtyUOMId
			,dblB3Price = @dblB3Price
			,intB3PriceUOMId = @intB3PriceUOMId
			-- B4
			,intBuyer4Id = @intBuyer4Id
			,dblB4QtyBought = @dblB4QtyBought
			,intB4QtyUOMId = @intB4QtyUOMId
			,dblB4Price = @dblB4Price
			,intB4PriceUOMId = @intB4PriceUOMId
			-- B5
			,intBuyer5Id = @intBuyer5Id
			,dblB5QtyBought = @dblB5QtyBought
			,intB5QtyUOMId = @intB5QtyUOMId
			,dblB5Price = @dblB5Price
			,intB5PriceUOMId = @intB5PriceUOMId
			,intFromLocationCodeId = @intFromLocationCodeId
			,intDestinationStorageLocationId = @intDestinationStorageLocationId
		FROM tblQMSample S
		WHERE S.intSampleId = @intSampleId

		UPDATE tblQMImportCatalogue
		SET intSampleId = @intSampleId
		WHERE intImportCatalogueId = @intImportCatalogueId

		-- Call uspMFUpdateInsertBatch
		DELETE
		FROM @MFBatchTableType
    
		SELECT TOP 1 @intETAPOL=IsNULL(LLT.dblPurchaseToShipment,0)
				,@intStockDate= IsNULL(LLT.dblPurchaseToShipment,0)+IsNULL(LLT.dblPortToPort,0)+ IsNULL(LLT.dblPortToMixingUnit,0) +IsNULL(LLT.dblMUToAvailableForBlending,0) 
		FROM dbo.tblQMSample S WITH (NOLOCK)  
		JOIN dbo.tblICItem I WITH (NOLOCK) ON I.intItemId = S.intItemId  
		AND S.intSampleId = @intSampleId  
		JOIN dbo.tblICCommodityAttribute CA WITH (NOLOCK) ON CA.intCommodityAttributeId = I.intOriginId  
		JOIN dbo.tblMFLocationLeadTime LLT WITH (NOLOCK) ON LLT.intOriginId = CA.intCountryID  
		AND LLT.intBuyingCenterId = S.intCompanyLocationId  
		AND LLT.intReceivingPlantId = @intPlantId  
		AND LLT.intReceivingStorageLocation = S.intDestinationStorageLocationId  
		AND LLT.intChannelId = S.intMarketZoneId  
		AND LLT.intPortOfDispatchId = S.intFromLocationCodeId  
		JOIN dbo.tblSMCity DP WITH (NOLOCK) ON DP.intCityId = LLT.intPortOfArrivalId 
		
		IF @intETAPOL IS NULL
		BEGIN
			SELECT  @intETAPOL=0
		END

		IF @intStockDate IS NULL
		BEGIN
			SELECT  @intStockDate=0
		END
		Select @dtmCurrentDate=Convert(Char, GETDATE(),101)
		SELECT @dtmStock=DateAdd(d,@intStockDate,@dtmCurrentDate)

		SELECT @dtmShippingDate=DateAdd(d,@intETAPOL,@dtmCurrentDate)

		INSERT INTO @MFBatchTableType (
			strBatchId
			,intSales
			,intSalesYear
			,dtmSalesDate
			,strTeaType
			,intBrokerId
			,strVendorLotNumber
			,intBuyingCenterLocationId
			,intStorageLocationId
			,intStorageUnitId
			,intBrokerWarehouseId
			,intParentBatchId
			,intInventoryReceiptId
			,intSampleId
			,intContractDetailId
			,str3PLStatus
			,strSupplierReference
			,strAirwayBillCode
			,strAWBSampleReceived
			,strAWBSampleReference
			,dblBasePrice
			,ysnBoughtAsReserved
			,dblBoughtPrice
			,dblBulkDensity
			,strBuyingOrderNumber
			,intSubBookId
			,strContainerNumber
			,intCurrencyId
			,dtmProductionBatch
			,dtmTeaAvailableFrom
			,strDustContent
			,ysnEUCompliant
			,strTBOEvaluatorCode
			,strEvaluatorRemarks
			,dtmExpiration
			,intFromPortId
			,dblGrossWeight
			,dtmInitialBuy
			,dblWeightPerUnit
			,dblLandedPrice
			,strLeafCategory
			,strLeafManufacturingType
			,strLeafSize
			,strLeafStyle
			,intBookId
			,dblPackagesBought
			,intItemUOMId
			,intWeightUOMId
			,strTeaOrigin
			,intOriginalItemId
			,dblPackagesPerPallet
			,strPlant
			,dblTotalQuantity
			,strSampleBoxNumber
			,dblSellingPrice
			,dtmStock
			,ysnStrategic
			,strTeaLingoSubCluster
			,dtmSupplierPreInvoiceDate
			,strSustainability
			,strTasterComments
			,dblTeaAppearance
			,strTeaBuyingOffice
			,strTeaColour
			,strTeaGardenChopInvoiceNumber
			,intGardenMarkId
			,strTeaGroup
			,dblTeaHue
			,dblTeaIntensity
			,strLeafGrade
			,dblTeaMoisture
			,dblTeaMouthFeel
			,ysnTeaOrganic
			,dblTeaTaste
			,dblTeaVolume
			,strFines
			,intTealingoItemId
			,dtmWarehouseArrival
			,intYearManufacture
			,strPackageSize
			,intPackageUOMId
			,dblTareWeight
			,strTaster
			,strFeedStock
			,strFlourideLimit
			,strLocalAuctionNumber
			,strPOStatus
			,strProductionSite
			,strReserveMU
			,strQualityComments
			,strRareEarth
			,strFreightAgent
			,strSealNumber
			,strContainerType
			,strVoyage
			,strVessel
			,intLocationId
			,intMixingUnitLocationId
			,intMarketZoneId
			,dblTeaTastePinpoint
			,dblTeaHuePinpoint
			,dblTeaIntensityPinpoint
			,dblTeaMouthFeelPinpoint
			,dblTeaAppearancePinpoint
			,dtmShippingDate
			,intCountryId
			,intSupplierId
			)
		SELECT strBatchId = S.strBatchNo
			,intSales = CAST(S.strSaleNumber AS INT)
			,intSalesYear = CAST(SY.strSaleYear AS INT)
			,dtmSalesDate = S.dtmSaleDate
			,strTeaType = CT.strCatalogueType
			,intBrokerId = S.intBrokerId
			,strVendorLotNumber = S.strRepresentLotNumber
			,intBuyingCenterLocationId = S.intCompanyLocationId
			,intStorageLocationId = S.intDestinationStorageLocationId
			,intStorageUnitId = NULL
			,intBrokerWarehouseId = NULL
			,intParentBatchId = NULL
			,intInventoryReceiptId = S.intInventoryReceiptId
			,intSampleId = S.intSampleId
			,intContractDetailId = S.intContractDetailId
			,str3PLStatus = S.str3PLStatus
			,strSupplierReference = S.strAdditionalSupplierReference
			,strAirwayBillCode = S.strCourierRef
			,strAWBSampleReceived = CAST(S.intAWBSampleReceived AS NVARCHAR(50))
			,strAWBSampleReference = S.strAWBSampleReference
			,dblBasePrice = @dblB1Price
			,ysnBoughtAsReserved = S.ysnBoughtAsReserve
			,dblBoughtPrice = @dblB1Price
			,dblBulkDensity = NULL
			,strBuyingOrderNumber = S.strBuyingOrderNo
			,intSubBookId = S.intSubBookId
			,strContainerNumber = S.strContainerNumber
			,intCurrencyId = S.intCurrencyId
			,dtmProductionBatch = S.dtmManufacturingDate
			,dtmTeaAvailableFrom = NULL
			,strDustContent = NULL
			,ysnEUCompliant = S.ysnEuropeanCompliantFlag
			,strTBOEvaluatorCode = ECTBO.strName
			,strEvaluatorRemarks = S.strComments3
			,dtmExpiration = NULL
			,intFromPortId = S.intFromLocationCodeId
			,dblGrossWeight = S.dblSampleQty +IsNULL(S.dblTareWeight,0) 
			,dtmInitialBuy = @dtmCurrentDate 
			--,dblWeightPerUnit = dbo.fnCalculateQtyBetweenUOM(QIUOM.intItemUOMId, WIUOM.intItemUOMId, 1)
			,dblWeightPerUnit = Case When IsNULL(S.dblB1QtyBought,0)>0 Then S.dblSampleQty/S.dblB1QtyBought Else 1 End
			,dblLandedPrice = NULL
			,strLeafCategory = LEAF_CATEGORY.strAttribute2
			,strLeafManufacturingType = LEAF_TYPE.strDescription
			,strLeafSize = BRAND.strBrandCode
			,strLeafStyle = STYLE.strName
			,intBookId = S.intBookId
			,dblPackagesBought = S.dblB1QtyBought
			,intItemUOMId = S.intSampleUOMId
			,intWeightUOMId = S.intSampleUOMId
			,strTeaOrigin = S.strCountry
			,intOriginalItemId = S.intItemId
			,dblPackagesPerPallet = IsNULL(I.intUnitPerLayer *I.intLayerPerPallet,20)
			,strPlant = @strPlantCode
			,dblTotalQuantity = S.dblSampleQty
			,strSampleBoxNumber = S.strSampleBoxNumber
			,dblSellingPrice = NULL
			,dtmStock = @dtmStock
			,ysnStrategic = NULL
			,strTeaLingoSubCluster = REGION.strDescription
			,dtmSupplierPreInvoiceDate = NULL
			,strSustainability = SUSTAINABILITY.strDescription
			,strTasterComments = S.strComments2
			,dblTeaAppearance = CASE 
				WHEN ISNULL(APPEARANCE.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(APPEARANCE.strPropertyValue AS NUMERIC(18, 6))
				END
			,strTeaBuyingOffice = IMP.strBuyingCenter
			,strTeaColour = COLOUR.strDescription
			,strTeaGardenChopInvoiceNumber = S.strChopNumber
			,intGardenMarkId = S.intGardenMarkId
			,strTeaGroup = ISNULL(BRAND.strBrandCode, '') + ISNULL(REGION.strDescription, '') + ISNULL(STYLE.strName, '')
			,dblTeaHue = CASE 
				WHEN ISNULL(HUE.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(HUE.strPropertyValue AS NUMERIC(18, 6))
				END
			,dblTeaIntensity = CASE 
				WHEN ISNULL(INTENSITY.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(INTENSITY.strPropertyValue AS NUMERIC(18, 6))
				END
			,strLeafGrade = GRADE.strDescription
			,dblTeaMoisture = CASE 
				WHEN ISNULL(MOISTURE.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(MOISTURE.strPropertyValue AS NUMERIC(18, 6))
				END
			,dblTeaMouthFeel = CASE 
				WHEN ISNULL(MOUTH_FEEL.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(MOUTH_FEEL.strPropertyValue AS NUMERIC(18, 6))
				END
			,ysnTeaOrganic = S.ysnOrganic
			,dblTeaTaste = CASE 
				WHEN ISNULL(TASTE.strPropertyValue, '') = ''
					THEN NULL
				ELSE CAST(TASTE.strPropertyValue AS NUMERIC(18, 6))
				END
			,dblTeaVolume = CASE WHEN ISNULL(VOLUME.strPropertyValue, '') = '' THEN NULL ELSE VOLUME.strPropertyValue END
			,strFines = CASE WHEN ISNULL(FINES.strPropertyValue, '') = '' THEN NULL ELSE FINES.strPropertyValue END
			,intTealingoItemId = S.intItemId
			,dtmWarehouseArrival = NULL
			,intYearManufacture = Datepart(YYYY,S.dtmManufacturingDate)
			,strPackageSize = PT.strUnitMeasure
			,intPackageUOMId = S.intNetWtPerPackagesUOMId
			,dblTareWeight = S.dblTareWeight
			,strTaster = IMP.strTaster
			,strFeedStock = NULL
			,strFlourideLimit = NULL
			,strLocalAuctionNumber = NULL
			,strPOStatus = NULL
			,strProductionSite = NULL
			,strReserveMU = NULL
			,strQualityComments = NULL
			,strRareEarth = NULL
			,strFreightAgent = NULL
			,strSealNumber = NULL
			,strContainerType = NULL
			,strVoyage = NULL
			,strVessel = NULL
			,intLocationId = S.intCompanyLocationId
			,intMixingUnitLocationId = MU.intCompanyLocationId
			,intMarketZoneId = S.intMarketZoneId
			,dblTeaTastePinpoint = TASTE.dblPinpointValue
			,dblTeaHuePinpoint = HUE.dblPinpointValue
			,dblTeaIntensityPinpoint = INTENSITY.dblPinpointValue
			,dblTeaMouthFeelPinpoint = MOUTH_FEEL.dblPinpointValue
			,dblTeaAppearancePinpoint = APPEARANCE.dblPinpointValue
			,dtmShippingDate=@dtmShippingDate
			,intCountryId=ORIGIN.intCountryID 
			,intSupplierId=S.intEntityId
		FROM tblQMSample S
		INNER JOIN tblQMImportCatalogue IMP ON IMP.intSampleId = S.intSampleId
		INNER JOIN tblQMSaleYear SY ON SY.intSaleYearId = S.intSaleYearId
		INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
		INNER JOIN tblICItem I ON I.intItemId = S.intItemId
		LEFT JOIN tblICCommodityAttribute REGION ON REGION.intCommodityAttributeId = I.intRegionId
		LEFT JOIN tblICCommodityAttribute ORIGIN ON ORIGIN.intCommodityAttributeId = S.intCountryID
		LEFT JOIN tblCTBook B ON B.intBookId = S.intBookId
		LEFT JOIN tblSMCompanyLocation MU ON MU.strLocationName = B.strBook
		LEFT JOIN tblICBrand BRAND ON BRAND.intBrandId = S.intBrandId
		LEFT JOIN tblCTValuationGroup STYLE ON STYLE.intValuationGroupId = S.intValuationGroupId
		LEFT JOIN tblICUnitMeasure PT on PT.intUnitMeasureId=S.intPackageTypeId
		-- Appearance
		OUTER APPLY (
			SELECT TR.strPropertyValue
				,TR.dblPinpointValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Appearance'
			WHERE TR.intSampleId = S.intSampleId
			) APPEARANCE
		-- Hue
		OUTER APPLY (
			SELECT TR.strPropertyValue
				,TR.dblPinpointValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Hue'
			WHERE TR.intSampleId = S.intSampleId
			) HUE
		-- Intensity
		OUTER APPLY (
			SELECT TR.strPropertyValue
				,TR.dblPinpointValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Intensity'
			WHERE TR.intSampleId = S.intSampleId
			) INTENSITY
		-- Taste
		OUTER APPLY (
			SELECT TR.strPropertyValue
				,TR.dblPinpointValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Taste'
			WHERE TR.intSampleId = S.intSampleId
			) TASTE
		-- Mouth Feel
		OUTER APPLY (
			SELECT TR.strPropertyValue
				,TR.dblPinpointValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Mouth Feel'
			WHERE TR.intSampleId = S.intSampleId
			) MOUTH_FEEL
		--Moisture
		OUTER APPLY (
			SELECT TR.strPropertyValue
				,TR.dblPinpointValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Moisture'
			WHERE TR.intSampleId = S.intSampleId
			) MOISTURE
		--Volume
		OUTER APPLY (
			SELECT TR.strPropertyValue
				,TR.dblPinpointValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Volume'
			WHERE TR.intSampleId = S.intSampleId
			) VOLUME
		--Fines
		OUTER APPLY (
			SELECT TR.strPropertyValue
				,TR.dblPinpointValue
			FROM tblQMTestResult TR
			JOIN tblQMProperty P ON P.intPropertyId = TR.intPropertyId
				AND P.strPropertyName = 'Fines'
			WHERE TR.intSampleId = S.intSampleId
			) FINES
		-- Colour
		LEFT JOIN tblICCommodityAttribute COLOUR ON COLOUR.intCommodityAttributeId = S.intSeasonId
		-- Manufacturing Leaf Type
		LEFT JOIN tblICCommodityAttribute LEAF_TYPE ON LEAF_TYPE.intCommodityAttributeId = S.intManufacturingLeafTypeId
		-- Evaluator's Code at TBO
		LEFT JOIN tblEMEntity ECTBO ON ECTBO.intEntityId = S.intEvaluatorsCodeAtTBOId
		-- Leaf Category
		LEFT JOIN tblICCommodityAttribute2 LEAF_CATEGORY ON LEAF_CATEGORY.intCommodityAttributeId2 = S.intLeafCategoryId
		-- Sustainability / Rainforest
		LEFT JOIN tblICCommodityProductLine SUSTAINABILITY ON SUSTAINABILITY.intCommodityProductLineId = S.intProductLineId
		-- Grade
		LEFT JOIN tblICCommodityAttribute GRADE ON GRADE.intCommodityAttributeId = S.intGradeId
		-- Weight Item UOM
		LEFT JOIN tblICItemUOM WIUOM ON WIUOM.intItemId = S.intItemId AND WIUOM.intUnitMeasureId = S.intSampleUOMId
		-- Qty Item UOM
		LEFT JOIN tblICItemUOM QIUOM ON QIUOM.intItemId = S.intItemId AND QIUOM.intUnitMeasureId = S.intB1QtyUOMId
		WHERE S.intSampleId = @intSampleId
			AND IMP.intImportLogId = @intImportLogId
			AND IsNULL(S.dblB1QtyBought, 0) > 0

		DECLARE @intInput INT
			,@intInputSuccess INT

		IF EXISTS (
				SELECT *
				FROM @MFBatchTableType
				)
		BEGIN
			-- If the buyer 1 qty and price fields are blank, delete the existing batch
			IF ISNULL(@dblB1QtyBought, 0) = 0 AND ISNULL(@dblB1Price, 0) = 0
			BEGIN
				DECLARE @intToDeleteBatchLocationId INT

				SELECT
					@strBatchId = B.strBatchId
					,@intToDeleteBatchLocationId = S.intLocationId
				FROM tblQMSample S
				INNER JOIN tblMFBatch B ON B.intSampleId = S.intSampleId
				WHERE S.intSampleId = @intSampleId


				IF @strBatchId IS NOT NULL
				BEGIN
					-- Delete batch for both TBO and MU
					EXEC uspMFDeleteBatch
						@strBatchId = @strBatchId
						,@intLocationId = @intToDeleteBatchLocationId
						,@ysnSuccess = @ysnSuccess OUTPUT
						,@strErrorMessage = @strErrorMessage OUTPUT

					IF @ysnSuccess = 0
						UPDATE tblQMImportCatalogue
						SET ysnProcessed = 1, ysnSuccess = 0, strLogResult = @strErrorMessage
						WHERE intImportCatalogueId = @intImportCatalogueId
				END
			END
			-- Else create/update the batch and process feed as 
			ELSE
			BEGIN
				EXEC uspMFUpdateInsertBatch @MFBatchTableType
					,@intInput
					,@intInputSuccess
					,@strBatchId OUTPUT
					,0

				UPDATE B
				SET B.intLocationId = L.intCompanyLocationId
					,strBatchId = @strBatchId
					--,intSampleId = NULL
					,dblOriginalTeaTaste = dblTeaTaste
					,dblOriginalTeaHue = dblTeaHue
					,dblOriginalTeaIntensity = dblTeaIntensity
					,dblOriginalTeaMouthfeel = dblTeaMouthFeel
					,dblOriginalTeaAppearance = dblTeaAppearance
					,dblOriginalTeaVolume = dblTeaVolume
					,dblOriginalTeaMoisture = dblTeaMoisture
					,strPlant=L.strVendorRefNoPrefix
				FROM @MFBatchTableType B
				JOIN tblCTBook Bk ON Bk.intBookId = B.intBookId
				JOIN tblSMCompanyLocation L ON L.strLocationName = Bk.strBook


				EXEC uspMFUpdateInsertBatch @MFBatchTableType
					,@intInput
					,@intInputSuccess
					,NULL
					,1

				UPDATE tblQMSample
				SET strBatchNo = @strBatchId
				WHERE intSampleId = @intSampleId				
			END
			
			DECLARE @strRowState NVARCHAR(50)
			SELECT @strRowState = CASE WHEN intConcurrencyId > 1 THEN 'Modified' ELSE 'Added' END
			FROM tblQMSample
			WHERE intSampleId = @intSampleId

			EXEC uspIPProcessPriceToFeed
				@intEntityUserId
				,@intSampleId
				,'Sample'
				,@strRowState
		END

		CONT:
		FETCH NEXT
		FROM @C
		INTO @intImportCatalogueId
			,@intSampleId
			,@intEntityUserId
			,@intPurchasingGroupId
			,@strPurchasingGroup
			,@intBookId
			,@strBook
			,@intCurrencyId
			,@strCurrency
			,@ysnBought
			,@intSubBookId
			,@strBuyingOrderNumber
			-- B1
			,@dblB1QtyBought
			,@intB1QtyUOMId
			,@dblB1Price
			,@intB1PriceUOMId
			-- B2
			,@intBuyer2Id
			,@dblB2QtyBought
			,@intB2QtyUOMId
			,@dblB2Price
			,@intB2PriceUOMId
			-- B3
			,@intBuyer3Id
			,@dblB3QtyBought
			,@intB3QtyUOMId
			,@dblB3Price
			,@intB3PriceUOMId
			-- B4
			,@intBuyer4Id
			,@dblB4QtyBought
			,@intB4QtyUOMId
			,@dblB4Price
			,@intB4PriceUOMId
			-- B5
			,@intBuyer5Id
			,@dblB5QtyBought
			,@intB5QtyUOMId
			,@dblB5Price
			,@intB5PriceUOMId

			,@strPlantCode
			,@intFromLocationCodeId 
			,@intDestinationStorageLocationId 
	
	END

	CLOSE @C

	DEALLOCATE @C

	EXEC uspQMGenerateSampleCatalogueImportAuditLog
		@intUserEntityId = @intEntityUserId
		,@strRemarks = 'Updated from Initial Buy Import'
		,@ysnCreate = 0
		,@ysnBeforeUpdate = 0

	COMMIT TRANSACTION
END TRY

BEGIN CATCH
	DECLARE @strErrorMsg NVARCHAR(MAX) = NULL

	SET @strErrorMsg = ERROR_MESSAGE()

	ROLLBACK TRANSACTION

	RAISERROR (
			@strErrorMsg
			,11
			,1
			)
END CATCH
