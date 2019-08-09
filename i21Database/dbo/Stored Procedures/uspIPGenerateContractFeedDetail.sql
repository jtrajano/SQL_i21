CREATE PROCEDURE uspIPGenerateContractFeedDetail
AS
BEGIN TRY
	DECLARE @intContractFeedId INT
		,@intRecordId INT
		,@intContractHeaderId INT
		,@strHeaderCondition NVARCHAR(MAX)
		,@strApproverXML NVARCHAR(MAX)
		,@intContractFeedHeaderId INT
		,@strContractNumber NVARCHAR(50)
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
	DECLARE @tblIPContractFeedHeader TABLE (
		intRecordId INT identity(1, 1)
		,intContractHeaderId INT
		,strContractNumber NVARCHAR(50)
		)
	DECLARE @tblIPContractFeedDetail TABLE (
		intContractFeedId INT
		,intContractHeaderId INT
		,strContractNumber NVARCHAR(50)
		)

	SELECT @intContractFeedId = MAX(intContractFeedId)
	FROM tblIPContractFeedDetail

	IF @intContractFeedId IS NULL
		SELECT @intContractFeedId = 0

	INSERT INTO @tblIPContractFeedDetail (
		intContractFeedId
		,intContractHeaderId
		,strContractNumber
		)
	SELECT intContractFeedId
		,intContractHeaderId
		,strContractNumber
	FROM tblCTContractFeed
	WHERE intContractFeedId > @intContractFeedId

	INSERT INTO @tblIPContractFeedHeader (
		intContractHeaderId
		,strContractNumber
		)
	SELECT DISTINCT intContractHeaderId
		,strContractNumber
	FROM @tblIPContractFeedDetail

	SELECT @intRecordId = min(intRecordId)
	FROM @tblIPContractFeedHeader

	WHILE @intRecordId IS NOT NULL
	BEGIN
		SELECT @intContractHeaderId = NULL
			,@strContractNumber = NULL
			,@strHeaderCondition = NULL
			,@intContractFeedHeaderId = NULL

		SELECT @intContractHeaderId = intContractHeaderId
			,@strContractNumber = strContractNumber
		FROM @tblIPContractFeedHeader
		WHERE intRecordId = @intRecordId

		---------------------------------------------Approver------------------------------------------
		SELECT @strApproverXML = NULL

		SELECT @strHeaderCondition = 'strContractNumber = ''' + @strContractNumber + ''''

		EXEC [dbo].[uspCTGetTableDataInXML] 'vyuCTContractApproverView'
			,@strHeaderCondition
			,@strApproverXML OUTPUT
			,NULL
			,NULL

		IF @strApproverXML IS NOT NULL
		BEGIN
			SELECT @intTransactionCount = @@TRANCOUNT

			BEGIN TRY
				IF @intTransactionCount = 0
					BEGIN TRANSACTION

				INSERT INTO tblIPContractFeedHeader (
					intContractHeaderId
					,strApproverXML
					)
				SELECT @intContractHeaderId
					,@strApproverXML

				SELECT @intContractFeedHeaderId = SCOPE_IDENTITY();

				INSERT INTO tblIPContractFeedDetail (
					intContractFeedHeaderId
					,intContractFeedId
					)
				SELECT @intContractFeedHeaderId
					,intContractFeedId
				FROM @tblIPContractFeedDetail
				WHERE intContractHeaderId = @intContractHeaderId

				IF @intTransactionCount = 0
					COMMIT TRANSACTION
			END TRY

			BEGIN CATCH
				IF XACT_STATE() != 0
					AND @intTransactionCount = 0
					ROLLBACK TRANSACTION
			END CATCH
		END

		SELECT @intRecordId = min(intRecordId)
		FROM @tblIPContractFeedHeader
		WHERE intRecordId > @intRecordId
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
