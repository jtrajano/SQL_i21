CREATE PROCEDURE [dbo].[uspRKSaveCurrencyExposure]
	@intCommodityId INT
	, @dtmFutureClosingDate DATETIME
	, @intCurrencyId INT
	, @intCurrencyExposureId INT
	, @dblAP NUMERIC(24, 10)
	, @dblAR NUMERIC(24, 10)	

AS

BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	DECLARE @tblRKStock TABLE (intRowNum INT
		, dblMarketPrice NUMERIC(24, 10)
		, dblValue NUMERIC(24, 10)
		, strContractNumber NVARCHAR(100)
		, strLotNumber NVARCHAR(100)
		, strName NVARCHAR(100)
		, strItemNo NVARCHAR(100)
		, strFutMarketName NVARCHAR(100)
		, strSpotMonth NVARCHAR(100)
		, dblSettlementPrice NUMERIC(24, 10)
		, dblMarketPremium NUMERIC(24, 10)
		, strMarketPremiumUOM NVARCHAR(100)
		, strMarketPriceUOM NVARCHAR(100)
		, dblQty NUMERIC(24, 10)
		, strCompanyName NVARCHAR(100)
		, intConcurrencyId INT
		, intContractDetailId INT
		, intStorageLocationId INT
		, intMarketPremiumUOMId INT
		, intMarketPriceCurrencyId INT
		, intItemId INT
		, intFutureMarketId INT
		, intCompanyId INT)

	INSERT INTO @tblRKStock (intRowNum
		, dblMarketPrice
		, dblValue
		, strContractNumber
		, strLotNumber
		, strName
		, strItemNo
		, strFutMarketName
		, strSpotMonth
		, dblSettlementPrice
		, dblMarketPremium
		, strMarketPremiumUOM
		, strMarketPriceUOM
		, dblQty
		, strCompanyName
		, intConcurrencyId
		, intContractDetailId
		, intStorageLocationId
		, intMarketPremiumUOMId
		, intMarketPriceCurrencyId
		, intItemId
		, intFutureMarketId
		, intCompanyId)
	EXEC uspRKCurrencyExposureForStock @intCommodityId = @intCommodityId
		, @dtmClosingPrice = @dtmFutureClosingDate
		, @intCurrencyId = @intCurrencyId
	
	DECLARE @tblRKExposureForOTC TABLE (intRowNum INT
		, strInternalTradeNo NVARCHAR(100)
		, dtmFilledDate DATETIME
		, strBuySell NVARCHAR(100)
		, intBankId INT
		, strBankName NVARCHAR(100)
		, dtmMaturityDate DATETIME
		, intCurrencyExchangeRateTypeId INT
		, strCurrencyExchangeRateType NVARCHAR(100)
		, dblContractAmount NUMERIC(24, 10)
		, dblExchangeRate NUMERIC(24, 10)
		, strExchangeFromCurrency NVARCHAR(100)
		, dblMatchAmount NUMERIC(24, 10)
		, strMatchedFromCurrency NVARCHAR(100)
		, strCompanyName NVARCHAR(100)
		, intConcurrencyId INT
		, intFutOptTransactionId INT
		, intExchangeRateCurrencyId INT
		, intAmountCurrencyId INT
		, intCompanyId INT)
						
	INSERT INTO @tblRKExposureForOTC (intRowNum
		, strInternalTradeNo
		, dtmFilledDate
		, strBuySell
		, intBankId
		, strBankName
		, dtmMaturityDate
		, intCurrencyExchangeRateTypeId
		, strCurrencyExchangeRateType
		, dblContractAmount
		, dblExchangeRate
		, strExchangeFromCurrency
		, dblMatchAmount
		, strMatchedFromCurrency
		, strCompanyName
		, intConcurrencyId
		, intFutOptTransactionId
		, intExchangeRateCurrencyId
		, intAmountCurrencyId
		, intCompanyId) 
	EXEC uspRKCurrencyExposureForOTC @intCurrencyId = @intCurrencyId
	
	DECLARE @tblRKExposureForNonOTC TABLE (intRowNum INT
		, strContractNumber NVARCHAR(100)
		, strName NVARCHAR(100)
		, dblQuantity NUMERIC(24, 10)
		, strUnitMeasure NVARCHAR(100)
		, dblOrigPrice NUMERIC(24, 10)
		, strOrigPriceUOM NVARCHAR(100)
		, dtmPeriod NVARCHAR(100)
		, strContractType NVARCHAR(100)
		, strCompanyName NVARCHAR(100)
		, intConcurrencyId INT
		, intContractDetailId INT
		, intEntityId INT
		, intUnitMeasureId INT
		, intCurrencyId INT
		, intCompanyId INT
		, dblPrice NUMERIC(24, 10)
		, dblUSDValue NUMERIC(24, 10))

	INSERT INTO @tblRKExposureForNonOTC (intRowNum
		, strContractNumber
		, strName
		, dblQuantity
		, strUnitMeasure
		, dblOrigPrice
		, strOrigPriceUOM
		, dtmPeriod
		, strContractType
		, strCompanyName
		, intConcurrencyId
		, intContractDetailId
		, intEntityId
		, intUnitMeasureId
		, intCurrencyId
		, intCompanyId
		, dblPrice
		, dblUSDValue)
	EXEC uspRKCurExpForNonSelectedCurrency @intCommodityId = @intCommodityId
		, @dtmClosingPrice = @dtmFutureClosingDate
		, @intCurrencyId =@intCurrencyId

	DECLARE @tblRKExposureSummary TABLE (intRowNum int
		, strSum NVARCHAR(100)
		, dblUSD NUMERIC(24, 10)
		, intConcurrencyId INT)
	
	INSERT INTO @tblRKExposureSummary (intRowNum
		, strSum
		, dblUSD
		, intConcurrencyId)
	EXEC uspRKCurrencyExposureSummary @intCommodityId = @intCommodityId
		, @dtmFutureClosingDate = @dtmFutureClosingDate
		, @intCurrencyId = @intCurrencyId
		, @dblAP = @dblAP
		, @dblAR = @dblAR
		
	-- Addded money market and bank balance value while saving -- start
	DECLARE @intRowNum int
	SELECT @intRowNum=max(intRowNum) from @tblRKExposureSummary 
	INSERT INTO @tblRKExposureSummary (	intRowNum 
								,strSum 
								,dblUSD 
								,intConcurrencyId 
								) 
	SELECT ISNULL(@intRowNum,0)+1,'1. Treasury',sum(dblAmount),1 from(
	SELECT ISNULL(SUM(dblAmount),0) dblAmount FROM tblRKCurExpBankBalance WHERE intCurrencyExposureId=@intCurrencyExposureId
	UNION ALL
	SELECT ISNULL(SUM(dblAmount),0) dblAmount FROM tblRKCurExpMoneyMarket WHERE intCurrencyExposureId=@intCurrencyExposureId)t
	-- end 

	BEGIN TRANSACTION 

	INSERT INTO tblRKCurExpStock (intConcurrencyId,
									intCurrencyExposureId,
									intContractDetailId,
									strLotNumber,
									intStorageLocationId,
									intItemId,
									intFutureMarketId,
									strSpotMonth,
									dblClosingPrice,
									dblMarketPremium,
									intMarketPremiumUOMId,
									dblMarketPrice,
									intMarketPriceUOMId,
									dblQuantity,
									dblValue,
									intCompanyId)
	SELECT 1,
			@intCurrencyExposureId,
			intContractDetailId,
			strLotNumber,
			intStorageLocationId,
			intItemId,
			intFutureMarketId,
			strSpotMonth,
			dblSettlementPrice,
			dblMarketPremium,
			intMarketPremiumUOMId,
			dblMarketPrice,
			intMarketPriceCurrencyId,
			dblQty,
			isnull(dblValue,0.0),
			intCompanyId FROM @tblRKStock

	insert into tblRKCurExpCurrencyContract(intConcurrencyId,
	intCurrencyExposureId,
	intFutOptTransactionId,
	dtmDate,
	strBuySell,
	intBankId,
	dtmMaturityDate,
	strCurrencyPair,
	dblAmount,
	intAmountCurrencyId,
	dblExchangeRate,
	intExchangeRateCurrencyId,
	dblBalanceAmount,
	intBalanceAmountCurrencyId,
	intCompanyId)
	SELECT 1,@intCurrencyExposureId,
			intFutOptTransactionId,
			dtmFilledDate,
			strBuySell,
			intBankId,
			dtmMaturityDate,
			strCurrencyExchangeRateType,
			dblContractAmount,
			intAmountCurrencyId,
			dblExchangeRate,
			intExchangeRateCurrencyId,
			dblMatchAmount,
			intAmountCurrencyId,
			intCompanyId 
	FROM @tblRKExposureForOTC

	INSERT INTO tblRKCurExpNonOpenSales(intConcurrencyId,
	intCurrencyExposureId,
	intCustomerId,
	dblQuantity,
	intQuantityUOMId,
	dblOrigPrice,
	intOrigPriceUOMId,
	intOrigPriceCurrencyId,
	dblPrice,
	strPeriod,
	strContractType,
	dblValueUSD,
	intCompanyId,intContractDetailId)
	SELECT 1,@intCurrencyExposureId,intEntityId,
	dblQuantity,
	intUnitMeasureId,
	dblOrigPrice,
	intUnitMeasureId,
	intCurrencyId,
	dblPrice,
	dtmPeriod,
	strContractType,
	dblUSDValue,
	intCompanyId,intContractDetailId from @tblRKExposureForNonOTC

	INSERT INTO tblRKCurExpSummary(intConcurrencyId,
	intCurrencyExposureId,
	strTotalSum,
	dblUSD)
	SELECT 1,@intCurrencyExposureId,strSum,sum(dblUSD) FROM @tblRKExposureSummary group by strSum
					
	COMMIT TRAN 
 
END TRY 
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF XACT_STATE() != 0 ROLLBACK TRANSACTION
	IF @ErrMsg != ''
	BEGIN
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
	END 
END CATCH 