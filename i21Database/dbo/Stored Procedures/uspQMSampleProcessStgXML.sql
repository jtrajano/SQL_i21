CREATE PROCEDURE [dbo].[uspQMSampleProcessStgXML] @intToCompanyId INT
AS
BEGIN TRY
	SET NOCOUNT ON

	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @intSampleStageId INT
	DECLARE @intSampleId INT
	DECLARE @strSampleNumber NVARCHAR(MAX)
	DECLARE @strNewSampleNumber NVARCHAR(MAX)
	DECLARE @strHeaderXML NVARCHAR(MAX)
	DECLARE @strDetailXML NVARCHAR(MAX)
	DECLARE @strTestResultXML NVARCHAR(MAX)
	DECLARE @strReference NVARCHAR(MAX)
	DECLARE @strRowState NVARCHAR(MAX)
	DECLARE @strFeedStatus NVARCHAR(MAX)
	DECLARE @dtmFeedDate DATETIME
	DECLARE @strMessage NVARCHAR(MAX)
	DECLARE @intMultiCompanyId INT
	DECLARE @intStgEntityId INT
	DECLARE @intCompanyLocationId INT
	DECLARE @strTransactionType NVARCHAR(MAX)
	DECLARE @intSampleAcknowledgementStageId INT
	DECLARE @strHeaderCondition NVARCHAR(MAX)
	DECLARE @strAckHeaderXML NVARCHAR(MAX)
	DECLARE @strAckDetailXML NVARCHAR(MAX)
	DECLARE @strAckTestResultXML NVARCHAR(MAX)
	DECLARE @idoc INT
		,@intTransactionCount INT
		,@intSampleRefId INT
		,@intNewSampleId INT
		,@intToBookId INT
		,@strFromBook NVARCHAR(100)
	DECLARE @strErrorMessage NVARCHAR(MAX)
		,@strSampleTypeName NVARCHAR(50)
		,@strProductValue NVARCHAR(100)
		,@strSampleStatus NVARCHAR(32)
		,@strPreviousSampleStatus NVARCHAR(32)
		,@strItemNo NVARCHAR(50)
		,@strContractItemName NVARCHAR(100)
		,@intContractDetailRefId INT
		,@strLotStatus NVARCHAR(50)
		,@strPartyName NVARCHAR(100)
		,@strTestedByName NVARCHAR(100)
		,@strSampleUOM NVARCHAR(50)
		,@strRepresentingUOM NVARCHAR(50)
		,@strSubLocationName NVARCHAR(50)
		,@strBundleItemNo NVARCHAR(50)
		,@intLoadDetailContainerLinkRefId INT
		,@intLoadDetailRefId INT
		,@strShiftName NVARCHAR(50)
		,@strLocationName NVARCHAR(50)
		,@strReceiptNumber NVARCHAR(50)
		,@strInvShipmentNumber NVARCHAR(50)
		,@strWorkOrderNo NVARCHAR(50)
		,@strStorageLocationName NVARCHAR(50)
		,@strBook NVARCHAR(100)
		,@strSubBook NVARCHAR(100)
		,@strForwardingAgentName NVARCHAR(100)
		,@strSentBy NVARCHAR(50)
		,@strSentByValue NVARCHAR(100)
		,@strCountry NVARCHAR(50)
		,@strCreatedUser NVARCHAR(100)
		,@strLastModifiedUser NVARCHAR(100)
		,@intOrgContractDetailId INT
		,@intOrgLoadDetailContainerLinkId INT
		,@intOrgLoadDetailId INT
	DECLARE @intSampleTypeId INT
		,@intProductTypeId INT
		,@intProductValueId INT
		,@intSampleStatusId INT
		,@intPreviousSampleStatusId INT
		,@intItemId INT
		,@intItemContractId INT
		,@intLotStatusId INT
		,@intEntityId INT
		,@intTestedById INT
		,@intSampleUOMId INT
		,@intRepresentingUOMId INT
		,@intCompanyLocationSubLocationId INT
		,@intItemBundleId INT
		,@intShiftId INT
		,@intLocationId INT
		,@intInventoryReceiptId INT
		,@intInventoryShipmentId INT
		,@intWorkOrderId INT
		,@intStorageLocationId INT
		,@intBookId INT
		,@intSubBookId INT
		,@intForwardingAgentId INT
		,@intSentById INT
		,@intContractDetailId INT
		,@intLoadDetailContainerLinkId INT
		,@intLoadContainerId INT
		,@intLoadDetailId INT
		,@intLoadId INT
		,@intCountryID INT
		,@intCreatedUserId INT
		,@intLastModifiedUserId INT
		,@dtmLastModified DATETIME
		,@ysnParent BIT
	DECLARE @intSampleDetailId INT
		,@strAttributeName NVARCHAR(50)
		,@strListItemName NVARCHAR(50)
		,@intAttributeId INT
		,@intListItemId INT
	DECLARE @intTestResultId INT
		,@intTemplateProductTypeId INT
		,@strTemplateProductValue NVARCHAR(50)
		,@strTestName NVARCHAR(50)
		,@strPropertyName NVARCHAR(100)
		,@strUnitMeasure NVARCHAR(50)
		,@strParentPropertyName NVARCHAR(100)
		,@strTestListItemName NVARCHAR(50)
		,@strPropertyItemNo NVARCHAR(50)
		,@intTemplateProductValueId INT
		,@intTestId INT
		,@intPropertyId INT
		,@intUnitMeasureId INT
		,@intParentPropertyId INT
		,@intTestListItemId INT
		,@intPropertyItemId INT
		,@dtmValidFrom DATETIME
		,@dtmValidTo DATETIME
		,@intPropertyValidityPeriodId INT
		,@intProductId INT
		,@intProductPropertyValidityPeriodId INT
		,@intTransactionId INT
		,@intCompanyId INT
		,@intScreenId INT
		,@intTransactionRefId INT
		,@intCompanyRefId INT
	DECLARE @tblQMSampleStage TABLE (intSampleStageId INT)

	INSERT INTO @tblQMSampleStage (intSampleStageId)
	SELECT intSampleStageId
	FROM tblQMSampleStage
	WHERE ISNULL(strFeedStatus, '') = ''
		AND intMultiCompanyId = @intToCompanyId

	SELECT @intSampleStageId = MIN(intSampleStageId)
	FROM @tblQMSampleStage

	IF @intSampleStageId IS NULL
	BEGIN
		RETURN
	END

	UPDATE t
	SET t.strFeedStatus = 'In-Progress'
	FROM tblQMSampleStage t
	JOIN @tblQMSampleStage pt ON pt.intSampleStageId = t.intSampleStageId

	WHILE @intSampleStageId > 0
	BEGIN
		SET @intSampleId = NULL
		SET @strSampleNumber = NULL
		SET @strHeaderXML = NULL
		SET @strDetailXML = NULL
		SET @strTestResultXML = NULL
		SET @strReference = NULL
		SET @strRowState = NULL
		SET @strFeedStatus = NULL
		SET @dtmFeedDate = NULL
		SET @strMessage = NULL
		SET @intMultiCompanyId = NULL
		SET @intStgEntityId = NULL
		SET @intCompanyLocationId = NULL
		SET @strTransactionType = NULL
		SET @intToBookId = NULL
		SET @strFromBook = NULL
		SELECT @intTransactionId = NULL
			,@intCompanyId = NULL
			,@intScreenId = NULL
			,@intTransactionRefId = NULL
			,@intCompanyRefId = NULL

		SELECT @intSampleId = intSampleId
			,@strSampleNumber = strSampleNumber
			,@strHeaderXML = strHeaderXML
			,@strDetailXML = strDetailXML
			,@strTestResultXML = strTestResultXML
			,@strReference = strReference
			,@strRowState = strRowState
			,@strFeedStatus = strFeedStatus
			,@dtmFeedDate = dtmFeedDate
			,@strMessage = strMessage
			,@intMultiCompanyId = intMultiCompanyId
			,@intStgEntityId = intEntityId
			,@intCompanyLocationId = intCompanyLocationId
			,@strTransactionType = strTransactionType
			,@intToBookId = intToBookId
			,@intTransactionId = intTransactionId
			,@intCompanyId = intCompanyId
		FROM tblQMSampleStage WITH (NOLOCK)
		WHERE intSampleStageId = @intSampleStageId

		BEGIN TRY
			SELECT @intSampleRefId = @intSampleId

			SELECT @intTransactionCount = @@TRANCOUNT

			IF @intTransactionCount = 0
				BEGIN TRANSACTION

			------------------Header------------------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strHeaderXML

			SELECT @strSampleTypeName = NULL
				,@strProductValue = NULL
				,@strSampleStatus = NULL
				,@strPreviousSampleStatus = NULL
				,@strItemNo = NULL
				,@strContractItemName = NULL
				,@intContractDetailRefId = NULL
				,@strLotStatus = NULL
				,@strPartyName = NULL
				,@strTestedByName = NULL
				,@strSampleUOM = NULL
				,@strRepresentingUOM = NULL
				,@strSubLocationName = NULL
				,@strBundleItemNo = NULL
				,@intLoadDetailContainerLinkRefId = NULL
				,@intLoadDetailRefId = NULL
				,@strShiftName = NULL
				,@strLocationName = NULL
				,@strReceiptNumber = NULL
				,@strInvShipmentNumber = NULL
				,@strWorkOrderNo = NULL
				,@strStorageLocationName = NULL
				,@strBook = NULL
				,@strSubBook = NULL
				,@strForwardingAgentName = NULL
				,@strSentBy = NULL
				,@strSentByValue = NULL
				,@intProductTypeId = NULL
				,@strCountry = NULL
				,@strCreatedUser = NULL
				,@strLastModifiedUser = NULL
				,@dtmLastModified = NULL
				,@ysnParent = NULL
				,@intOrgContractDetailId = NULL
				,@intOrgLoadDetailContainerLinkId = NULL
				,@intOrgLoadDetailId = NULL

			SELECT @strSampleTypeName = strSampleTypeName
				,@strProductValue = strProductValue
				,@strSampleStatus = strSampleStatus
				,@strPreviousSampleStatus = strPreviousSampleStatus
				,@strItemNo = strItemNo
				,@strContractItemName = strContractItemName
				,@intContractDetailRefId = intContractDetailRefId
				,@strLotStatus = strLotStatus
				,@strPartyName = strPartyName
				,@strTestedByName = strTestedByName
				,@strSampleUOM = strSampleUOM
				,@strRepresentingUOM = strRepresentingUOM
				,@strSubLocationName = strSubLocationName
				,@strBundleItemNo = strBundleItemNo
				,@intLoadDetailContainerLinkRefId = intLoadDetailContainerLinkRefId
				,@intLoadDetailRefId = intLoadDetailRefId
				,@strShiftName = strShiftName
				,@strLocationName = strLocationName
				,@strReceiptNumber = strReceiptNumber
				,@strInvShipmentNumber = strInvShipmentNumber
				,@strWorkOrderNo = strWorkOrderNo
				,@strStorageLocationName = strStorageLocationName
				,@strBook = strBook
				,@strSubBook = strSubBook
				,@strForwardingAgentName = strForwardingAgentName
				,@strSentBy = strSentBy
				,@strSentByValue = strSentByValue
				,@intProductTypeId = intProductTypeId
				,@strCountry = strCountry
				,@strCreatedUser = strCreatedUser
				,@strLastModifiedUser = strLastModifiedUser
				,@dtmLastModified = dtmLastModified
				,@ysnParent = ysnParent
				,@intOrgContractDetailId = intContractDetailId
				,@intOrgLoadDetailContainerLinkId = intLoadDetailContainerLinkId
				,@intOrgLoadDetailId = intLoadDetailId
			FROM OPENXML(@idoc, 'vyuQMSampleHeaderViews/vyuQMSampleHeaderView', 2) WITH (
					strSampleTypeName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strProductValue NVARCHAR(100) Collate Latin1_General_CI_AS
					,strSampleStatus NVARCHAR(32) Collate Latin1_General_CI_AS
					,strPreviousSampleStatus NVARCHAR(32) Collate Latin1_General_CI_AS
					,strItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,strContractItemName NVARCHAR(100) Collate Latin1_General_CI_AS
					,intContractDetailRefId INT
					,strLotStatus NVARCHAR(50) Collate Latin1_General_CI_AS
					,strPartyName NVARCHAR(100) Collate Latin1_General_CI_AS
					,strTestedByName NVARCHAR(100) Collate Latin1_General_CI_AS
					,strSampleUOM NVARCHAR(50) Collate Latin1_General_CI_AS
					,strRepresentingUOM NVARCHAR(50) Collate Latin1_General_CI_AS
					,strSubLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strBundleItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,intLoadDetailContainerLinkRefId INT
					,intLoadDetailRefId INT
					,strShiftName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strReceiptNumber NVARCHAR(50) Collate Latin1_General_CI_AS
					,strInvShipmentNumber NVARCHAR(50) Collate Latin1_General_CI_AS
					,strWorkOrderNo NVARCHAR(50) Collate Latin1_General_CI_AS
					,strStorageLocationName NVARCHAR(50) Collate Latin1_General_CI_AS
					,strBook NVARCHAR(100) Collate Latin1_General_CI_AS
					,strSubBook NVARCHAR(100) Collate Latin1_General_CI_AS
					,strForwardingAgentName NVARCHAR(100) Collate Latin1_General_CI_AS
					,strSentBy NVARCHAR(50) Collate Latin1_General_CI_AS
					,strSentByValue NVARCHAR(100) Collate Latin1_General_CI_AS
					,intProductTypeId INT
					,strCountry NVARCHAR(50) Collate Latin1_General_CI_AS
					,strCreatedUser NVARCHAR(100) Collate Latin1_General_CI_AS
					,strLastModifiedUser NVARCHAR(100) Collate Latin1_General_CI_AS
					,dtmLastModified DATETIME
					,ysnParent BIT
					,intContractDetailId INT
					,intLoadDetailContainerLinkId INT
					,intLoadDetailId INT
					) x

			IF @strSampleTypeName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblQMSampleType ST WITH (NOLOCK)
					WHERE ST.strSampleTypeName = @strSampleTypeName
					)
			BEGIN
				SELECT @strErrorMessage = 'Sample Type ' + @strSampleTypeName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strProductValue IS NOT NULL
				AND @intProductTypeId IS NOT NULL
			BEGIN
				IF @intProductTypeId = 2
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblICItem t WITH (NOLOCK)
							WHERE t.strItemNo = @strProductValue
							)
					BEGIN
						SELECT @strErrorMessage = 'Product Item ' + @strProductValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
				ELSE IF @intProductTypeId = 3
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblICInventoryReceipt t WITH (NOLOCK)
							WHERE t.strReceiptNumber = @strProductValue
							)
					BEGIN
						SELECT @strErrorMessage = 'Product Inv Receipt ' + @strProductValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
				ELSE IF @intProductTypeId = 4
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblICInventoryShipment t WITH (NOLOCK)
							WHERE t.strShipmentNumber = @strProductValue
							)
					BEGIN
						SELECT @strErrorMessage = 'Product Inv Shipment ' + @strProductValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
				ELSE IF @intProductTypeId = 6
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblICLot t WITH (NOLOCK)
							WHERE t.strLotNumber = @strProductValue
							)
					BEGIN
						SELECT @strErrorMessage = 'Product Lot ' + @strProductValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
				ELSE IF @intProductTypeId = 8
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblCTContractDetail t WITH (NOLOCK)
							WHERE t.intContractDetailId = @strProductValue
							)
					BEGIN
						SELECT @strErrorMessage = 'Product Contract ' + @strProductValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
				ELSE IF @intProductTypeId = 9
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblLGLoadDetailContainerLink t WITH (NOLOCK)
							WHERE t.intLoadDetailContainerLinkId = @strProductValue
							)
					BEGIN
						SELECT @strErrorMessage = 'Product Load Container ' + @strProductValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
				ELSE IF @intProductTypeId = 10
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblLGLoadDetail t WITH (NOLOCK)
							WHERE t.intLoadDetailId = @strProductValue
							)
					BEGIN
						SELECT @strErrorMessage = 'Product Load Shipment ' + @strProductValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
				ELSE IF @intProductTypeId = 11
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblICParentLot t WITH (NOLOCK)
							WHERE t.strParentLotNumber = @strProductValue
							)
					BEGIN
						SELECT @strErrorMessage = 'Product Parent Lot ' + @strProductValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
				ELSE IF @intProductTypeId = 12
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblMFWorkOrder t WITH (NOLOCK)
							WHERE t.strWorkOrderNo = @strProductValue
							)
					BEGIN
						SELECT @strErrorMessage = 'Product Work Order ' + @strProductValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
			END

			IF @strSampleStatus IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblQMSampleStatus SS WITH (NOLOCK)
					WHERE SS.strSecondaryStatus = @strSampleStatus
					)
			BEGIN
				SELECT @strErrorMessage = 'Sample Status ' + @strSampleStatus + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strPreviousSampleStatus IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblQMSampleStatus SS WITH (NOLOCK)
					WHERE SS.strSecondaryStatus = @strPreviousSampleStatus
					)
			BEGIN
				SELECT @strErrorMessage = 'Previous Sample Status ' + @strPreviousSampleStatus + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strItemNo IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICItem I WITH (NOLOCK)
					WHERE I.strItemNo = @strItemNo
					)
			BEGIN
				SELECT @strErrorMessage = 'Item No ' + @strItemNo + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strContractItemName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICItemContract IC WITH (NOLOCK)
					WHERE IC.strContractItemName = @strContractItemName
					)
			BEGIN
				SELECT @strErrorMessage = 'Contract Item ' + @strContractItemName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strLotStatus IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICLotStatus LS WITH (NOLOCK)
					WHERE LS.strSecondaryStatus = @strLotStatus
					)
			BEGIN
				SELECT @strErrorMessage = 'Lot Status ' + @strLotStatus + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			--IF @intContractDetailRefId IS NULL
			--	AND @strPartyName IS NOT NULL
			--	AND NOT EXISTS (
			--		SELECT 1
			--		FROM tblEMEntity t
			--		JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
			--		WHERE ET.strType IN (
			--				'Vendor'
			--				,'Customer'
			--				)
			--			AND t.strName = @strPartyName
			--			AND t.strEntityNo <> ''
			--		)
			--BEGIN
			--	SELECT @strErrorMessage = 'Party ' + @strPartyName + ' is not available.'

			--	RAISERROR (
			--			@strErrorMessage
			--			,16
			--			,1
			--			)
			--END

			IF @strTestedByName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblEMEntity t WITH (NOLOCK)
					JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
					WHERE ET.strType = 'User'
						AND t.strName = @strTestedByName
						AND t.strEntityNo <> ''
					)
			BEGIN
				SELECT @strErrorMessage = 'Tested By ' + @strTestedByName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strSampleUOM IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICUnitMeasure UOM WITH (NOLOCK)
					WHERE UOM.strUnitMeasure = @strSampleUOM
					)
			BEGIN
				SELECT @strErrorMessage = 'Sample UOM ' + @strSampleUOM + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strRepresentingUOM IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICUnitMeasure UOM WITH (NOLOCK)
					WHERE UOM.strUnitMeasure = @strRepresentingUOM
					)
			BEGIN
				SELECT @strErrorMessage = 'Representing UOM ' + @strRepresentingUOM + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			--IF @strSubLocationName IS NOT NULL
			--	AND NOT EXISTS (
			--		SELECT 1
			--		FROM tblSMCompanyLocationSubLocation CS WITH (NOLOCK)
			--		WHERE CS.strSubLocationName = @strSubLocationName
			--		)
			--BEGIN
			--	SELECT @strErrorMessage = 'Sub Location ' + @strSubLocationName + ' is not available.'

			--	RAISERROR (
			--			@strErrorMessage
			--			,16
			--			,1
			--			)
			--END

			IF @strBundleItemNo IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICItem I WITH (NOLOCK)
					WHERE I.strItemNo = @strBundleItemNo
					)
			BEGIN
				SELECT @strErrorMessage = 'Bundle Item ' + @strBundleItemNo + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strShiftName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblMFShift S WITH (NOLOCK)
					WHERE S.strShiftName = @strShiftName
					)
			BEGIN
				SELECT @strErrorMessage = 'Shift ' + @strShiftName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strLocationName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblSMCompanyLocation CL WITH (NOLOCK)
					WHERE CL.strLocationName = @strLocationName
					)
			BEGIN
				SELECT @strErrorMessage = 'Location ' + @strLocationName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strReceiptNumber IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICInventoryReceipt IR WITH (NOLOCK)
					WHERE IR.strReceiptNumber = @strReceiptNumber
					)
			BEGIN
				SELECT @strErrorMessage = 'Inv Receipt ' + @strReceiptNumber + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strInvShipmentNumber IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICInventoryShipment INVS WITH (NOLOCK)
					WHERE INVS.strShipmentNumber = @strInvShipmentNumber
					)
			BEGIN
				SELECT @strErrorMessage = 'Inv Shipment ' + @strInvShipmentNumber + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strWorkOrderNo IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblMFWorkOrder W WITH (NOLOCK)
					WHERE W.strWorkOrderNo = @strWorkOrderNo
					)
			BEGIN
				SELECT @strErrorMessage = 'Work Order ' + @strWorkOrderNo + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strStorageLocationName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblICStorageLocation SL WITH (NOLOCK)
					WHERE SL.strName = @strStorageLocationName
					)
			BEGIN
				SELECT @strErrorMessage = 'Storage Location ' + @strStorageLocationName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strBook IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTBook B WITH (NOLOCK)
					WHERE B.strBook = @strBook
					)
			BEGIN
				SELECT @strErrorMessage = 'Book ' + @strBook + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strSubBook IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblCTSubBook SB WITH (NOLOCK)
					WHERE SB.strSubBook = @strSubBook
					)
			BEGIN
				SELECT @strErrorMessage = 'Sub Book ' + @strSubBook + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strForwardingAgentName IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblEMEntity t WITH (NOLOCK)
					JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
					WHERE ET.strType = 'Forwarding Agent'
						AND t.strName = @strForwardingAgentName
						AND t.strEntityNo <> ''
					)
			BEGIN
				SELECT @strErrorMessage = 'Forwarding Agent ' + @strForwardingAgentName + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @strSentByValue IS NOT NULL
				AND ISNULL(@strSentBy, '') <> ''
			BEGIN
				IF @strSentBy = 'Self'
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblSMCompanyLocation CL WITH (NOLOCK)
							WHERE CL.strLocationName = @strSentByValue
							)
					BEGIN
						SELECT @strErrorMessage = 'Sent By Location ' + @strSentByValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
				ELSE IF @strSentBy = 'Forwarding Agent'
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblEMEntity t WITH (NOLOCK)
							JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
							WHERE ET.strType = 'Forwarding Agent'
								AND t.strName = @strSentByValue
								AND t.strEntityNo <> ''
							)
					BEGIN
						SELECT @strErrorMessage = 'Sent By Agent ' + @strSentByValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
				ELSE IF @strSentBy = 'Seller'
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblEMEntity t WITH (NOLOCK)
							JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
							WHERE ET.strType = 'Vendor'
								AND t.strName = @strSentByValue
								AND t.strEntityNo <> ''
							)
					BEGIN
						SELECT @strErrorMessage = 'Sent By Seller ' + @strSentByValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
				ELSE IF @strSentBy = 'Users'
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblEMEntity t WITH (NOLOCK)
							JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
							WHERE ET.strType = 'User'
								AND t.strName = @strSentByValue
								AND t.strEntityNo <> ''
							)
					BEGIN
						SELECT @strErrorMessage = 'Sent By User ' + @strSentByValue + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
			END

			IF @intContractDetailRefId IS NULL
				AND @intOrgContractDetailId IS NOT NULL
			BEGIN
				SELECT @strErrorMessage = 'Contract Seq Ref ' + LTRIM(@intOrgContractDetailId) + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @intContractDetailRefId IS NOT NULL
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblCTContractDetail t WITH (NOLOCK)
						WHERE t.intContractDetailId = @intContractDetailRefId
						)
				BEGIN
					SELECT @strErrorMessage = 'Contract Seq ' + LTRIM(@intContractDetailRefId) + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				-- Destination to Source validation for contract
				IF @ysnParent = 0
				BEGIN
					IF NOT EXISTS (
							SELECT 1
							FROM tblLGAllocationDetail t WITH (NOLOCK)
							WHERE t.intSContractDetailId = @intContractDetailRefId
							)
					BEGIN
						SELECT @strErrorMessage = 'Contract Seq ' + LTRIM(@intContractDetailRefId) + ' is not available.'

						RAISERROR (
								@strErrorMessage
								,16
								,1
								)
					END
				END
			END

			IF @intLoadDetailContainerLinkRefId IS NULL
				AND @intOrgLoadDetailContainerLinkId IS NOT NULL
			BEGIN
				SELECT @strErrorMessage = 'Container Ref ' + LTRIM(@intOrgLoadDetailContainerLinkId) + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @intLoadDetailContainerLinkRefId IS NOT NULL
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblLGLoadDetailContainerLink t WITH (NOLOCK)
						WHERE t.intLoadDetailContainerLinkId = @intLoadDetailContainerLinkRefId
						)
				BEGIN
					SELECT @strErrorMessage = 'Load Container ' + LTRIM(@intLoadDetailContainerLinkRefId) + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END
			END

			IF @intLoadDetailRefId IS NULL
				AND @intOrgLoadDetailId IS NOT NULL
			BEGIN
				SELECT @strErrorMessage = 'Load Shipment Ref ' + LTRIM(@intOrgLoadDetailId) + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			IF @intLoadDetailRefId IS NOT NULL
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblLGLoadDetail t WITH (NOLOCK)
						WHERE t.intLoadDetailId = @intLoadDetailRefId
						)
				BEGIN
					SELECT @strErrorMessage = 'Load Shipment ' + LTRIM(@intLoadDetailRefId) + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END
			END

			IF @strCountry IS NOT NULL
				AND NOT EXISTS (
					SELECT 1
					FROM tblSMCountry C WITH (NOLOCK)
					WHERE C.strCountry = @strCountry
					)
			BEGIN
				SELECT @strErrorMessage = 'Country ' + @strCountry + ' is not available.'

				RAISERROR (
						@strErrorMessage
						,16
						,1
						)
			END

			--IF @strCreatedUser IS NOT NULL
			--	AND NOT EXISTS (
			--		SELECT 1
			--		FROM tblEMEntity t
			--		JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
			--		WHERE ET.strType = 'User'
			--			AND t.strName = @strCreatedUser
			--			AND t.strEntityNo <> ''
			--		)
			--BEGIN
			--	SELECT @strErrorMessage = 'Created By ' + @strCreatedUser + ' is not available.'

			--	RAISERROR (
			--			@strErrorMessage
			--			,16
			--			,1
			--			)
			--END

			--IF @strLastModifiedUser IS NOT NULL
			--	AND NOT EXISTS (
			--		SELECT 1
			--		FROM tblEMEntity t
			--		JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
			--		WHERE ET.strType = 'User'
			--			AND t.strName = @strLastModifiedUser
			--			AND t.strEntityNo <> ''
			--		)
			--BEGIN
			--	SELECT @strErrorMessage = 'Last Modified By ' + @strLastModifiedUser + ' is not available.'

			--	RAISERROR (
			--			@strErrorMessage
			--			,16
			--			,1
			--			)
			--END

			SELECT @intSampleTypeId = NULL
				,@intProductValueId = NULL
				,@intSampleStatusId = NULL
				,@intPreviousSampleStatusId = NULL
				,@intItemId = NULL
				,@intItemContractId = NULL
				,@intLotStatusId = NULL
				,@intEntityId = NULL
				,@intTestedById = NULL
				,@intSampleUOMId = NULL
				,@intRepresentingUOMId = NULL
				,@intCompanyLocationSubLocationId = NULL
				,@intItemBundleId = NULL
				,@intShiftId = NULL
				,@intLocationId = NULL
				,@intInventoryReceiptId = NULL
				,@intInventoryShipmentId = NULL
				,@intWorkOrderId = NULL
				,@intStorageLocationId = NULL
				,@intBookId = NULL
				,@intSubBookId = NULL
				,@intForwardingAgentId = NULL
				,@intSentById = NULL
				,@intContractDetailId = NULL
				,@intLoadDetailContainerLinkId = NULL
				,@intLoadContainerId = NULL
				,@intLoadDetailId = NULL
				,@intLoadId = NULL
				,@intCountryID = NULL
				,@intCreatedUserId = NULL
				,@intLastModifiedUserId = NULL

			SELECT @intSampleTypeId = t.intSampleTypeId
			FROM tblQMSampleType t WITH (NOLOCK)
			WHERE t.strSampleTypeName = @strSampleTypeName

			SELECT @intSampleStatusId = t.intSampleStatusId
			FROM tblQMSampleStatus t WITH (NOLOCK)
			WHERE t.strSecondaryStatus = @strSampleStatus

			SELECT @intPreviousSampleStatusId = t.intSampleStatusId
			FROM tblQMSampleStatus t WITH (NOLOCK)
			WHERE t.strSecondaryStatus = @strPreviousSampleStatus

			SELECT @intItemId = t.intItemId
			FROM tblICItem t WITH (NOLOCK)
			WHERE t.strItemNo = @strItemNo

			SELECT @intItemContractId = t.intItemContractId
			FROM tblICItemContract t WITH (NOLOCK)
			WHERE t.strContractItemName = @strContractItemName

			SELECT @intLotStatusId = t.intLotStatusId
			FROM tblICLotStatus t WITH (NOLOCK)
			WHERE t.strSecondaryStatus = @strLotStatus

			--SELECT @intEntityId = t.intEntityId
			--FROM tblEMEntity t
			--JOIN tblEMEntityType ET ON ET.intEntityId = t.intEntityId
			--WHERE ET.strType IN (
			--		'Vendor'
			--		,'Customer'
			--		)
			--	AND t.strName = @strPartyName
			--	AND t.strEntityNo <> ''

			SELECT @intTestedById = t.intEntityId
			FROM tblEMEntity t WITH (NOLOCK)
			JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'User'
				AND t.strName = @strTestedByName
				AND t.strEntityNo <> ''

			SELECT @intSampleUOMId = t.intUnitMeasureId
			FROM tblICUnitMeasure t WITH (NOLOCK)
			WHERE t.strUnitMeasure = @strSampleUOM

			SELECT @intRepresentingUOMId = t.intUnitMeasureId
			FROM tblICUnitMeasure t WITH (NOLOCK)
			WHERE t.strUnitMeasure = @strRepresentingUOM

			SELECT @intCompanyLocationSubLocationId = t.intCompanyLocationSubLocationId
			FROM tblSMCompanyLocationSubLocation t WITH (NOLOCK)
			WHERE t.strSubLocationName = @strSubLocationName

			SELECT @intItemBundleId = t.intItemId
			FROM tblICItem t WITH (NOLOCK)
			WHERE t.strItemNo = @strBundleItemNo

			SELECT @intShiftId = t.intShiftId
			FROM tblMFShift t WITH (NOLOCK)
			WHERE t.strShiftName = @strShiftName

			SELECT @intLocationId = t.intCompanyLocationId
			FROM tblSMCompanyLocation t WITH (NOLOCK)
			WHERE t.strLocationName = @strLocationName

			SELECT @intInventoryReceiptId = t.intInventoryReceiptId
			FROM tblICInventoryReceipt t WITH (NOLOCK)
			WHERE t.strReceiptNumber = @strReceiptNumber

			SELECT @intInventoryShipmentId = t.intInventoryShipmentId
			FROM tblICInventoryShipment t WITH (NOLOCK)
			WHERE t.strShipmentNumber = @strInvShipmentNumber

			SELECT @intWorkOrderId = t.intWorkOrderId
			FROM tblMFWorkOrder t WITH (NOLOCK)
			WHERE t.strWorkOrderNo = @strWorkOrderNo

			SELECT @intStorageLocationId = t.intStorageLocationId
			FROM tblICStorageLocation t WITH (NOLOCK)
			WHERE t.strName = @strStorageLocationName

			SELECT @intBookId = t.intBookId
			FROM tblCTBook t WITH (NOLOCK)
			WHERE t.strBook = @strBook

			SELECT @intSubBookId = t.intSubBookId
			FROM tblCTSubBook t WITH (NOLOCK)
			WHERE t.strSubBook = @strSubBook

			SELECT @intForwardingAgentId = t.intEntityId
			FROM tblEMEntity t WITH (NOLOCK)
			JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'Forwarding Agent'
				AND t.strName = @strForwardingAgentName
				AND t.strEntityNo <> ''

			IF @strSentBy = 'Self'
			BEGIN
				SELECT @intSentById = t.intCompanyLocationId
				FROM tblSMCompanyLocation t WITH (NOLOCK)
				WHERE t.strLocationName = @strSentByValue
			END
			ELSE IF @strSentBy = 'Forwarding Agent'
			BEGIN
				SELECT @intSentById = t.intEntityId
				FROM tblEMEntity t WITH (NOLOCK)
				JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
				WHERE ET.strType = 'Forwarding Agent'
					AND t.strName = @strSentByValue
					AND t.strEntityNo <> ''
			END
			ELSE IF @strSentBy = 'Seller'
			BEGIN
				SELECT @intSentById = t.intEntityId
				FROM tblEMEntity t WITH (NOLOCK)
				JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
				WHERE ET.strType = 'Vendor'
					AND t.strName = @strSentByValue
					AND t.strEntityNo <> ''
			END
			ELSE IF @strSentBy = 'Users'
			BEGIN
				SELECT @intSentById = t.intEntityId
				FROM tblEMEntity t WITH (NOLOCK)
				JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
				WHERE ET.strType = 'User'
					AND t.strName = @strSentByValue
					AND t.strEntityNo <> ''
			END

			IF @intProductTypeId = 2
			BEGIN
				SELECT @intProductValueId = t.intItemId
				FROM tblICItem t WITH (NOLOCK)
				WHERE t.strItemNo = @strProductValue
			END
			ELSE IF @intProductTypeId = 3
			BEGIN
				SELECT @intProductValueId = t.intInventoryReceiptId
				FROM tblICInventoryReceipt t WITH (NOLOCK)
				WHERE t.strReceiptNumber = @strProductValue
			END
			ELSE IF @intProductTypeId = 4
			BEGIN
				SELECT @intProductValueId = t.intInventoryShipmentId
				FROM tblICInventoryShipment t WITH (NOLOCK)
				WHERE t.strShipmentNumber = @strProductValue
			END
			ELSE IF @intProductTypeId = 6
			BEGIN
				SELECT @intProductValueId = t.intLotId
				FROM tblICLot t WITH (NOLOCK)
				WHERE t.strLotNumber = @strProductValue
					AND t.intStorageLocationId = @intStorageLocationId
			END
			ELSE IF @intProductTypeId = 8
			BEGIN
				SELECT @intProductValueId = t.intContractDetailId
				FROM tblCTContractDetail t WITH (NOLOCK)
				WHERE t.intContractDetailId = @strProductValue

				IF @ysnParent = 0
				BEGIN
					SELECT @intProductValueId = t.intPContractDetailId
					FROM tblLGAllocationDetail t WITH (NOLOCK)
					WHERE t.intSContractDetailId = @intContractDetailRefId
				END
			END
			ELSE IF @intProductTypeId = 9
			BEGIN
				SELECT @intProductValueId = t.intLoadDetailContainerLinkId
				FROM tblLGLoadDetailContainerLink t WITH (NOLOCK)
				WHERE t.intLoadDetailContainerLinkId = @strProductValue
			END
			ELSE IF @intProductTypeId = 10
			BEGIN
				SELECT @intProductValueId = t.intLoadDetailId
				FROM tblLGLoadDetail t WITH (NOLOCK)
				WHERE t.intLoadDetailId = @strProductValue
			END
			ELSE IF @intProductTypeId = 11
			BEGIN
				SELECT @intProductValueId = t.intParentLotId
				FROM tblICParentLot t WITH (NOLOCK)
				WHERE t.strParentLotNumber = @strProductValue
			END
			ELSE IF @intProductTypeId = 12
			BEGIN
				SELECT @intProductValueId = t.intWorkOrderId
				FROM tblMFWorkOrder t WITH (NOLOCK)
				WHERE t.strWorkOrderNo = @strProductValue
			END

			IF @intContractDetailRefId IS NOT NULL
			BEGIN
				SELECT @intContractDetailId = t.intContractDetailId
					,@intEntityId = CH.intEntityId
				FROM tblCTContractDetail t WITH (NOLOCK)
				JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = t.intContractHeaderId
				WHERE t.intContractDetailId = @intContractDetailRefId

				IF @ysnParent = 0
				BEGIN
					SELECT @intContractDetailId = t.intPContractDetailId
						,@intEntityId = CH.intEntityId
					FROM tblLGAllocationDetail t WITH (NOLOCK)
					JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = t.intPContractDetailId
					JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
					WHERE t.intSContractDetailId = @intContractDetailRefId
				END
			END

			IF @intLoadDetailContainerLinkRefId IS NOT NULL
			BEGIN
				SELECT @intLoadDetailContainerLinkId = t.intLoadDetailContainerLinkId
					,@intLoadContainerId = t.intLoadContainerId
				FROM tblLGLoadDetailContainerLink t WITH (NOLOCK)
				WHERE t.intLoadDetailContainerLinkId = @intLoadDetailContainerLinkRefId
			END

			IF @intLoadDetailRefId IS NOT NULL
			BEGIN
				SELECT @intLoadDetailId = t.intLoadDetailId
					,@intLoadId = t.intLoadId
				FROM tblLGLoadDetail t WITH (NOLOCK)
				WHERE t.intLoadDetailId = @intLoadDetailRefId
			END

			SELECT @intCountryID = intCountryID
			FROM tblSMCountry t WITH (NOLOCK)
			WHERE t.strCountry = @strCountry

			SELECT @intCreatedUserId = t.intEntityId
			FROM tblEMEntity t WITH (NOLOCK)
			JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'User'
				AND t.strName = @strCreatedUser
				AND t.strEntityNo <> ''

			IF @intCreatedUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity WITH (NOLOCK)
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intCreatedUserId = intEntityId
					FROM tblSMUserSecurity WITH (NOLOCK)
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intCreatedUserId = intEntityId
					FROM tblSMUserSecurity WITH (NOLOCK)
			END

			SELECT @intLastModifiedUserId = t.intEntityId
			FROM tblEMEntity t WITH (NOLOCK)
			JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
			WHERE ET.strType = 'User'
				AND t.strName = @strLastModifiedUser
				AND t.strEntityNo <> ''

			IF @intLastModifiedUserId IS NULL
			BEGIN
				IF EXISTS (
						SELECT 1
						FROM tblSMUserSecurity WITH (NOLOCK)
						WHERE strUserName = 'irelyadmin'
						)
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity WITH (NOLOCK)
					WHERE strUserName = 'irelyadmin'
				ELSE
					SELECT TOP 1 @intLastModifiedUserId = intEntityId
					FROM tblSMUserSecurity WITH (NOLOCK)
			END

			IF @strRowState <> 'Delete'
			BEGIN
				IF NOT EXISTS (
						SELECT 1
						FROM tblQMSample WITH (NOLOCK)
						WHERE intSampleRefId = @intSampleRefId
							AND intBookId = @intToBookId
						)
					SELECT @strRowState = 'Added'
				ELSE
					SELECT @strRowState = 'Modified'
			END

			IF @strRowState = 'Delete'
			BEGIN
				SELECT @intNewSampleId = intSampleId
					,@strNewSampleNumber = strSampleNumber
				FROM tblQMSample WITH (NOLOCK)
				WHERE intSampleRefId = @intSampleRefId
					AND intBookId = @intToBookId

				SELECT @strHeaderCondition = 'intSampleId = ' + LTRIM(@intNewSampleId)

				EXEC uspCTGetTableDataInXML 'tblQMSample'
					,@strHeaderCondition
					,@strAckHeaderXML OUTPUT

				EXEC uspCTGetTableDataInXML 'tblQMSampleDetail'
					,@strHeaderCondition
					,@strAckDetailXML OUTPUT

				EXEC uspCTGetTableDataInXML 'tblQMTestResult'
					,@strHeaderCondition
					,@strAckTestResultXML OUTPUT

				DELETE
				FROM tblQMSample
				WHERE intSampleRefId = @intSampleRefId
					AND intBookId = @intToBookId

				GOTO ext
			END

			IF @strRowState = 'Added'
			BEGIN
				EXEC uspMFGeneratePatternId @intCategoryId = NULL
					,@intItemId = NULL
					,@intManufacturingId = NULL
					,@intSubLocationId = NULL
					,@intLocationId = @intCompanyLocationId
					,@intOrderTypeId = NULL
					,@intBlendRequirementId = NULL
					,@intPatternCode = 62
					,@ysnProposed = 0
					,@strPatternString = @strNewSampleNumber OUTPUT

				INSERT INTO tblQMSample (
					intConcurrencyId
					,intSampleTypeId
					,strSampleNumber
					,strSampleRefNo
					,intProductTypeId
					,intProductValueId
					,intSampleStatusId
					,intPreviousSampleStatusId
					,intItemId
					,intItemContractId
					,intContractDetailId
					,intCountryID
					,ysnIsContractCompleted
					,intLotStatusId
					,intEntityId
					,strShipmentNumber
					,strLotNumber
					,strSampleNote
					,dtmSampleReceivedDate
					,dtmTestedOn
					,intTestedById
					,dblSampleQty
					,intSampleUOMId
					,dblRepresentingQty
					,intRepresentingUOMId
					,strRefNo
					,dtmTestingStartDate
					,dtmTestingEndDate
					,dtmSamplingEndDate
					,strSamplingMethod
					,strContainerNumber
					,strMarks
					,intCompanyLocationSubLocationId
					,strCountry
					,intItemBundleId
					,intLoadContainerId
					,intLoadDetailContainerLinkId
					,intLoadId
					,intLoadDetailId
					,dtmBusinessDate
					,intShiftId
					,intLocationId
					,intInventoryReceiptId
					,intInventoryShipmentId
					,intWorkOrderId
					,strComment
					,ysnAdjustInventoryQtyBySampleQty
					,intStorageLocationId
					,intBookId
					,intSubBookId
					,strChildLotNumber
					,strCourier
					,strCourierRef
					,intForwardingAgentId
					,strForwardingAgentRef
					,strSentBy
					,intSentById
					,intSampleRefId
					,ysnParent
					,intCreatedUserId
					,dtmCreated
					,intLastModifiedUserId
					,dtmLastModified
					)
				SELECT 1 intConcurrencyId
					,@intSampleTypeId
					,@strNewSampleNumber
					,@strSampleNumber
					,@intProductTypeId
					,@intProductValueId
					,@intSampleStatusId
					,@intPreviousSampleStatusId
					,@intItemId
					,@intItemContractId
					,@intContractDetailId
					,@intCountryID
					,ysnIsContractCompleted
					,@intLotStatusId
					,@intEntityId
					,strShipmentNumber
					,strLotNumber
					,strSampleNote
					,dtmSampleReceivedDate
					,dtmTestedOn
					,@intTestedById
					,dblSampleQty
					,@intSampleUOMId
					,dblRepresentingQty
					,@intRepresentingUOMId
					,strRefNo
					,dtmTestingStartDate
					,dtmTestingEndDate
					,dtmSamplingEndDate
					,strSamplingMethod
					,strContainerNumber
					,strMarks
					,@intCompanyLocationSubLocationId
					,strCountry
					,@intItemBundleId
					,@intLoadContainerId
					,@intLoadDetailContainerLinkId
					,@intLoadId
					,@intLoadDetailId
					,dtmBusinessDate
					,@intShiftId
					,@intLocationId
					,@intInventoryReceiptId
					,@intInventoryShipmentId
					,@intWorkOrderId
					,strComment
					,ysnAdjustInventoryQtyBySampleQty
					,@intStorageLocationId
					,@intBookId
					,@intSubBookId
					,strChildLotNumber
					,strCourier
					,strCourierRef
					,@intForwardingAgentId
					,strForwardingAgentRef
					,strSentBy
					,@intSentById
					,@intSampleRefId
					,0
					,@intCreatedUserId
					,dtmCreated
					,@intLastModifiedUserId
					,@dtmLastModified
				FROM OPENXML(@idoc, 'vyuQMSampleHeaderViews/vyuQMSampleHeaderView', 2) WITH (
						ysnIsContractCompleted BIT
						,strShipmentNumber NVARCHAR(30)
						,strLotNumber NVARCHAR(50)
						,strSampleNote NVARCHAR(512)
						,dtmSampleReceivedDate DATETIME
						,dtmTestedOn DATETIME
						,dblSampleQty NUMERIC(18, 6)
						,dblRepresentingQty NUMERIC(18, 6)
						,strRefNo NVARCHAR(100)
						,dtmTestingStartDate DATETIME
						,dtmTestingEndDate DATETIME
						,dtmSamplingEndDate DATETIME
						,strSamplingMethod NVARCHAR(50)
						,strContainerNumber NVARCHAR(100)
						,strMarks NVARCHAR(100)
						,strCountry NVARCHAR(100)
						,dtmBusinessDate DATETIME
						,strComment NVARCHAR(MAX)
						,ysnAdjustInventoryQtyBySampleQty BIT
						,strChildLotNumber NVARCHAR(50)
						,strCourier NVARCHAR(50)
						,strCourierRef NVARCHAR(50)
						,strForwardingAgentRef NVARCHAR(50)
						,strSentBy NVARCHAR(50)
						,intSampleRefId INT
						,dtmCreated DATETIME
						)

				SELECT @intNewSampleId = SCOPE_IDENTITY()
			END

			IF @strRowState = 'Modified'
			BEGIN
				UPDATE tblQMSample
				SET intConcurrencyId = intConcurrencyId + 1
					,intSampleTypeId = @intSampleTypeId
					,strSampleRefNo = @strSampleNumber
					,intProductTypeId = @intProductTypeId
					,intProductValueId = @intProductValueId
					,intSampleStatusId = @intSampleStatusId
					,intPreviousSampleStatusId = @intPreviousSampleStatusId
					,intItemId = @intItemId
					,intItemContractId = @intItemContractId
					,intContractDetailId = @intContractDetailId
					,intCountryID = @intCountryID
					,ysnIsContractCompleted = x.ysnIsContractCompleted
					,intLotStatusId = @intLotStatusId
					,intEntityId = @intEntityId
					,strShipmentNumber = x.strShipmentNumber
					,strLotNumber = x.strLotNumber
					,strSampleNote = x.strSampleNote
					,dtmSampleReceivedDate = x.dtmSampleReceivedDate
					,dtmTestedOn = x.dtmTestedOn
					,dblSampleQty = x.dblSampleQty
					,intSampleUOMId = @intSampleUOMId
					,dblRepresentingQty = x.dblRepresentingQty
					,intRepresentingUOMId = @intRepresentingUOMId
					,strRefNo = x.strRefNo
					,dtmTestingStartDate = x.dtmTestingStartDate
					,dtmTestingEndDate = x.dtmTestingEndDate
					,dtmSamplingEndDate = x.dtmSamplingEndDate
					,strSamplingMethod = x.strSamplingMethod
					,strContainerNumber = x.strContainerNumber
					,strMarks = x.strMarks
					,intCompanyLocationSubLocationId = @intCompanyLocationSubLocationId
					,strCountry = x.strCountry
					,intItemBundleId = @intItemBundleId
					,intLoadContainerId = @intLoadContainerId
					,intLoadDetailContainerLinkId = @intLoadDetailContainerLinkId
					,intLoadId = @intLoadId
					,intLoadDetailId = @intLoadDetailId
					,intInventoryReceiptId = @intInventoryReceiptId
					,intInventoryShipmentId = @intInventoryShipmentId
					,intWorkOrderId = @intWorkOrderId
					,strComment = x.strComment
					,ysnAdjustInventoryQtyBySampleQty = x.ysnAdjustInventoryQtyBySampleQty
					,intStorageLocationId = @intStorageLocationId
					,intBookId = @intBookId
					,intSubBookId = @intSubBookId
					,strChildLotNumber = x.strChildLotNumber
					,strCourier = x.strCourier
					,strCourierRef = x.strCourierRef
					,intForwardingAgentId = @intForwardingAgentId
					,strForwardingAgentRef = x.strForwardingAgentRef
					,strSentBy = x.strSentBy
					,intSentById = @intSentById
					,intLastModifiedUserId = @intLastModifiedUserId
					,dtmLastModified = @dtmLastModified
				FROM OPENXML(@idoc, 'vyuQMSampleHeaderViews/vyuQMSampleHeaderView', 2) WITH (
						ysnIsContractCompleted BIT
						,strShipmentNumber NVARCHAR(30)
						,strLotNumber NVARCHAR(50)
						,strSampleNote NVARCHAR(512)
						,dtmSampleReceivedDate DATETIME
						,dtmTestedOn DATETIME
						,dblSampleQty NUMERIC(18, 6)
						,dblRepresentingQty NUMERIC(18, 6)
						,strRefNo NVARCHAR(100)
						,dtmTestingStartDate DATETIME
						,dtmTestingEndDate DATETIME
						,dtmSamplingEndDate DATETIME
						,strSamplingMethod NVARCHAR(50)
						,strContainerNumber NVARCHAR(100)
						,strMarks NVARCHAR(100)
						,strCountry NVARCHAR(100)
						,strComment NVARCHAR(MAX)
						,ysnAdjustInventoryQtyBySampleQty BIT
						,strChildLotNumber NVARCHAR(50)
						,strCourier NVARCHAR(50)
						,strCourierRef NVARCHAR(50)
						,strForwardingAgentRef NVARCHAR(50)
						,strSentBy NVARCHAR(50)
						) x
				WHERE tblQMSample.intSampleRefId = @intSampleRefId
					AND tblQMSample.intBookId = @intToBookId

				SELECT @intNewSampleId = intSampleId
					,@strNewSampleNumber = strSampleNumber
				FROM tblQMSample WITH (NOLOCK)
				WHERE intSampleRefId = @intSampleRefId
					AND intBookId = @intToBookId
			END

			EXEC sp_xml_removedocument @idoc

			------------------------------------Detail--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strDetailXML

			DECLARE @tblQMSampleDetail TABLE (intSampleDetailId INT)

			INSERT INTO @tblQMSampleDetail (intSampleDetailId)
			SELECT intSampleDetailId
			FROM OPENXML(@idoc, 'vyuQMSampleDetailViews/vyuQMSampleDetailView', 2) WITH (intSampleDetailId INT)

			SELECT @intSampleDetailId = MIN(intSampleDetailId)
			FROM @tblQMSampleDetail

			WHILE @intSampleDetailId IS NOT NULL
			BEGIN
				SELECT @strAttributeName = NULL
					,@strListItemName = NULL

				SELECT @strAttributeName = strAttributeName
					,@strListItemName = strListItemName
				FROM OPENXML(@idoc, 'vyuQMSampleDetailViews/vyuQMSampleDetailView', 2) WITH (
						strAttributeName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strListItemName NVARCHAR(50) Collate Latin1_General_CI_AS
						,intSampleDetailId INT
						) SD
				WHERE intSampleDetailId = @intSampleDetailId

				IF @strAttributeName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMAttribute t WITH (NOLOCK)
						WHERE t.strAttributeName = @strAttributeName
						)
				BEGIN
					SELECT @strErrorMessage = 'Detail Attribute ' + @strAttributeName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strListItemName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMListItem t WITH (NOLOCK)
						WHERE t.strListItemName = @strListItemName
						)
				BEGIN
					SELECT @strErrorMessage = 'Detail List Item ' + @strListItemName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intAttributeId = NULL
					,@intListItemId = NULL

				SELECT @intAttributeId = t.intAttributeId
				FROM tblQMAttribute t WITH (NOLOCK)
				WHERE t.strAttributeName = @strAttributeName

				SELECT @intListItemId = t.intListItemId
				FROM tblQMListItem t WITH (NOLOCK)
				WHERE t.strListItemName = @strListItemName

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMSampleDetail WITH (NOLOCK)
						WHERE intSampleDetailRefId = @intSampleDetailId
							AND intSampleId = @intNewSampleId
						)
				BEGIN
					INSERT INTO tblQMSampleDetail (
						intConcurrencyId
						,intSampleId
						,intAttributeId
						,strAttributeValue
						,intListItemId
						,ysnIsMandatory
						,intSampleDetailRefId
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						)
					SELECT 1
						,@intNewSampleId
						,@intAttributeId
						,strAttributeValue
						,@intListItemId
						,ysnIsMandatory
						,@intSampleDetailId
						,@intLastModifiedUserId
						,@dtmLastModified
						,@intLastModifiedUserId
						,@dtmLastModified
					FROM OPENXML(@idoc, 'vyuQMSampleDetailViews/vyuQMSampleDetailView', 2) WITH (
							strAttributeValue NVARCHAR(50)
							,ysnIsMandatory BIT
							,intSampleDetailId INT
							) x
					WHERE x.intSampleDetailId = @intSampleDetailId
				END
				ELSE
				BEGIN
					UPDATE tblQMSampleDetail
					SET intConcurrencyId = intConcurrencyId + 1
						,intAttributeId = @intAttributeId
						,strAttributeValue = x.strAttributeValue
						,intListItemId = @intListItemId
						,ysnIsMandatory = x.ysnIsMandatory
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = @dtmLastModified
					FROM OPENXML(@idoc, 'vyuQMSampleDetailViews/vyuQMSampleDetailView', 2) WITH (
							strAttributeValue NVARCHAR(50)
							,ysnIsMandatory BIT
							,intSampleDetailId INT
							) x
					JOIN tblQMSampleDetail SD ON SD.intSampleDetailRefId = x.intSampleDetailId
						AND SD.intSampleId = @intNewSampleId
					WHERE x.intSampleDetailId = @intSampleDetailId
				END

				SELECT @intSampleDetailId = MIN(intSampleDetailId)
				FROM @tblQMSampleDetail
				WHERE intSampleDetailId > @intSampleDetailId
			END

			DELETE
			FROM tblQMSampleDetail
			WHERE intSampleId = @intNewSampleId
				AND intSampleDetailRefId NOT IN (
					SELECT intSampleDetailId
					FROM @tblQMSampleDetail
					)

			EXEC sp_xml_removedocument @idoc

			------------------------------------Test Result--------------------------------------------
			EXEC sp_xml_preparedocument @idoc OUTPUT
				,@strTestResultXML

			DECLARE @tblQMTestResult TABLE (intTestResultId INT)

			INSERT INTO @tblQMTestResult (intTestResultId)
			SELECT intTestResultId
			FROM OPENXML(@idoc, 'vyuQMSampleTestResultViews/vyuQMSampleTestResultView', 2) WITH (intTestResultId INT)

			SELECT @intTestResultId = MIN(intTestResultId)
			FROM @tblQMTestResult

			WHILE @intTestResultId IS NOT NULL
			BEGIN
				SELECT @intTemplateProductTypeId = NULL
					,@strTemplateProductValue = NULL
					,@strTestName = NULL
					,@strPropertyName = NULL
					,@strUnitMeasure = NULL
					,@strParentPropertyName = NULL
					,@strTestListItemName = NULL
					,@strPropertyItemNo = NULL
					,@dtmValidFrom = NULL
					,@dtmValidTo = NULL

				SELECT @intTemplateProductTypeId = intTemplateProductTypeId
					,@strTemplateProductValue = strTemplateProductValue
					,@strTestName = strTestName
					,@strPropertyName = strPropertyName
					,@strUnitMeasure = strUnitMeasure
					,@strParentPropertyName = strParentPropertyName
					,@strTestListItemName = strTestListItemName
					,@strPropertyItemNo = strPropertyItemNo
					,@dtmValidFrom = dtmValidFrom
					,@dtmValidTo = dtmValidTo
				FROM OPENXML(@idoc, 'vyuQMSampleTestResultViews/vyuQMSampleTestResultView', 2) WITH (
						intTemplateProductTypeId INT
						,strTemplateProductValue NVARCHAR(50) Collate Latin1_General_CI_AS
						,strTestName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strPropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strUnitMeasure NVARCHAR(50) Collate Latin1_General_CI_AS
						,strParentPropertyName NVARCHAR(100) Collate Latin1_General_CI_AS
						,strTestListItemName NVARCHAR(50) Collate Latin1_General_CI_AS
						,strPropertyItemNo NVARCHAR(50) Collate Latin1_General_CI_AS
						,dtmValidFrom DATETIME
						,dtmValidTo DATETIME
						,intTestResultId INT
						) TR
				WHERE intTestResultId = @intTestResultId

				IF @strTemplateProductValue IS NOT NULL
					AND @intTemplateProductTypeId IS NOT NULL
				BEGIN
					IF @intTemplateProductTypeId = 1
					BEGIN
						IF NOT EXISTS (
								SELECT 1
								FROM tblICCategory t WITH (NOLOCK)
								WHERE t.strCategoryCode = @strTemplateProductValue
								)
						BEGIN
							SELECT @strErrorMessage = 'Product Value Category ' + @strTemplateProductValue + ' is not available.'

							RAISERROR (
									@strErrorMessage
									,16
									,1
									)
						END
					END
					ELSE IF @intTemplateProductTypeId = 2
					BEGIN
						IF NOT EXISTS (
								SELECT 1
								FROM tblICItem t WITH (NOLOCK)
								WHERE t.strItemNo = @strTemplateProductValue
								)
						BEGIN
							SELECT @strErrorMessage = 'Product Value Item ' + @strTemplateProductValue + ' is not available.'

							RAISERROR (
									@strErrorMessage
									,16
									,1
									)
						END
					END
				END

				IF @strTestName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMTest t WITH (NOLOCK)
						WHERE t.strTestName = @strTestName
						)
				BEGIN
					SELECT @strErrorMessage = 'Test ' + @strTestName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strPropertyName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMProperty t WITH (NOLOCK)
						WHERE t.strPropertyName = @strPropertyName
						)
				BEGIN
					SELECT @strErrorMessage = 'Property ' + @strPropertyName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strUnitMeasure IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICUnitMeasure t WITH (NOLOCK)
						WHERE t.strUnitMeasure = @strUnitMeasure
						)
				BEGIN
					SELECT @strErrorMessage = 'UOM ' + @strUnitMeasure + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strParentPropertyName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMProperty t WITH (NOLOCK)
						WHERE t.strPropertyName = @strParentPropertyName
						)
				BEGIN
					SELECT @strErrorMessage = 'Parent Property ' + @strParentPropertyName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strTestListItemName IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblQMListItem t WITH (NOLOCK)
						WHERE t.strListItemName = @strTestListItemName
						)
				BEGIN
					SELECT @strErrorMessage = 'Test List Item ' + @strTestListItemName + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @strPropertyItemNo IS NOT NULL
					AND NOT EXISTS (
						SELECT 1
						FROM tblICItem t WITH (NOLOCK)
						WHERE t.strItemNo = @strPropertyItemNo
						)
				BEGIN
					SELECT @strErrorMessage = 'Test Property Item ' + @strPropertyItemNo + ' is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				SELECT @intTemplateProductValueId = NULL
					,@intTestId = NULL
					,@intPropertyId = NULL
					,@intUnitMeasureId = NULL
					,@intParentPropertyId = NULL
					,@intTestListItemId = NULL
					,@intPropertyItemId = NULL
					,@intPropertyValidityPeriodId = NULL
					,@intProductId = NULL
					,@intProductPropertyValidityPeriodId = NULL

				IF @intTemplateProductTypeId = 1
				BEGIN
					SELECT @intTemplateProductValueId = t.intCategoryId
					FROM tblICCategory t WITH (NOLOCK)
					WHERE t.strCategoryCode = @strTemplateProductValue
				END
				ELSE IF @intTemplateProductTypeId = 2
				BEGIN
					SELECT @intTemplateProductValueId = t.intItemId
					FROM tblICItem t WITH (NOLOCK)
					WHERE t.strItemNo = @strTemplateProductValue
				END

				SELECT @intTestId = t.intTestId
				FROM tblQMTest t WITH (NOLOCK)
				WHERE t.strTestName = @strTestName

				SELECT @intPropertyId = t.intPropertyId
				FROM tblQMProperty t WITH (NOLOCK)
				WHERE t.strPropertyName = @strPropertyName

				SELECT @intUnitMeasureId = t.intUnitMeasureId
				FROM tblICUnitMeasure t WITH (NOLOCK)
				WHERE t.strUnitMeasure = @strUnitMeasure

				SELECT @intParentPropertyId = t.intPropertyId
				FROM tblQMProperty t WITH (NOLOCK)
				WHERE t.strPropertyName = @strParentPropertyName

				SELECT @intTestListItemId = t.intListItemId
				FROM tblQMListItem t WITH (NOLOCK)
				WHERE t.strListItemName = @strTestListItemName

				SELECT @intPropertyItemId = t.intItemId
				FROM tblICItem t WITH (NOLOCK)
				WHERE t.strItemNo = @strPropertyItemNo

				IF @intPropertyId IS NOT NULL
					AND @dtmValidFrom IS NOT NULL
					AND @dtmValidTo IS NOT NULL
				BEGIN
					SELECT @intPropertyValidityPeriodId = intPropertyValidityPeriodId
					FROM tblQMPropertyValidityPeriod WITH (NOLOCK)
					WHERE intPropertyId = @intPropertyId
						AND DATEPART(mm, dtmValidFrom) = DATEPART(mm, @dtmValidFrom)
						AND DATEPART(dd, dtmValidFrom) = DATEPART(dd, @dtmValidFrom)
						AND DATEPART(mm, dtmValidTo) = DATEPART(mm, @dtmValidTo)
						AND DATEPART(dd, dtmValidTo) = DATEPART(dd, @dtmValidTo)
				END

				-- intProductId should fill only for creation
				IF @intTemplateProductTypeId = 3
					OR @intTemplateProductTypeId = 4
					OR @intTemplateProductTypeId = 5
				BEGIN
					SELECT @intProductId = P.intProductId
					FROM tblQMProduct P WITH (NOLOCK)
					JOIN tblQMProductControlPoint PC WITH (NOLOCK) ON PC.intProductId = P.intProductId
						AND PC.intSampleTypeId = @intSampleTypeId
					WHERE P.intProductTypeId = @intTemplateProductTypeId
						AND P.ysnActive = 1
				END
				ELSE IF (
						@intTemplateProductTypeId = 1
						OR @intTemplateProductTypeId = 2
						)
					AND @intTemplateProductValueId IS NOT NULL
				BEGIN
					SELECT @intProductId = P.intProductId
					FROM tblQMProduct P WITH (NOLOCK)
					JOIN tblQMProductControlPoint PC WITH (NOLOCK) ON PC.intProductId = P.intProductId
						AND PC.intSampleTypeId = @intSampleTypeId
					WHERE P.intProductTypeId = @intTemplateProductTypeId
						AND P.intProductValueId = @intTemplateProductValueId
						AND P.ysnActive = 1
				END

				IF @intProductId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Template is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF @intProductId IS NOT NULL
					AND @intTestId IS NOT NULL
					AND @intPropertyId IS NOT NULL
					AND @dtmValidFrom IS NOT NULL
					AND @dtmValidTo IS NOT NULL
				BEGIN
					SELECT @intProductPropertyValidityPeriodId = PPV.intProductPropertyValidityPeriodId
					FROM tblQMProduct PRD WITH (NOLOCK)
					JOIN tblQMProductProperty PP WITH (NOLOCK) ON PP.intProductId = PRD.intProductId
						AND PRD.intProductId = @intProductId
						AND PP.intTestId = @intTestId
						AND PP.intPropertyId = @intPropertyId
					JOIN tblQMProductPropertyValidityPeriod PPV WITH (NOLOCK) ON PPV.intProductPropertyId = PP.intProductPropertyId
						AND DATEPART(mm, dtmValidFrom) = DATEPART(mm, @dtmValidFrom)
						AND DATEPART(dd, dtmValidFrom) = DATEPART(dd, @dtmValidFrom)
						AND DATEPART(mm, dtmValidTo) = DATEPART(mm, @dtmValidTo)
						AND DATEPART(dd, dtmValidTo) = DATEPART(dd, @dtmValidTo)
				END

				IF @intProductPropertyValidityPeriodId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Template Property is not available.'

					RAISERROR (
							@strErrorMessage
							,16
							,1
							)
				END

				IF NOT EXISTS (
						SELECT 1
						FROM tblQMTestResult WITH (NOLOCK)
						WHERE intTestResultRefId = @intTestResultId
							AND intSampleId = @intNewSampleId
						)
				BEGIN
					INSERT INTO tblQMTestResult (
						intConcurrencyId
						,intSampleId
						,intProductId
						,intProductTypeId
						,intProductValueId
						,intTestId
						,intPropertyId
						,strPanelList
						,strPropertyValue
						,dtmCreateDate
						,strResult
						,ysnFinal
						,strComment
						,intSequenceNo
						,dtmValidFrom
						,dtmValidTo
						,strPropertyRangeText
						,dblMinValue
						,dblMaxValue
						,dblLowValue
						,dblHighValue
						,intUnitMeasureId
						,strFormulaParser
						,dblCrdrPrice
						,dblCrdrQty
						,intProductPropertyValidityPeriodId
						,intPropertyValidityPeriodId
						,intControlPointId
						,intParentPropertyId
						,intRepNo
						,strFormula
						,intListItemId
						,strIsMandatory
						,intPropertyItemId
						,dtmPropertyValueCreated
						,intTestResultRefId
						,intCreatedUserId
						,dtmCreated
						,intLastModifiedUserId
						,dtmLastModified
						)
					SELECT 1
						,@intNewSampleId
						,@intProductId
						,@intProductTypeId
						,@intProductValueId
						,@intTestId
						,@intPropertyId
						,strPanelList
						,strPropertyValue
						,dtmCreateDate
						,strResult
						,ysnFinal
						,strComment
						,intSequenceNo
						,dtmValidFrom
						,dtmValidTo
						,strPropertyRangeText
						,dblMinValue
						,dblMaxValue
						,dblLowValue
						,dblHighValue
						,@intUnitMeasureId
						,strFormulaParser
						,dblCrdrPrice
						,dblCrdrQty
						,@intProductPropertyValidityPeriodId
						,@intPropertyValidityPeriodId
						,intControlPointId
						,@intParentPropertyId
						,intRepNo
						,strFormula
						,@intListItemId
						,strIsMandatory
						,@intPropertyItemId
						,dtmPropertyValueCreated
						,@intTestResultId
						,@intLastModifiedUserId
						,@dtmLastModified
						,@intLastModifiedUserId
						,@dtmLastModified
					FROM OPENXML(@idoc, 'vyuQMSampleTestResultViews/vyuQMSampleTestResultView', 2) WITH (
							strPanelList NVARCHAR(50)
							,strPropertyValue NVARCHAR(MAX)
							,dtmCreateDate DATETIME
							,strResult NVARCHAR(20)
							,ysnFinal BIT
							,strComment NVARCHAR(MAX)
							,intSequenceNo INT
							,dtmValidFrom DATETIME
							,dtmValidTo DATETIME
							,strPropertyRangeText NVARCHAR(MAX)
							,dblMinValue NUMERIC(18, 6)
							,dblMaxValue NUMERIC(18, 6)
							,dblLowValue NUMERIC(18, 6)
							,dblHighValue NUMERIC(18, 6)
							,strFormulaParser NVARCHAR(MAX)
							,dblCrdrPrice NUMERIC(18, 6)
							,dblCrdrQty NUMERIC(18, 6)
							,intControlPointId INT
							,intRepNo INT
							,strFormula NVARCHAR(MAX)
							,strIsMandatory NVARCHAR(20)
							,dtmPropertyValueCreated DATETIME
							,intTestResultId INT
							) x
					WHERE x.intTestResultId = @intTestResultId
				END
				ELSE
				BEGIN
					UPDATE tblQMTestResult
					SET intConcurrencyId = intConcurrencyId + 1
						,intProductTypeId = @intProductTypeId
						,intProductValueId = @intProductValueId
						,strPropertyValue = x.strPropertyValue
						,strResult = x.strResult
						,strComment = x.strComment
						,intSequenceNo = x.intSequenceNo
						,intControlPointId = x.intControlPointId
						,intListItemId = @intListItemId
						,dtmPropertyValueCreated = x.dtmPropertyValueCreated
						,intLastModifiedUserId = @intLastModifiedUserId
						,dtmLastModified = @dtmLastModified
					FROM OPENXML(@idoc, 'vyuQMSampleTestResultViews/vyuQMSampleTestResultView', 2) WITH (
							strPropertyValue NVARCHAR(MAX)
							,strResult NVARCHAR(20)
							,strComment NVARCHAR(MAX)
							,intSequenceNo INT
							,intControlPointId INT
							,dtmPropertyValueCreated DATETIME
							,intTestResultId INT
							) x
					JOIN tblQMTestResult TR ON TR.intTestResultRefId = x.intTestResultId
						AND TR.intSampleId = @intNewSampleId
					WHERE x.intTestResultId = @intTestResultId
				END

				SELECT @intTestResultId = MIN(intTestResultId)
				FROM @tblQMTestResult
				WHERE intTestResultId > @intTestResultId
			END

			DELETE
			FROM tblQMTestResult
			WHERE intSampleId = @intNewSampleId
				AND intTestResultRefId NOT IN (
					SELECT intTestResultId
					FROM @tblQMTestResult
					)

			--EXEC sp_xml_removedocument @idoc
			SELECT @strHeaderCondition = 'intSampleId = ' + LTRIM(@intNewSampleId)

			EXEC uspCTGetTableDataInXML 'tblQMSample'
				,@strHeaderCondition
				,@strAckHeaderXML OUTPUT

			EXEC uspCTGetTableDataInXML 'tblQMSampleDetail'
				,@strHeaderCondition
				,@strAckDetailXML OUTPUT

			EXEC uspCTGetTableDataInXML 'tblQMTestResult'
				,@strHeaderCondition
				,@strAckTestResultXML OUTPUT

			ext:

			SELECT @intCompanyRefId = intCompanyId
			FROM tblQMSample WITH (NOLOCK)
			WHERE intSampleId = @intNewSampleId

			IF (@intNewSampleId > 0)
			BEGIN
				DECLARE @StrDescription AS NVARCHAR(MAX)

				SELECT @strFromBook = B.strBook
				FROM tblSMInterCompanyTransactionConfiguration TC WITH (NOLOCK)
				JOIN tblSMInterCompanyTransactionType TT WITH (NOLOCK) ON TT.intInterCompanyTransactionTypeId = TC.intFromTransactionTypeId
					AND TT.strTransactionType = 'Quality Sample'
					AND TC.intToBookId = @intToBookId
				JOIN tblCTBook B WITH (NOLOCK) ON B.intBookId = TC.intFromBookId

				IF @strRowState = 'Added'
				BEGIN
					SELECT @StrDescription = 'Created from ' + @strFromBook + ': ' + @strSampleNumber

					EXEC uspSMAuditLog @keyValue = @intNewSampleId
						,@screenName = 'Quality.view.QualitySample'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strNewSampleNumber
				END
				ELSE IF @strRowState = 'Modified'
				BEGIN
					SELECT @StrDescription = 'Updated from ' + @strFromBook + ': ' + @strSampleNumber

					EXEC uspSMAuditLog @keyValue = @intNewSampleId
						,@screenName = 'Quality.view.QualitySample'
						,@entityId = @intLastModifiedUserId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@changeDescription = @StrDescription
						,@fromValue = ''
						,@toValue = @strNewSampleNumber
				END
			END

			SELECT @intScreenId = intScreenId
			FROM tblSMScreen WITH (NOLOCK)
			WHERE strNamespace = 'Quality.view.QualitySample'

			SELECT @intTransactionRefId = intTransactionId
			FROM tblSMTransaction WITH (NOLOCK)
			WHERE intRecordId = @intNewSampleId
				AND intScreenId = @intScreenId

			IF @ysnParent = 1
			BEGIN
				SELECT TOP 1 @intMultiCompanyId = intCompanyId
				FROM tblIPMultiCompany
				WHERE ysnParent = 1
			END
			ELSE
			BEGIN
				SELECT @intMultiCompanyId = @intCompanyId
			END

			DECLARE @strSQL NVARCHAR(MAX)
				,@strServerName NVARCHAR(50)
				,@strDatabaseName NVARCHAR(50)

			SELECT @strServerName = strServerName
				,@strDatabaseName = strDatabaseName
			FROM tblIPMultiCompany WITH (NOLOCK)
			WHERE intCompanyId = @intCompanyId

			SELECT @strSQL = N'INSERT INTO ' + @strServerName + '.' + @strDatabaseName + '.dbo.tblQMSampleAcknowledgementStage (
				intSampleId
				,strSampleAckNumber
				,dtmFeedDate
				,strMessage
				,strTransactionType
				,intMultiCompanyId
				,strAckHeaderXML
				,strAckDetailXML
				,strAckTestResultXML
				,strRowState
				,intTransactionId
				,intCompanyId
				,intTransactionRefId
				,intCompanyRefId
				)
			SELECT @intNewSampleId
				,@strNewSampleNumber
				,GETDATE()
				,''Success''
				,@strTransactionType
				,@intMultiCompanyId
				,@strAckHeaderXML
				,@strAckDetailXML
				,@strAckTestResultXML
				,@strRowState
				,@intTransactionId
				,@intCompanyId
				,@intTransactionRefId
				,@intCompanyRefId'

			EXEC sp_executesql @strSQL
				,N'@intNewSampleId INT
					,@strNewSampleNumber NVARCHAR(MAX)
					,@strTransactionType NVARCHAR(MAX)
					,@intMultiCompanyId INT
					,@strAckHeaderXML NVARCHAR(MAX)
					,@strAckDetailXML NVARCHAR(MAX)
					,@strAckTestResultXML NVARCHAR(MAX)
					,@strRowState NVARCHAR(MAX)
					,@intTransactionId INT
					,@intCompanyId INT
					,@intTransactionRefId INT
					,@intCompanyRefId INT'
				,@intNewSampleId
				,@strNewSampleNumber
				,@strTransactionType
				,@intMultiCompanyId
				,@strAckHeaderXML
				,@strAckDetailXML
				,@strAckTestResultXML
				,@strRowState
				,@intTransactionId
				,@intCompanyId
				,@intTransactionRefId
				,@intCompanyRefId

			SELECT @intSampleAcknowledgementStageId = SCOPE_IDENTITY()

			IF @strRowState <> 'Delete'
			BEGIN
				IF @intTransactionRefId IS NULL
				BEGIN
					SELECT @strErrorMessage = 'Current Transaction Id is not available. '

					RAISERROR (
								@strErrorMessage
								,16
								,1
								)
				END
				ELSE
				BEGIN
					EXECUTE dbo.uspSMInterCompanyUpdateMapping @currentTransactionId = @intTransactionRefId
						,@referenceTransactionId = @intTransactionId
						,@referenceCompanyId = @intCompanyId
				END
			END

			EXEC sp_xml_removedocument @idoc

			UPDATE tblQMSampleStage
			SET strFeedStatus = 'Processed'
				,intNewSampleId = @intNewSampleId
				,strNewSampleNumber = @strNewSampleNumber
				,strNewSampleTypeName = @strSampleTypeName
				,strMessage = 'Success'
			WHERE intSampleStageId = @intSampleStageId

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

			UPDATE tblQMSampleStage
			SET strFeedStatus = 'Failed'
				,strMessage = @ErrMsg
				,intNewSampleId = @intNewSampleId
				,strNewSampleNumber = @strNewSampleNumber
				,strNewSampleTypeName = @strSampleTypeName
			WHERE intSampleStageId = @intSampleStageId
		END CATCH

		SELECT @intSampleStageId = MIN(intSampleStageId)
		FROM @tblQMSampleStage
		WHERE intSampleStageId > @intSampleStageId
			--AND ISNULL(strFeedStatus, '') = ''
			--AND intMultiCompanyId = @intToCompanyId
	END

	UPDATE t
	SET t.strFeedStatus = NULL
	FROM tblQMSampleStage t
	JOIN @tblQMSampleStage pt ON pt.intSampleStageId = t.intSampleStageId
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
