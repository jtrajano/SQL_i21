CREATE PROCEDURE uspRKMatchDerivativesHistoryInsert
	 @intMatchFuturesPSHeaderId INT
	,@action NVARCHAR(20)
	,@userId INT
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

BEGIN TRANSACTION 



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

	IF @@ERROR <> 0	GOTO _Rollback

--=====================================================================================================================================
-- 	EXIT ROUTINES
---------------------------------------------------------------------------------------------------------------------------------------
_Commit:
	COMMIT TRANSACTION
	GOTO _Exit
	
_Rollback:
	ROLLBACK TRANSACTION

_Exit: