CREATE PROCEDURE [dbo].[uspRKSavePnsOptionsMatched]
	@strXml NVARCHAR(MAX)
	, @strTranNoPNS NVARCHAR(50) OUT

AS    
  
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
	
	DECLARE @idoc INT
	DECLARE @intOptionsMatchPnSHeaderId INT
	DECLARE @strTranNo NVARCHAR(50)
	DECLARE @dtmMatchDate  DATETIME
	DECLARE @dblMatchQty NUMERIC(18,6)
	DECLARE @intLFutOptTransactionId int
	DECLARE @intSFutOptTransactionId int
	DECLARE @strExpiredTranNo NVARCHAR(50)
	DECLARE @strExercisedAssignedNo NVARCHAR(50)
	DECLARE @ErrMsg NVARCHAR(Max)
	
	EXEC sp_xml_preparedocument @idoc OUTPUT, @strXml
	
	BEGIN TRANSACTION
	
	------------------------- Delete Matched ---------------------
	DECLARE @tblMatchedDelete TABLE (strTranNo NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL
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
  
	IF EXISTS(SELECT * FROM @tblMatchedDelete)
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
		FROM tblRKOptionsMatchPnS  p
		JOIN @tblMatchedDelete m ON p.strTranNo=m.strTranNo
		
		DELETE FROM tblRKOptionsMatchPnS
		WHERE CONVERT(INT,strTranNo) IN ( SELECT CONVERT(INT,strTranNo) FROM @tblMatchedDelete)
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
		DELETE FROM tblRKOptionsPnSExpired
		WHERE CONVERT(INT, strTranNo) IN (SELECT CONVERT(INT, strTranNo) FROM @tblExpiredDelete)
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
		WHERE intFutOptTransactionId in (SELECT intFutTransactionId
										FROM tblRKOptionsPnSExercisedAssigned
										WHERE CONVERT(INT, strTranNo) IN (SELECT CONVERT(INT, strTranNo)
																		FROM @tblExercisedAssignedDelete))
		
		DELETE FROM tblRKFutOptTransaction
		WHERE intFutOptTransactionId IN (SELECT intFutTransactionId
										FROM tblRKOptionsPnSExercisedAssigned
										WHERE convert(int,strTranNo) in( SELECT convert(int,strTranNo) from @tblExercisedAssignedDelete))
										
		DELETE FROM tblRKOptionsPnSExercisedAssigned
		WHERE CONVERT(INT, strTranNo) IN (SELECT CONVERT(INT,strTranNo) from @tblExercisedAssignedDelete)
	END
	
	------------------------- END Delete ExercisedAssigned ---------------------
	---------------Header Record Insert ----------------
	
	INSERT INTO tblRKOptionsMatchPnSHeader (intConcurrencyId) VALUES (1)  
  
	SELECT @intOptionsMatchPnSHeaderId = SCOPE_IDENTITY();
	---------------Matched Record Insert ----------------
	
	SELECT @strTranNo = ISNULL(MAX(CONVERT(INT, strTranNo)), 0) FROM tblRKOptionsMatchPnS
	
	INSERT INTO tblRKOptionsMatchPnS (intOptionsMatchPnSHeaderId
		, strTranNo
		, dtmMatchDate
		, dblMatchQty
		, intLFutOptTransactionId
		, intSFutOptTransactionId
		, intConcurrencyId)
	
	SELECT @intOptionsMatchPnSHeaderId as intOptionsMatchPnSHeaderId
		, @strTranNo + ROW_NUMBER()over(order by intLFutOptTransactionId)strTranNo
		, dtmMatchDate
		, dblMatchQty
		, intLFutOptTransactionId
		, intSFutOptTransactionId
		, 1 as intConcurrencyId
	FROM OPENXML(@idoc,'root/Transaction', 2)
	WITH ([intOptionsMatchPnSHeaderId] INT
		, [dtmMatchDate] DATETIME
		, [dblMatchQty] NUMERIC(18,6)
		, [intLFutOptTransactionId] INT
		, [intSFutOptTransactionId] INT)
	
	DECLARE @strName NVARCHAR(100) = ''
	SELECT @strName = [userName]
	FROM OPENXML(@idoc,'root/Transaction', 2)
	WITH ([userName] NVARCHAR(max))
	
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
	
	---------------Expired Record Insert ----------------
	SELECT @strExpiredTranNo = ISNULL(MAX(CONVERT(INT, strTranNo)),0) FROM tblRKOptionsPnSExpired
	
	INSERT INTO tblRKOptionsPnSExpired (intOptionsMatchPnSHeaderId
		, strTranNo
		, dtmExpiredDate
		, dblLots
		, intFutOptTransactionId
		, intConcurrencyId)
	SELECT @intOptionsMatchPnSHeaderId as intOptionsMatchPnSHeaderId
		, @strExpiredTranNo + ROW_NUMBER() OVER(ORDER BY intFutOptTransactionId) strTranNo
		, dtmExpiredDate
		, dblLots
		, intFutOptTransactionId
		, 1 as intConcurrencyId
	FROM OPENXML(@idoc,'root/Expired', 2)
	WITH ([dtmExpiredDate] DATETIME
		, [dblLots] NUMERIC(18,6)
		, [intFutOptTransactionId] INT)
	
	---------------Exercised/Assigned Record Insert ----------------
	DECLARE @tblExercisedAssignedDetail TABLE (RowNumber INT IDENTITY(1,1)
		, intFutOptTransactionId INT
		, dblLots NUMERIC(18,6)
		, dtmTranDate DATETIME
		, ysnAssigned BIT)
	
	INSERT INTO @tblExercisedAssignedDetail
	SELECT intFutOptTransactionId
		, dblLots
		, dtmTranDate
		, ysnAssigned
	FROM OPENXML(@idoc,'root/ExercisedAssigned', 2)
	WITH ([intFutOptTransactionId] INT
		, [dblLots] NUMERIC(18,6)
		, [dtmTranDate] DATETIME
		, [ysnAssigned] BIT)
	
	DECLARE @mRowNumber INT
		, @intFutOptTransactionId INT
		, @NewFutOptTransactionId INT
		, @NewFutOptTransactionHeaderId INT
		, @dblLots NUMERIC(18,6)
		, @dtmTranDate DATETIME
		, @intInternalTradeNo INT
		, @ysnAssigned BIT
	
	SELECT @mRowNumber = MIN(RowNumber) FROM @tblExercisedAssignedDetail
	
	WHILE @mRowNumber IS NOT NULL
	BEGIN
		DECLARE @intOptionsPnSExercisedAssignedId INT
			, @strSelectedInstrumentType NVARCHAR(100)
			, @intSelectedInstrumentTypeId INT
		SELECT @strExercisedAssignedNo = ISNULL(MAX(CONVERT(INT, strTranNo)), 0) + 1 FROM tblRKOptionsPnSExercisedAssigned
		SELECT @intFutOptTransactionId = intFutOptTransactionId
			, @dblLots = dblLots
			, @dtmTranDate = dtmTranDate
			, @ysnAssigned = ysnAssigned
		FROM @tblExercisedAssignedDetail
		WHERE RowNumber = @mRowNumber
		
		SELECT @intSelectedInstrumentTypeId = intSelectedInstrumentTypeId
			, @strSelectedInstrumentType = CASE WHEN ISNULL(intSelectedInstrumentTypeId, 1) = 1 then 'Exchange Traded'
												WHEN intSelectedInstrumentTypeId = 2 THEN 'OTC'
												ELSE 'OTC - Others' END
		FROM tblRKFutOptTransaction
		WHERE intFutOptTransactionId = @intFutOptTransactionId
		
		INSERT INTO tblRKFutOptTransactionHeader (intConcurrencyId
			, dtmTransactionDate
			, intSelectedInstrumentTypeId
			, strSelectedInstrumentType)
		VALUES (1, @dtmTranDate, @intSelectedInstrumentTypeId, @strSelectedInstrumentType)
		SELECT @NewFutOptTransactionHeaderId = SCOPE_IDENTITY()
		
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
		SELECT @strTranNo = strTranNo
		FROM tblRKOptionsPnSExercisedAssigned
		WHERE intOptionsPnSExercisedAssignedId = @intOptionsPnSExercisedAssignedId
		
		----------------- Created Future Transaction Based on the Option Transaction ----------------------------------
		SELECT @intInternalTradeNo = intNumber FROM tblSMStartingNumber WHERE intStartingNumberId = 45
		
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
			, @intSelectedInstrumentTypeId
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
			, @dblLots as dblLots
			, om.intFutureMonthId as intFutureMonthId
			, t.intOptionMonthId
			, t.strOptionType
			, ISNULL(t.dblStrike,0.0) as dblStrike
			, CASE WHEN strBuySell = 'Buy' THEN 'This futures transaction was the result of Option No. (' + @strTranNo + ') being exercised on (' + CONVERT(NVARCHAR, @dtmTranDate, 101) + ')'
				ELSE 'This futures transaction was the result of Option No. (' + @strTranNo + ') being assigned on (' + CONVERT(NVARCHAR, @dtmTranDate, 101) + ')' END strReference
			, t.strStatus
			, @dtmTranDate as dtmFilledDate
			, t.strReserveForFix
			, t.intBookId
			, t.intSubBookId
			, t.ysnOffset
			, GETDATE()
		FROM tblRKFutOptTransaction t
		JOIN tblRKOptionsMonth om on t.intOptionMonthId=om.intOptionMonthId WHERE intFutOptTransactionId =@intFutOptTransactionId
		
		SELECT @NewFutOptTransactionId = SCOPE_IDENTITY();
		
		DECLARE @NewBuySell NVARCHAR(15) = ''
		DECLARE @intInternalTradeNo1 INT
		
		SELECT @NewBuySell = CASE WHEN (strBuySell = 'Buy' AND strOptionType = 'Call') THEN 'Buy'
								WHEN (strBuySell = 'Buy' AND strOptionType = 'Put') THEN 'Sell'
								WHEN (strBuySell = 'Sell' AND strOptionType = 'Call') THEN 'Sell'
								WHEN (strBuySell = 'Sell' AND strOptionType = 'Put') THEN 'Buy' END
		FROM tblRKFutOptTransaction
		WHERE intFutOptTransactionId = @NewFutOptTransactionId
		
		UPDATE tblSMStartingNumber SET intNumber = ISNULL(intNumber, 0) + 1 WHERE intStartingNumberId = 45
		
		UPDATE tblRKFutOptTransaction
		SET strBuySell = @NewBuySell
			, strOptionType = null
			, intOptionMonthId = null
		WHERE intFutOptTransactionId = @NewFutOptTransactionId

		DECLARE @intUserId INT
		SELECT TOP 1 @intUserId = intEntityId FROM tblEMEntity WHERE strName = @strName

		EXEC [uspRKFutOptTransactionHistory] @intFutOptTransactionId = @NewFutOptTransactionId
			, @intFutOptTransactionHeaderId = @NewFutOptTransactionHeaderId
			, @strScreenName = 'Option Lifecycle'
			, @intUserId = @intUserId
			, @action = 'ADD'
		
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
	IF (@ErrMsg != '')
	BEGIN
		RAISERROR(@ErrMsg, 16, 1, 'WITH NOWAIT')
	END
END CATCH
GO