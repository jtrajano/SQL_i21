CREATE PROCEDURE uspRKAutoHedgeDerivative
	@strContractNumber NVARCHAR(100) 
	, @strContractSequence NVARCHAR(100)
	, @intFutOptTransactionId INT 
	, @intEntityUserId INT
	, @strResultOutput NVARCHAR(MAX) = '' OUT
AS

--DECLARE @strContractNumber NVARCHAR(100) = '237'
--	, @strContractSequence NVARCHAR(100) = '10'
--	, @intFutOptTransactionId INT = 22441
--	, @intEntityUserId INT = 1
--	, @strResultOutput NVARCHAR(MAX) = ''
	
	

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DECLARE @ErrorMessage NVARCHAR(4000)
DECLARE @ErrorSeverity INT
DECLARE @ErrorState INT

BEGIN TRY


DECLARE @dblToBeHedgedLots NUMERIC(18,6)
	,@intContractDetailId INT = NULL
	, @intContractHeaderId INT = NULL
	,@dtmCurrentDate DATETIME  = GETDATE()
	,@strContractType NVARCHAR(50)
	,@strFutMarketNameCnt NVARCHAR(50)
	,@strFutureMonthCnt NVARCHAR(50)
	,@strCommodityCodeCnt NVARCHAR(50)
	,@strLocationNameCnt NVARCHAR(100)
	
	,@strInternalTradeNo NVARCHAR(100)
	,@dblHedgedLots NUMERIC(18,6)
	,@dblPrice  NUMERIC(18,6)
	,@strBuySell NVARCHAR(10)
	,@strFutMarketNameDer NVARCHAR(50)
	,@strFutureMonthDer NVARCHAR(50)
	,@strCommodityCodeDer NVARCHAR(50)
	,@strLocationNameDer NVARCHAR(100)

SELECT
	@strInternalTradeNo = D.strInternalTradeNo
	,@dblHedgedLots = D.dblNoOfContract
	,@strBuySell = D.strBuySell
	,@strFutMarketNameDer = F.strFutMarketName
	,@strFutureMonthDer  = FM.strFutureMonth
	,@strCommodityCodeDer = C.strCommodityCode
	,@strLocationNameDer  = L.strLocationName
	,@dblPrice = dblPrice
FROM tblRKFutOptTransaction D
INNER JOIN tblRKFutureMarket F ON F.intFutureMarketId = D.intFutureMarketId
INNER JOIN tblRKFuturesMonth FM ON FM.intFutureMonthId = D.intFutureMonthId
INNER JOIN tblICCommodity C ON C.intCommodityId = D.intCommodityId
INNER JOIN tblSMCompanyLocation L ON L.intCompanyLocationId = D.intLocationId
WHERE intFutOptTransactionId = @intFutOptTransactionId


select
	@dblToBeHedgedLots = dblToBeHedgedLots
	,@intContractDetailId = intContractDetailId
	,@intContractHeaderId = intContractHeaderId
	,@strContractType = strContractType
	,@strFutMarketNameCnt = strFutMarketName
	,@strFutureMonthCnt = strFutureMonth
	,@strCommodityCodeCnt = strCommodityCode
	,@strLocationNameCnt = strLocationName
from vyuRKGetAssignPhysicalTransaction where strContractNumber = @strContractNumber and intContractSeq = @strContractSequence



IF @dblHedgedLots <= @dblToBeHedgedLots 
BEGIN
	DECLARE @strXml NVARCHAR(MAX) = '<root><intAssignFuturesToContractHeaderId>1</intAssignFuturesToContractHeaderId>'



	DECLARE @tmpHedging TABLE (
		intContractHeaderId INT
		,intContractDetailId INT
		,dtmMatchDate DATETIME
		,intFutOptTransactionId INT
		,dblAssignedLots NUMERIC(18,6)
		,dblAssignedLotsToSContract NUMERIC(18,6)
		,dblAssignedLotsToPContract NUMERIC(18,6)
		,dblPrice NUMERIC(18,6)
		,intUserId INT
		,ysnAutoPrice BIT
		,dblHedgedLots NUMERIC(18,6)
		,ysnIsHedged BIT
	)

	INSERT INTO @tmpHedging(
		intContractHeaderId
		, intContractDetailId
		, dtmMatchDate
		, intFutOptTransactionId
		, dblAssignedLots
		, dblAssignedLotsToSContract
		, dblAssignedLotsToPContract
		, dblPrice
		, intUserId
		, ysnAutoPrice
		, dblHedgedLots
		, ysnIsHedged
	)
	select
		@intContractHeaderId
		,@intContractDetailId 
		,@dtmCurrentDate
		,@intFutOptTransactionId 
		,dblAssignedLots = 0
		,dblAssignedLotsToSContract = 0
		,dblAssignedLotsToPContract = 0
		,@dblPrice
		,@intEntityUserId
		,ysnAutoPrice = 0
		,@dblHedgedLots
		,ysnIsHedged = 1

	SET @strXml += (SELECT 
		intContractHeaderId
		, intContractDetailId
		, dtmMatchDate
		, intFutOptTransactionId
		, dblAssignedLots
		, dblAssignedLotsToSContract
		, dblAssignedLotsToPContract
		, dblPrice
		, intUserId
		, ysnAutoPrice
		, dblHedgedLots
		, ysnIsHedged
	FROM @tmpHedging
	FOR XML RAW('Transaction'), ELEMENTS)


	SET @strXml += '</root>'
	
	EXEC uspRKAssignFuturesToContractSummarySave @strXml, 0
	
	SET @strResultOutput = 'Derivative ' + @strInternalTradeNo +' was successfully hedged to Contract ' + @strContractNumber + '-'+ @strContractSequence + '.'
END

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
