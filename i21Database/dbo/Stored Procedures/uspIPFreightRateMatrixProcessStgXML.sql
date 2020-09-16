CREATE PROCEDURE uspIPFreightRateMatrixProcessStgXML
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @idoc INT
		,@intTransactionCount INT
		,@ErrMsg NVARCHAR(MAX)
		,@strErrorMessage NVARCHAR(MAX)
	DECLARE @intFreightRateMatrixStageId INT
		,@intFreightRateMatrixId INT
		,@strHeaderXML NVARCHAR(MAX)
		,@strRowState NVARCHAR(MAX)
		,@intMultiCompanyId INT
		,@strUserName NVARCHAR(100)
	DECLARE @strName NVARCHAR(100)
		,@strCurrency NVARCHAR(40)
		,@strContainerType NVARCHAR(50)
	DECLARE @intEntityId INT
		,@intCurrencyId INT
		,@intContainerTypeId INT
		,@intLastModifiedUserId INT
		,@intNewFreightRateMatrixId INT
		,@intFreightRateMatrixRefId INT
	DECLARE @tblLGFreightRateMatrixStage TABLE (intFreightRateMatrixStageId INT)

	INSERT INTO @tblLGFreightRateMatrixStage (intFreightRateMatrixStageId)
	SELECT intFreightRateMatrixStageId
	FROM tblLGFreightRateMatrixStage
	WHERE ISNULL(strFeedStatus, '') = ''

	SELECT @intFreightRateMatrixStageId = MIN(intFreightRateMatrixStageId)
	FROM @tblLGFreightRateMatrixStage

	IF @intFreightRateMatrixStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblLGFreightRateMatrixStage t
	JOIN @tblLGFreightRateMatrixStage pt ON pt.intFreightRateMatrixStageId = t.intFreightRateMatrixStageId

	WHILE @intFreightRateMatrixStageId > 0
	BEGIN
		SELECT @intFreightRateMatrixId = NULL
			,@strHeaderXML = NULL
			,@strRowState = NULL
			,@intMultiCompanyId = NULL
			,@strUserName = NULL

		SELECT @intFreightRateMatrixId = intFreightRateMatrixId
			,@strHeaderXML = strHeaderXML
			,@strRowState = strRowState
			,@intMultiCompanyId = intMultiCompanyId
			,@strUserName = strUserName
		FROM tblLGFreightRateMatrixStage
		WHERE intFreightRateMatrixStageId = @intFreightRateMatrixStageId

		BEGIN TRY
			SELECT @intFreightRateMatrixRefId = @intFreightRateMatrixId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strName = NULL
				,@strCurrency = NULL
				,@strContainerType = NULL

			SELECT @strName = strName
				,@strCurrency = strCurrency
				,@strContainerType = strContainerType
			FROM OPENXML(@idoc, 'vyuIPGetFreightRateMatrixs/vyuIPGetFreightRateMatrix', 2) WITH (
					strName NVARCHAR(100) Collate Latin1_General_CI_AS
					,strCurrency NVARCHAR(40) Collate Latin1_General_CI_AS
					,strContainerType NVARCHAR(50) Collate Latin1_General_CI_AS
					) x

			IF @strName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblEMEntity t
					WHERE t.strName = @strName
					)
			BEGIN
				SELECT @strErrorMessage = 'Shipping Line ' + @strName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strCurrency IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblSMCurrency t
					WHERE t.strCurrency = @strCurrency
					)
			BEGIN
				SELECT @strErrorMessage = 'Currency ' + @strCurrency + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strContainerType IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblLGContainerType t
					WHERE t.strContainerType = @strContainerType
					)
			BEGIN
				SELECT @strErrorMessage = 'Container Type ' + @strContainerType + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			SELECT @intEntityId = NULL
				,@intCurrencyId = NULL
				,@intContainerTypeId = NULL
				,@intLastModifiedUserId = NULL

			SELECT @intEntityId = t.intEntityId
			FROM tblEMEntity t
			WHERE t.strName = @strName

			SELECT @intCurrencyId = t.intCurrencyID
			FROM tblSMCurrency t
			WHERE t.strCurrency = @strCurrency

			SELECT @intContainerTypeId = t.intContainerTypeId
			FROM tblLGContainerType t
			WHERE t.strContainerType = @strContainerType

			SELECT @intLastModifiedUserId = t.intEntityId
			FROM tblEMEntity t
			JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'User'
				AND t.strName = @strUserName
				AND t.strEntityNo <> ''

			IF @intLastModifiedUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity
			END

			IF @strRowState <> 'Delete'
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblLGFreightRateMatrix
						WHERE intFreightRateMatrixRefId = @intFreightRateMatrixRefId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewFreightRateMatrixId = @intFreightRateMatrixRefId

				DELETE
				FROM tblLGFreightRateMatrix
				WHERE intFreightRateMatrixRefId = @intFreightRateMatrixRefId
				
				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				INSERT INTO tblLGFreightRateMatrix (
					intEntityId
					,intType
					,strServiceContractNo
					,dtmDate
					,dtmValidFrom
					,dtmValidTo
					,strOriginPort
					,strDestinationCity
					,intLeadTime
					,dblBasicCost
					,intCurrencyId
					,intContainerTypeId
					,dblFuelCost
					,dblAdditionalCost
					,dblTerminalHandlingCharges
					,dblDestinationDeliveryCharges
					,dblTotalCostPerContainer
					,intConcurrencyId
					,intFreightRateMatrixRefId
					)
				SELECT @intEntityId
					,intType
					,strServiceContractNo
					,dtmDate
					,dtmValidFrom
					,dtmValidTo
					,strOriginPort
					,strDestinationCity
					,intLeadTime
					,dblBasicCost
					,@intCurrencyId
					,@intContainerTypeId
					,dblFuelCost
					,dblAdditionalCost
					,dblTerminalHandlingCharges
					,dblDestinationDeliveryCharges
					,dblTotalCostPerContainer
					,1
					,@intFreightRateMatrixRefId
				FROM OPENXML(@idoc, 'vyuIPGetFreightRateMatrixs/vyuIPGetFreightRateMatrix', 2) WITH (
						[intType] INT
						,[strServiceContractNo] NVARCHAR(100)
						,[dtmDate] DATETIME
						,[dtmValidFrom] DATETIME
						,[dtmValidTo] DATETIME
						,[strOriginPort] NVARCHAR(100)
						,[strDestinationCity] NVARCHAR(100)
						,[intLeadTime] INT
						,[dblBasicCost] NUMERIC(18, 6)
						,[dblFuelCost] NUMERIC(18, 6)
						,[dblAdditionalCost] NUMERIC(18, 6)
						,[dblTerminalHandlingCharges] NUMERIC(18, 6)
						,[dblDestinationDeliveryCharges] NUMERIC(18, 6)
						,[dblTotalCostPerContainer] NUMERIC(18, 6)
						)

				SELECT @intNewFreightRateMatrixId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblLGFreightRateMatrix
				SET intEntityId = @intEntityId
					,intType = x.intType
					,strServiceContractNo = x.strServiceContractNo
					,dtmDate = x.dtmDate
					,dtmValidFrom = x.dtmValidFrom
					,dtmValidTo = x.dtmValidTo
					,strOriginPort = x.strOriginPort
					,strDestinationCity = x.strDestinationCity
					,intLeadTime = x.intLeadTime
					,dblBasicCost = x.dblBasicCost
					,intCurrencyId = @intCurrencyId
					,intContainerTypeId = @intContainerTypeId
					,dblFuelCost = x.dblFuelCost
					,dblAdditionalCost = x.dblAdditionalCost
					,dblTerminalHandlingCharges = x.dblTerminalHandlingCharges
					,dblDestinationDeliveryCharges = x.dblDestinationDeliveryCharges
					,dblTotalCostPerContainer = x.dblTotalCostPerContainer
					,intConcurrencyId = intConcurrencyId + 1
				FROM OPENXML(@idoc, 'vyuIPGetFreightRateMatrixs/vyuIPGetFreightRateMatrix', 2) WITH (
						[intType] INT
						,[strServiceContractNo] NVARCHAR(100)
						,[dtmDate] DATETIME
						,[dtmValidFrom] DATETIME
						,[dtmValidTo] DATETIME
						,[strOriginPort] NVARCHAR(100)
						,[strDestinationCity] NVARCHAR(100)
						,[intLeadTime] INT
						,[dblBasicCost] NUMERIC(18, 6)
						,[dblFuelCost] NUMERIC(18, 6)
						,[dblAdditionalCost] NUMERIC(18, 6)
						,[dblTerminalHandlingCharges] NUMERIC(18, 6)
						,[dblDestinationDeliveryCharges] NUMERIC(18, 6)
						,[dblTotalCostPerContainer] NUMERIC(18, 6)
						) x
				WHERE tblLGFreightRateMatrix.intFreightRateMatrixRefId = @intFreightRateMatrixRefId
				
				SELECT @intNewFreightRateMatrixId = intFreightRateMatrixId
				FROM tblLGFreightRateMatrix
				WHERE intFreightRateMatrixRefId = @intFreightRateMatrixRefId
			END

			ext:

			EXEC sp_xml_removedocument @idoc

			UPDATE tblLGFreightRateMatrixStage
			SET strFeedStatus = 'Processed'
				,strMessage = 'Success'
				,intStatusId = 1
			WHERE intFreightRateMatrixStageId = @intFreightRateMatrixStageId

			-- Audit Log
			IF (@intNewFreightRateMatrixId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created '

					EXEC uspSMAuditLog @keyValue = @intNewFreightRateMatrixId
						,@screenName = 'Logistics.view.FreightRateMatrix'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = ''
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated '

					EXEC uspSMAuditLog @keyValue = @intNewFreightRateMatrixId
						,@screenName = 'Logistics.view.FreightRateMatrix'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = ''
				END
			END

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

			UPDATE tblLGFreightRateMatrixStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
				,intStatusId = 2
			WHERE intFreightRateMatrixStageId = @intFreightRateMatrixStageId
		END CATCH

		SELECT @intFreightRateMatrixStageId = MIN(intFreightRateMatrixStageId)
		FROM @tblLGFreightRateMatrixStage
		WHERE intFreightRateMatrixStageId > @intFreightRateMatrixStageId
			--AND ISNULL(strFeedStatus, '') = ''
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblLGFreightRateMatrixStage t
	JOIN @tblLGFreightRateMatrixStage pt ON pt.intFreightRateMatrixStageId = t.intFreightRateMatrixStageId
		AND t.strFeedStatus = 'In-Progress'
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
