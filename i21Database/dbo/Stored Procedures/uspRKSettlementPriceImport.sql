CREATE PROCEDURE [dbo].[uspRKSettlementPriceImport]
	@intEntityUserId VARCHAR (100) = NULL

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		, @strDateTimeFormat NVARCHAR(50)
		, @ConvertYear INT
		, @dtmPriceDate1 NVARCHAR(50)
		, @strMarket NVARCHAR(50) = NULL
		, @strSettlementDate NVARCHAR(50) = NULL
		, @intFutureMarketId INT = NULL
		, @intFutureSettlementPriceId int = NULL
		, @newlyCreatedIds NVARCHAR(MAX) = ''
	
	SELECT @strDateTimeFormat = strDateTimeFormat FROM tblRKCompanyPreference

	IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI' OR ISNULL(@strDateTimeFormat,'') = '')
		SELECT @ConvertYear = 101
	ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI')
		SELECT @ConvertYear = 103
		
	BEGIN TRAN

	DECLARE @mRowNumber INT
	SELECT ROW_NUMBER() OVER (ORDER BY strFutureMarket) intRowNum
		, strFutureMarket
	INTO #temp
	FROM (
		SELECT DISTINCT strFutureMarket FROM tblRKSettlementPriceImport
	) t
	
	SELECT @mRowNumber = MIN(intRowNum) FROM #temp
	WHILE @mRowNumber > 0
	BEGIN
		SELECT @strMarket = ''
			, @strSettlementDate = ''
			, @intFutureMarketId = NULL
			, @intFutureSettlementPriceId = NULL
		
		SELECT @strMarket = strFutureMarket
		FROM #temp WHERE intRowNum = @mRowNumber
		SELECT @strMarket = LTRIM(RTRIM(strFutureMarket))
			, @strSettlementDate = CONVERT(DATETIME, strPriceDate, @ConvertYear)
		FROM tblRKSettlementPriceImport
		WHERE strFutureMarket = @strMarket
		
		SELECT @intFutureMarketId = intFutureMarketId FROM tblRKFutureMarket WHERE strFutMarketName = @strMarket
		
		DECLARE @intCommodityMarketId INT = NULL
		SELECT @intCommodityMarketId = intCommodityMarketId FROM tblRKFutureMarket m
		JOIN tblRKCommodityMarketMapping mm ON m.intFutureMarketId = mm.intFutureMarketId
		WHERE m.intFutureMarketId = @intFutureMarketId
		
		INSERT INTO tblRKFuturesSettlementPrice(intFutureMarketId, dtmPriceDate, intConcurrencyId, intCommodityMarketId, strPricingType)
		VALUES(@intFutureMarketId, @strSettlementDate, 1, @intCommodityMarketId, 'Mark To Market')
		
		SELECT @intFutureSettlementPriceId = SCOPE_IDENTITY()
		
		SET @newlyCreatedIds = @newlyCreatedIds + CAST(@intFutureSettlementPriceId as NVARCHAR(50)) + ','
		
		--Insert Futures Month settlement Price	
		INSERT INTO tblRKFutSettlementPriceMarketMap (intConcurrencyId, intFutureSettlementPriceId, intFutureMonthId, dblLastSettle, dblLow, dblHigh, strComments)
		SELECT 1, @intFutureSettlementPriceId, intFutureMonthId, dblLastSettle, dblLow, dblHigh, strFutComments
		FROM tblRKSettlementPriceImport i
		JOIN tblRKFuturesMonth fm ON fm.strFutureMonth = REPLACE(i.strFutureMonth, '-', ' ') AND intFutureMarketId = @intFutureMarketId
		WHERE strInstrumentType = 'Futures' AND strFutureMarket = @strMarket
		
		-- Insert Options Month settlement Price
		INSERT INTO tblRKOptSettlementPriceMarketMap (intConcurrencyId, intFutureSettlementPriceId, intOptionMonthId, dblStrike, intTypeId, dblSettle, dblDelta, strComments)
		SELECT 1
			, @intFutureSettlementPriceId
			, intOptionMonthId
			, dblStrike
			, CASE WHEN strType = 'Put' THEN 1 WHEN strType = 'Call' THEN 2 ELSE 0 END
			, dblSettle
			, dblDelta
			, strFutComments
		FROM tblRKSettlementPriceImport i
		JOIN tblRKOptionsMonth fm ON fm.strOptionMonth = REPLACE(i.strFutureMonth, '-', ' ') AND intFutureMarketId = @intFutureMarketId
		WHERE strInstrumentType LIKE 'Opt%' AND strFutureMarket = @strMarket
		
		EXEC uspSMAuditLog @keyValue = @intFutureSettlementPriceId
			, @screenName = 'RiskManagement.view.FuturesOptionsSettlementPrices'
			, @entityId = @intEntityUserId
			, @actionType = 'Imported'
			, @changeDescription = ''
			, @fromValue = ''
			, @toValue = ''
		
		SELECT @mRowNumber = MIN(intRowNum)	FROM #temp WHERE intRowNum > @mRowNumber
	END

	COMMIT TRAN
	
	SELECT FM.strFutMarketName AS Result1
		, SP.strPricingType AS Result2
		, SP.dtmPriceDate AS Result3
		, strFutureMonth Result4
		, 'Futures' Result5
	FROM tblRKFuturesSettlementPrice SP
	INNER JOIN tblRKFutSettlementPriceMarketMap MM ON MM.intFutureSettlementPriceId = SP.intFutureSettlementPriceId
	INNER JOIN tblRKFutureMarket FM ON SP.intFutureMarketId = FM.intFutureMarketId 
	INNER JOIN tblRKFuturesMonth MO ON MO.intFutureMonthId = MM.intFutureMonthId
	WHERE MM.intFutureSettlementPriceId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@newlyCreatedIds))
	
	UNION ALL SELECT FM.strFutMarketName AS Result1
		, SP.strPricingType AS Result2
		, SP.dtmPriceDate AS Result3
		, strOptionMonth Result4
		, 'Options' Result5
	FROM tblRKFuturesSettlementPrice SP 
	INNER JOIN tblRKOptSettlementPriceMarketMap MM ON MM.intFutureSettlementPriceId = SP.intFutureSettlementPriceId
	INNER JOIN tblRKFutureMarket FM ON SP.intFutureMarketId = FM.intFutureMarketId 
	INNER JOIN tblRKOptionsMonth MO ON MO.intOptionMonthId = MM.intOptionMonthId
	WHERE MM.intFutureSettlementPriceId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@newlyCreatedIds)) 
END TRY
BEGIN CATCH
	IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
END CATCH