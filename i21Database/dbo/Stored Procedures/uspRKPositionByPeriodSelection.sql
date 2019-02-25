CREATE PROCEDURE [dbo].[uspRKPositionByPeriodSelection]
	@intCommodityId NVARCHAR(MAX)
	, @intCompanyLocationId NVARCHAR(MAX)
	, @intQuantityUOMId INT
	, @intUnitMeasureId INT
	, @intCurrencyID INT
	, @strGroupings NVARCHAR(100) = ''
	, @dtmDate1 DATETIME = NULL
	, @dtmDate2 DATETIME = NULL
	, @dtmDate3 DATETIME = NULL
	, @dtmDate4 DATETIME = NULL
	, @dtmDate5 DATETIME = NULL
	, @dtmDate6 DATETIME = NULL
	, @dtmDate7 DATETIME = NULL
	, @dtmDate8 DATETIME = NULL
	, @dtmDate9 DATETIME = NULL
	, @dtmDate10 DATETIME = NULL
	, @dtmDate11 DATETIME = NULL
	, @dtmDate12 DATETIME = NULL
	, @ysnSummary BIT = NULL
	, @intItemId INT = NULL
	, @ysnCanadianCustomer BIT = NULL

AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY

	DECLARE @ysnSubCurrency INT
		, @intMainCurrencyId INT
		, @intCurrencyID1 INT

	SELECT @ysnSubCurrency = ysnSubCurrency
		, @intMainCurrencyId = intMainCurrencyId
	FROM tblSMCurrency WHERE intCurrencyID = @intCurrencyID

	IF (ISNULL(@ysnSubCurrency, 0) = 1)
	BEGIN
		SET @intCurrencyID1 = @intMainCurrencyId
	END
	ELSE
	BEGIN
		SET @intCurrencyID1 = @intCurrencyID
	END

	DECLARE @MonthList AS TABLE (intRowNumber INT
		, dtmMonth NVARCHAR(15))
	
	INSERT INTO @MonthList
	SELECT intRowNumber
		, dtmMonth
	FROM(
		SELECT 1 AS intRowNumber, RIGHT(CONVERT(VARCHAR(11),@dtmDate1,106),8) dtmMonth
		UNION ALL SELECT 2 AS intRowNumber, RIGHT(CONVERT(VARCHAR(11),@dtmDate2,106),8) dtmMonth
		UNION ALL SELECT 3 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate3,106),8) dtmMonth
		UNION ALL SELECT 4 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate4,106),8) dtmMonth
		UNION ALL SELECT 5 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate5,106),8) dtmMonth
		UNION ALL SELECT 6 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate6,106),8) dtmMonth
		UNION ALL SELECT 7 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate7,106),8) dtmMonth
		UNION ALL SELECT 8 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate8,106),8) dtmMonth
		UNION ALL SELECT 9 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate9,106),8) dtmMonth
		UNION ALL SELECT 10 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate10,106),8) dtmMonth
		UNION ALL SELECT 11 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate11,106),8) dtmMonth
		UNION ALL SELECT 12 AS intRowNumber,RIGHT(CONVERT(VARCHAR(11),@dtmDate12,106),8) dtmMonth)t
	
	DELETE FROM @MonthList WHERE ISNULL(dtmMonth, '') = ''
	
	DECLARE @strCurrencyName NVARCHAR(MAX)
		
	SELECT TOP 1 @strCurrencyName = strCurrency
	FROM tblSMCurrency
	WHERE intCurrencyID = @intCurrencyID1
	
	DECLARE @List AS TABLE (intRowNumber INT IDENTITY PRIMARY KEY
		, strCommodity NVARCHAR(200)
		, strHeaderValue NVARCHAR(200)
		, strSubHeading NVARCHAR(200)
		, strSecondSubHeading NVARCHAR(200)
		, strContractEndMonth NVARCHAR(100)
		, strContractBasis NVARCHAR(200)
		, dblBalance DECIMAL(24,10)
		, strMarketZoneCode NVARCHAR(200)
		, dblFuturesPrice DECIMAL(24,10)
		, dblBasisPrice DECIMAL(24,10)
		, dblCashPrice DECIMAL(24,10)
		, dblWtAvgPriced DECIMAL(24,10)
		, dblQuantity DECIMAL(24,10)
		, strLocationName NVARCHAR(200)
		, strContractNumber NVARCHAR(200)
		, strItemNo NVARCHAR(200)
		, intOrderByOne INT
		, intOrderByTwo INT
		, intOrderByThree INT
		, dblRate DECIMAL(24,10)
		, ExRate DECIMAL(24,10)
		, strCurrencyExchangeRateType NVARCHAR(200)
		, intContractHeaderId INT
		, intFutOptTransactionHeaderId INT)
	
	DECLARE @FinalList AS TABLE (intRowNumber INT
		, strCommodity NVARCHAR(200)
		, strHeaderValue NVARCHAR(200)
		, strSubHeading NVARCHAR(200)
		, strSecondSubHeading NVARCHAR(200)
		, strContractEndMonth NVARCHAR(100)
		, strContractBasis NVARCHAR(200)
		, dblBalance DECIMAL(24,10)
		, strMarketZoneCode NVARCHAR(200)
		, dblFuturesPrice DECIMAL(24,10)
		, dblBasisPrice DECIMAL(24,10)
		, dblCashPrice DECIMAL(24,10)
		, dblWtAvgPriced DECIMAL(24,10)
		, dblQuantity DECIMAL(24,10)
		, strLocationName NVARCHAR(200)
		, strContractNumber NVARCHAR(200)
		, strItemNo NVARCHAR(200)
		, intOrderByOne INT
		, intOrderByTwo INT
		, intOrderByThree INT
		, dblRate DECIMAL(24,10)
		, ExRate DECIMAL(24,10)
		, strCurrencyExchangeRateType NVARCHAR(200)
		, intContractHeaderId INT
		, intFutOptTransactionHeaderId INT)
	
	SELECT intCommodityId = CAST(Item as INT)
	INTO #CommodityList
	FROM [dbo].[fnSplitString](@intCommodityId, ',')
	WHERE CAST(Item as INT) <> 0

	SELECT intCompanyLocationId = CAST(Item AS INT)
	INTO #CompanyLocationList
	FROM [dbo].[fnSplitString](@intCompanyLocationId, ',')
	WHERE CAST(Item as INT) <> 0

	DECLARE @ContractRateDetail AS TABLE (intContractDetailId INT
		, dblExRate NUMERIC(24,10))

	INSERT INTO @ContractRateDetail (intContractDetailId, dblExRate)
	SELECT cd.intContractDetailId
		, (CASE WHEN (@intCurrencyID1 <> c1.intCurrencyID AND @intCurrencyID1 <> c.intCurrencyID) THEN NULL
				WHEN @intCurrencyID1 = c1.intCurrencyID THEN (1 / ISNULL(cd.dblRate, 1))
				ELSE (CASE WHEN ISNULL(cd.dblRate, 0) = 0 THEN ISNULL(RD.dblRate, 0)
							ELSE ISNULL(cd.dblRate, 0) END) END)
	FROM vyuRKPositionByPeriodContDetView cd
	JOIN tblSMCurrencyExchangeRate et ON cd.intCurrencyExchangeRateId = et.intCurrencyExchangeRateId 
	JOIN tblSMCurrency c ON et.intFromCurrencyId = c.intCurrencyID
	JOIN tblSMCurrency c1 ON et.intToCurrencyId = c1.intCurrencyID
	LEFT JOIN tblSMCurrencyExchangeRateDetail RD ON RD.intCurrencyExchangeRateId = et.intCurrencyExchangeRateId
	WHERE cd.intCommodityId IN (SELECT intCommodityId FROM #CommodityList) AND dblBalance > 0
	
	DECLARE @ContractCost AS TABLE (intContractDetailId INT
		, dblRate NUMERIC(24,10))

	INSERT INTO @ContractCost (intContractDetailId, dblRate)
	SELECT intContractDetailId
		, SUM(dblRate)
	FROM (
		SELECT ccv.intContractDetailId
			, dblRate = dbo.[fnRKGetCurrencyConversionRate](ccv.intContractDetailId
														, @intCurrencyID1
														, @intUnitMeasureId
														, SUM(dblAmountPer)
														, CASE WHEN ccv.strCostMethod = 'Percentage' THEN cd.intCurrencyId ELSE ccv.intCurrencyId END)
		FROM vyuRKPositionByPeriodContDetView cd
		JOIN vyuCTContractCostView ccv ON cd.intContractDetailId = ccv.intContractDetailId
		JOIN vyuCTContractCostEnquiryCost cv ON cv.intContractCostId = ccv.intContractCostId
		WHERE ccv.strItemNo = 'Freight'
			AND (ISNULL(ysnAccrue, 0) = 1 OR (ISNULL(ysnAccrue, 0) = 0 AND ISNULL(ysnPrice, 0) = 0 AND ISNULL(ysnBasis, 0) = 0))
			AND cd.intCommodityId IN (SELECT intCommodityId FROM #CommodityList)
			AND dblBalance > 0
		GROUP BY ccv.intCurrencyId
			, ccv.strCostMethod
			, ccv.intContractDetailId
			, cd.intCurrencyId
	) t GROUP BY intContractDetailId

	-- Priced Contract	
	IF @strGroupings = 'Contract Terms'
	BEGIN
		INSERT INTO @List(strCommodity
			, strSubHeading
			, strSecondSubHeading
			, strContractEndMonth
			, strContractBasis
			, dblBalance
			, strMarketZoneCode
			, dblFuturesPrice
			, dblBasisPrice
			, dblCashPrice
			, dblRate
			, strLocationName
			, strContractNumber
			, ExRate
			, strCurrencyExchangeRateType
			, intContractHeaderId
			, intFutOptTransactionHeaderId)
		SELECT strCommodity = strCommodityCode
			, strContractType + '-' + cd.strPricingType + ' - ' + ISNULL(strContractBasis, '')
			, CASE WHEN CH.intContractTypeId = 1 THEN 'Purchase Quantity' ELSE 'Sale Quantity' END
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), dtmEndDate, 106), 8)
			, strContractBasis
			, Balance = SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(dblBalance, 0)), 0))
			, strMarketZoneCode
			, dblFuturesPrice = ISNULL(cd.dblFutureRate, 0)
			, dblBasisPrice = (CASE WHEN ISNULL(cd.intPricingTypeId, 0) = 3 THEN 0
									ELSE (CASE WHEN ISNULL(@ysnCanadianCustomer,0) = 1 THEN ISNULL(cd.dblCashRate, 0) - ISNULL(cd.dblFutures, 0)
												ELSE ISNULL(cd.dblBasisRate, 0) END) END)
			, dblCashPrice = ISNULL(cd.dblCashRate, 0)
			, dblRate = (SELECT TOP 1 cc.dblRate FROM @ContractCost cc WHERE cd.intContractDetailId = cc.intContractDetailId)
			, strLocationName
			, strContractNumber = cd.strContractNumber + ' - ' + CONVERT(NVARCHAR, intContractSeq)
			, ExRate = (SELECT TOP 1 a.dblExRate FROM @ContractRateDetail a WHERE a.intContractDetailId = cd.intContractDetailId)
			, strCurrencyExchangeRateType = dbo.fnRKGetCurrencyExchangeRateType(cd.intContractDetailId)
			, CH.intContractHeaderId
			, intFutOptTransactionHeaderId = NULL
		FROM (SELECT MainView.*
				, MainCurrency.ysnSubCurrency
				, dblCashRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) END
				, dblBasisRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) END
				, dblFutureRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) END
			FROM vyuRKPositionByPeriodContDetView MainView
			JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = MainView.intCurrencyId) cd
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId AND cd.intContractStatusId <> 3
		JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = cd.intCommodityId AND ium1.intUnitMeasureId = @intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId AND cd.intPricingTypeId IN (1, 2, 3, 5)
		WHERE CH.intCommodityId in (SELECT intCommodityId FROM #CommodityList)
			AND dblBalance > 0
			AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #CompanyLocationList)
			ANd cd.intItemId = ISNULL(@intItemId, cd.intItemId)
		GROUP BY strCommodityCode
			, strLocationName
			, cd.strContractNumber
			, cd.intContractSeq
			, RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8)
			, strContractType
			, cd.intCurrencyId
			, cd.intItemId
			, cd.intPriceUnitMeasureId
			, strMarketZoneCode
			, strContractBasis
			, ISNULL(cd.dblFutureRate, 0)
			, ISNULL(cd.dblBasisRate, 0)
			, ISNULL(cd.dblCashRate, 0)
			, cd.dblFutures
			, CH.intContractTypeId
			, cd.intPricingTypeId
			, cd.strPricingType
			, cd.intContractDetailId
			, CH.intContractHeaderId
			, cd.ysnSubCurrency
			, cd.dblRate
		
		INSERT INTO @List(strCommodity
			, strSubHeading
			, strSecondSubHeading
			, strContractEndMonth
			, dblBalance
			, strMarketZoneCode
			, dblFuturesPrice
			, dblBasisPrice
			, dblCashPrice
			, strLocationName
			, strContractNumber
			, ExRate
			, strCurrencyExchangeRateType
			, intContractHeaderId
			, intFutOptTransactionHeaderId)
		SELECT strCommodity
			, CASE WHEN strSecondSubHeading = 'Purchase Quantity' THEN 'Purchase Total' ELSE 'Sale Total' END
			, CASE WHEN strSecondSubHeading = 'Purchase Quantity' THEN 'Purchase Total' ELSE 'Sale Total' END
			, strContractEndMonth
			, dblBalance
			, strMarketZoneCode
			, dblFuturesPrice
			, dblBasisPrice
			, dblCashPrice
			, strLocationName
			, strContractNumber
			, ExRate
			, strCurrencyExchangeRateType
			, intContractHeaderId
			, intFutOptTransactionHeaderId 
		FROM @List
		WHERE strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity'
	END

	IF @strGroupings= 'Market Zone'
	BEGIN
		INSERT INTO @List(strCommodity
			,strSubHeading
			,strSecondSubHeading
			,strContractEndMonth
			,dblBalance
			,strMarketZoneCode
			,dblFuturesPrice
			,dblBasisPrice
			,dblCashPrice
			,dblRate
			,strLocationName
			,strContractNumber
			,ExRate
			,strCurrencyExchangeRateType
			,intContractHeaderId
			,intFutOptTransactionHeaderId)
		SELECT strCommodity = strCommodityCode
			, strContractType + '-' + cd.strPricingType + ' - ' + ISNULL(strMarketZoneCode, '')
			, CASE WHEN CH.intContractTypeId = 1 THEN 'Purchase Quantity' ELSE 'Sale Quantity' END
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), dtmEndDate, 106), 8)
			, Balance = SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId,ium1.intCommodityUnitMeasureId,ISNULL(dblBalance,0)),0))
			, strMarketZoneCode
			, dblFuturesPrice = ISNULL(cd.dblFutureRate, 0)
			, dblBasisPrice = (CASE WHEN ISNULL(cd.intPricingTypeId, 0) = 3 THEN 0
									ELSE (CASE WHEN ISNULL(@ysnCanadianCustomer,0) = 1 THEN ISNULL(cd.dblCashRate, 0) - ISNULL(cd.dblFutures, 0)
											ELSE ISNULL(cd.dblBasisRate, 0) END) END)
			, dblCashPrice = ISNULL(cd.dblCashRate, 0)
			, dblRate = (SELECT TOP 1 cc.dblRate FROM @ContractCost cc WHERE cd.intContractDetailId = cc.intContractDetailId)
			, strLocationName
			, strContractNumber = cd.strContractNumber + ' - ' + CONVERT(NVARCHAR, intContractSeq)
			, ExRate = (SELECT TOP 1 a.dblExRate FROM @ContractRateDetail a WHERE a.intContractDetailId = cd.intContractDetailId)
			, strCurrencyExchangeRateType = dbo.fnRKGetCurrencyExchangeRateType(cd.intContractDetailId)
			, CH.intContractHeaderId
			, intFutOptTransactionHeaderId = NULL
		FROM (SELECT MainView.*
				, MainCurrency.ysnSubCurrency
				, dblCashRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) END
				, dblBasisRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) END
				, dblFutureRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) END
			FROM vyuRKPositionByPeriodContDetView MainView
			JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = MainView.intCurrencyId) cd
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId AND cd.intContractStatusId <> 3
		JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = cd.intCommodityId AND ium1.intUnitMeasureId = @intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId AND cd.intPricingTypeId IN (1, 2, 3, 5)
		WHERE CH.intCommodityId IN (SELECT intCommodityId FROM #CommodityList)
			AND dblBalance > 0
			AND cd.intCompanyLocationId IN (SELECT intCompanyLocationId FROM #CompanyLocationList)
			AND cd.intItemId = ISNULL(@intItemId, cd.intItemId)
		GROUP BY strCommodityCode
			,strLocationName
			,cd.strContractNumber
			,cd.intContractSeq
			,RIGHT(CONVERT(VARCHAR(11),dtmEndDate,106),8)
			,strContractType
			,cd.intCurrencyId
			,cd.intItemId
			,cd.intPriceUnitMeasureId
			,strMarketZoneCode
			, ISNULL(cd.dblFutureRate, 0)
			, ISNULL(cd.dblBasisRate, 0)
			, ISNULL(cd.dblCashRate, 0)
			, cd.dblFutures
			,CH.intContractTypeId
			,cd.intPricingTypeId
			,cd.strPricingType
			,cd.intContractDetailId
			,CH.intContractHeaderId
			,cd.ysnSubCurrency
			,cd.dblRate

		INSERT INTO @List(strCommodity
			, strSubHeading
			, strSecondSubHeading
			, strContractEndMonth
			, dblBalance
			, strMarketZoneCode
			, dblFuturesPrice
			, dblBasisPrice
			, dblCashPrice
			, dblRate
			, strLocationName
			, strContractNumber
			, ExRate
			, strCurrencyExchangeRateType
			, intContractHeaderId
			, intFutOptTransactionHeaderId)
		SELECT strCommodity
			, CASE WHEN strSecondSubHeading = 'Purchase Quantity' THEN 'Purchase Total' ELSE 'Sale Total' END
			, CASE WHEN strSecondSubHeading = 'Purchase Quantity' THEN 'Purchase Total' ELSE 'Sale Total' END
			, strContractEndMonth
			, dblBalance
			, strMarketZoneCode
			, dblFuturesPrice
			, dblBasisPrice
			, dblCashPrice
			, dblRate
			, strLocationName
			, strContractNumber
			, ExRate
			, strCurrencyExchangeRateType
			, intContractHeaderId
			, intFutOptTransactionHeaderId
		FROM @List
		WHERE strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity'
	END

	IF @strGroupings= 'Market Zone and Contract Terms'
	BEGIN
		INSERT INTO @List(strCommodity
			, strSubHeading
			, strSecondSubHeading
			, strContractEndMonth
			, strContractBasis
			, dblBalance
			, strMarketZoneCode
			, dblFuturesPrice
			, dblBasisPrice
			, dblCashPrice
			, dblRate
			, strLocationName
			, strContractNumber
			, ExRate
			, strCurrencyExchangeRateType
			, intContractHeaderId
			, intFutOptTransactionHeaderId)
		SELECT strCommodity = strCommodityCode
		, strContractType + '-' + cd.strPricingType + ' - ' + ISNULL(strContractBasis, '') + ' - ' + ISNULL(strMarketZoneCode, '')
		, CASE WHEN CH.intContractTypeId = 1 THEN 'Purchase Quantity' ELSE 'Sale Quantity' END
		, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), dtmEndDate, 106), 8)
		, strContractBasis
		, Balance = SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(dblBalance, 0)), 0))
		, strMarketZoneCode
		, dblFuturesPrice = ISNULL(cd.dblFutureRate, 0)
		, dblBasisPrice = (CASE WHEN ISNULL(cd.intPricingTypeId, 0) = 3 THEN 0
								ELSE (CASE WHEN ISNULL(@ysnCanadianCustomer, 0) = 1 THEN ISNULL(cd.dblCashRate, 0) - ISNULL(cd.dblFutures, 0)
										ELSE ISNULL(cd.dblBasisRate, 0) END) END)
		, dblCashPrice = ISNULL(cd.dblCashRate, 0)
		, dblRate = (SELECT TOP 1 cc.dblRate FROM @ContractCost cc WHERE cd.intContractDetailId=cc.intContractDetailId)
		, strLocationName
		, strContractNumber = cd.strContractNumber + ' - ' + CONVERT(NVARCHAR, intContractSeq)
		, ExRate = (SELECT TOP 1 a.dblExRate FROM @ContractRateDetail a WHERE a.intContractDetailId=cd.intContractDetailId)
		, strCurrencyExchangeRateType = dbo.fnRKGetCurrencyExchangeRateType(cd.intContractDetailId)
		, CH.intContractHeaderId
		, intFutOptTransactionHeaderId = NULL
		FROM (SELECT MainView.*
				, MainCurrency.ysnSubCurrency
				, dblCashRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) END
				, dblBasisRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) END
				, dblFutureRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) END
			FROM vyuRKPositionByPeriodContDetView MainView
			JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = MainView.intCurrencyId) cd
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId AND cd.intContractStatusId <> 3
		JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = cd.intCommodityId AND ium1.intUnitMeasureId=@intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId AND cd.intPricingTypeId IN (1, 2, 3, 5)
		WHERE CH.intCommodityId in (SELECT intCommodityId FROM #CommodityList)
			AND dblBalance > 0
			AND cd.intCompanyLocationId in (SELECT intCompanyLocationId FROM #CompanyLocationList)
			AND cd.intItemId = ISNULL(@intItemId, cd.intItemId)
		GROUP BY strCommodityCode
			, strLocationName
			, cd.strContractNumber
			, cd.intContractSeq
			, RIGHT(CONVERT(VARCHAR(11), dtmEndDate, 106), 8)
			, strContractType
			, cd.intCurrencyId
			, cd.intItemId
			, cd.intPriceUnitMeasureId
			, strMarketZoneCode
			, strContractBasis
			, ISNULL(cd.dblFutureRate, 0)
			, ISNULL(cd.dblBasisRate, 0)
			, ISNULL(cd.dblCashRate, 0)
			, cd.dblFutures
			, cd.dblRate
			, CH.intContractTypeId
			, cd.intPricingTypeId
			, cd.strPricingType
			, cd.intContractDetailId
			, CH.intContractHeaderId
			, cd.ysnSubCurrency
		
		INSERT INTO @List(strCommodity
			, strSubHeading
			, strSecondSubHeading
			, strContractEndMonth
			, dblBalance
			, strMarketZoneCode
			, dblFuturesPrice
			, dblBasisPrice
			, dblCashPrice
			, dblRate
			, strLocationName
			, strContractNumber
			, ExRate
			, strCurrencyExchangeRateType
			, intContractHeaderId
			, intFutOptTransactionHeaderId)
		SELECT strCommodity
			, CASE WHEN strSecondSubHeading = 'Purchase Quantity' THEN 'Purchase Total' ELSE 'Sale Total' END
			, CASE WHEN strSecondSubHeading = 'Purchase Quantity' THEN 'Purchase Total' ELSE 'Sale Total' END
			, strContractEndMonth
			, dblBalance
			, strMarketZoneCode
			, dblFuturesPrice
			, dblBasisPrice
			, dblCashPrice
			, dblRate
			, strLocationName
			, strContractNumber
			, ExRate
			, strCurrencyExchangeRateType
			, intContractHeaderId
			, intFutOptTransactionHeaderId
		FROM @List
		WHERE strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity'
	END

	IF @strGroupings= 'By Item' 
	BEGIN
		INSERT INTO @List(strCommodity
			, strSubHeading
			, strSecondSubHeading
			, strContractEndMonth
			, dblBalance
			, strMarketZoneCode
			, dblFuturesPrice
			, dblBasisPrice
			, dblCashPrice
			, dblRate
			, strLocationName
			, strContractNumber
			, strItemNo
			, ExRate
			, strCurrencyExchangeRateType
			, intContractHeaderId
			, intFutOptTransactionHeaderId)
		SELECT strCommodity = strCommodityCode
			, strContractType + '-' + cd.strPricingType + ' - ' + strItemNo
			, CASE WHEN CH.intContractTypeId = 1 THEN 'Purchase Quantity' ELSE 'Sale Quantity' END
			, strContractEndMonth = RIGHT(CONVERT(VARCHAR(11), dtmEndDate, 106), 8)
			, Balance = SUM(ISNULL(dbo.fnCTConvertQuantityToTargetCommodityUOM(ium.intCommodityUnitMeasureId, ium1.intCommodityUnitMeasureId, ISNULL(dblBalance, 0)), 0))
			, strMarketZoneCode
			, dblFuturesPrice = ISNULL(cd.dblFutureRate, 0)
			, dblBasisPrice = (CASE WHEN ISNULL(cd.intPricingTypeId, 0) = 3 THEN 0
									ELSE (CASE WHEN (ISNULL(@ysnCanadianCustomer, 0) = 0 AND ISNULL(cd.dblFutures, 0) <> 0) THEN ISNULL(cd.dblCashRate, 0) - ISNULL(cd.dblFutures, 0)
												ELSE ISNULL(cd.dblBasisRate, 0) END) END)
			, dblCashPrice = ISNULL(cd.dblCashRate, 0)
			, dblRate = (SELECT TOP 1 cc.dblRate FROM @ContractCost cc WHERE cd.intContractDetailId=cc.intContractDetailId)
			, strLocationName
			, strContractNumber = cd.strContractNumber + ' - ' + CONVERT(NVARCHAR, intContractSeq)
			, strItemNo
			, ExRate = (SELECT TOP 1 a.dblExRate FROM @ContractRateDetail a WHERE a.intContractDetailId=cd.intContractDetailId)
			, strCurrencyExchangeRateType = dbo.fnRKGetCurrencyExchangeRateType(cd.intContractDetailId)
			, CH.intContractHeaderId
			, intFutOptTransactionHeaderId = NULL
		FROM (SELECT MainView.*
				, MainCurrency.ysnSubCurrency
				, dblCashRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblCashPrice, 0), NULL) END
				, dblBasisRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblBasis, 0), NULL) END
				, dblFutureRate = CASE WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100
									WHEN MainCurrency.ysnSubCurrency = 1 AND ISNULL(@ysnSubCurrency, 0) = 0
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100 / 100
									WHEN MainCurrency.ysnSubCurrency = 0 AND ISNULL(@ysnSubCurrency, 0) = 1
										THEN dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) * 100
									ELSE dbo.[fnRKGetCurrencyConversionRate](MainView.intContractDetailId, @intCurrencyID1, @intUnitMeasureId, ISNULL(MainView.dblFutures, 0), NULL) END
			FROM vyuRKPositionByPeriodContDetView MainView
			JOIN tblSMCurrency MainCurrency ON MainCurrency.intCurrencyID = MainView.intCurrencyId) cd
		JOIN tblICCommodityUnitMeasure ium ON ium.intCommodityId = cd.intCommodityId AND cd.intUnitMeasureId = ium.intUnitMeasureId AND cd.intContractStatusId <> 3
		JOIN tblICCommodityUnitMeasure ium1 ON ium1.intCommodityId = cd.intCommodityId AND ium1.intUnitMeasureId = @intQuantityUOMId
		INNER JOIN tblCTContractHeader CH ON CH.intContractHeaderId = cd.intContractHeaderId
		INNER JOIN tblCTPricingType PT ON PT.intPricingTypeId = cd.intPricingTypeId AND cd.intPricingTypeId IN (1, 2, 3, 5)
		WHERE CH.intCommodityId in (SELECT intCommodityId FROM #CommodityList)
			AND dblBalance > 0
			AND cd.intCompanyLocationId in (SELECT intCompanyLocationId FROM #CompanyLocationList)
			AND cd.intItemId = ISNULL(@intItemId, cd.intItemId)
		GROUP BY CH.intContractTypeId
			, strCommodityCode
			, strLocationName
			, cd.strContractNumber
			, cd.intContractSeq
			, RIGHT(CONVERT(VARCHAR(11), dtmEndDate, 106), 8)
			, strContractType
			, cd.intCurrencyId
			, cd.intItemId
			, cd.intPriceUnitMeasureId
			, strMarketZoneCode
			, strItemNo
			, ISNULL(cd.dblFutureRate, 0)
			, ISNULL(cd.dblBasisRate, 0)
			, ISNULL(cd.dblCashRate, 0)
			, cd.dblFutures
			, CH.intContractTypeId
			, cd.intPricingTypeId
			, cd.strPricingType
			, cd.intContractDetailId
			, CH.intContractHeaderId
			, cd.ysnSubCurrency
			, cd.dblRate
		ORDER BY CH.intContractTypeId
			, cd.intPricingTypeId
			
		INSERT INTO @List(strCommodity
			,strSubHeading
			,strSecondSubHeading
			,strContractEndMonth
			,dblBalance
			,strMarketZoneCode
			,dblFuturesPrice
			,dblBasisPrice
			,dblCashPrice
			,dblRate
			,strLocationName
			,strContractNumber
			,ExRate
			,strCurrencyExchangeRateType
			,intContractHeaderId
			,intFutOptTransactionHeaderId)
		SELECT strCommodity
			, CASE WHEN strSecondSubHeading = 'Purchase Quantity' THEN 'Purchase Total' ELSE 'Sale Total' END
			, CASE WHEN strSecondSubHeading = 'Purchase Quantity' THEN 'Purchase Total' ELSE 'Sale Total' END
			,strContractEndMonth
			,dblBalance
			,strMarketZoneCode
			,dblFuturesPrice
			,dblBasisPrice
			,dblCashPrice
			,dblRate
			,strLocationName
			,strContractNumber
			,ExRate
			,strCurrencyExchangeRateType
			,intContractHeaderId
			,intFutOptTransactionHeaderId
		FROM @List
		WHERE strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity'
	END


	----------------------- Futures

	INSERT INTO @List(strCommodity
		,strHeaderValue
		,strSubHeading
		,strSecondSubHeading
		,strContractEndMonth
		,dblBalance
		,dblFuturesPrice
		,strContractNumber
		,strLocationName
		,intContractHeaderId
		,intFutOptTransactionHeaderId)
	SELECT DISTINCT strCommodityCode
		, strHeaderValue = 'Futures - Long'
		, strSubHeading = 'Futures - Long'
		, strSecondSubHeading = 'Futures - Long'
		, strFutureMonth
		, intOpenContract = (dblNoOfContract - ISNULL(intOpenContract, 0)) * dblContractSize
		, dblPrice
		, strInternalTradeNo
		, strLocationName
		, intContractHeaderId
		, intFutOptTransactionHeaderId 
	FROM (
		SELECT ot.intFutOptTransactionId
			, ot.strInternalTradeNo
			, dblNoOfContract = SUM(ot.dblNoOfContract)
			, strFutureMonth = RIGHT(CONVERT(VARCHAR(11), dtmFutureMonthsDate, 106), 8)
			, ot.dblPrice
			, strCommodityCode
			, intOpenContract = (SELECT SUM(CONVERT(INT, mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf WHERE ot.intFutOptTransactionId = mf.intLFutOptTransactionId)
			, strLocationName
			, dblContractSize
			, intContractHeaderId = NULL
			, ot.intFutOptTransactionHeaderId
		FROM tblRKFutOptTransaction ot
		JOIN tblRKFutureMarket m ON ot.intFutureMarketId = m.intFutureMarketId
		JOIN tblRKFuturesMonth fm ON ot.intFutureMonthId = fm.intFutureMonthId AND ysnExpired = 0
		JOIN tblICCommodity c ON ot.intCommodityId = c.intCommodityId
		JOIN tblSMCompanyLocation l ON ot.intLocationId = l.intCompanyLocationId
		WHERE ot.strBuySell = 'Buy'
			AND ot.intCommodityId in (SELECT intCommodityId FROM #CommodityList)
			AND ot.intLocationId in (SELECT intCompanyLocationId FROM #CompanyLocationList)
		GROUP BY intFutOptTransactionId
			, strCommodityCode
			, strLocationName
			, strInternalTradeNo
			, RIGHT(CONVERT(VARCHAR(11), dtmFutureMonthsDate, 106), 8)
			, dblPrice
			, dblContractSize
			, ot.intFutOptTransactionHeaderId) t

	------------------ short 
	INSERT INTO @List(strCommodity
		,strHeaderValue
		,strSubHeading
		,strSecondSubHeading
		,strContractEndMonth
		,dblBalance
		,dblFuturesPrice
		,strContractNumber
		,strLocationName
		,intContractHeaderId
		,intFutOptTransactionHeaderId)
	SELECT DISTINCT strCommodityCode
		, strHeaderValue = 'Futures - Short'
		, strSubHeading = 'Futures - Short'
		, strSecondSubHeading = 'Futures - Short'
		, strFutureMonth
		, intOpenContract = - (dblNoOfContract - ISNULL(dblNoOfContract, 0)) * dblContractSize
		, dblPrice
		, strInternalTradeNo
		, strLocationName
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM (
		SELECT ot.intFutOptTransactionId
			, ot.strInternalTradeNo
			, dblNoOfContract = SUM(ot.dblNoOfContract)
			, strFutureMonth = RIGHT(CONVERT(VARCHAR(11), dtmFutureMonthsDate, 106), 8)
			, ot.dblPrice
			, strCommodityCode
			, intOpenContract = (SELECT SUM(CONVERT(INT, mf.dblMatchQty)) FROM tblRKMatchFuturesPSDetail mf WHERE ot.intFutOptTransactionId = mf.intSFutOptTransactionId)
			, strLocationName
			, dblContractSize
			, intContractHeaderId = NULL
			, ot.intFutOptTransactionHeaderId
		FROM tblRKFutOptTransaction ot
		JOIN tblRKFutureMarket m ON ot.intFutureMarketId = m.intFutureMarketId
		JOIN tblRKFuturesMonth fm ON ot.intFutureMonthId = fm.intFutureMonthId AND fm.ysnExpired = 0
		JOIN tblICCommodity c ON ot.intCommodityId = c.intCommodityId
		JOIN tblSMCompanyLocation l ON ot.intLocationId = l.intCompanyLocationId
		WHERE ot.strBuySell = 'Sell'
			AND ot.intCommodityId IN (SELECT intCommodityId FROM #CommodityList)
			AND ot.intLocationId IN (SELECT intCompanyLocationId FROM #CompanyLocationList)
		GROUP BY intFutOptTransactionId
			, strCommodityCode
			, strLocationName
			, strInternalTradeNo
			, RIGHT(CONVERT(VARCHAR(11), dtmFutureMonthsDate, 106), 8)
			, dblPrice
			, dblContractSize
			, ot.intFutOptTransactionHeaderId) t
 
	-- Net Futures
	INSERT INTO @List(strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, dblBalance
		, strContractNumber
		, strLocationName
		, intContractHeaderId
		, intFutOptTransactionHeaderId)
	SELECT strCommodity
		, 'Net Futures'
		, 'Net Futures'
		, 'Net Futures'
		, strContractEndMonth
		, dblBalance
		, strContractNumber
		, strLocationName
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @List
	WHERE (strHeaderValue = 'Futures - Long' AND strSecondSubHeading = 'Futures - Long') OR (strHeaderValue = 'Futures - Short' AND strSecondSubHeading = 'Futures - Short')
	
	---Previous

	DECLARE @count INT
		, @Month NVARCHAR(50)
		, @PreviousMonth NVARCHAR(50)
		, @intMonth INT
	
	SELECT @count = MIN(intRowNumber) FROM @MonthList
	
	WHILE (@count IS NOT NULL)
	BEGIN
		SELECT @intMonth = intRowNumber, @Month = dtmMonth FROM @MonthList WHERE intRowNumber = @count

		IF (@count = 1)
		BEGIN
			 INSERT INTO @FinalList(strCommodity
				, strSubHeading
				, strSecondSubHeading
				, strContractEndMonth
				, strContractBasis
				, dblBalance
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, strItemNo
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId)
			SELECT strCommodity
				, strSubHeading
				, strSecondSubHeading
				, strContractEndMonth
				, strContractBasis
				, dblBalance
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, strItemNo
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM @List
			WHERE (CONVERT(DATETIME, '01 ' + strContractEndMonth)) = (CONVERT(DATETIME, '01 ' + @Month))
		END
		ELSE
		BEGIN
			SELECT @PreviousMonth = dtmMonth FROM @MonthList WHERE intRowNumber = (@count - 1)
			
			INSERT INTO @FinalList(strCommodity
				, strSubHeading
				, strSecondSubHeading
				, strContractEndMonth
				, strContractBasis
				, dblBalance
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, strItemNo
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId)
			SELECT strCommodity
				, strSubHeading
				, strSecondSubHeading
				, strContractEndMonth = @Month
				, strContractBasis
				, SUM(ISNULL(dblBalance, 0))
				, strMarketZoneCode
				, SUM(ISNULL(dblFuturesPrice, 0))
				, SUM(ISNULL(dblBasisPrice, 0))
				, SUM(ISNULL(dblCashPrice, 0))
				, dblRate
				, strLocationName
				, strContractNumber
				, strItemNo
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM @List
			WHERE (CONVERT(DATETIME, '01 ' + strContractEndMonth)) > (CONVERT(DATETIME, '01 ' + @PreviousMonth))
				AND (CONVERT(DATETIME, '01 ' + strContractEndMonth)) <= (CONVERT(DATETIME, '01 ' + @Month)) 
			GROUP BY strCommodity
				, strSubHeading
				, strSecondSubHeading
				, strContractBasis
				, strMarketZoneCode
				, dblRate
				, strLocationName
				, strContractNumber
				, strItemNo
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
		END

		SELECT @count = MIN(intRowNumber) FROM @MonthList WHERE intRowNumber > @count 
	END

	DECLARE @Month1 NVARCHAR(50)
	SELECT TOP 1 @Month1 = dtmMonth FROM @MonthList ORDER BY intRowNumber
	
	-- Previous
	INSERT INTO @FinalList(strCommodity
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblRate
		, strLocationName
		, strContractNumber
		, strItemNo
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId)
	SELECT strCommodity
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth = 'Previous'
		, strContractBasis
		, SUM(ISNULL(dblBalance, 0))
		, strMarketZoneCode
		, SUM(ISNULL(dblFuturesPrice, 0))
		, SUM(ISNULL(dblBasisPrice, 0))
		, SUM(ISNULL(dblCashPrice, 0))
		, dblRate
		, strLocationName
		, strContractNumber
		, strItemNo
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @List
	WHERE (CONVERT(DATETIME, '01 ' + strContractEndMonth)) < (CONVERT(DATETIME, '01 ' + @Month1))
	GROUP BY strCommodity
		, strSubHeading
		, strSecondSubHeading
		, strContractBasis
		, strMarketZoneCode
		, dblRate
		, strLocationName
		, strContractNumber
		, strItemNo
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId

	---- Future
	DECLARE @Month2 NVARCHAR(50)
	SELECT TOP 1 @Month2 = dtmMonth FROM @MonthList ORDER BY intRowNumber DESC
	
	INSERT INTO @FinalList(strCommodity
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblRate
		, strLocationName
		, strContractNumber
		, strItemNo
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId)
	SELECT strCommodity
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth = 'Future'
		, strContractBasis
		, SUM(ISNULL(dblBalance, 0))
		, strMarketZoneCode
		, dblFuturesPrice = SUM(ISNULL(dblFuturesPrice, 0))
		, dblBasisPrice = SUM(ISNULL(dblBasisPrice, 0))
		, dblCashPrice = SUM(ISNULL(dblCashPrice, 0))
		, dblRate
		, strLocationName
		, strContractNumber
		, strItemNo
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @List
	WHERE (CONVERT(DATETIME, '01 ' + strContractEndMonth)) > (CONVERT(DATETIME, '01 ' + @Month2))
	GROUP BY strCommodity
		, strSubHeading
		, strSecondSubHeading
		, strContractBasis
		, strMarketZoneCode
		, dblRate
		, strLocationName
		, strContractNumber
		, strItemNo
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	
	------ Pulling from header details...
	SELECT DISTINCT ROW_NUMBER() OVER(ORDER BY intCommodityId ASC) AS intRecordNo
		, intCommodityId
	INTO #CommodityCounter
	FROM #CommodityList
	ORDER BY intCommodityId ASC

	DECLARE @commodityId INT
		, @rowNo INT
		, @MaxRow INT
		, @strCommodity NVARCHAR(100)
		, @intCommodityIdentity INT
		, @intMinRowNumber INT
		, @dblInventoryQty NUMERIC(24, 10) = 0.00
		, @strCommodityCode NVARCHAR(500)
		, @Ownership NUMERIC(24,10)
		, @PurchaseBasisDel NUMERIC(24,10)

	SELECT TOP 1 @rowNo = intRecordNo FROM #CommodityCounter
	SELECT TOP 1 @MaxRow = MAX(intRecordNo) FROM #CommodityCounter
	
	WHILE (@rowNo <= @MaxRow)
	BEGIN
		SELECT TOP 1 @commodityId = intCommodityId FROM #CommodityCounter WHERE intRecordNo = @rowNo
		
		INSERT INTO @FinalList(strCommodity
			, strHeaderValue
			, strSubHeading
			, strSecondSubHeading
			, strContractEndMonth
			, dblBalance)
		EXEC uspRKPositionByPeriodSelectionHeader @commodityId, @intCompanyLocationId, @intQuantityUOMId
		
		SET @rowNo += 1
	END
	-------

	SELECT TOP 1 @rowNo = intRecordNo FROM #CommodityCounter
		
	WHILE (@rowNo <= @MaxRow)
	BEGIN
		SELECT TOP 1 @commodityId = intCommodityId FROM #CommodityCounter WHERE intRecordNo = @rowNo
		
		SELECT @strCommodityCode = strCommodityCode FROM tblICCommodity Where intCommodityId = @commodityId
		SELECT @dblInventoryQty = SUM(dblBalance) FROM @FinalList where strCommodity = @strCommodityCode AND strSubHeading = 'Inventory'
		SELECT @Ownership = SUM(dblBalance) FROM @FinalList WHERE strCommodity = @strCommodityCode AND strSubHeading = 'Inventory' AND strSecondSubHeading = 'Ownership'
		SELECT @PurchaseBasisDel = SUM(dblBalance) FROM @FinalList WHERE strCommodity = @strCommodityCode AND strSubHeading = 'Inventory' AND strSecondSubHeading = 'Purchase Basis Delivery'
		
		IF EXISTS (SELECT TOP 1 1 FROM @FinalList WHERE strCommodity = @strCommodityCode AND strContractEndMonth = 'Previous')
		BEGIN
			INSERT INTO @FinalList(strCommodity
				, strSubHeading
				, strSecondSubHeading
				, strContractEndMonth
				, dblBalance
				, strContractBasis
				, strLocationName
				, strContractNumber)
			SELECT @strCommodityCode, 'Purchase Total', 'Purchase Total', 'Previous', @dblInventoryQty, '', '', ''
				
			---- cash exposure
			UNION ALL SELECT @strCommodityCode, 'Cash Exposure', 'Cash Exposure', 'Previous', @Ownership, NULL, NULL, NULL
			UNION ALL SELECT @strCommodityCode, 'Cash Exposure', 'Cash Exposure', 'Previous', -@PurchaseBasisDel, NULL, NULL, NULL
				
			UNION ALL SELECT strCommodity
				, 'Cash Exposure'
				, 'Cash Exposure'
				, 'Previous'
				, CASE WHEN strSecondSubHeading = 'Sale Quantity' THEN - dblBalance ELSE dblBalance END
				, strContractBasis
				, strLocationName
				, strContractNumber
			FROM @FinalList
			WHERE strCommodity = @strCommodityCode
				AND strContractEndMonth = 'Previous'
				AND ((strSubHeading LIKE '%Purchase-Priced%' AND strSecondSubHeading = 'Purchase Quantity') OR (strSubHeading LIKE '%Purchase-HTA%' AND strSecondSubHeading='Purchase Quantity')
				OR (strSubHeading LIKE '%Sale-Priced%' AND strSecondSubHeading = 'Sale Quantity') OR (strSubHeading LIKE '%Sale-HTA%' AND strSecondSubHeading = 'Sale Quantity')
				OR (strSubHeading = 'Net Futures' AND strSecondSubHeading = 'Net Futures'))

			---- Basis exposure
			UNION ALL SELECT @strCommodityCode, 'Basis Exposure', 'Basis Exposure', 'Previous', @Ownership, NULL, NULL, NULL
				
			UNION ALL SELECT strCommodity
				, 'Basis Exposure'
				, 'Basis Exposure'
				, 'Previous'
				, CASE WHEN strSecondSubHeading = 'Sale Quantity' THEN - dblBalance ELSE dblBalance END
				, strContractBasis
				, strLocationName
				, strContractNumber
			FROM @FinalList
			WHERE strCommodity = @strCommodityCode 
				AND strContractEndMonth = 'Previous'
				AND ((strSubHeading LIKE '%Purchase-Priced%' AND strSecondSubHeading='Purchase Quantity') OR (strSubHeading LIKE '%Purchase-Basis%' AND strSecondSubHeading = 'Purchase Quantity')
				OR (strSubHeading LIKE '%Sale-Priced%' AND strSecondSubHeading = 'Sale Quantity') OR (strSubHeading LIKE '%Sale-Basis%' AND strSecondSubHeading = 'Sale Quantity'))
		END
		ELSE
		BEGIN
			DECLARE @MonthPurTot NVARCHAR(50)
				
			SELECT TOP 1 @MonthPurTot = dtmMonth FROM @MonthList m
			JOIN @FinalList f ON f.strContractEndMonth = m.dtmMonth AND f.dblBalance IS NOT NULL
			ORDER BY m.intRowNumber
			
			IF (@MonthPurTot) IS NOT NULL
			BEGIN
				INSERT INTO @FinalList(strCommodity
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strContractBasis
					, strLocationName
					, strContractNumber)
				SELECT @strCommodityCode
					, 'Purchase Total'
					, 'Purchase Total'
					, @MonthPurTot
					, @dblInventoryQty
					, strContractBasis = ''
					, strLocationName = ''
					, strContractNumber = ''
				
				---- case exposure
				UNION ALL SELECT @strCommodityCode, 'Cash Exposure', 'Cash Exposure', @MonthPurTot, @Ownership, NULL, NULL, NULL
				UNION ALL SELECT @strCommodityCode,'Cash Exposure','Cash Exposure',@MonthPurTot,-@PurchaseBasisDel, NULL, NULL, NULL
					
				---- Basis exposure
				UNION ALL SELECT @strCommodityCode, 'Basis Exposure', 'Basis Exposure', @MonthPurTot, @Ownership, NULL, NULL, NULL
			END
			ELSE
			BEGIN
				INSERT INTO @FinalList(strCommodity
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strContractBasis
					, strLocationName
					, strContractNumber)
				SELECT @strCommodityCode
					, 'Purchase Total'
					, 'Purchase Total'
					, 'Future'
					, @dblInventoryQty
					, '' strContractBasis
					, '' strLocationName
					, '' strContractNumber
					
				---- case exposure
				UNION ALL SELECT @strCommodityCode, 'Cash Exposure', 'Cash Exposure', 'Future', @Ownership, NULL, NULL, NULL
				UNION ALL SELECT @strCommodityCode, 'Cash Exposure', 'Cash Exposure', 'Future', -@PurchaseBasisDel, NULL, NULL, NULL

				---- Basis exposure
				UNION ALL SELECT @strCommodityCode, 'Basis Exposure', 'Basis Exposure', 'Future', @Ownership, NULL, NULL, NULL
			END
		END
			
		--Net Physical position
		INSERT INTO @FinalList(strCommodity
			, strSubHeading
			, strSecondSubHeading
			, strContractEndMonth
			, dblBalance
			, strContractBasis
			, strLocationName
			, strContractNumber
			, intContractHeaderId
			, intFutOptTransactionHeaderId)
		SELECT @strCommodityCode
			, 'Net Physical Position'
			, 'Net Physical Position'
			, strContractEndMonth
			, CASE WHEN strSubHeading = 'Sale Total' THEN - dblBalance ELSE dblBalance END
			, strContractBasis
			, strLocationName
			, strContractNumber
			, intContractHeaderId
			, intFutOptTransactionHeaderId
		FROM @FinalList
		WHERE (strSubHeading ='Purchase Total' OR strSubHeading = 'Sale Total') AND strCommodity = @strCommodityCode
		
		---- case exposure
		INSERT INTO @FinalList(strCommodity
			, strSubHeading
			, strSecondSubHeading
			, strContractEndMonth
			, dblBalance
			, strContractBasis
			, strLocationName
			, strContractNumber
			, intContractHeaderId
			, intFutOptTransactionHeaderId)
		SELECT strCommodity
			, 'Cash Exposure'
			, 'Cash Exposure'
			, strContractEndMonth
			, CASE WHEN strSecondSubHeading = 'Sale Quantity' THEN - dblBalance ELSE dblBalance END
			, strContractBasis
			, strLocationName
			, strContractNumber
			, intContractHeaderId
			, intFutOptTransactionHeaderId
		FROM @FinalList
		WHERE strCommodity = @strCommodityCode AND strContractEndMonth <> 'Previous'
			AND ((strSubHeading LIKE '%Purchase-Priced%' AND strSecondSubHeading='Purchase Quantity') OR (strSubHeading LIKE '%Sale-Priced%' AND strSecondSubHeading = 'Sale Quantity')
			OR (strSubHeading LIKE '%Purchase-HTA%' AND strSecondSubHeading = 'Purchase Quantity') OR (strSubHeading LIKE '%Sale-HTA%' AND strSecondSubHeading = 'Sale Quantity')
			OR (strSubHeading = 'Net Futures' AND strSecondSubHeading = 'Net Futures'))
		
		----- Basis Exposure
		INSERT INTO @FinalList(strCommodity
			, strSubHeading
			, strSecondSubHeading
			, strContractEndMonth
			, dblBalance
			, strContractBasis
			, strLocationName
			, strContractNumber
			, intContractHeaderId
			, intFutOptTransactionHeaderId)
		SELECT strCommodity
			, 'Basis Exposure'
			, 'Basis Exposure'
			, strContractEndMonth
			, CASE WHEN strSecondSubHeading = 'Sale Quantity' THEN - dblBalance ELSE dblBalance END
			, strContractBasis
			, strLocationName
			, strContractNumber
			, intContractHeaderId
			, intFutOptTransactionHeaderId
		FROM @FinalList
		WHERE strCommodity = @strCommodityCode AND strContractEndMonth <> 'Previous'
			AND ((strSubHeading LIKE '%Purchase-Priced%' AND strSecondSubHeading = 'Purchase Quantity') OR ( strSubHeading LIKE '%Purchase-Basis%' AND strSecondSubHeading = 'Purchase Quantity')
			OR (strSubHeading LIKE '%Sale-Priced%' AND strSecondSubHeading = 'Sale Quantity') OR (strSubHeading LIKE '%Sale-Basis%' AND strSecondSubHeading = 'Sale Quantity'))

		SET @rowNo += 1
	END

	----------------------  DONE FOR ALL..........
	----------Cumulative Calculation
	SELECT TOP 1 @rowNo = intRecordNo FROM #CommodityCounter
		
	WHILE (@rowNo <= @MaxRow)
	BEGIN
		SELECT TOP 1 @commodityId = intCommodityId FROM #CommodityCounter WHERE intRecordNo = @rowNo
		SELECT TOP 1 @strCommodityCode = strCommodityCode FROM tblICCommodity Where intCommodityId = @commodityId
		
		IF (@commodityId > 0)
		BEGIN
			----------Wt Avg --------------
			INSERT INTO @FinalList (strCommodity
				, strHeaderValue
				, strSubHeading
				, strSecondSubHeading
				, strContractEndMonth
				, dblBalance
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId)
			SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, strSecondSubHeading = 'Wt./Avg Price'
				, strContractEndMonth
				, ISNULL(dblBalance, 0) * ISNULL(dblFuturesPrice, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY strCommodity, strContractEndMonth, strSubHeading)
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSubHeading = 'Futures - Long' OR  strSubHeading = 'Futures - Short')
					AND strCommodity = @strCommodityCode
					AND dblBalance <> 0
					AND ISNULL(dblFuturesPrice, 0) <> 0)t
			
			UNION ALL SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, strSecondSubHeading = 'Wt./Avg Price'
				, 'Total'
				, ISNULL(dblBalance, 0) * ISNULL(dblFuturesPrice, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY strCommodity, strSubHeading)
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSubHeading = 'Futures - Long' OR strSubHeading = 'Futures - Short')
					AND strCommodity = @strCommodityCode
					AND dblBalance <> 0
					AND ISNULL(dblFuturesPrice, 0) <> 0
					AND strSecondSubHeading <> 'Wt./Avg Price')t
			
			---------RK Module
			INSERT INTO @FinalList (strCommodity
				, strHeaderValue
				, strSubHeading
				, strSecondSubHeading
				, strContractEndMonth
				, dblBalance
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId)
			SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, strSecondSubHeading = 'Wt./Avg Futures'
				, strContractEndMonth
				, ISNULL(dblBalance, 0) * ISNULL(dblFuturesPrice, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY strCommodity, strContractEndMonth, strSecondSubHeading, strSubHeading)
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity')
					AND strCommodity = @strCommodityCode
					AND dblBalance <> 0
					AND ISNULL(dblFuturesPrice, 0) <> 0)t
			
			UNION ALL SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, strSecondSubHeading = 'Wt./Avg Futures'
				, 'Total'
				, (ISNULL(dblBalance, 0) * ISNULL(dblFuturesPrice, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY strCommodity, strSecondSubHeading, strSubHeading))
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity')
					AND strCommodity = @strCommodityCode
					AND dblBalance <> 0
					AND ISNULL(dblFuturesPrice, 0) <> 0)t
			
			UNION ALL SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, strSecondSubHeading = 'Wt./Avg Basis'
				, strContractEndMonth
				, ISNULL(dblBalance, 0) * ISNULL(dblBasisPrice, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY @strCommodityCode, strContractEndMonth, strSecondSubHeading, strSubHeading)
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity')
					AND strCommodity = @strCommodityCode
					AND dblBalance <> 0
					AND ISNULL(dblBasisPrice, 0) <> 0)t
			
			UNION ALL SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, strSecondSubHeading = 'Wt./Avg Basis'
				, 'Total'
				, ISNULL(dblBalance, 0) * ISNULL(dblBasisPrice, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY @strCommodityCode, strSecondSubHeading, strSubHeading)
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity')
					AND strCommodity = @strCommodityCode
					AND dblBalance <> 0
					AND ISNULL(dblBasisPrice, 0) <> 0)t
			
			UNION ALL SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, strSecondSubHeading = 'Wt./Avg Cash'
				, strContractEndMonth
				, ISNULL(dblBalance, 0) * ISNULL(dblCashPrice, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY @strCommodityCode, strContractEndMonth, strSecondSubHeading, strSubHeading)
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity')
					AND strCommodity = @strCommodityCode
					AND dblBalance <> 0
					AND ISNULL(dblCashPrice, 0) <> 0)t

			UNION ALL SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, 'Wt./Avg Cash' as strSecondSubHeading
				, 'Total'
				, ISNULL(dblBalance, 0) * ISNULL(dblCashPrice, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY @strCommodityCode, strSecondSubHeading, strSubHeading)
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity')
					and strCommodity = @strCommodityCode
					and dblBalance <> 0
					AND ISNULL(dblCashPrice, 0) <> 0)t
					
			UNION ALL SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, 'Wt./Avg Freight' as strSecondSubHeading
				, strContractEndMonth
				, ISNULL(dblBalance, 0) * ISNULL(dblRate, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY @strCommodityCode, strContractEndMonth, strSecondSubHeading, strSubHeading)
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity')
					AND strCommodity = @strCommodityCode
					AND dblBalance <> 0
					AND dblRate > 0)t
		
			UNION ALL SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, 'Wt./Avg Freight' as strSecondSubHeading
				, 'Total'
				, ISNULL(dblBalance, 0) * ISNULL(dblRate, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY @strCommodityCode, strSecondSubHeading, strSubHeading)
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity')
					AND strCommodity = @strCommodityCode
					AND dblBalance <> 0
					AND dblRate > 0)t
				
			UNION ALL SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, 'Exchange -' + strCurrencyExchangeRateType as strSecondSubHeading
				, strContractEndMonth
				, ISNULL(dblBalance, 0) * ISNULL(ExRate, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY @strCommodityCode, strContractEndMonth, strSecondSubHeading, strCurrencyExchangeRateType)
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity')
					AND strCommodity = @strCommodityCode
					AND dblBalance <> 0
					AND ISNULL(ExRate, 0) <> 0)t
		
			UNION ALL SELECT strCommodity
				, strHeaderValue
				, strSubHeading
				, 'Exchange -' + strCurrencyExchangeRateType as strSecondSubHeading
				, 'Total'
				, ISNULL(dblBalance, 0) * ISNULL(ExRate, 0) / SUM(ISNULL(dblBalance, 0)) OVER (PARTITION BY @strCommodityCode, strSubHeading, strSecondSubHeading, strCurrencyExchangeRateType)
				, strMarketZoneCode
				, dblFuturesPrice
				, dblBasisPrice
				, dblCashPrice
				, dblRate
				, strLocationName
				, strContractNumber
				, ExRate
				, strCurrencyExchangeRateType
				, intContractHeaderId
				, intFutOptTransactionHeaderId
			FROM(
				SELECT strCommodity
					, strHeaderValue
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strMarketZoneCode
					, dblFuturesPrice
					, dblBasisPrice
					, dblCashPrice
					, dblRate
					, strLocationName
					, strContractNumber
					, ExRate
					, strCurrencyExchangeRateType
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity')
					AND strCommodity = @strCommodityCode
					AND dblBalance <> 0
					AND ISNULL(ExRate, 0) <> 0)t
		
			-- Cumulative start
			IF EXISTS(SELECT TOP 1 1 FROM @FinalList WHERE strContractEndMonth = 'Previous')
			BEGIN
				INSERT INTO @FinalList(strCommodity
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance)
				SELECT strCommodity
					, 'Cumulative physical position'
					, 'Cumulative physical position'
					, 'Previous'
					, dblBalance
				FROM @FinalList
				WHERE strSubHeading = 'Net Physical Position'
					AND strContractEndMonth = 'Previous'
					AND strCommodity = @strCommodityCode
			END
		
			DECLARE @countC INT
				, @MonthC NVARCHAR(50)
				, @PreviousMonthC NVARCHAR(50)
				, @intMonthC INT

			SELECT @countC = MIN(intRowNumber) FROM @MonthList
		
			DECLARE @previousValue NUMERIC(24, 10)
		
			SELECT @previousValue = SUM(ISNULL(dblBalance, 0))
			FROM @FinalList
			WHERE strSubHeading = 'Cumulative physical position'
				AND strContractEndMonth = 'Previous'
				AND strCommodity = @strCommodityCode
		
			WHILE (@countC IS NOT NULL)
			BEGIN
				SELECT @intMonthC = intRowNumber
					, @MonthC = dtmMonth
				FROM @MonthList
				WHERE intRowNumber = @countC
			
				IF (@countC = 1)
				BEGIN
					INSERT INTO @FinalList(strCommodity
						, strSubHeading
						, strSecondSubHeading
						, strContractEndMonth
						, dblBalance)
					SELECT strCommodity
						, 'Cumulative physical position'
						, 'Cumulative physical position'
						, @MonthC
						, SUM(dblBalance) + ISNULL(@previousValue, 0)
					FROM @FinalList
					WHERE strSubHeading = 'Net Physical Position'
						AND strContractEndMonth = @MonthC
						AND strCommodity = @strCommodityCode
					GROUP BY strCommodity
				
					SELECT @previousValue = SUM(dblBalance) + ISNULL(@previousValue, 0)
					FROM @FinalList
					WHERE strSubHeading = 'Net Physical Position'
						AND strContractEndMonth = @MonthC
						AND strCommodity = @strCommodityCode
					GROUP BY strCommodity
				END
				ELSE
				BEGIN
					DECLARE @PreviousMonthQumPosition NUMERIC(24, 10)

					SELECT @PreviousMonthC = dtmMonth
					FROM @MonthList
					WHERE intRowNumber = (@countC - 1)
				
					INSERT INTO @FinalList(strCommodity
						, strSubHeading
						, strSecondSubHeading
						, strContractEndMonth
						, dblBalance)
					SELECT strCommodity
						, 'Cumulative physical position'
						, 'Cumulative physical position'
						, strContractEndMonth = @MonthC
						, SUM(ISNULL(dblBalance, 0)) + @previousValue
					FROM @FinalList
					WHERE (CONVERT(DATETIME, '01 ' + strContractEndMonth)) > (CONVERT(DATETIME, '01 ' + @PreviousMonthC))
						AND (CONVERT(DATETIME, '01 ' + strContractEndMonth)) <= (CONVERT(DATETIME, '01 ' + @MonthC))
						AND strSubHeading = 'Net Physical Position'
						AND strContractEndMonth <> 'Future'
						AND strContractEndMonth <> 'Previous'
						AND strCommodity = @strCommodityCode
						AND strContractEndMonth <> 'Total'
					GROUP BY strCommodity
				
					SELECT @previousValue = SUM(ISNULL(dblBalance, 0)) + @previousValue
					FROM @FinalList
					WHERE (CONVERT(DATETIME, '01 ' + strContractEndMonth)) > (CONVERT(DATETIME, '01 ' + @PreviousMonthC))
						AND (CONVERT(DATETIME, '01 ' + strContractEndMonth)) <= (CONVERT(DATETIME, '01 ' + @MonthC))
						AND strSubHeading = 'Net Physical Position'
						AND strContractEndMonth <> 'Future'
						AND strContractEndMonth <> 'Previous'
						AND strCommodity = @strCommodityCode
						AND strContractEndMonth <> 'Total'
					GROUP BY strCommodity
				END
			
				SELECT @countC = min(intRowNumber) from @MonthList where intRowNumber>@countC
			END
		
			IF EXISTS(SELECT TOP 1 1 FROM @FinalList WHERE strContractEndMonth = 'Future')
			BEGIN
				INSERT INTO @FinalList(strCommodity
					, strSubHeading
					, strSecondSubHeading
					, strContractEndMonth
					, dblBalance
					, strContractBasis
					, strLocationName
					, strContractNumber
					, intContractHeaderId
					, intFutOptTransactionHeaderId)
				SELECT strCommodity
					, 'Cumulative physical position'
					, 'Cumulative physical position'
					, strContractEndMonth
					, dblBalance = (CASE WHEN strSubHeading = 'Sale Total' THEN -dblBalance ELSE dblBalance END)
					, strContractBasis
					, strLocationName
					, strContractNumber
					, intContractHeaderId
					, intFutOptTransactionHeaderId
				FROM @FinalList
				WHERE (strSubHeading = 'Purchase Total' OR strSubHeading = 'Sale Total')
					AND strCommodity = @strCommodityCode
					AND strContractEndMonth = 'Future'
				
				INSERT INTO @FinalList(strCommodity
					,strSubHeading
					,strSecondSubHeading
					,strContractEndMonth
					,dblBalance)
				SELECT @strCommodityCode
					,'Cumulative physical position'
					,'Cumulative physical position'
					,'Future'
					,ISNULL(@previousValue, 0)
			END
		END
		
		SET @rowNo += 1
	END 
	
	INSERT INTO @FinalList(strCommodity
		,strHeaderValue
		,strSubHeading
		,strSecondSubHeading
		,strContractEndMonth
		,strContractBasis
		,dblBalance
		,strMarketZoneCode
		,dblFuturesPrice
		,dblBasisPrice
		,dblCashPrice
		,dblRate
		,strLocationName
		,strContractNumber
		,strItemNo
		,intOrderByOne
		,intOrderByTwo
		,ExRate
		,intContractHeaderId
		,intFutOptTransactionHeaderId)
	SELECT strCommodity
		,strHeaderValue
		,strSubHeading
		,strSecondSubHeading
		,'Total'
		,strContractBasis
		,dblBalance
		,strMarketZoneCode
		,dblFuturesPrice
		,dblBasisPrice
		,dblCashPrice
		,dblRate
		,strLocationName
		,strContractNumber
		,strItemNo
		,intOrderByOne
		,intOrderByTwo
		,ExRate
		,intContractHeaderId
		,intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE (strSubHeading = 'Wt./Avg Price' AND strSecondSubHeading = 'Total')
		OR ((strSecondSubHeading = 'Purchase Quantity' OR strSecondSubHeading = 'Sale Quantity'
			OR strSubHeading = 'Purchase Total' OR strSubHeading = 'Sale Total'
			OR strSubHeading = 'Net Futures' OR strSubHeading = 'Cumulative physical position'
			OR strSubHeading = 'Net Physical Position' OR strSubHeading = 'Cash Exposure'
			OR strSubHeading = 'Basis Exposure' OR strSubHeading = 'Basis Exposure' OR strSubHeading = 'Basis Exposure'))
	
	INSERT INTO @FinalList(strCommodity
		,strHeaderValue
		,strSubHeading
		,strSecondSubHeading
		,strContractEndMonth
		,strContractBasis
		,dblBalance
		,strMarketZoneCode
		,dblFuturesPrice
		,dblBasisPrice
		,dblCashPrice
		,dblRate
		,strLocationName
		,strContractNumber
		,strItemNo
		,intOrderByOne
		,intOrderByTwo
		,ExRate
		,intContractHeaderId
		,intFutOptTransactionHeaderId)
	SELECT strCommodity
		,strHeaderValue
		,strSubHeading
		,strSecondSubHeading
		,'Total'
		,strContractBasis
		,dblBalance
		,strMarketZoneCode
		,dblFuturesPrice
		,dblBasisPrice
		,dblCashPrice
		,dblRate
		,strLocationName
		,strContractNumber
		,strItemNo
		,intOrderByOne
		,intOrderByTwo
		,ExRate
		,intContractHeaderId
		,intFutOptTransactionHeaderId
	FROM @List
	WHERE (strSubHeading = 'Futures - Long' OR strSubHeading = 'Futures - Short')
		AND strSecondSubHeading <> 'Total'
	
	DELETE @List
	
	UPDATE @FinalList SET dblBalance = NULL WHERE dblBalance = 0
	
	DECLARE @Result AS TABLE (intRowNumber INT IDENTITY PRIMARY KEY
		, strCommodity NVARCHAR(200)
		, strHeaderValue NVARCHAR(200)
		, strSubHeading NVARCHAR(200)
		, strSecondSubHeading NVARCHAR(200)
		, strContractEndMonth NVARCHAR(100)
		, strContractBasis NVARCHAR(200)
		, dblBalance DECIMAL(24,10)
		, strMarketZoneCode NVARCHAR(200)
		, dblFuturesPrice DECIMAL(24,10)
		, dblBasisPrice DECIMAL(24,10)
		, dblCashPrice DECIMAL(24,10)
		, dblWtAvgPriced DECIMAL(24,10)
		, dblQuantity DECIMAL(24,10)
		, strLocationName NVARCHAR(200)
		, strContractNumber NVARCHAR(200)
		, strItemNo NVARCHAR(200)
		, intOrderByOne INT
		, intOrderByTwo INT
		, intOrderByThree INT
		, dblRate DECIMAL(24,10)
		, ExRate DECIMAL(24,10)
		, strCurrencyExchangeRateType NVARCHAR(200)
		, intContractHeaderId INT
		, intFutOptTransactionHeaderId INT)
	
	DECLARE @strCommodityName NVARCHAR(100)
		, @strSubHeading NVARCHAR(100)
		, @strSecondSubHeading NVARCHAR(100)
		, @strHeaderValue NVARCHAR(100)
	
	SELECT TOP 1 @strCommodityName = strCommodity
		, @strHeaderValue = strHeaderValue
		, @strSubHeading = strSubHeading
		, @strSecondSubHeading = strSecondSubHeading
	FROM @FinalList
	WHERE strSecondSubHeading = 'Purchase Quantity'

	INSERT INTO @FinalList (strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId)
	SELECT DISTINCT @strCommodityName
		, @strHeaderValue
		, @strSubHeading
		, @strSecondSubHeading
		, strContractEndMonth
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
		, NULL
	FROM @FinalList
	WHERE strContractEndMonth NOT IN (SELECT DISTINCT FL.strContractEndMonth
									FROM @FinalList FL
									WHERE FL.strCommodity = @strCommodityName AND FL.strSecondSubHeading = 'Purchase Quantity')
	
	INSERT INTO @Result (strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId)
	SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE (strSubHeading = 'Inventory')
	
	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous'
		AND strSecondSubHeading = 'Purchase Quantity'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading = 'Purchase Quantity'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total')
		AND strSecondSubHeading = 'Purchase Quantity'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous'
		AND strSecondSubHeading = 'Wt./Avg Futures'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
			AND strSecondSubHeading = 'Wt./Avg Futures'
			AND (strSubHeading LIKE '%Purchase-Priced%'
				OR strSubHeading LIKE '%Purchase-Basis%'
				OR strSubHeading LIKE '%Purchase-HTA%'
				OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Futures'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous'
		AND strSecondSubHeading = 'Wt./Avg Basis'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Basis'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Basis'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous'
		AND strSecondSubHeading = 'Wt./Avg Price'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Price'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') 
		AND strSecondSubHeading = 'Wt./Avg Price'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous'
		AND strSecondSubHeading = 'Wt./Avg Cash'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Cash'
		AND(strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Cash'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous'
		AND strSecondSubHeading = 'Wt./Avg Freight'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Freight'
		AND (strSubHeading LIKE '%Purchase-Priced%'
				OR strSubHeading LIKE '%Purchase-Basis%'
				OR strSubHeading LIKE '%Purchase-HTA%'
				OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') 
		AND strSecondSubHeading = 'Wt./Avg Freight'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')
	
	-------------------
	INSERT INTO @Result (strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId)
	SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' 
		AND strSecondSubHeading LIKE 'Exchange -%'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading LIKE 'Exchange -%'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future','Total') 
		AND strSecondSubHeading LIKE 'Exchange -%'
		AND (strSubHeading LIKE '%Purchase-Priced%'
			OR strSubHeading LIKE '%Purchase-Basis%'
			OR strSubHeading LIKE '%Purchase-HTA%'
			OR strSubHeading LIKE '%Purchase-DP%')
	------------------------

	INSERT INTO @Result (strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId)
	SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' AND strSubHeading = 'Purchase Total'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strSubHeading = 'Purchase Total' AND strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') AND strSubHeading = 'Purchase Total'

	--------------  sale
	INSERT INTO @Result (strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId)
	SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous'
		AND strSecondSubHeading = 'Sale Quantity'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading = 'Sale Quantity'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') 
		AND strSecondSubHeading = 'Sale Quantity'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' 
		AND strSecondSubHeading = 'Wt./Avg Futures'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Futures'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') 
		AND strSecondSubHeading = 'Wt./Avg Futures'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' 
		AND strSecondSubHeading = 'Wt./Avg Basis'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Basis'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') 
		AND strSecondSubHeading = 'Wt./Avg Basis'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' 
		AND strSecondSubHeading = 'Wt./Avg Price'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Price'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future','Total') 
		AND strSecondSubHeading = 'Wt./Avg Price'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous'
		AND strSecondSubHeading = 'Wt./Avg Cash'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Cash'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous'
		and strSecondSubHeading = 'Wt./Avg Freight'
		and (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading = 'Wt./Avg Freight'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future','Total') 
		AND strSecondSubHeading = 'Wt./Avg Freight'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' 
		AND strSecondSubHeading LIKE 'Exchange -%'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')
		AND strSecondSubHeading LIKE 'Exchange -%'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') 
		AND strSecondSubHeading LIKE 'Exchange -%'
		AND (strSubHeading LIKE '%Sale-Priced%'
			OR strSubHeading LIKE '%Sale-Basis%'
			OR strSubHeading LIKE '%Sale-HTA%'
			OR strSubHeading LIKE '%Sale-DP%')

	INSERT INTO @Result (strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId)
	SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' AND strSubHeading = 'Sale Total'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strSubHeading = 'Sale Total' AND strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') AND strSubHeading = 'Sale Total'
	----------------------------------- end
	
	INSERT INTO @Result (strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId)
	SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' AND strSubHeading = 'Net Physical Position'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strSubHeading = 'Net Physical Position' AND strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') AND strSubHeading = 'Net Physical Position'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' AND strSubHeading = 'Cumulative physical position'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strSubHeading = 'Cumulative physical position' AND strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') AND strSubHeading = 'Cumulative physical position'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' AND strSubHeading = 'Futures - Long'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strSubHeading = 'Futures - Long' AND strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future','Total') AND strSubHeading = 'Futures - Long'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' AND strSubHeading = 'Futures - Short'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strSubHeading = 'Futures - Short' AND strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future','Total') AND strSubHeading = 'Futures - Short'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' AND strSubHeading = 'Net Futures'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strSubHeading = 'Net Futures' AND strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') AND strSubHeading = 'Net Futures'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' AND strSubHeading = 'Cash Exposure'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strSubHeading = 'Cash Exposure' AND strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') AND strSubHeading = 'Cash Exposure'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth = 'Previous' AND strSubHeading = 'Basis Exposure'

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strSubHeading = 'Basis Exposure' AND strContractEndMonth NOT IN ('Previous', 'Future', 'Inventory', 'Total')

	UNION ALL SELECT strCommodity
		, strHeaderValue
		, strSubHeading
		, strSecondSubHeading
		, strContractEndMonth
		, strContractBasis
		, dblBalance
		, strMarketZoneCode
		, dblFuturesPrice
		, dblBasisPrice
		, dblCashPrice
		, dblWtAvgPriced
		, dblQuantity
		, strLocationName
		, strContractNumber
		, strItemNo
		, intOrderByOne
		, intOrderByTwo
		, intOrderByThree
		, dblRate
		, ExRate
		, strCurrencyExchangeRateType
		, intContractHeaderId
		, intFutOptTransactionHeaderId
	FROM @FinalList
	WHERE strContractEndMonth IN ('Future', 'Total') AND strSubHeading = 'Basis Exposure'

	IF ISNULL(@ysnSummary,0) = 0
	BEGIN 
		SELECT * FROM @Result  order by intRowNumber
	END
	ELSE
	BEGIN
		SELECT * FROM @Result WHERE strSecondSubHeading  not LIKE '%Wt./Avg%'
		AND strSecondSubHeading not LIKE '%' + @strCurrencyName + '%' 	
	END

	DROP TABLE #CommodityList
	DROP TABLE #CompanyLocationList

END TRY
BEGIN CATCH
	SELECT 
		@ErrorMessage = ERROR_MESSAGE(),
		@ErrorSeverity = ERROR_SEVERITY(),
		@ErrorState = ERROR_STATE();

	-- Use RAISERROR inside the CATCH block to return error
	-- information about the original error that caused
	-- execution to jump to the CATCH block.
	RAISERROR (
		@ErrorMessage, -- Message text.
		@ErrorSeverity, -- Severity.
		@ErrorState -- State.
	);
END CATCH