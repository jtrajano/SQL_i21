CREATE PROCEDURE uspIPProcessContractFeedDetail
AS
BEGIN TRY
	DECLARE @intContractFeedHeaderId INT
		,@intContractHeaderId INT
		,@strApproverXML NVARCHAR(MAX)
		,@strSubmittedByXML  NVARCHAR(MAX)
		,@intContractHeaderRefId INT
		,@strErrorMessage NVARCHAR(MAX)
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@idoc INT

	SELECT @intContractFeedHeaderId = MIN(intContractFeedHeaderId)
	FROM tblIPContractFeedHeader
	WHERE strFeedStatus IS NULL

	WHILE @intContractFeedHeaderId IS NOT NULL
	BEGIN
		SELECT @intContractHeaderId = NULL
			,@strApproverXML = NULL
			,@intContractHeaderRefId = NULL
			,@strSubmittedByXML=NULL

		SELECT @intContractHeaderId = intContractHeaderId
			,@strApproverXML = strApproverXML
			,@strSubmittedByXML = strSubmittedByXML
		FROM tblIPContractFeedHeader
		WHERE intContractFeedHeaderId = @intContractFeedHeaderId

		SELECT @intContractHeaderRefId = intContractHeaderId
		FROM tblCTContractHeader
		WHERE intContractHeaderRefId = @intContractHeaderId

		EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strApproverXML

		BEGIN TRY
			IF EXISTS (
					SELECT *
					FROM OPENXML(@idoc, 'vyuCTContractApproverViews/vyuCTContractApproverView', 2) WITH (strName NVARCHAR(100) Collate Latin1_General_CI_AS) x
					LEFT JOIN tblEMEntity U ON U.strName = x.strName
					WHERE U.strName IS NULL
					)
			BEGIN
				SELECT @strErrorMessage = 'Approver ' + x.strName + ' is not available.'
				FROM OPENXML(@idoc, 'vyuCTContractApproverViews/vyuCTContractApproverView', 2) WITH (strName NVARCHAR(100) Collate Latin1_General_CI_AS) x
				LEFT JOIN tblEMEntity U ON U.strName = x.strName
				WHERE U.strName IS NULL

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			DELETE
			FROM tblCTIntrCompApproval
			WHERE intContractHeaderId = @intContractHeaderRefId
			AND ysnApproval=1
			AND intPriceFixationId is NULL

			INSERT INTO tblCTIntrCompApproval (
				intContractHeaderId
				,strName
				,strUserName
				,strScreen
				,intConcurrencyId
				,ysnApproval
				)
			SELECT @intContractHeaderRefId
				,strName
				,strUserName
				,strScreenName
				,1 AS intConcurrencyId
				,1
			FROM OPENXML(@idoc, 'vyuCTContractApproverViews/vyuCTContractApproverView', 2) WITH (
					strName NVARCHAR(100) Collate Latin1_General_CI_AS
					,strUserName NVARCHAR(100) Collate Latin1_General_CI_AS
					,strScreenName NVARCHAR(250) Collate Latin1_General_CI_AS
					) x

			EXEC sp_xml_removedocument @idoc

			EXEC sp_xml_preparedocument @idoc OUTPUT
			,@strSubmittedByXML
				
			DELETE
			FROM tblCTIntrCompApproval
			WHERE intContractHeaderId = @intContractHeaderRefId
			AND ysnApproval=0
			AND intPriceFixationId is NULL

			INSERT INTO tblCTIntrCompApproval (
				intContractHeaderId
				,strName
				,strUserName
				,strScreen
				,intConcurrencyId
				,ysnApproval
				)
			SELECT @intContractHeaderRefId
				,strName
				,strUserName
				,strScreenName
				,1 AS intConcurrencyId
				,0
			FROM OPENXML(@idoc, 'vyuIPContractSubmittedByViews/vyuIPContractSubmittedByView', 2) WITH (
					strName NVARCHAR(100) Collate Latin1_General_CI_AS
					,strUserName NVARCHAR(100) Collate Latin1_General_CI_AS
					,strScreenName NVARCHAR(250) Collate Latin1_General_CI_AS
					) x

			UPDATE tblIPContractFeedHeader
			SET strFeedStatus = 'Processed'
				,strMessage = NULL
				,intStatusId =1
			WHERE intContractFeedHeaderId = @intContractFeedHeaderId

			EXEC sp_xml_removedocument @idoc

			IF @intTransactionCount = 0
				COMMIT TRANSACTION
		END TRY

		BEGIN CATCH
			SET @ErrMsg = ERROR_MESSAGE()

			IF @idoc <> 0
				EXEC sp_xml_removedocument @idoc

			IF XACT_STATE() != 0
				AND @intTransactionCount = 0
				ROLLBACK TRANSACTION

			UPDATE tblIPContractFeedHeader
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
				,intStatusId =0
			WHERE intContractFeedHeaderId = @intContractFeedHeaderId
		END CATCH

		SELECT @intContractFeedHeaderId = MIN(intContractFeedHeaderId)
		FROM tblIPContractFeedHeader
		WHERE strFeedStatus IS NULL
			AND intContractFeedHeaderId > @intContractFeedHeaderId
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
