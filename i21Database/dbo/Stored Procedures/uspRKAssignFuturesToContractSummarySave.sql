﻿CREATE PROCEDURE [dbo].[uspRKAssignFuturesToContractSummarySave]
	@strXml NVARCHAR(MAX)
	,@ysnAllowDerivativeAssignToMultipleContracts BIT = NULL

AS

BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
	
	DECLARE @idoc INT
		, @intAssignFuturesToContractHeaderId INT
		, @intContractDetailId INT
		, @dtmMatchDate DATETIME
		, @intFutOptTransactionId INT
		, @dblAssignedLots INT
		, @ErrMsg NVARCHAR(MAX)
	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml
	
	BEGIN TRANSACTION
	
	------------------------- Delete Matched ---------------------
	DECLARE @tblMatchedDelete TABLE (intAssignFuturesToContractSummaryId INT
		, ysnDeleted BIT)
	
	INSERT INTO @tblMatchedDelete
	SELECT intAssignFuturesToContractSummaryId
		, ysnDeleted
	FROM OPENXML(@idoc,'root/DeleteMatched', 2)
	WITH (intAssignFuturesToContractSummaryId INT
		, ysnDeleted BIT)
	
	IF EXISTS (SELECT TOP 1 1 FROM tblCTPriceFixationDetail
				WHERE intFutOptTransactionId IN (SELECT intFutOptTransactionId FROM tblRKAssignFuturesToContractSummary
												WHERE intAssignFuturesToContractSummaryId IN (SELECT intAssignFuturesToContractSummaryId FROM @tblMatchedDelete)))
	BEGIN
		RAISERROR('The transaction already assigned. Cannot delete the transaction.', 16, 1)
	END
	
	UPDATE tblRKFutOptTransaction
	SET intContractDetailId = NULL
	WHERE intFutOptTransactionId IN (SELECT intFutOptTransactionId FROM tblRKAssignFuturesToContractSummary
									WHERE intAssignFuturesToContractSummaryId IN (SELECT intAssignFuturesToContractSummaryId FROM @tblMatchedDelete))
	
	IF @ysnAllowDerivativeAssignToMultipleContracts = 1
	BEGIN
		UPDATE DER
		SET DER.dblPContractBalanceLots = DER.dblPContractBalanceLots + dblAssignedLotsToPContract
			,DER.dblSContractBalanceLots = DER.dblSContractBalanceLots + dblAssignedLotsToSContract
		FROM tblRKFutOptTransaction DER
		INNER JOIN (SELECT intFutOptTransactionId, SUM(dblAssignedLotsToPContract) as dblAssignedLotsToPContract, SUM(dblAssignedLotsToSContract) as dblAssignedLotsToSContract FROM tblRKAssignFuturesToContractSummary
										WHERE intAssignFuturesToContractSummaryId IN (SELECT intAssignFuturesToContractSummaryId FROM @tblMatchedDelete) GROUP BY intFutOptTransactionId) AFC
			ON AFC.intFutOptTransactionId = DER.intFutOptTransactionId
	END

	IF EXISTS(SELECT TOP 1 1 FROM @tblMatchedDelete)
	BEGIN
		DELETE FROM tblRKAssignFuturesToContractSummary
		WHERE intAssignFuturesToContractSummaryId IN (SELECT intAssignFuturesToContractSummaryId FROM @tblMatchedDelete)
	END
	----------------------- END Delete Matched ---------------------
	
	---------------Header Record Insert ----------------
	INSERT INTO tblRKAssignFuturesToContractSummaryHeader (intConcurrencyId)
	VALUES (1)
	
	SELECT @intAssignFuturesToContractHeaderId = SCOPE_IDENTITY();
	
	---------------Matched Record Insert ----------------
	SELECT intRowNum  = ROW_NUMBER() OVER(ORDER BY intContractDetailId)
		, intAssignFuturesToContractHeaderId =  @intAssignFuturesToContractHeaderId
		, intConcurrencyId = 1
		, CASE WHEN ISNULL(intContractHeaderId,0) = 0 THEN NULL ELSE intContractHeaderId END intContractHeaderId
		, CASE WHEN ISNULL(intContractDetailId,0) = 0 THEN NULL ELSE intContractDetailId END intContractDetailId
		, dtmMatchDate
		, intFutOptTransactionId
		, dblAssignedLots
		, dblHedgedLots
		, ysnIsHedged
		, dblAssignedLotsToSContract
		, dblAssignedLotsToPContract
		, dblPrice
		, intUserId
		, ysnAutoPrice
	INTO #tempAssignFuturesToContractSummary
	FROM OPENXML(@idoc,'root/Transaction', 2)
	WITH (intContractHeaderId INT
		, intContractDetailId INT
		, dtmMatchDate DATETIME
		, intFutOptTransactionId INT
		, dblAssignedLots NUMERIC(16, 10)
		, dblHedgedLots NUMERIC(18, 6)
		, ysnIsHedged BIT
		, dblAssignedLotsToSContract NUMERIC(16, 10)
		, dblAssignedLotsToPContract NUMERIC(16, 10)
		, dblPrice NUMERIC(16,10)
		, intUserId INT
		, ysnAutoPrice BIT)

	DECLARE @intRowNum INT
		,@dblAssignedLotsToSContract  NUMERIC(16, 10)
		,@dblAssignedLotsToPContract  NUMERIC(16, 10)
		,@dblPrice  NUMERIC(16, 10)
		,@intUserId INT
		,@dblContractSize NUMERIC(16, 10)
		,@dblQuantityToPrice  NUMERIC(16, 10)
		,@ysnAutoPrice BIT
		

	WHILE EXISTS (SELECT TOP 1 * FROM #tempAssignFuturesToContractSummary)
	BEGIN
		
		SELECT  TOP 1 @intRowNum = intRowNum 
			, @intContractDetailId = intContractDetailId
			, @intFutOptTransactionId = intFutOptTransactionId
			, @dblAssignedLots = dblAssignedLots
			, @dblAssignedLotsToSContract = dblAssignedLotsToSContract * -1
			, @dblAssignedLotsToPContract = dblAssignedLotsToPContract * -1
			, @dblPrice = dblPrice
			, @intUserId = intUserId
			, @ysnAutoPrice = ysnAutoPrice
		FROM #tempAssignFuturesToContractSummary

		INSERT INTO tblRKAssignFuturesToContractSummary (intAssignFuturesToContractHeaderId
			, intConcurrencyId
			, intContractHeaderId
			, intContractDetailId
			, dtmMatchDate
			, intFutOptTransactionId
			, dblAssignedLots
			, dblHedgedLots
			, ysnIsHedged
			, dblAssignedLotsToSContract
			, dblAssignedLotsToPContract)
		SELECT intAssignFuturesToContractHeaderId
			,intConcurrencyId
			, intContractHeaderId
			, intContractDetailId
			, dtmMatchDate
			, intFutOptTransactionId
			, dblAssignedLots
			, dblHedgedLots
			, ysnIsHedged
			, dblAssignedLotsToSContract
			, dblAssignedLotsToPContract
		FROM #tempAssignFuturesToContractSummary WHERE intRowNum = @intRowNum

		DELETE FROM #tempAssignFuturesToContractSummary WHERE intRowNum = @intRowNum
	
		IF @ysnAllowDerivativeAssignToMultipleContracts = 1 
		BEGIN
			
			IF @dblAssignedLotsToPContract <> 0
			BEGIN
				EXEC uspRKUpdateDerivativeContractBalanceLots @intFutOptTransactionId,'Purchase',@dblAssignedLotsToPContract
				SET @dblAssignedLots = ABS(@dblAssignedLotsToPContract)
			END
			ELSE
			BEGIN
				EXEC uspRKUpdateDerivativeContractBalanceLots @intFutOptTransactionId,'Sale',@dblAssignedLotsToSContract
				SET @dblAssignedLots = ABS(@dblAssignedLotsToSContract)
			END

			IF @ysnAutoPrice = 1
			BEGIN
			
				SELECT @dblContractSize = dblContractSize 
				FROM tblCTContractDetail CD 
				INNER JOIN tblRKFutureMarket FM ON FM.intFutureMarketId = CD.intFutureMarketId
				WHERE CD.intContractDetailId = @intContractDetailId

				SET @dblQuantityToPrice = @dblAssignedLots * @dblContractSize

				EXEC uspCTCreatePrice @intContractDetailId, @dblQuantityToPrice, @dblPrice, @intUserId, 1
			END
		END
	
	
	END


	
	COMMIT TRAN
	
	EXEC sp_xml_removedocument @idoc
	--============================================================================================
	-- This block is to insert to inter company staging table if the following conditions are met
	-- * It is a hedge transaction
	-- * Short or Long Futures are configured in Inter Company Transaction Configuration
	--=============================================================================================

	DECLARE @ysnShortFuturesConfigured BIT
		, @ysnLongFuturesConfigured BIT
		, @intInterCompanyTransactionConfigurationId INT

	SELECT TOP 1 @ysnShortFuturesConfigured = 1
		, @intInterCompanyTransactionConfigurationId = intInterCompanyTransactionConfigurationId
	FROM tblSMInterCompanyTransactionConfiguration TC
	JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
	WHERE TT.strTransactionType = 'Short Futures'
	
	SELECT TOP 1 @ysnLongFuturesConfigured = 1
		, @intInterCompanyTransactionConfigurationId = intInterCompanyTransactionConfigurationId
	FROM tblSMInterCompanyTransactionConfiguration TC
	JOIN tblSMInterCompanyTransactionType TT ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
	WHERE TT.strTransactionType = 'Long Futures'
	
	SELECT *
	INTO #tempRKAssignFuturesToContractSummary
	FROM tblRKAssignFuturesToContractSummary
	WHERE intAssignFuturesToContractHeaderId = @intAssignFuturesToContractHeaderId
	
	WHILE EXISTS (SELECT TOP 1 1 FROM #tempRKAssignFuturesToContractSummary)
	BEGIN
		DECLARE @intAssignFuturesToContractSummaryId INT
			, @ysnIsHedged BIT
			, @strBuySell NVARCHAR(20)
			, @strContractType NVARCHAR(20)
			, @intFutOptTransactionHeaderId INT
			, @intContractHeaderId INT
			, @strInternalTradeNo NVARCHAR(20)
			, @dblHedgedLots INT
		
		SELECT TOP 1 @intAssignFuturesToContractSummaryId = intAssignFuturesToContractSummaryId
		FROM #tempRKAssignFuturesToContractSummary
		
		SELECT DISTINCT @ysnIsHedged = ysnIsHedged
			, @strBuySell = strBuySell
			, @intFutOptTransactionHeaderId = intFutOptTransactionHeaderId
			, @intContractHeaderId = intContractHeaderId
			, @strInternalTradeNo = strInternalTradeNo
			, @dblHedgedLots = dblHedgedLots
		FROM vyuRKAssignFuturesToContractSummary
		WHERE intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId
		
		IF @ysnIsHedged = 1
		BEGIN
			IF @strBuySell = 'Sell' AND @ysnShortFuturesConfigured = 1
			BEGIN
				EXEC uspRKInterCompanyDerivativeEntryPopulateStgXML @intFutOptTransactionHeaderId,@intContractHeaderId,@strInternalTradeNo,@dblHedgedLots,'SELL','ADDED', @intInterCompanyTransactionConfigurationId
			END
			
			IF @strBuySell = 'Buy' AND @ysnLongFuturesConfigured = 1 
			BEGIN
				EXEC uspRKInterCompanyDerivativeEntryPopulateStgXML @intFutOptTransactionHeaderId,@intContractHeaderId,@strInternalTradeNo,@dblHedgedLots,'BUY','ADDED', @intInterCompanyTransactionConfigurationId
			END
		END
		
		DELETE FROM #tempRKAssignFuturesToContractSummary WHERE intAssignFuturesToContractSummaryId = @intAssignFuturesToContractSummaryId
	END
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF XACT_STATE() != 0 ROLLBACK TRANSACTION
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
	IF @ErrMsg != ''
	BEGIN
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH 