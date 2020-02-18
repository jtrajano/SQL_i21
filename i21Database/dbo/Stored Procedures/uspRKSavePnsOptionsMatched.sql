CREATE PROCEDURE [dbo].[uspRKSavePnsOptionsMatched]
	@strXml NVARCHAR(MAX)
	, @strTranNoPNS NVARCHAR(50) OUT
	, @intUserId INT

AS    

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRY

	DECLARE @idoc INT
	DECLARE @intOptionsMatchPnSHeaderId INT
	DECLARE @strTranNo NVARCHAR(50)
	DECLARE @dtmMatchDate DATETIME
	
	DECLARE @intLFutOptTransactionId INT
	DECLARE @intSFutOptTransactionId INT
	DECLARE @strExpiredTranNo NVARCHAR(50)
	DECLARE @strExercisedAssignedNo NVARCHAR(50)
	DECLARE @ErrMsg NVARCHAR(MAX)
	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml
	
	BEGIN TRANSACTION
	
	------------------------- Delete Matched ---------------------
	DECLARE @tblMatchedDelete TABLE ( strTranNo NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL
		, userName NVARCHAR(50)
		, ysnDeleted BIT)
	
	INSERT INTO @tblMatchedDelete
	SELECT strTranNo
		, userName
		, ysnDeleted
	FROM OPENXML(@idoc,'root/DeleteMatched', 2)
	WITH ([strTranNo] INT
		, [userName] NVARCHAR(100)
		, [ysnDeleted] BIT)
		
	IF EXISTS(SELECT TOP 1 1 FROM @tblMatchedDelete)
	BEGIN
		INSERT INTO tblRKMatchDerivativesHistoryForOption (intOptionsMatchPnSHeaderId
			, intMatchOptionsPnSId
			, dblMatchQty
			, dtmMatchDate
			, intLFutOptTransactionId
			, intSFutOptTransactionId
			, dtmTransactionDate
			, strUserName)
		SELECT intOptionsMatchPnSHeaderId
			, intMatchOptionsPnSId
			, - (dblMatchQty)
			, dtmMatchDate
			, intLFutOptTransactionId
			, intSFutOptTransactionId
			, GETDATE()
			, userName
		FROM tblRKOptionsMatchPnS p
		JOIN @tblMatchedDelete m on p.strTranNo = m.strTranNo
		
		SELECT DISTINCT intOptionsMatchPnSHeaderId
		INTO #tmpMatchDeleted
		FROM tblRKOptionsMatchPnS WHERE CONVERT(INT, strTranNo) IN (SELECT CONVERT(INT, strTranNo) FROM @tblMatchedDelete)
		
		DECLARE @intMatchDeletedId INT

		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpMatchDeleted)
		BEGIN
			SELECT TOP 1 @intMatchDeletedId = intOptionsMatchPnSHeaderId FROM #tmpMatchDeleted

			EXEC uspIPInterCompanyPreStageOptionsPnS @intOptionsMatchPnSHeaderId = @intMatchDeletedId
				, @strRowState = 'Modified'
				, @intUserId = @intUserId

			DELETE FROM #tmpMatchDeleted WHERE intOptionsMatchPnSHeaderId = @intMatchDeletedId
		END
		
		DROP TABLE #tmpMatchDeleted

		DELETE FROM tblRKOptionsMatchPnS WHERE CONVERT(INT, strTranNo) IN (SELECT CONVERT(INT, strTranNo) FROM @tblMatchedDelete)

	END
	------------------------- END Delete Matched ---------------------
	
	------------------------- Delete Expired ---------------------
	DECLARE @tblExpiredDelete TABLE (strTranNo NVARCHAR(MAX)
		, ysnDeleted BIT)
		
	INSERT INTO @tblExpiredDelete
	SELECT strTranNo
		, ysnDeleted
	FROM OPENXML(@idoc,'root/DeleteExpired', 2)
	WITH ([strTranNo] INT
		, [ysnDeleted] BIT)
		
	IF EXISTS(SELECT TOP 1 1 FROM @tblExpiredDelete)
	BEGIN
		SELECT DISTINCT intOptionsMatchPnSHeaderId
		INTO #tmpExpireDeleted
		FROM tblRKOptionsMatchPnS WHERE CONVERT(INT, strTranNo) IN (SELECT CONVERT(INT, strTranNo) FROM @tblExpiredDelete)
		
		DECLARE @intExpireDeletedId INT

		WHILE EXISTS (SELECT TOP 1 1 FROM #tmpExpireDeleted)
		BEGIN
			SELECT TOP 1 @intExpireDeletedId = intOptionsMatchPnSHeaderId FROM #tmpExpireDeleted

			EXEC uspIPInterCompanyPreStageOptionsPnS @intOptionsMatchPnSHeaderId = @intExpireDeletedId
				, @strRowState = 'Modified'
				, @intUserId = @intUserId

			DELETE FROM #tmpExpireDeleted WHERE intOptionsMatchPnSHeaderId = @intExpireDeletedId
		END
		
		DROP TABLE #tmpExpireDeleted

		DELETE FROM tblRKOptionsPnSExpired WHERE CONVERT(INT, strTranNo) IN (SELECT CONVERT(INT, strTranNo) FROM @tblExpiredDelete)

	END
	------------------------- END Delete Expired ---------------------------
	
	------------------------- Delete ExercisedAssigned ---------------------
	DECLARE @tblExercisedAssignedDelete TABLE (strTranNo NVARCHAR(MAX)
		, ysnDeleted BIT)
	
	INSERT INTO @tblExercisedAssignedDelete
	SELECT strTranNo
		, ysnDeleted
	FROM OPENXML(@idoc,'root/DeleteExercisedAssigned', 2)
	WITH ([strTranNo] INT
		, [ysnDeleted] BIT)
	
	IF EXISTS(SELECT TOP 1 1 FROM @tblExercisedAssignedDelete)
	BEGIN
		SELECT intFutOptTransactionHeaderId
		INTO #temp
		FROM tblRKFutOptTransaction
		WHERE intFutOptTransactionId IN (SELECT intFutTransactionId
										FROM tblRKOptionsPnSExercisedAssigned
										WHERE CONVERT(INT, strTranNo) IN (SELECT CONVERT(INT, strTranNo) FROM @tblExercisedAssignedDelete))
		
		DELETE FROM tblRKFutOptTransaction
		WHERE intFutOptTransactionId IN (SELECT intFutTransactionId
										FROM tblRKOptionsPnSExercisedAssigned
										WHERE CONVERT(INT, strTranNo) IN (SELECT CONVERT(INT, strTranNo) FROM @tblExercisedAssignedDelete))
		
		DELETE FROM tblRKOptionsPnSExercisedAssigned
		WHERE CONVERT(INT, strTranNo) IN (SELECT CONVERT(INT, strTranNo) FROM @tblExercisedAssignedDelete)
	END
	------------------------- END Delete ExercisedAssigned ---------------------
	
	---------------Header Record Insert ----------------
	INSERT INTO tblRKOptionsMatchPnSHeader (intConcurrencyId)
	VALUES (1)
	
	SELECT @intOptionsMatchPnSHeaderId = SCOPE_IDENTITY();
	---------------Matched Record Insert ----------------
	DECLARE @MaxRow INT
	SELECT @strTranNo = ISNULL(MAX(CONVERT(INT, strTranNo)), 0), @MaxRow = MAX(ISNULL(intOptionsMatchPnSHeaderId, 0)) FROM tblRKOptionsMatchPnS
	
	INSERT INTO tblRKOptionsMatchPnS (intOptionsMatchPnSHeaderId
		, strTranNo
		, dtmMatchDate
		, dblMatchQty
		, intLFutOptTransactionId
		, intSFutOptTransactionId
		, intConcurrencyId)
	SELECT @intOptionsMatchPnSHeaderId as intOptionsMatchPnSHeaderId
		, @strTranNo + ROW_NUMBER() OVER (ORDER BY intLFutOptTransactionId) strTranNo
		, dtmMatchDate
		, dblMatchQty
		, intLFutOptTransactionId
		, intSFutOptTransactionId
		, 1 as intConcurrencyId
	FROM OPENXML(@idoc,'root/Transaction', 2)
	WITH ([intOptionsMatchPnSHeaderId] INT
		, [dtmMatchDate]  DATETIME
		, [dblMatchQty] Numeric(18,6)
		, [intLFutOptTransactionId] INT
		, [intSFutOptTransactionId] INT)
	
	DECLARE @strName NVARCHAR(100) = ''
	SELECT @strName = [userName]
	FROM OPENXML(@idoc,'root/Transaction', 2)
	WITH ([userName] NVARCHAR(MAX))
	
	DECLARE @intOptMPNSId INT
	SELECT @intOptMPNSId = SCOPE_IDENTITY()
	SELECT TOP 1 @strTranNoPNS = strTranNo FROM tblRKOptionsMatchPnS WHERE intMatchOptionsPnSId = @intOptMPNSId
	
	INSERT INTO tblRKMatchDerivativesHistoryForOption (intOptionsMatchPnSHeaderId
		, intMatchOptionsPnSId
		, dblMatchQty
		, dtmMatchDate
		, intLFutOptTransactionId
		, intSFutOptTransactionId
		, dtmTransactionDate
		, strUserName)
	SELECT intOptionsMatchPnSHeaderId
		, intMatchOptionsPnSId
		, dblMatchQty
		, dtmMatchDate
		, intLFutOptTransactionId
		, intSFutOptTransactionId
		, GETDATE()
		, @strName
	FROM tblRKOptionsMatchPnS
	WHERE strTranNo = @strTranNoPNS

	DECLARE @newRowId INT
	SELECT DISTINCT intOptionsMatchPnSHeaderId INTO #tmpNewMatched FROM tblRKOptionsMatchPnS WHERE intOptionsMatchPnSHeaderId > @MaxRow
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpNewMatched)
	BEGIN
		SELECT TOP 1 @newRowId = intOptionsMatchPnSHeaderId FROM #tmpNewMatched

		EXEC uspIPInterCompanyPreStageOptionsPnS @intOptionsMatchPnSHeaderId = @newRowId
			, @strRowState = 'Added'
			, @intUserId = @intUserId

		DELETE FROM #tmpNewMatched WHERE intOptionsMatchPnSHeaderId = @newRowId
	END

	DROP TABLE #tmpNewMatched
	
	---------------Expired Record Insert ----------------
	SET @MaxRow = NULL
	SELECT @strExpiredTranNo = ISNULL(MAX(CONVERT(INT, strTranNo)), 0), @MaxRow = MAX(ISNULL(intOptionsPnSExpiredId, 0)) FROM tblRKOptionsPnSExpired
	
	INSERT INTO tblRKOptionsPnSExpired (intOptionsMatchPnSHeaderId
		, strTranNo
		, dtmExpiredDate
		, dblLots
		, intFutOptTransactionId
		, intConcurrencyId)
	SELECT
		@intOptionsMatchPnSHeaderId as intOptionsMatchPnSHeaderId
		, @strExpiredTranNo + ROW_NUMBER() OVER (ORDER BY intFutOptTransactionId) strTranNo
		, dtmExpiredDate
		, dblLots
		, intFutOptTransactionId
		, 1 as intConcurrencyId
	FROM OPENXML(@idoc,'root/Expired', 2)
	WITH ([dtmExpiredDate]  DATETIME
		, [dblLots] numeric(18,6)
		, [intFutOptTransactionId] INT)

	SET @newRowId = NULL
	SELECT DISTINCT intOptionsMatchPnSHeaderId INTO #tmpNewExpired FROM tblRKOptionsPnSExpired WHERE intOptionsPnSExpiredId > @MaxRow
	WHILE EXISTS (SELECT TOP 1 1 FROM #tmpNewExpired)
	BEGIN
		SELECT TOP 1 @newRowId = intOptionsMatchPnSHeaderId FROM #tmpNewExpired

		EXEC uspIPInterCompanyPreStageOptionsPnS @intOptionsMatchPnSHeaderId = @newRowId
			, @strRowState = 'Added'
			, @intUserId = @intUserId

		DELETE FROM #tmpNewExpired WHERE intOptionsMatchPnSHeaderId = @newRowId
	END

	DROP TABLE #tmpNewExpired
	
	---------------Exercised/Assigned Record Insert ----------------
	DECLARE @tblExercisedAssignedDetail TABLE (RowNumber INT IDENTITY(1,1)
		, intFutOptTransactionId INT
		, dblLots numeric(18,6)
		, dtmTranDate DATETIME
		, ysnAssigned BIT)
	
	INSERT INTO @tblExercisedAssignedDetail
	SELECT intFutOptTransactionId
		, dblLots
		, dtmTranDate
		, ysnAssigned
	FROM OPENXML(@idoc,'root/ExercisedAssigned', 2)
	WITH ([intFutOptTransactionId] INT
		, dblLots numeric(18,6)
		, [dtmTranDate] DATETIME
		, [ysnAssigned] BIT)
	
	DECLARE @mRowNumber INT
		, @intFutOptTransactionId INT
		, @NewFutOptTransactionId INT
		, @NewFutOptTransactionHeaderId INT
		, @dblLots Numeric(18,6)
		, @dtmTranDate DATETIME
		, @intInternalTradeNo INT
		, @ysnAssigned BIT
	
	SELECT @mRowNumber = MIN(RowNumber) FROM @tblExercisedAssignedDetail
	WHILE @mRowNumber IS NOT NULL
	BEGIN
		DECLARE @intOptionsPnSExercisedAssignedId INT
		SELECT @strExercisedAssignedNo = ISNULL(MAX(CONVERT(INT, strTranNo)), 0) + 1 FROM tblRKOptionsPnSExercisedAssigned
		SELECT @intFutOptTransactionId = intFutOptTransactionId
			, @dblLots = dblLots
			, @dtmTranDate = dtmTranDate
			, @ysnAssigned = ysnAssigned
		FROM @tblExercisedAssignedDetail WHERE RowNumber = @mRowNumber
		
		INSERT INTO tblRKFutOptTransactionHeader (intConcurrencyId
			, dtmTransactionDate
			, intSelectedInstrumentTypeId
			, strSelectedInstrumentType)
		VALUES (1
			, @dtmTranDate
			, 1
			, 'Exchange Traded')
		
		SELECT @NewFutOptTransactionHeaderId = SCOPE_IDENTITY();

		INSERT INTO tblRKOptionsPnSExercisedAssigned (intOptionsMatchPnSHeaderId
			, strTranNo
			, dtmTranDate
			, dblLots
			, intFutOptTransactionId
			, ysnAssigned
			, intConcurrencyId)
		VALUES (@intOptionsMatchPnSHeaderId
			, @strExercisedAssignedNo
			, @dtmTranDate
			, @dblLots
			, @intFutOptTransactionId
			, @ysnAssigned
			, 1)
		
		SELECT @intOptionsPnSExercisedAssignedId = SCOPE_IDENTITY()
		
		DECLARE @intTransactionId NVARCHAR(50)
		SET @strTranNo = ''
		SELECT @strTranNo = strTranNo FROM tblRKOptionsPnSExercisedAssigned WHERE intOptionsPnSExercisedAssignedId = @intOptionsPnSExercisedAssignedId
		
		----------------- Created Future Transaction Based on the Option Transaction ----------------------------------
		SELECT @intInternalTradeNo = intNumber
		FROM tblSMStartingNumber WHERE intStartingNumberId = 45
		INSERT INTO tblRKFutOptTransaction (intFutOptTransactionHeaderId
			, intConcurrencyId
			, intSelectedInstrumentTypeId
			, dtmTransactionDate
			, intEntityId
			, intBrokerageAccountId
			, intFutureMarketId
			, intInstrumentTypeId
			, intCommodityId
			, intLocationId
			, intTraderId
			, intCurrencyId
			, strInternalTradeNo
			, strBrokerTradeNo
			, strBuySell
			, dblNoOfContract
			, intFutureMonthId
			, intOptionMonthId
			, strOptionType
			, dblPrice
			, strReference
			, strStatus
			, dtmFilledDate
			, strReserveForFix
			, intBookId
			, intSubBookId
			, ysnOffset
			, dtmCreateDateTime)
		SELECT @NewFutOptTransactionHeaderId
			, 1
			, 1
			, @dtmTranDate
			, t.intEntityId
			, t.intBrokerageAccountId
			, t.intFutureMarketId
			, 1
			, t.intCommodityId
			, t.intLocationId
			, t.intTraderId
			, t.intCurrencyId
			, 'O-' + CONVERT(NVARCHAR(50), @intInternalTradeNo) AS strInternalTradeNo
			, t.strBrokerTradeNo
			, t.strBuySell
			, @dblLots AS dblLots
			, om.intFutureMonthId AS intFutureMonthId
			, t.intOptionMonthId
			, t.strOptionType
			, isnull(t.dblStrike, 0.0) as dblStrike
			, CASE WHEN strBuySell = 'Buy' THEN 'This futures transaction was the result of Option No. (' + @strTranNo + ') being exercised on (' + CONVERT(NVARCHAR, @dtmTranDate, 101) +')'
				ELSE 'This futures transaction was the result of Option No. (' + @strTranNo + ') being assigned on (' + CONVERT(NVARCHAR, @dtmTranDate,101) +')' end strReference
			, t.strStatus
			, @dtmTranDate as dtmFilledDate
			, t.strReserveForFix
			, t.intBookId
			, t.intSubBookId
			, t.ysnOffset
			, GETDATE() 
		FROM tblRKFutOptTransaction t
		JOIN tblRKOptionsMonth om ON t.intOptionMonthId = om.intOptionMonthId
		WHERE intFutOptTransactionId = @intFutOptTransactionId
		
		SELECT @NewFutOptTransactionId = SCOPE_IDENTITY();

		DECLARE @NewBuySell NVARCHAR(15) = ''
		DECLARE @intInternalTradeNo1 INT  

		SELECT @NewBuySell = CASE WHEN (strBuySell = 'Buy' AND strOptionType= 'Call') THEN 'Buy'
								WHEN (strBuySell = 'Buy' AND strOptionType= 'Put') THEN 'Sell'
								WHEN (strBuySell = 'Sell' AND strOptionType= 'Call') THEN 'Sell'
								WHEN (strBuySell = 'Sell' AND strOptionType= 'Put') THEN 'Buy' End
		FROM tblRKFutOptTransaction Where intFutOptTransactionId=@NewFutOptTransactionId  

		UPDATE tblSMStartingNumber SET intNumber = ISNULL(intNumber, 0) + 1 WHERE intStartingNumberId = 45
		UPDATE tblRKFutOptTransaction
		SET strBuySell = @NewBuySell
			, strOptionType = null
			, intOptionMonthId = null
		WHERE intFutOptTransactionId = @NewFutOptTransactionId

		DECLARE @UserId INT
		SELECT TOP 1 @UserId = intEntityId FROM tblEMEntity WHERE strName = @strName
		EXEC uspRKFutOptTransactionHistory @NewFutOptTransactionId, @NewFutOptTransactionHeaderId, 'Exercise Options', @UserId, 'ADD'
		
		UPDATE tblRKOptionsPnSExercisedAssigned SET intFutTransactionId = @NewFutOptTransactionId WHERE intOptionsPnSExercisedAssignedId = @intOptionsPnSExercisedAssignedId
		SELECT @mRowNumber = MIN(RowNumber) FROM @tblExercisedAssignedDetail WHERE RowNumber > @mRowNumber
	END
	
	COMMIT TRAN
	EXEC sp_xml_removedocument @idoc
END TRY
BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	IF XACT_STATE() != 0 ROLLBACK TRANSACTION
	IF @idoc <> 0 EXEC sp_xml_removedocument @idoc
	
	If @ErrMsg != ''
	BEGIN
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH
GO