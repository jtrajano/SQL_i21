CREATE PROCEDURE uspIPProcessSAPShipmentStatus_ST @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
AS
BEGIN TRY
	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF

	DECLARE @intMinRowNo INT
		,@ErrMsg NVARCHAR(MAX)
		,@strFinalErrMsg NVARCHAR(MAX) = ''
		,@intEntityId INT
	DECLARE @strContractNumber NVARCHAR(50)
		,@intContractSeq INT
		,@strBLNumber NVARCHAR(100)
		,@strStatus NVARCHAR(100)
		,@dtmArrivedInPort DATETIME
		,@dtmCustomsReleased DATETIME
		,@dtmETA DATETIME
	DECLARE @strLoadNumber NVARCHAR(100)
		,@strDeliveryNo NVARCHAR(50)
		,@intLoadId INT
	DECLARE @dtmNewArrivedInPort DATETIME
		,@dtmNewCustomsReleased DATETIME
		,@ysnNewArrivedInPort BIT
		,@ysnNewCustomsReleased BIT
		,@dtmOldArrivedInPort DATETIME
		,@dtmOldCustomsReleased DATETIME
		,@ysnOldArrivedInPort BIT
		,@ysnOldCustomsReleased BIT
		,@dtmOldETA DATETIME
		,@strDetails NVARCHAR(MAX)

	SELECT @intMinRowNo = Min(intStageShipmentStatusId)
	FROM tblIPShipmentStatusStage WITH (NOLOCK)

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		BEGIN TRY
			SET @intNoOfRowsAffected = 1

			SELECT @strContractNumber = NULL
				,@intContractSeq = NULL
				,@strBLNumber = NULL
				,@strStatus = NULL
				,@dtmArrivedInPort = NULL
				,@dtmCustomsReleased = NULL
				,@dtmETA = NULL

			SELECT @strLoadNumber = NULL
				,@strDeliveryNo = NULL
				,@intLoadId = NULL

			SELECT @dtmNewArrivedInPort = NULL
				,@dtmNewCustomsReleased = NULL
				,@ysnNewArrivedInPort = NULL
				,@ysnNewCustomsReleased = NULL
				,@dtmOldArrivedInPort = NULL
				,@dtmOldCustomsReleased = NULL
				,@ysnOldArrivedInPort = NULL
				,@ysnOldCustomsReleased = NULL
				,@dtmOldETA = NULL

			SELECT @strContractNumber = strContractNumber
				,@intContractSeq = intContractSeq
				,@strBLNumber = strBLNumber
				,@strStatus = strStatus
				,@dtmArrivedInPort = dtmArrivedInPort
				,@dtmCustomsReleased = dtmCustomsReleased
				,@dtmETA = dtmETA
			FROM tblIPShipmentStatusStage WITH (NOLOCK)
			WHERE intStageShipmentStatusId = @intMinRowNo

			SELECT @strLoadNumber = L.strLoadNumber
				,@strDeliveryNo = L.strExternalShipmentNumber
				,@intLoadId = L.intLoadId
				,@dtmOldArrivedInPort = L.dtmArrivedInPort
				,@dtmOldCustomsReleased = L.dtmCustomsReleased
				,@ysnOldArrivedInPort = L.ysnArrivedInPort
				,@ysnOldCustomsReleased = L.ysnCustomsReleased
				,@dtmOldETA = L.dtmETAPOD
			FROM tblLGLoad L WITH (NOLOCK)
			JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LD.intLoadId = L.intLoadId
				AND L.intShipmentType = 1
				AND L.strBLNumber = @strBLNumber
			JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId
				AND CD.intContractSeq = @intContractSeq
			JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
				AND CH.strContractNumber = @strContractNumber

			SET @strInfo1 = ISNULL(@strLoadNumber, '') + ' / ' + ISNULL(@strDeliveryNo, '')
			SET @strInfo2 = ISNULL(CONVERT(VARCHAR(10), @dtmETA, 121), '')

			SELECT @intEntityId = intEntityId
			FROM tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = 'IRELYADMIN'

			IF @strStatus IS NULL
				AND @dtmETA IS NULL
			BEGIN
				RAISERROR (
						'Invalid Status and ETA. '
						,16
						,1
						)
			END

			IF ISNULL(@intLoadId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Load No. '
						,16
						,1
						)
			END

			BEGIN TRAN

			-- Shipment Status Update
			IF ISNULL(@strStatus, '') <> ''
			BEGIN
				IF @strStatus <> 'Arrived in Port'
					AND @strStatus <> 'Customs Released'
				BEGIN
					RAISERROR (
							'Invalid Status. '
							,16
							,1
							)
				END

				UPDATE tblLGLoad
				SET intConcurrencyId = intConcurrencyId + 1
					,ysnArrivedInPort = CASE 
						WHEN @strStatus = 'Arrived in Port'
							THEN 1
						ELSE ysnArrivedInPort
						END
					,ysnCustomsReleased = CASE 
						WHEN @strStatus = 'Customs Released'
							THEN 1
						ELSE ysnCustomsReleased
						END
					,dtmArrivedInPort = CASE 
						WHEN @dtmArrivedInPort IS NOT NULL
							THEN @dtmArrivedInPort
						ELSE dtmArrivedInPort
						END
					,dtmCustomsReleased = CASE 
						WHEN @dtmCustomsReleased IS NOT NULL
							THEN @dtmCustomsReleased
						ELSE dtmCustomsReleased
						END
				WHERE intLoadId = @intLoadId
					AND intShipmentStatus = 3

				SELECT @dtmNewArrivedInPort = L.dtmArrivedInPort
					,@dtmNewCustomsReleased = L.dtmCustomsReleased
					,@ysnNewArrivedInPort = L.ysnArrivedInPort
					,@ysnNewCustomsReleased = L.ysnCustomsReleased
				FROM tblLGLoad L WITH (NOLOCK)
				WHERE L.intLoadId = @intLoadId

				-- Audit Log
				SELECT @strDetails = ''

				DECLARE @SingleAuditLogParam SingleAuditLogParam
				DECLARE @intId INT = 0

				SET @intId += 1
				INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
				SELECT @intId, '', 'Updated', 'Updated - Record: ' + CAST(@intLoadId AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL

				IF (@dtmOldArrivedInPort <> @dtmNewArrivedInPort)
				BEGIN
					SET @strDetails += '{"change":"dtmArrivedInPort","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldArrivedInPort, '')) + '","to":"' + LTRIM(ISNULL(@dtmNewArrivedInPort, '')) + '","leaf":true,"changeDescription":"Arrived in Port Date"},'

					SET @intId += 1
					INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
					SELECT @intId, '', '', 'dtmArrivedInPort', LTRIM(ISNULL(@dtmOldArrivedInPort, '')), LTRIM(ISNULL(@dtmNewArrivedInPort, '')), 'Arrived in Port Date', NULL, NULL, 1
				END

				IF (@dtmOldCustomsReleased <> @dtmNewCustomsReleased)
				BEGIN
					SET @strDetails += '{"change":"dtmCustomsReleased","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldCustomsReleased, '')) + '","to":"' + LTRIM(ISNULL(@dtmNewCustomsReleased, '')) + '","leaf":true,"changeDescription":"Customs Released Date"},'

					SET @intId += 1
					INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
					SELECT @intId, '', '', 'dtmCustomsReleased', LTRIM(ISNULL(@dtmOldCustomsReleased, '')), LTRIM(ISNULL(@dtmNewCustomsReleased, '')), 'Customs Released Date', NULL, NULL, 1
				END

				IF (@ysnOldArrivedInPort <> @ysnNewArrivedInPort)
				BEGIN	
					SET @strDetails += '{"change":"ysnArrivedInPort","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@ysnOldArrivedInPort, '')) + '","to":"' + LTRIM(ISNULL(@ysnNewArrivedInPort, '')) + '","leaf":true,"changeDescription":"Arrived In Port"},'

					SET @intId += 1
					INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
					SELECT @intId, '', '', 'ysnArrivedInPort', LTRIM(ISNULL(@ysnOldArrivedInPort, '')), LTRIM(ISNULL(@ysnNewArrivedInPort, '')), 'Arrived In Port', NULL, NULL, 1
				END

				IF (@ysnOldCustomsReleased <> @ysnNewCustomsReleased)
				BEGIN	
					SET @strDetails += '{"change":"ysnCustomsReleased","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@ysnOldCustomsReleased, '')) + '","to":"' + LTRIM(ISNULL(@ysnNewCustomsReleased, '')) + '","leaf":true,"changeDescription":"Customs Released"},'

					SET @intId += 1
					INSERT INTO @SingleAuditLogParam ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
					SELECT @intId, '', '', 'ysnCustomsReleased', LTRIM(ISNULL(@ysnOldCustomsReleased, '')), LTRIM(ISNULL(@ysnNewCustomsReleased, '')), 'Customs Released', NULL, NULL, 1
				END

				IF (LEN(@strDetails) > 1)
				BEGIN
					SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

					EXEC uspSMAuditLog @keyValue = @intLoadId
						,@screenName = 'Logistics.view.ShipmentSchedule'
						,@entityId = @intEntityId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @strDetails

					BEGIN TRY
						EXEC uspSMSingleAuditLog 
							@screenName     = 'Logistics.view.ShipmentSchedule',
							@recordId       = @intLoadId,
							@entityId       = @intEntityId,
							@AuditLogParam  = @SingleAuditLogParam
					END TRY
					BEGIN CATCH
					END CATCH
				END
			END

			-- ETA Date Update
			IF @dtmETA IS NOT NULL
			BEGIN
				IF ISNULL(CONVERT(VARCHAR(10), @dtmOldETA, 112), '') <> ISNULL(CONVERT(VARCHAR(10), @dtmETA, 112), '')
				BEGIN
					UPDATE tblLGLoad
					SET intConcurrencyId = intConcurrencyId + 1
						,dtmETAPOD = @dtmETA
					WHERE intLoadId = @intLoadId

					-- To set Contract Updated Availability Date and send Contract Update feed to SAP
					EXEC uspLGCreateLoadIntegrationLog @intLoadId = @intLoadId
						,@strRowState = 'Modified'
						,@intShipmentType = 1

					-- To send LS Update to Inter Company
					EXEC uspLGInterCompanyTransaction @intLoadId = @intLoadId
						,@strRowState = 'Modified'

					-- Audit Log
					SELECT @strDetails = ''

					SET @strDetails += '{"change":"dtmETAPOD","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldETA, '')) + '","to":"' + LTRIM(ISNULL(@dtmETA, '')) + '","leaf":true,"changeDescription":"ETA POD"}'

					EXEC uspSMAuditLog @keyValue = @intLoadId
						,@screenName = 'Logistics.view.ShipmentSchedule'
						,@entityId = @intEntityId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @strDetails

					BEGIN TRY
						DECLARE @SingleAuditLogParam2 SingleAuditLogParam
						INSERT INTO @SingleAuditLogParam2 ([Id], [KeyValue], [Action], [Change], [From], [To], [Alias], [Field], [Hidden], [ParentId])
								SELECT 1, '', 'Updated', 'Updated - Record: ' + CAST(@intLoadId AS VARCHAR(MAX)), NULL, NULL, NULL, NULL, NULL, NULL
								UNION ALL
								SELECT 2, '', '', 'dtmETAPOD', LTRIM(ISNULL(@dtmOldETA, '')), LTRIM(ISNULL(@dtmETA, '')), 'ETA POD', NULL, NULL, 1

						EXEC uspSMSingleAuditLog 
							@screenName     = 'Logistics.view.ShipmentSchedule',
							@recordId       = @intLoadId,
							@entityId       = @intEntityId,
							@AuditLogParam  = @SingleAuditLogParam2
					END TRY
					BEGIN CATCH
					END CATCH
				END
			END

			--Move to Archive
			INSERT INTO tblIPShipmentStatusArchive (
				strContractNumber
				,intContractSeq
				,strBLNumber
				,strStatus
				,dtmArrivedInPort
				,dtmCustomsReleased
				,dtmETA
				,strLoadNumber
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				)
			SELECT strContractNumber
				,intContractSeq
				,strBLNumber
				,strStatus
				,dtmArrivedInPort
				,dtmCustomsReleased
				,dtmETA
				,strLoadNumber
				,strTransactionType
				,''
				,'Success'
				,strSessionId
			FROM tblIPShipmentStatusStage
			WHERE intStageShipmentStatusId = @intMinRowNo

			DELETE
			FROM tblIPShipmentStatusStage
			WHERE intStageShipmentStatusId = @intMinRowNo

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPShipmentStatusError (
				strContractNumber
				,intContractSeq
				,strBLNumber
				,strStatus
				,dtmArrivedInPort
				,dtmCustomsReleased
				,dtmETA
				,strLoadNumber
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				)
			SELECT strContractNumber
				,intContractSeq
				,strBLNumber
				,strStatus
				,dtmArrivedInPort
				,dtmCustomsReleased
				,dtmETA
				,strLoadNumber
				,strTransactionType
				,@ErrMsg
				,'Failed'
				,strSessionId
			FROM tblIPShipmentStatusStage
			WHERE intStageShipmentStatusId = @intMinRowNo

			DELETE
			FROM tblIPShipmentStatusStage
			WHERE intStageShipmentStatusId = @intMinRowNo
		END CATCH

		SELECT @intMinRowNo = Min(intStageShipmentStatusId)
		FROM tblIPShipmentStatusStage WITH (NOLOCK)
		WHERE intStageShipmentStatusId > @intMinRowNo
	END

	IF ISNULL(@strFinalErrMsg, '') <> ''
		RAISERROR (
				@strFinalErrMsg
				,16
				,1
				)
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
