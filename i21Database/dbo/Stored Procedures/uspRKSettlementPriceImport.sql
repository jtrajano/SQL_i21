CREATE PROC [dbo].[uspRKSettlementPriceImport]
AS
BEGIN TRY

DECLARE @ErrMsg nvarchar(Max)

DECLARE @strDateTimeFormat nvarchar(50)
DECLARE @ConvertYear int
DECLARE @dtmPriceDate1 nvarchar(50)

	DECLARE @strMarket nvarchar(50) = null
	DECLARE @strSettlementDate nvarchar(50) = null
	DECLARE @intFutureMarketId int = null
	DECLARE @intFutureSettlementPriceId int = null
	DECLARE @newlyCreatedIds nvarchar(max) = ''

SELECT @strDateTimeFormat = strDateTimeFormat FROM tblRKCompanyPreference

IF (@strDateTimeFormat = 'MM DD YYYY HH:MI' OR @strDateTimeFormat ='YYYY MM DD HH:MI' OR ISNULL(@strDateTimeFormat,'') = '')
SELECT @ConvertYear=101
ELSE IF (@strDateTimeFormat = 'DD MM YYYY HH:MI' OR @strDateTimeFormat ='YYYY DD MM HH:MI')
SELECT @ConvertYear=103


BEGIN TRAN

IF NOT EXISTS(SELECT intImportSettlementPriceId FROM tblRKSettlementPriceImport_ErrLog)
BEGIN
DECLARE @mRowNumber INT
SELECT ROW_NUMBER()  OVER (ORDER BY strFutureMarket) intRowNum,strFutureMarket INTO #temp from(
SELECT DISTINCT strFutureMarket  FROM tblRKSettlementPriceImport)t


SELECT @mRowNumber = MIN(intRowNum) FROM #temp
WHILE @mRowNumber > 0
	BEGIN

	set @strMarket  = ''
	set @strSettlementDate  = ''
	set @intFutureMarketId = null
	set @intFutureSettlementPriceId = null

	SELECT @strMarket=strFutureMarket from #temp where intRowNum=@mRowNumber

	
	SELECT @strMarket=ltrim(rtrim(strFutureMarket)),@strSettlementDate=CONVERT(DATETIME,dtmPriceDate,@ConvertYear) FROM tblRKSettlementPriceImport where strFutureMarket=@strMarket
	SELECT @intFutureMarketId=intFutureMarketId from tblRKFutureMarket where strFutMarketName=@strMarket


		DECLARE @intCommodityMarketId INT = NULL
	SELECT @intCommodityMarketId=intCommodityMarketId FROM tblRKFutureMarket m
	JOIN tblRKCommodityMarketMapping mm on m.intFutureMarketId=mm.intFutureMarketId 
	WHERE m.intFutureMarketId=@intFutureMarketId

  INSERT INTO tblRKFuturesSettlementPrice(intFutureMarketId,dtmPriceDate,intConcurrencyId,intCommodityMarketId,strPricingType)
   VALUES(@intFutureMarketId,@strSettlementDate,1,@intCommodityMarketId,'Mark To Market')

	SELECT @intFutureSettlementPriceId = scope_Identity()

	SET @newlyCreatedIds = @newlyCreatedIds +  CAST(@intFutureSettlementPriceId as nvarchar(50)) + ','

--Insert Futures Month settlement Price	
	INSERT INTO tblRKFutSettlementPriceMarketMap (intConcurrencyId,intFutureSettlementPriceId,intFutureMonthId,dblLastSettle,dblLow,dblHigh,strComments)
	SELECT 1,@intFutureSettlementPriceId,intFutureMonthId,dblLastSettle,dblLow,dblHigh,strFutComments FROM tblRKSettlementPriceImport i
	JOIN tblRKFuturesMonth fm on fm.strFutureMonth=replace(i.strFutureMonth ,'-',' ') and intFutureMarketId=@intFutureMarketId
	WHERE strInstrumentType='Futures' and strFutureMarket=@strMarket

-- Insert Options Month settlement Price	
	INSERT INTO tblRKOptSettlementPriceMarketMap (intConcurrencyId,intFutureSettlementPriceId,intOptionMonthId,dblStrike,intTypeId,dblSettle,dblDelta,strComments)
	SELECT 1,@intFutureSettlementPriceId,intOptionMonthId,dblStrike,CASE WHEN strType = 'Put' THEN 1 
																		WHEN strType = 'Call' THEN 2 ELSE 0 END,
			  dblSettle,dblDelta,strFutComments FROM tblRKSettlementPriceImport i
	JOIN tblRKOptionsMonth fm on fm.strOptionMonth=replace(i.strFutureMonth ,'-',' ')  and intFutureMarketId=@intFutureMarketId
	WHERE strInstrumentType like 'Opt%' and strFutureMarket=@strMarket


SELECT @mRowNumber = MIN(intRowNum)	FROM #temp	WHERE intRowNum > @mRowNumber
END

END

COMMIT TRAN

--This will return the newly created Settlement Price
SELECT FM.strFutMarketName AS Result1,SP.strPricingType AS Result2,SP.dtmPriceDate AS Result3 FROM tblRKFuturesSettlementPrice SP INNER JOIN tblRKFutureMarket FM ON SP.intFutureMarketId = FM.intFutureMarketId WHERE intFutureSettlementPriceId IN (SELECT intID FROM dbo.fnGetRowsFromDelimitedValues(@newlyCreatedIds))


END TRY
BEGIN CATCH
 IF XACT_STATE() != 0 AND @@TRANCOUNT > 0 ROLLBACK TRANSACTION    
 SET @ErrMsg = ERROR_MESSAGE()  
 RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT') 
End Catch

