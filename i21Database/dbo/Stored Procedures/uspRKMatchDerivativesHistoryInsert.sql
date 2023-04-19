CREATE PROCEDURE uspRKMatchDerivativesHistoryInsert
	  @intMatchFuturesPSHeaderId INT
	, @action NVARCHAR(20)
	, @userId INT
	, @intMatchFuturesPSDetailId INT = NULL
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 

DECLARE @SummaryLog AS RKSummaryLog

-- MATCH HEADER CREATE/DELETE
IF (ISNULL(@intMatchFuturesPSDetailId, 0) = 0)
BEGIN
	-- Create the entry for Match Derivative History
	IF @action = 'ADD' 
	BEGIN
		INSERT INTO tblRKMatchDerivativesHistory(
			 intMatchFuturesPSHeaderId
			,intMatchFuturesPSDetailId
			,dblMatchQty
			,dtmMatchDate
			,dblFutCommission
			,intLFutOptTransactionId
			,intSFutOptTransactionId
			,dtmTransactionDate
			,strUserName
		)
		SELECT
			 H.intMatchFuturesPSHeaderId	
			,D.intMatchFuturesPSDetailId
			,D.dblMatchQty
			,H.dtmMatchDate
			,D.dblFutCommission
			,D.intLFutOptTransactionId
			,D.intSFutOptTransactionId
			,GETDATE()
			,(SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = @userId)
		FROM 
		tblRKMatchFuturesPSHeader H
		INNER JOIN tblRKMatchFuturesPSDetail D ON H.intMatchFuturesPSHeaderId = D.intMatchFuturesPSHeaderId
		WHERE H.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId

		IF @@ERROR <> 0	GOTO _Rollback
	END
	ELSE --FOR DELETE
	BEGIN
		DECLARE @intMatchNo INT
			, @strUserName NVARCHAR(200)

		SELECT @intMatchNo = intMatchNo FROM tblRKMatchFuturesPSHeader WHERE intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
		SELECT TOP 1 @strUserName = strName FROM tblEMEntity WHERE intEntityId = @userId 

		IF ISNULL(@intMatchNo, 0) <> 0 AND ISNULL(@strUserName, '') <> ''
		BEGIN
			EXEC uspRKPostUnpostToSAPStaging @intMatchNo, 0, @strUserName
		END
		
		SELECT intFutOptTransactionId
		INTO #tmpDerivativesToDelete 
		FROM (
			SELECT intFutOptTransactionId = intLFutOptTransactionId
			FROM tblRKMatchDerivativesHistory H
			WHERE H.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId

			UNION ALL

			SELECT intFutOptTransactionId = intSFutOptTransactionId
			FROM tblRKMatchDerivativesHistory H
			WHERE H.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
		) t

		INSERT INTO tblRKMatchDerivativesHistory(
			 intMatchFuturesPSHeaderId
			,intMatchFuturesPSDetailId
			,dblMatchQty
			,dtmMatchDate
			,dblFutCommission
			,intLFutOptTransactionId
			,intSFutOptTransactionId
			,dtmTransactionDate
			,strUserName
		)
		SELECT
			 intMatchFuturesPSHeaderId	
			,intMatchFuturesPSDetailId
			,dblMatchQty * -1
			,dtmMatchDate
			,dblFutCommission * -1
			,intLFutOptTransactionId
			,intSFutOptTransactionId
			,GETDATE()
			,(SELECT TOP 1 strName FROM tblEMEntity WHERE intEntityId = @userId)
		FROM 
		tblRKMatchDerivativesHistory H
		WHERE H.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId

		INSERT INTO @SummaryLog(strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intFutOptTransactionId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutureMarketId
			, intFutureMonthId
			, dblNoOfLots
			, dblPrice
			, dblContractSize
			, intEntityId
			, intUserId
			, intCommodityUOMId
			, strMiscFields
			, intActionId)
		SELECT strBucketType
			, strTransactionType
			, intTransactionRecordId
			, intTransactionRecordHeaderId
			, strDistributionType
			, strTransactionNumber
			, dtmTransactionDate
			, intFutOptTransactionId
			, intCommodityId
			, intLocationId
			, intBookId
			, intSubBookId
			, intFutureMarketId
			, intFutureMonthId
			, dblNoOfLots =  dblOrigNoOfLots * -1
			, dblPrice
			, dblContractSize
			, intEntityId
			, intUserId = @userId
			, intCommodityUOMId = intOrigUOMId
			, strMiscFields = strMiscField
			, intActionId = 68
		FROM tblRKSummaryLog  
		WHERE strTransactionType = 'Match Derivatives'  
		AND intTransactionRecordHeaderId = @intMatchFuturesPSHeaderId
		AND intFutOptTransactionId IN (SELECT intFutOptTransactionId
										 FROM #tmpDerivativesToDelete)

		EXEC uspRKLogRiskPosition @SummaryLog
	

		DROP TABLE #tmpDerivativesToDelete

		IF @@ERROR <> 0	GOTO _Rollback

	END
END
-- MATCH DETAIL CREATE/DELETE
ELSE
BEGIN 
	DECLARE @strName NVARCHAR(200) = '' 
		, @dtmCurrentDate DATETIME = GETDATE()

	SELECT TOP 1 @strName = strName FROM tblEMEntity WHERE intEntityId = @userId

	-- Create the entry for Match Derivative History
	IF @action = 'ADD DETAIL' 
	BEGIN
		INSERT INTO tblRKMatchDerivativesHistory(
			  intMatchFuturesPSHeaderId
			, intMatchFuturesPSDetailId
			, dblMatchQty
			, dtmMatchDate
			, dblFutCommission
			, intLFutOptTransactionId
			, intSFutOptTransactionId
			, dtmTransactionDate
			, strUserName
		)
		SELECT
			  H.intMatchFuturesPSHeaderId	
			, D.intMatchFuturesPSDetailId
			, D.dblMatchQty
			, H.dtmMatchDate
			, D.dblFutCommission
			, D.intLFutOptTransactionId
			, D.intSFutOptTransactionId
			, @dtmCurrentDate
			, @strName
		FROM 
		tblRKMatchFuturesPSHeader H
		INNER JOIN tblRKMatchFuturesPSDetail D ON H.intMatchFuturesPSHeaderId = D.intMatchFuturesPSHeaderId
		WHERE H.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
		AND D.intMatchFuturesPSDetailId = @intMatchFuturesPSDetailId

		IF @@ERROR <> 0	GOTO _Rollback
	END

	ELSE IF @action = 'DELETE DETAIL'
	BEGIN

		INSERT INTO tblRKMatchDerivativesHistory(
			  intMatchFuturesPSHeaderId
			, intMatchFuturesPSDetailId
			, dblMatchQty
			, dtmMatchDate
			, dblFutCommission
			, intLFutOptTransactionId
			, intSFutOptTransactionId
			, dtmTransactionDate
			, strUserName
		)
		SELECT
			  intMatchFuturesPSHeaderId	
			, intMatchFuturesPSDetailId
			, dblMatchQty * -1
			, dtmMatchDate
			, dblFutCommission * -1
			, intLFutOptTransactionId
			, intSFutOptTransactionId
			, @dtmCurrentDate
			, @strName
		FROM 
		tblRKMatchDerivativesHistory H
		WHERE H.intMatchFuturesPSHeaderId = @intMatchFuturesPSHeaderId
		AND H.intMatchFuturesPSDetailId = @intMatchFuturesPSDetailId

		IF @@ERROR <> 0	GOTO _Rollback
	END
END

GOTO _Commit
--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
_Commit:
	COMMIT TRANSACTION
	GOTO _Exit
	
_Rollback:
	ROLLBACK TRANSACTION

_Exit: