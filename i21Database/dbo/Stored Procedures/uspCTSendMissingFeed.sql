CREATE PROCEDURE [dbo].[uspCTSendMissingFeed]

AS
	DECLARE @Transaction TABLE (
		intTransactionId INT
		,intRecordId INT
		)
	DECLARE @intTransactionId INT
		,@intRecordId INT

	INSERT INTO @Transaction
	SELECT DISTINCT TR.intTransactionId
		,TR.intRecordId
	FROM tblSMTransaction TR WITH (NOLOCK)
	LEFT JOIN tblCTContractFeed FD WITH (NOLOCK) ON FD.intContractHeaderId = TR.intRecordId
	WHERE TR.intScreenId = 11
		AND ISNULL(TR.ysnOnceApproved, 0) = 1
		AND FD.intContractFeedId IS NULL
		AND TR.strTransactionNo NOT LIKE 'CP%'
		AND intTransactionId <> 58191

	SELECT @intTransactionId = MIN(intTransactionId)
	FROM @Transaction

	WHILE ISNULL(@intTransactionId, 0) > 0
	BEGIN
		SELECT @intRecordId = NULL

		SELECT @intRecordId = intRecordId
		FROM @Transaction
		WHERE intTransactionId = @intTransactionId

		SELECT @intRecordId
			,@intTransactionId

		BEGIN TRY
			BEGIN TRAN

			EXEC uspCTContractApproved @intRecordId
				,1
				,NULL
				,1

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			ROLLBACK TRAN

			SELECT ERROR_MESSAGE()
		END CATCH

		SELECT @intTransactionId = MIN(intTransactionId)
		FROM @Transaction
		WHERE intTransactionId > @intTransactionId
	END
