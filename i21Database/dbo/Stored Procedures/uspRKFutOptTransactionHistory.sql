CREATE PROCEDURE [dbo].[uspRKFutOptTransactionHistory] @intFutOptTransactionId INT = NULL
	,@intNewNoOfContract INT = NULL
	,@strScreenName NVARCHAR(100) = NULL
	,@strNewBuySell NVARCHAR(10) = NULL
	,@intUserId INT = NULL
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
		,@strUserName NVARCHAR(100)
		,@intOldNoOfContract INT
		,@strOldBuySell NVARCHAR(10)

	SELECT TOP 1 @intOldNoOfContract = intNewNoOfContract
		,@strOldBuySell = strNewBuySell
	FROM [tblRKFutOptTransactionHistory]
	WHERE intFutOptTransactionId = @intFutOptTransactionId
	ORDER BY intFutOptTransactionHistoryId DESC

	SELECT @strUserName = strName
	FROM tblEMEntity
	WHERE intEntityId = @intUserId

	IF NOT EXISTS (
			SELECT intFutOptTransactionId
			FROM tblRKFutOptTransaction
			WHERE intFutOptTransactionId = @intFutOptTransactionId
			)
	BEGIN
	INSERT INTO tblRKFutOptTransactionHistory (
				intFutOptTransactionId
				,intOldNoOfContract
				,intNewNoOfContract
				,intBalanceContract
				,strScreenName
				,strOldBuySell
				,strNewBuySell
				,dtmTransactionDate
				,strUserName
				)
			SELECT @intFutOptTransactionId
				,isnull(@intNewNoOfContract, 0)
				,-isnull(@intNewNoOfContract, 0)
				,-isnull(@intNewNoOfContract, 0)
				,@strScreenName
				,@strOldBuySell
				,@strNewBuySell
				,getdate()
				,@strUserName
	END
	ELSE
	BEGIN
		IF NOT EXISTS (
				SELECT intFutOptTransactionId
				FROM [tblRKFutOptTransactionHistory]
				WHERE intFutOptTransactionId = @intFutOptTransactionId
				)
		BEGIN
			INSERT INTO tblRKFutOptTransactionHistory (
				intFutOptTransactionId
				,intOldNoOfContract
				,intNewNoOfContract
				,intBalanceContract
				,strScreenName
				,strOldBuySell
				,strNewBuySell
				,dtmTransactionDate
				,strUserName
				)
			SELECT @intFutOptTransactionId
				,0
				,isnull(@intNewNoOfContract, 0)
				,isnull(@intNewNoOfContract, 0)
				,@strScreenName
				,@strOldBuySell
				,@strNewBuySell
				,getdate()
				,@strUserName
		END
		ELSE
		BEGIN
			IF ((@intOldNoOfContract <> @intNewNoOfContract) OR (@strOldBuySell <> @strNewBuySell))
				INSERT INTO tblRKFutOptTransactionHistory (
					intFutOptTransactionId
					,intOldNoOfContract
					,intNewNoOfContract
					,intBalanceContract
					,strScreenName
					,strOldBuySell
					,strNewBuySell
					,dtmTransactionDate
					,strUserName
					)
				SELECT @intFutOptTransactionId
					,isnull(@intOldNoOfContract, 0)
					,isnull(@intNewNoOfContract, 0)
					,isnull(@intNewNoOfContract, 0) - isnull(@intOldNoOfContract, 0)
					,@strScreenName
					,@strOldBuySell
					,@strNewBuySell
					,getdate()
					,@strUserName
		END
	END
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()

	RAISERROR (
			@ErrMsg
			,16
			,1
			,'WITH NOWAIT'
			)
END CATCH