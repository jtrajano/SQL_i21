CREATE PROCEDURE uspIPProcessSAPShippingInstruction @strInfo1 NVARCHAR(MAX) = '' OUT
	,@strInfo2 NVARCHAR(MAX) = '' OUT
	,@intNoOfRowsAffected INT = 0 OUT
	,@ysnProcessDeadLockEntry BIT = 0
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
		,@strRowState NVARCHAR(50)
	DECLARE @strCustomerReference NVARCHAR(100)
		,@strERPPONumber NVARCHAR(100)
		,@strOriginPort NVARCHAR(200)
		,@strDestinationPort NVARCHAR(200)
		,@dtmETSPOL DATETIME
		,@dtmDeadlineCargo DATETIME
		,@dtmETAPOD DATETIME
		,@dtmETAPOL DATETIME
		,@strBookingReference NVARCHAR(100)
		,@strServiceContractNumber NVARCHAR(100)
		,@strBLNumber NVARCHAR(100)
		,@strMVessel NVARCHAR(200)
		,@strMVoyageNumber NVARCHAR(100)
		,@strShippingMode NVARCHAR(100)
		,@strShippingLine NVARCHAR(100)
		,@intNumberOfContainers INT
		,@strContainerType NVARCHAR(50)
		,@strPartyAlias NVARCHAR(100)
		,@strPartyName NVARCHAR(100)
		,@strForwardingAgent NVARCHAR(100)
		,@strContractPartyName NVARCHAR(100)
		,@strPartyType NVARCHAR(50)
	DECLARE @strLoadNumber NVARCHAR(100)
		,@intLoadId INT
		,@intContractDetailId INT
		,@intOriginPortId INT
		,@intDestinationPortId INT
		,@intShippingModeId INT
		,@intShippingLineEntityId INT
		,@intContainerTypeId INT
		,@intShipperId INT
		,@intForwardingAgentEntityId INT
		,@intContractShipperId INT
		,@intMainContractHeaderId INT
		,@intContractSeq INT
		,@intShipmentType INT
		,@intShipmentStatus INT
		,@intSourceType INT
		,@intTransportationMode INT
		,@intPurchaseSale INT
		,@intPositionId INT
		,@intBookId INT
		,@intSubBookId INT
		,@ysnLoadBased BIT
		,@intTransUsedBy INT
		,@intFreightTermId INT
		,@intWeightUnitMeasureId INT
		,@intCurrencyId INT
		,@strPackingDescription NVARCHAR(50)
		,@dtmStartDate DATETIME
		,@dtmEndDate DATETIME
		,@dtmPlannedAvailabilityDate DATETIME
		,@intLocationId INT
		,@intLeadTime INT
		,@dtmCalculatedAvailabilityDate DATETIME
	DECLARE @strDescription NVARCHAR(MAX)
		,@intOldPurchaseSale INT
		,@intOldPositionId INT
		,@strOldOriginPort NVARCHAR(200)
		,@strOldDestinationPort NVARCHAR(200)
		,@dtmOldETSPOL DATETIME
		,@dtmOldDeadlineCargo DATETIME
		,@dtmOldETAPOD DATETIME
		,@dtmOldETAPOL DATETIME
		,@strOldBookingReference NVARCHAR(100)
		,@strOldServiceContractNumber NVARCHAR(100)
		,@strOldBLNumber NVARCHAR(100)
		,@strOldMVessel NVARCHAR(200)
		,@strOldMVoyageNumber NVARCHAR(100)
		,@strOldShippingMode NVARCHAR(100)
		,@strOldShippingLine NVARCHAR(100)
		,@intOldShippingLineEntityId INT
		,@strOldForwardingAgent NVARCHAR(100)
		,@intOldForwardingAgentEntityId INT
		,@intOldNumberOfContainers INT
		,@intOldContainerTypeId INT
		,@strOldContainerType NVARCHAR(50)
		,@strOldPackingDescription NVARCHAR(50)
		,@dtmOldStartDate DATETIME
		,@dtmOldEndDate DATETIME
		,@dtmOldPlannedAvailabilityDate DATETIME
		,@strOldCustomerReference NVARCHAR(100)
	DECLARE @intNewStageLoadId INT
	DECLARE @tblLGLoadDetail TABLE (intStageLoadDetailId INT)
	DECLARE @intStageLoadDetailId INT
		,@strCommodityCode NVARCHAR(50)
		,@strItemNo NVARCHAR(50)
		,@strContractItemName NVARCHAR(100)
		,@dblQuantity NUMERIC(18, 6)
		,@dblGrossWeight NUMERIC(18, 6)
		,@strPackageType NVARCHAR(50)
		,@strOrgItemNo NVARCHAR(50)
		,@strOrgContractItemName NVARCHAR(100)
	DECLARE @intCommodityId INT
		,@intItemId INT
		,@intItemContractId INT
		,@intVendorEntityId INT
		,@intCompanyLocationId INT
		,@intItemUOMId INT
		,@intWeightItemUOMId INT
		,@strPriceStatus NVARCHAR(100)
		,@dblUnitPrice NUMERIC(18, 6)
		,@intPriceCurrencyId INT
		,@intPriceUOMId INT
		,@dblAmount NUMERIC(18, 6)
		,@strVendorReference NVARCHAR(200)
		,@intPSubLocationId INT
		,@intPNumberOfContainers INT
		,@dblOldDetailQuantity NUMERIC(18, 6)
		,@intContractHeaderId INT
	DECLARE @tblLGLoadDetailChanges TABLE (
		dblOldQuantity NUMERIC(18, 6)
		,dblNewQuantity NUMERIC(18, 6)
		,dblOldGross NUMERIC(18, 6)
		,dblNewGross NUMERIC(18, 6)
		,intLoadDetailId INT
		,strAuditLogInfo NVARCHAR(200)
		,intPContractDetailId INT
		)
	DECLARE @dblOldQuantity NUMERIC(18, 6)
		,@dblNewQuantity NUMERIC(18, 6)
		,@dblOldGross NUMERIC(18, 6)
		,@dblNewGross NUMERIC(18, 6)
		,@intAuditLoadDetailId INT
		,@strAuditLogInfo NVARCHAR(200)
	DECLARE @tblLGLoadNotifyParties TABLE (intStageLoadNotifyPartiesId INT)
	DECLARE @intStageLoadNotifyPartiesId INT
	DECLARE @strNotifyPartyType NVARCHAR(50)
		,@strNotifyPartyName NVARCHAR(100)
		,@strNotifyPartyLocation NVARCHAR(100)
		,@intLoadNotifyPartyId INT
	DECLARE @intNotifyEntityId INT
		,@intNotifyEntityLocationId INT
		,@intCompanySetupID INT
		,@strNotifyOrConsignee NVARCHAR(100)
		,@strType NVARCHAR(100)
	DECLARE @intConsigneeCount INT
		,@intFirstNotifyCount INT
		,@intSecondNotifyCount INT
	DECLARE @tblLGLoadDocuments TABLE (intStageLoadDocumentsId INT)
	DECLARE @intStageLoadDocumentsId INT
	DECLARE @strDocumentName NVARCHAR(50)
		,@intOriginal INT
		,@intCopies INT
		,@intLoadDocumentId INT
	DECLARE @intDocumentId INT
		,@strDocumentType NVARCHAR(100)
	DECLARE @DeadlockRecords TABLE (intStageLoadId INT)
	DECLARE @intStageLoadId INT
		,@intNewDLStageLoadId INT
	DECLARE @tblDeleteNotifyParties TABLE (intLoadNotifyPartyId INT)
	DECLARE @tblLGLoadNotifyPartiesChanges TABLE (
		intLoadNotifyPartyId INT
		,strAction NVARCHAR(50)
		,strNotifyOrConsignee NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,intNewEntityId INT
		,intNewCompanySetupID INT
		,intNewEntityLocationId INT
		,intOldEntityId INT
		,intOldCompanySetupID INT
		,intOldEntityLocationId INT
		)
	DECLARE @intAuditLoadNotifyPartyId INT
		,@strAction NVARCHAR(50)
		,@strAuditNotifyOrConsignee NVARCHAR(100)
		,@intNewEntityId INT
		,@intNewCompanySetupID INT
		,@intNewEntityLocationId INT
		,@intOldEntityId INT
		,@intOldCompanySetupID INT
		,@intOldEntityLocationId INT
	DECLARE @tblLGLoadNotifyPartiesOrg TABLE (
		intLoadNotifyPartyId INT
		,strNotifyOrConsignee NVARCHAR(100) COLLATE Latin1_General_CI_AS
		)
	DECLARE @strNewEntityName NVARCHAR(100)
		,@strNewCompanyName NVARCHAR(100)
		,@strNewEntityLocationName NVARCHAR(100)
		,@strOldEntityName NVARCHAR(100)
		,@strOldCompanyName NVARCHAR(100)
		,@strOldEntityLocationName NVARCHAR(100)
	DECLARE @tblDeleteDocuments TABLE (intLoadDocumentId INT)
	DECLARE @tblLGLoadDocumentsChanges TABLE (
		intLoadDocumentId INT
		,strAction NVARCHAR(50)
		,strDocumentName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		,strNewDocumentType NVARCHAR(100)
		,intNewOriginal INT
		,intNewCopies INT
		,strOldDocumentType NVARCHAR(100)
		,intOldOriginal INT
		,intOldCopies INT
		)
	DECLARE @intAuditLoadDocumentId INT
		,@strAuditAction NVARCHAR(50)
		,@strAuditDocumentName NVARCHAR(50)
		,@strNewDocumentType NVARCHAR(100)
		,@intNewOriginal INT
		,@intNewCopies INT
		,@strOldDocumentType NVARCHAR(100)
		,@intOldOriginal INT
		,@intOldCopies INT
	DECLARE @tblLGLoadDocumentsOrg TABLE (
		intLoadDocumentId INT
		,strDocumentName NVARCHAR(50) COLLATE Latin1_General_CI_AS
		)
	DECLARE @strFileName NVARCHAR(MAX)

	-- To reprocess all LSI / LS / LSI_Cancel deadlock feeds
	IF @ysnProcessDeadLockEntry = 1
	BEGIN
		IF NOT EXISTS (
				SELECT 1
				FROM tblIPLoadError WITH (NOLOCK)
				WHERE ysnDeadlockError = 1
				)
		BEGIN
			RETURN
		END

		DELETE
		FROM @DeadlockRecords

		INSERT INTO @DeadlockRecords (intStageLoadId)
		SELECT intStageLoadId
		FROM tblIPLoadError WITH (NOLOCK)
		WHERE ysnDeadlockError = 1

		SELECT @intStageLoadId = MIN(intStageLoadId)
		FROM @DeadlockRecords

		WHILE @intStageLoadId IS NOT NULL
		BEGIN
			SELECT @intNewDLStageLoadId = NULL
				,@strFileName = NULL
				,@strERPPONumber = NULL

			SELECT @strFileName = strFileName
				,@strERPPONumber = strERPPONumber
			FROM tblIPLoadError WITH (NOLOCK)
			WHERE intStageLoadId = @intStageLoadId

			IF EXISTS (
				SELECT 1 FROM tblIPLoadStage
				WHERE strFileName = @strFileName
					AND strERPPONumber = @strERPPONumber
				)
			BEGIN
				UPDATE tblIPLoadError
				SET strAckStatus = 'Ack Sent'
					,ysnDeadlockError = 0
				WHERE intStageLoadId = @intStageLoadId

				GOTO NextRec
			END

			INSERT INTO tblIPLoadStage (
				strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETAPOD
				,dtmETAPOL
				,dtmDeadlineCargo
				,dtmETSPOL
				,strBookingReference
				,strServiceContractNumber
				,strBLNumber
				,dtmBLDate
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strPartyAlias
				,strPartyName
				,strPartyType
				,strLoadNumber
				,strAction
				,strFileName
				,strCancelStatus
				,dtmCancelDate
				,strTransactionType
				,strSessionId
				,ysnDeadlockError
				)
			SELECT strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETAPOD
				,dtmETAPOL
				,dtmDeadlineCargo
				,dtmETSPOL
				,strBookingReference
				,strServiceContractNumber
				,strBLNumber
				,dtmBLDate
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strPartyAlias
				,strPartyName
				,strPartyType
				,strLoadNumber
				,strAction
				,strFileName
				,strCancelStatus
				,dtmCancelDate
				,strTransactionType
				,strSessionId
				,ysnDeadlockError
			FROM tblIPLoadError
			WHERE intStageLoadId = @intStageLoadId

			SELECT @intNewDLStageLoadId = SCOPE_IDENTITY()

			INSERT INTO tblIPLoadDetailStage (
				intStageLoadId
				,strCustomerReference
				,strCommodityCode
				,strItemNo
				,strContractItemName
				,dblQuantity
				,dblGrossWeight
				,strPackageType
				)
			SELECT @intNewDLStageLoadId
				,strCustomerReference
				,strCommodityCode
				,strItemNo
				,strContractItemName
				,dblQuantity
				,dblGrossWeight
				,strPackageType
			FROM tblIPLoadDetailError
			WHERE intStageLoadId = @intStageLoadId

			INSERT INTO tblIPLoadContainerStage (
				intStageLoadId
				,strCustomerReference
				,strContainerNumber
				,strContainerType
				,dblGrossWt
				,dblTareWt
				,dblQuantity
				)
			SELECT @intNewDLStageLoadId
				,strCustomerReference
				,strContainerNumber
				,strContainerType
				,dblGrossWt
				,dblTareWt
				,dblQuantity
			FROM tblIPLoadContainerError
			WHERE intStageLoadId = @intStageLoadId

			INSERT INTO tblIPLoadNotifyPartiesStage (
				intStageLoadId
				,strCustomerReference
				,strPartyType
				,strPartyName
				,strPartyLocation
				)
			SELECT @intNewDLStageLoadId
				,strCustomerReference
				,strPartyType
				,strPartyName
				,strPartyLocation
			FROM tblIPLoadNotifyPartiesError
			WHERE intStageLoadId = @intStageLoadId

			INSERT INTO tblIPLoadDocumentsStage (
				intStageLoadId
				,strCustomerReference
				,strTypeCode
				,strName
				,intOriginal
				,intCopies
				)
			SELECT @intNewDLStageLoadId
				,strCustomerReference
				,strTypeCode
				,strName
				,intOriginal
				,intCopies
			FROM tblIPLoadDocumentsError
			WHERE intStageLoadId = @intStageLoadId

			DELETE
			FROM tblIPLoadError
			WHERE intStageLoadId = @intStageLoadId

			NextRec:

			SELECT @intStageLoadId = MIN(intStageLoadId)
			FROM @DeadlockRecords
			WHERE intStageLoadId > @intStageLoadId
		END
	END

	SELECT @intMinRowNo = Min(intStageLoadId)
	FROM tblIPLoadStage WITH (NOLOCK)
	WHERE ISNULL(strTransactionType, '') = 'ShippingInstruction'

	WHILE (@intMinRowNo IS NOT NULL)
	BEGIN
		BEGIN TRY
			SET @intNoOfRowsAffected = 1

			SELECT @strCustomerReference = NULL
				,@strERPPONumber = NULL
				,@strOriginPort = NULL
				,@strDestinationPort = NULL
				,@dtmETSPOL = NULL
				,@dtmDeadlineCargo = NULL
				,@dtmETAPOD = NULL
				,@dtmETAPOL = NULL
				,@strBookingReference = NULL
				,@strServiceContractNumber = NULL
				,@strBLNumber = NULL
				,@strMVessel = NULL
				,@strMVoyageNumber = NULL
				,@strShippingMode = NULL
				,@strShippingLine = NULL
				,@intNumberOfContainers = NULL
				,@strContainerType = NULL
				,@strPartyAlias = NULL
				,@strPartyName = NULL
				,@strForwardingAgent = NULL
				,@strContractPartyName = NULL
				,@strPartyType = NULL

			SELECT @strLoadNumber = NULL
				,@intLoadId = NULL
				,@intContractDetailId = NULL
				,@intOriginPortId = NULL
				,@intDestinationPortId = NULL
				,@intShippingModeId = NULL
				,@intShippingLineEntityId = NULL
				,@intContainerTypeId = NULL
				,@intShipperId = NULL
				,@intForwardingAgentEntityId = NULL
				,@intContractShipperId = NULL
				,@intMainContractHeaderId = NULL
				,@intContractSeq = NULL
				,@intShipmentType = NULL
				,@intShipmentStatus = NULL
				,@intSourceType = NULL
				,@intTransportationMode = NULL
				,@intPurchaseSale = NULL
				,@intPositionId = NULL
				,@intBookId = NULL
				,@intSubBookId = NULL
				,@ysnLoadBased = NULL
				,@intTransUsedBy = NULL
				,@intFreightTermId = NULL
				,@intWeightUnitMeasureId = NULL
				,@intCurrencyId = NULL
				,@strPackingDescription = NULL
				,@strPackageType = NULL
				,@dtmStartDate = NULL
				,@dtmEndDate = NULL
				,@dtmPlannedAvailabilityDate = NULL
				,@intLocationId = NULL
				,@intLeadTime = NULL
				,@dtmCalculatedAvailabilityDate = NULL

			SELECT @strDescription = NULL
				,@intOldPurchaseSale = NULL
				,@intOldPositionId = NULL
				,@strOldOriginPort = NULL
				,@strOldDestinationPort = NULL
				,@dtmOldETSPOL = NULL
				,@dtmOldDeadlineCargo = NULL
				,@dtmOldETAPOD = NULL
				,@dtmOldETAPOL = NULL
				,@strOldBookingReference = NULL
				,@strOldServiceContractNumber = NULL
				,@strOldBLNumber = NULL
				,@strOldMVessel = NULL
				,@strOldMVoyageNumber = NULL
				,@strOldShippingMode = NULL
				,@strOldShippingLine = NULL
				,@intOldShippingLineEntityId = NULL
				,@strOldForwardingAgent = NULL
				,@intOldForwardingAgentEntityId = NULL
				,@intOldNumberOfContainers = NULL
				,@intOldContainerTypeId = NULL
				,@strOldContainerType = NULL
				,@strOldPackingDescription = NULL
				,@dtmOldStartDate = NULL
				,@dtmOldEndDate = NULL
				,@dtmOldPlannedAvailabilityDate = NULL
				,@strOldCustomerReference = NULL

			SELECT @intStageLoadDetailId = NULL
				,@strRowState = ''

			SELECT @strCustomerReference = strCustomerReference
				,@strERPPONumber = strERPPONumber
				,@strOriginPort = strOriginPort
				,@strDestinationPort = strDestinationPort
				,@dtmETSPOL = dtmETSPOL
				,@dtmDeadlineCargo = dtmDeadlineCargo
				,@dtmETAPOD = dtmETAPOD
				,@dtmETAPOL = dtmETAPOL
				,@strBookingReference = strBookingReference
				,@strServiceContractNumber = strServiceContractNumber
				,@strBLNumber = strBLNumber
				,@strMVessel = strMVessel
				,@strMVoyageNumber = strMVoyageNumber
				,@strShippingMode = strShippingMode
				,@strShippingLine = strShippingLine
				,@intNumberOfContainers = ISNULL(intNumberOfContainers, 0)
				,@strContainerType = strContainerType
				,@strPartyAlias = strPartyAlias
				,@strPartyName = strPartyName
				,@strPartyType = strPartyType
			FROM tblIPLoadStage WITH (NOLOCK)
			WHERE intStageLoadId = @intMinRowNo

			UPDATE tblIPLoadError
			SET ysnDeadlockError = 0
			WHERE ysnDeadlockError = 1
				AND strCustomerReference = @strCustomerReference

			SELECT TOP 1 @strPackageType = strPackageType
			FROM tblIPLoadDetailStage
			WHERE intStageLoadId = @intMinRowNo

			IF ISNULL(@strCustomerReference, '') = ''
			BEGIN
				RAISERROR (
						'Invalid Customer Reference. '
						,16
						,1
						)
			END

			SELECT @intContractDetailId = t.intContractDetailId
			FROM tblCTContractDetail t WITH (NOLOCK)
			WHERE t.strERPPONumber = @strERPPONumber

			IF ISNULL(@strERPPONumber, '') = ''
				OR ISNULL(@intContractDetailId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid ERP PO Number. '
						,16
						,1
						)
			END

			SELECT @intOriginPortId = t.intCityId
			FROM tblSMCity t WITH (NOLOCK)
			WHERE t.strCity = @strOriginPort
				AND t.ysnPort = 1

			IF ISNULL(@intOriginPortId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Loading Port. '
						,16
						,1
						)
			END

			SELECT @intDestinationPortId = t.intCityId
			FROM tblSMCity t WITH (NOLOCK)
			WHERE t.strCity = @strDestinationPort
				AND t.ysnPort = 1

			IF ISNULL(@intDestinationPortId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Destination Port. '
						,16
						,1
						)
			END

			IF @dtmETSPOL IS NULL
			BEGIN
				RAISERROR (
						'Invalid Instr ETD. '
						,16
						,1
						)
			END

			IF @dtmDeadlineCargo IS NULL
			BEGIN
				RAISERROR (
						'Invalid Instr ETA. '
						,16
						,1
						)
			END

			-- If Ata(dtmETAPOD) is empty, take Eta(dtmDeadlineCargo)
			--IF @dtmETAPOD IS NULL
			--BEGIN
			--	SELECT @dtmETAPOD = @dtmDeadlineCargo
			--END
			--IF @dtmETAPOL IS NULL
			--BEGIN
			--	RAISERROR (
			--			'Invalid Act. ETD. '
			--			,16
			--			,1
			--			)
			--END
			IF ISNULL(@strShippingLine, '') <> ''
			BEGIN
				SELECT @intShippingLineEntityId = t.intEntityId
				FROM tblEMEntity t WITH (NOLOCK)
				WHERE t.strName = @strShippingLine

				IF ISNULL(@intShippingLineEntityId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Shipping Line. '
							,16
							,1
							)
				END
			END

			SELECT @intShippingModeId = t.intShippingModeId
			FROM tblLGShippingMode t WITH (NOLOCK)
			WHERE t.strShippingMode = @strShippingMode

			IF ISNULL(@intShippingModeId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Shipping Mode. '
						,16
						,1
						)
			END

			IF @strContainerType = '20GP'
				SELECT @strContainerType = '20 FT'
			ELSE IF @strContainerType = '40GP'
				SELECT @strContainerType = '40 FT'

			SELECT @intContainerTypeId = t.intContainerTypeId
			FROM tblLGContainerType t WITH (NOLOCK)
			WHERE t.strContainerType = @strContainerType

			IF ISNULL(@intContainerTypeId, 0) = 0
			BEGIN
				RAISERROR (
						'Invalid Container Type. '
						,16
						,1
						)
			END

			SELECT TOP 1 @strPartyName = strPartyName
			FROM tblIPLoadNotifyPartiesStage WITH (NOLOCK)
			WHERE intStageLoadId = @intMinRowNo
				AND strPartyType = 'CZ'

			IF ISNULL(@strPartyName, '') <> ''
			BEGIN
				SELECT @intShipperId = t.intEntityId
				FROM tblEMEntity t WITH (NOLOCK)
				JOIN tblEMEntityType ET WITH (NOLOCK) ON ET.intEntityId = t.intEntityId
				JOIN tblAPVendor V WITH (NOLOCK) ON V.intEntityId = t.intEntityId
				WHERE ET.strType = 'Producer'
					--AND t.ysnActive = 1
					--AND t.strEntityNo <> ''
					AND t.strName = @strPartyName

				IF ISNULL(@intShipperId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Shipper. '
							,16
							,1
							)
				END
			END

			SELECT TOP 1 @strForwardingAgent = strPartyName
			FROM tblIPLoadNotifyPartiesStage WITH (NOLOCK)
			WHERE intStageLoadId = @intMinRowNo
				AND strPartyType = 'FW'

			IF ISNULL(@strForwardingAgent, '') <> ''
			BEGIN
				SELECT @intForwardingAgentEntityId = t.intEntityId
				FROM vyuLGNotifyParties t WITH (NOLOCK)
				WHERE t.strEntity = 'Forwarding Agent'
					AND t.strName = @strForwardingAgent

				IF ISNULL(@intForwardingAgentEntityId, 0) = 0
				BEGIN
					RAISERROR (
							'Invalid Forwarding Agent. '
							,16
							,1
							)
				END
			END

			-- Should not go based on Customer Ref since it will clash with Slicing logic
			SELECT TOP 1 @strLoadNumber = L.strLoadNumber
				,@intLoadId = L.intLoadId
			FROM tblLGLoad L WITH (NOLOCK)
			JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LD.intLoadId = L.intLoadId
				AND L.intShipmentType = 2
				AND LD.intPContractDetailId = @intContractDetailId
				AND L.intShipmentStatus <> 10

			--AND L.strCustomerReference = @strCustomerReference
			SELECT @intShipmentType = 2
				,@intShipmentStatus = 7
				,@intSourceType = 2
				,@intTransportationMode = 2
				,@intTransUsedBy = 1

			SELECT TOP 1 @intFreightTermId = intDefaultFreightTermId
				,@intWeightUnitMeasureId = intWeightUOMId
			FROM tblLGCompanyPreference WITH (NOLOCK)

			SELECT TOP 1 @intCurrencyId = intDefaultCurrencyId
			FROM tblSMCompanyPreference WITH (NOLOCK)

			IF ISNULL(@intLoadId, 0) = 0
			BEGIN
				SELECT @strRowState = 'Added'

				SELECT @intContractDetailId = CD.intContractDetailId
					,@intPurchaseSale = CH.intContractTypeId
					,@intPositionId = CH.intPositionId
					,@intBookId = CH.intBookId
					,@intSubBookId = CH.intSubBookId
					,@ysnLoadBased = CH.ysnLoad
					,@strPackingDescription = CD.strPackingDescription
					,@dtmStartDate = CD.dtmStartDate
					,@dtmEndDate = CD.dtmEndDate
					,@dtmPlannedAvailabilityDate = CD.dtmPlannedAvailabilityDate
					,@intLocationId = CD.intCompanyLocationId
					,@intContractShipperId = CD.intShipperId
					,@intMainContractHeaderId = CD.intContractHeaderId
					,@intContractSeq = CD.intContractSeq
				FROM tblCTContractDetail CD WITH (NOLOCK)
				JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
					AND CD.strERPPONumber = @strERPPONumber
			END
			ELSE
			BEGIN
				SELECT @strRowState = 'Modified'

				SELECT @strLoadNumber = L.strLoadNumber
					,@intContractDetailId = CD.intContractDetailId
					,@intPurchaseSale = CH.intContractTypeId
					,@intPositionId = CH.intPositionId
					,@intBookId = CH.intBookId
					,@intSubBookId = CH.intSubBookId
					,@ysnLoadBased = CH.ysnLoad
					,@strPackingDescription = L.strPackingDescription
					,@dtmStartDate = CD.dtmStartDate
					,@dtmEndDate = CD.dtmEndDate
					,@dtmPlannedAvailabilityDate = CD.dtmPlannedAvailabilityDate
					,@intLocationId = CD.intCompanyLocationId
					,@intContractShipperId = CD.intShipperId
					,@intMainContractHeaderId = CD.intContractHeaderId
					,@intContractSeq = CD.intContractSeq
					,@intShipmentStatus = L.intShipmentStatus
				FROM tblLGLoad L WITH (NOLOCK)
				JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LD.intLoadId = L.intLoadId
					AND L.intLoadId = @intLoadId
				JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
			END

			IF ISNULL(@strPackageType, '') <> ''
				SELECT @strPackingDescription = @strPackageType

			UPDATE tblIPLoadStage
			SET strAction = @strRowState
			WHERE intStageLoadId = @intMinRowNo

			SELECT @intEntityId = intEntityId
			FROM tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = 'IRELYADMIN'

			IF @intShipmentStatus = 10
			BEGIN
				RAISERROR (
						'Shipping instruction cannot update since it is already cancelled. '
						,16
						,1
						)
			END

			BEGIN TRAN

			-- Shipment Instruction Create / Update
			IF @strRowState = 'Added'
			BEGIN
				EXEC uspSMGetStartingNumber 106
					,@strLoadNumber OUTPUT

				INSERT INTO tblLGLoad (
					intConcurrencyId
					,strLoadNumber
					,intPurchaseSale
					,dtmScheduledDate
					,intUserSecurityId
					,intSourceType
					,intPositionId
					,intWeightUnitMeasureId
					,intTransportationMode
					,intShipmentStatus
					,intTransUsedBy
					,intShipmentType
					,intFreightTermId
					,intCurrencyId
					,strPackingDescription
					,dtmStartDate
					,dtmEndDate
					,dtmPlannedAvailabilityDate
					,strCustomerReference
					,strOriginPort
					,strDestinationPort
					,strOriginPort1
					,strDestinationPort1
					,dtmETSPOL
					,dtmETSPOL1
					,dtmDeadlineCargo
					,dtmETAPOD
					,dtmETAPOL
					,dtmETAPOD1
					,strBookingReference
					,strServiceContractNumber
					,strBLNumber
					,intShippingLineEntityId
					,strMVessel
					,strMVoyageNumber
					,strShippingMode
					,intNumberOfContainers
					,intContainerTypeId
					,intForwardingAgentEntityId
					)
				SELECT 1
					,@strLoadNumber
					,@intPurchaseSale
					,GETDATE()
					,@intEntityId
					,@intSourceType
					,@intPositionId
					,@intWeightUnitMeasureId
					,@intTransportationMode
					,@intShipmentStatus
					,@intTransUsedBy
					,@intShipmentType
					,@intFreightTermId
					,@intCurrencyId
					,@strPackingDescription
					,@dtmStartDate
					,@dtmEndDate
					,@dtmPlannedAvailabilityDate
					,@strCustomerReference
					,@strOriginPort
					,@strDestinationPort
					,@strOriginPort
					,@strDestinationPort
					,@dtmETSPOL
					,@dtmETSPOL
					,@dtmDeadlineCargo
					,@dtmETAPOD
					,@dtmETAPOL
					,@dtmETAPOD
					,@strBookingReference
					,@strServiceContractNumber
					,@strBLNumber
					,@intShippingLineEntityId
					,@strMVessel
					,@strMVoyageNumber
					,@strShippingMode
					,@intNumberOfContainers
					,@intContainerTypeId
					,@intForwardingAgentEntityId

				SELECT @intLoadId = SCOPE_IDENTITY()

				SELECT @intLeadTime = ISNULL(DPort.intLeadTime, 0)
				FROM tblLGLoad L
				OUTER APPLY (SELECT TOP 1 intLeadTime FROM tblSMCity DPort 
							WHERE DPort.strCity = L.strDestinationPort AND DPort.ysnPort = 1) DPort
				WHERE L.intLoadId = @intLoadId

				SELECT @dtmCalculatedAvailabilityDate = DATEADD(DD, ISNULL(@intLeadTime, 0), @dtmETAPOD)

				UPDATE tblLGLoad
				SET dtmPlannedAvailabilityDate = @dtmCalculatedAvailabilityDate
				WHERE intLoadId = @intLoadId

				SELECT @dtmPlannedAvailabilityDate = @dtmCalculatedAvailabilityDate

				-- Audit Log
				IF (@intLoadId > 0)
				BEGIN
					SELECT @strDescription = 'Load created from external system. '

					EXEC uspSMAuditLog @keyValue = @intLoadId
						,@screenName = 'Logistics.view.ShipmentSchedule'
						,@entityId = @intEntityId
						,@actionType = 'Created'
						,@actionIcon = 'small-new-plus'
						,@changeDescription = @strDescription
						,@fromValue = ''
						,@toValue = @strLoadNumber
				END
			END
			ELSE IF @strRowState = 'Modified'
			BEGIN
				SELECT @intOldPurchaseSale = intPurchaseSale
					,@intOldPositionId = intPositionId
					,@strOldOriginPort = strOriginPort
					,@strOldDestinationPort = strDestinationPort
					,@dtmOldETSPOL = dtmETSPOL
					,@dtmOldDeadlineCargo = dtmDeadlineCargo
					,@dtmOldETAPOD = dtmETAPOD
					,@dtmOldETAPOL = dtmETAPOL
					,@strOldBookingReference = strBookingReference
					,@strOldServiceContractNumber = strServiceContractNumber
					,@strOldBLNumber = strBLNumber
					,@strOldMVessel = strMVessel
					,@strOldMVoyageNumber = strMVoyageNumber
					,@strOldShippingMode = strShippingMode
					,@intOldShippingLineEntityId = intShippingLineEntityId
					,@intOldForwardingAgentEntityId = intForwardingAgentEntityId
					,@intOldNumberOfContainers = intNumberOfContainers
					,@intOldContainerTypeId = intContainerTypeId
					,@strOldPackingDescription = strPackingDescription
					,@dtmOldStartDate = dtmStartDate
					,@dtmOldEndDate = dtmEndDate
					,@dtmOldPlannedAvailabilityDate = dtmPlannedAvailabilityDate
					,@strOldCustomerReference = strCustomerReference
				FROM tblLGLoad L WITH (NOLOCK)
				WHERE L.intLoadId = @intLoadId

				SELECT @strOldContainerType = t.strContainerType
				FROM tblLGContainerType t WITH (NOLOCK)
				WHERE t.intContainerTypeId = @intOldContainerTypeId

				SELECT @strOldShippingLine = t.strName
				FROM tblEMEntity t WITH (NOLOCK)
				WHERE t.intEntityId = @intOldShippingLineEntityId

				SELECT @strOldForwardingAgent = t.strName
				FROM tblEMEntity t WITH (NOLOCK)
				WHERE t.intEntityId = @intOldForwardingAgentEntityId

				UPDATE tblLGLoad
				SET intConcurrencyId = intConcurrencyId + 1
					,intPurchaseSale = @intPurchaseSale
					,intPositionId = @intPositionId
					,strPackingDescription = @strPackingDescription
					--,dtmStartDate = @dtmStartDate
					--,dtmEndDate = @dtmEndDate
					,dtmPlannedAvailabilityDate = @dtmPlannedAvailabilityDate
					,strOriginPort = @strOriginPort
					,strDestinationPort = @strDestinationPort
					,strOriginPort1 = @strOriginPort
					,strDestinationPort1 = @strDestinationPort
					,dtmETSPOL = @dtmETSPOL
					,dtmETSPOL1 = @dtmETSPOL
					,dtmDeadlineCargo = @dtmDeadlineCargo
					,dtmETAPOD = @dtmETAPOD
					,dtmETAPOL = @dtmETAPOL
					,dtmETAPOD1 = @dtmETAPOD
					,strBookingReference = @strBookingReference
					,strServiceContractNumber = @strServiceContractNumber
					,strBLNumber = @strBLNumber
					,intShippingLineEntityId = @intShippingLineEntityId
					,intForwardingAgentEntityId = @intForwardingAgentEntityId
					,strMVessel = @strMVessel
					,strMVoyageNumber = @strMVoyageNumber
					,strShippingMode = @strShippingMode
					,intNumberOfContainers = @intNumberOfContainers
					,intContainerTypeId = @intContainerTypeId
					,strCustomerReference = @strCustomerReference
				WHERE intLoadId = @intLoadId

				SELECT @intLeadTime = ISNULL(DPort.intLeadTime, 0)
				FROM tblLGLoad L
				OUTER APPLY (SELECT TOP 1 intLeadTime FROM tblSMCity DPort 
							WHERE DPort.strCity = L.strDestinationPort AND DPort.ysnPort = 1) DPort
				WHERE L.intLoadId = @intLoadId

				SELECT @dtmCalculatedAvailabilityDate = DATEADD(DD, ISNULL(@intLeadTime, 0), @dtmETAPOD)

				UPDATE tblLGLoad
				SET dtmPlannedAvailabilityDate = @dtmCalculatedAvailabilityDate
				WHERE intLoadId = @intLoadId

				SELECT @dtmPlannedAvailabilityDate = @dtmCalculatedAvailabilityDate

				-- Audit Log
				IF (@intLoadId > 0)
				BEGIN
					DECLARE @strDetails NVARCHAR(MAX) = ''

					IF (@strOldCustomerReference <> @strCustomerReference)
						SET @strDetails += '{"change":"strCustomerReference","iconCls":"small-gear","from":"' + LTRIM(@strOldCustomerReference) + '","to":"' + LTRIM(@strCustomerReference) + '","leaf":true,"changeDescription":"Customer Ref."},'

					IF (@intOldPurchaseSale <> @intPurchaseSale)
						SET @strDetails += '{"change":"intPurchaseSale","iconCls":"small-gear","from":"' + LTRIM(@intOldPurchaseSale) + '","to":"' + LTRIM(@intPurchaseSale) + '","leaf":true,"changeDescription":"intPurchaseSale"},'

					IF (@intOldPositionId <> @intPositionId)
						SET @strDetails += '{"change":"intPositionId","iconCls":"small-gear","from":"' + LTRIM(@intOldPositionId) + '","to":"' + LTRIM(@intPositionId) + '","leaf":true,"changeDescription":"intPositionId"},'

					IF (@strOldOriginPort <> @strOriginPort)
						SET @strDetails += '{"change":"strOriginPort","iconCls":"small-gear","from":"' + LTRIM(@strOldOriginPort) + '","to":"' + LTRIM(@strOriginPort) + '","leaf":true,"changeDescription":"Loading Port"},'

					IF (@strOldDestinationPort <> @strDestinationPort)
						SET @strDetails += '{"change":"strDestinationPort","iconCls":"small-gear","from":"' + LTRIM(@strOldDestinationPort) + '","to":"' + LTRIM(@strDestinationPort) + '","leaf":true,"changeDescription":"Destination Port"},'

					IF (CONVERT(DATETIME, CONVERT(NVARCHAR, @dtmOldETSPOL, 101)) <> CONVERT(DATETIME, CONVERT(NVARCHAR, @dtmETSPOL, 101)))
						SET @strDetails += '{"change":"dtmETSPOL","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldETSPOL, '')) + '","to":"' + LTRIM(ISNULL(@dtmETSPOL, '')) + '","leaf":true,"changeDescription":"Instr ETD"},'

					IF (CONVERT(DATETIME, CONVERT(NVARCHAR, @dtmOldDeadlineCargo, 101)) <> CONVERT(DATETIME, CONVERT(NVARCHAR, @dtmDeadlineCargo, 101)))
						SET @strDetails += '{"change":"dtmDeadlineCargo","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldDeadlineCargo, '')) + '","to":"' + LTRIM(ISNULL(@dtmDeadlineCargo, '')) + '","leaf":true,"changeDescription":"Instr ETA"},'

					IF (CONVERT(DATETIME, CONVERT(NVARCHAR, @dtmOldETAPOD, 101)) <> CONVERT(DATETIME, CONVERT(NVARCHAR, @dtmETAPOD, 101)))
						SET @strDetails += '{"change":"dtmETAPOD","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldETAPOD, '')) + '","to":"' + LTRIM(ISNULL(@dtmETAPOD, '')) + '","leaf":true,"changeDescription":"Act. ETA"},'

					IF (CONVERT(DATETIME, CONVERT(NVARCHAR, @dtmOldETAPOL, 101)) <> CONVERT(DATETIME, CONVERT(NVARCHAR, @dtmETAPOL, 101)))
						SET @strDetails += '{"change":"dtmETAPOL","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldETAPOL, '')) + '","to":"' + LTRIM(ISNULL(@dtmETAPOL, '')) + '","leaf":true,"changeDescription":"Act. ETD"},'

					IF (@strOldBookingReference <> @strBookingReference)
						SET @strDetails += '{"change":"strBookingReference","iconCls":"small-gear","from":"' + LTRIM(@strOldBookingReference) + '","to":"' + LTRIM(@strBookingReference) + '","leaf":true,"changeDescription":"Booking Ref."},'

					IF (ISNULL(@strOldServiceContractNumber, '') <> @strServiceContractNumber)
						SET @strDetails += '{"change":"strServiceContractNumber","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@strOldServiceContractNumber, '')) + '","to":"' + LTRIM(@strServiceContractNumber) + '","leaf":true,"changeDescription":"Service Contract No."},'

					IF (@strOldBLNumber <> @strBLNumber)
						SET @strDetails += '{"change":"strBLNumber","iconCls":"small-gear","from":"' + LTRIM(@strOldBLNumber) + '","to":"' + LTRIM(@strBLNumber) + '","leaf":true,"changeDescription":"BOL No."},'

					IF (@strOldMVessel <> @strMVessel)
						SET @strDetails += '{"change":"strMVessel","iconCls":"small-gear","from":"' + LTRIM(@strOldMVessel) + '","to":"' + LTRIM(@strMVessel) + '","leaf":true,"changeDescription":"MV Name"},'

					IF (@strOldMVoyageNumber <> @strMVoyageNumber)
						SET @strDetails += '{"change":"strMVoyageNumber","iconCls":"small-gear","from":"' + LTRIM(@strOldMVoyageNumber) + '","to":"' + LTRIM(@strMVoyageNumber) + '","leaf":true,"changeDescription":"MV Voyage No."},'

					IF (@strOldShippingMode <> @strShippingMode)
						SET @strDetails += '{"change":"strShippingMode","iconCls":"small-gear","from":"' + LTRIM(@strOldShippingMode) + '","to":"' + LTRIM(@strShippingMode) + '","leaf":true,"changeDescription":"Shipping Mode"},'

					IF (@intOldShippingLineEntityId <> @intShippingLineEntityId)
						SET @strDetails += '{"change":"strShippingLine","iconCls":"small-gear","from":"' + LTRIM(@strOldShippingLine) + '","to":"' + LTRIM(@strShippingLine) + '","leaf":true,"changeDescription":"Shipping Line"},'

					IF (ISNULL(@intOldForwardingAgentEntityId, 0) <> @intForwardingAgentEntityId)
						SET @strDetails += '{"change":"strForwardingAgent","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@strOldForwardingAgent, '')) + '","to":"' + LTRIM(@strForwardingAgent) + '","leaf":true,"changeDescription":"Forwarding Agent"},'

					IF (@intOldNumberOfContainers <> @intNumberOfContainers)
						SET @strDetails += '{"change":"intNumberOfContainers","iconCls":"small-gear","from":"' + LTRIM(@intOldNumberOfContainers) + '","to":"' + LTRIM(@intNumberOfContainers) + '","leaf":true,"changeDescription":"No. of Containers"},'

					IF (@intOldContainerTypeId <> @intContainerTypeId)
						SET @strDetails += '{"change":"strContainerType","iconCls":"small-gear","from":"' + LTRIM(@strOldContainerType) + '","to":"' + LTRIM(@strContainerType) + '","leaf":true,"changeDescription":"Container Type"},'

					IF (@strOldPackingDescription <> @strPackingDescription)
						SET @strDetails += '{"change":"strPackingDescription","iconCls":"small-gear","from":"' + LTRIM(@strOldPackingDescription) + '","to":"' + LTRIM(@strPackingDescription) + '","leaf":true,"changeDescription":"Packing Description"},'

					--IF (@dtmOldStartDate <> @dtmStartDate)
					--	SET @strDetails += '{"change":"dtmStartDate","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldStartDate, '')) + '","to":"' + LTRIM(ISNULL(@dtmStartDate, '')) + '","leaf":true,"changeDescription":"Start Date"},'
					--IF (@dtmOldEndDate <> @dtmEndDate)
					--	SET @strDetails += '{"change":"dtmEndDate","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldEndDate, '')) + '","to":"' + LTRIM(ISNULL(@dtmEndDate, '')) + '","leaf":true,"changeDescription":"End Date"},'
					IF (@dtmOldPlannedAvailabilityDate <> @dtmPlannedAvailabilityDate)
						SET @strDetails += '{"change":"dtmPlannedAvailabilityDate","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldPlannedAvailabilityDate, '')) + '","to":"' + LTRIM(ISNULL(@dtmPlannedAvailabilityDate, '')) + '","leaf":true,"changeDescription":"Planned Availability"},'

					IF (LEN(@strDetails) > 1)
					BEGIN
						SET @strDetails = SUBSTRING(@strDetails, 0, LEN(@strDetails))

						EXEC uspSMAuditLog @keyValue = @intLoadId
							,@screenName = 'Logistics.view.ShipmentSchedule'
							,@entityId = @intEntityId
							,@actionType = 'Updated'
							,@actionIcon = 'small-tree-modified'
							,@details = @strDetails
					END
				END
			END

			UPDATE tblIPLoadStage
			SET strLoadNumber = @strLoadNumber
			WHERE intStageLoadId = @intMinRowNo

			SET @strInfo1 = ISNULL(@strCustomerReference, '') + ' / ' + ISNULL(@strERPPONumber, '')
			SET @strInfo2 = ISNULL(@strLoadNumber, '')

			IF NOT EXISTS (
				SELECT 1
				FROM tblIPLoadDetailStage
				WHERE intStageLoadId = @intMinRowNo
				)
			BEGIN
				RAISERROR (
						'Commodity Item block is required. '
						,16
						,1
						)
			END

			-- Load Detail
			IF @strRowState = 'Added'
				OR @strRowState = 'Modified'
			BEGIN
				DELETE
				FROM @tblLGLoadDetail

				DELETE
				FROM @tblLGLoadDetailChanges

				INSERT INTO @tblLGLoadDetailChanges (
					dblOldQuantity
					,dblOldGross
					,intLoadDetailId
					,intPContractDetailId
					,strAuditLogInfo
					)
				SELECT LD.dblQuantity
					,LD.dblGross
					,LD.intLoadDetailId
					,LD.intPContractDetailId
					,CH.strContractNumber + '/' + LTRIM(CD.intContractSeq) + ' - ' + ISNULL(IC.strContractItemName, IM.strDescription)
				FROM tblLGLoadDetail LD WITH (NOLOCK)
				JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN tblICItem IM WITH (NOLOCK) ON IM.intItemId = CD.intItemId
				LEFT JOIN tblICItemContract IC WITH (NOLOCK) ON IC.intItemContractId = CD.intItemContractId
				WHERE LD.intLoadId = @intLoadId

				INSERT INTO @tblLGLoadDetail (intStageLoadDetailId)
				SELECT intStageLoadDetailId
				FROM tblIPLoadDetailStage WITH (NOLOCK)
				WHERE intStageLoadId = @intMinRowNo

				SELECT @intStageLoadDetailId = MIN(intStageLoadDetailId)
				FROM @tblLGLoadDetail

				WHILE @intStageLoadDetailId IS NOT NULL
				BEGIN
					SELECT @strCommodityCode = NULL
						,@strItemNo = NULL
						,@strContractItemName = NULL
						,@dblQuantity = NULL
						,@dblGrossWeight = NULL
						,@strPackageType = NULL
						,@strOrgItemNo = NULL
						,@strOrgContractItemName = NULL

					SELECT @intCommodityId = NULL
						,@intItemId = NULL
						,@intItemContractId = NULL
						,@intVendorEntityId = NULL
						,@intCompanyLocationId = NULL
						,@intItemUOMId = NULL
						,@intWeightItemUOMId = NULL
						,@strPriceStatus = NULL
						,@dblUnitPrice = NULL
						,@intPriceCurrencyId = NULL
						,@intPriceUOMId = NULL
						,@dblAmount = NULL
						,@strVendorReference = NULL
						,@intPSubLocationId = NULL
						,@intPNumberOfContainers = NULL
						,@dblOldDetailQuantity = NULL
						,@intContractHeaderId = NULL

					SELECT @strCommodityCode = strCommodityCode
						,@strItemNo = strItemNo
						,@strContractItemName = strContractItemName
						,@dblQuantity = ISNULL(dblQuantity, 0)
						,@dblGrossWeight = ISNULL(dblGrossWeight, 0)
						,@strPackageType = strPackageType
					FROM tblIPLoadDetailStage WITH (NOLOCK)
					WHERE intStageLoadDetailId = @intStageLoadDetailId

					SELECT @intCommodityId = t.intCommodityId
					FROM tblICCommodity t WITH (NOLOCK)
					WHERE t.strCommodityCode = @strCommodityCode

					IF ISNULL(@intCommodityId, 0) = 0
					BEGIN
						RAISERROR (
								'Invalid Commodity. '
								,16
								,1
								)
					END

					IF LOWER(@strCommodityCode) <> 'coffee'
					BEGIN
						RAISERROR (
								'Commodity should be Coffee. '
								,16
								,1
								)
					END

					SELECT @intItemId = t.intItemId
					FROM tblICItem t WITH (NOLOCK)
					WHERE t.strItemNo = @strItemNo

					IF ISNULL(@intItemId, 0) = 0
					BEGIN
						RAISERROR (
								'Invalid Item No. '
								,16
								,1
								)
					END

					IF NOT EXISTS (
							SELECT 1
							FROM tblCTContractDetail t WITH (NOLOCK)
							WHERE t.intContractDetailId = @intContractDetailId
								AND t.intItemId = @intItemId
							)
					BEGIN
						RAISERROR (
								'Item No is not matching with Contract Sequence Item. '
								,16
								,1
								)
					END

					SELECT @intItemContractId = CD.intItemContractId
						,@strOrgContractItemName = IC.strContractItemName
						,@strOrgItemNo = I.strItemNo
					FROM tblCTContractDetail CD WITH (NOLOCK)
					JOIN tblICItem I WITH (NOLOCK) ON I.intItemId = CD.intItemId
						AND CD.intContractDetailId = @intContractDetailId
					JOIN tblICItemContract IC WITH (NOLOCK) ON IC.intItemContractId = CD.intItemContractId

					IF @strContractItemName <> @strOrgContractItemName
					BEGIN
						RAISERROR (
								'Invalid Contract Item. '
								,16
								,1
								)
					END

					IF @strItemNo <> @strOrgItemNo
						AND @strContractItemName <> @strOrgContractItemName
					BEGIN
						RAISERROR (
								'Contract Item is not matching in the Contract Sequence. '
								,16
								,1
								)
					END

					IF @dblQuantity <= 0
					BEGIN
						RAISERROR (
								'Invalid Quantity. '
								,16
								,1
								)
					END

					IF @dblGrossWeight <= 0
					BEGIN
						RAISERROR (
								'Invalid Weight. '
								,16
								,1
								)
					END

					SELECT @intVendorEntityId = CH.intEntityId
						,@intCompanyLocationId = CD.intCompanyLocationId
						--,CD.dblQuantity
						,@intItemUOMId = CD.intItemUOMId
						--,CD.dblNetWeight
						,@intWeightItemUOMId = CD.intNetWeightUOMId
						,@strPriceStatus = PT.strPricingType
						,@dblUnitPrice = CD.dblCashPrice
						,@intPriceCurrencyId = CD.intCurrencyId
						,@intPriceUOMId = CD.intPriceItemUOMId
						,@dblAmount = CD.dblTotalCost
						,@strVendorReference = CH.strCustomerContract
						,@intPSubLocationId = CD.intSubLocationId
						,@intPNumberOfContainers = CD.intNumberOfContainers
						,@intContractHeaderId = CD.intContractHeaderId
					FROM tblCTContractDetail CD WITH (NOLOCK)
					JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
						AND CD.intContractDetailId = @intContractDetailId
					LEFT JOIN tblCTPricingType PT WITH (NOLOCK) ON PT.intPricingTypeId = CD.intPricingTypeId

					IF @strRowState = 'Added'
					BEGIN
						INSERT INTO tblLGLoadDetail (
							intConcurrencyId
							,intLoadId
							,intVendorEntityId
							,intItemId
							,intPContractDetailId
							,intPCompanyLocationId
							,dblQuantity
							,intItemUOMId
							,dblGross
							,dblTare
							,dblNet
							,intWeightItemUOMId
							,strPriceStatus
							,dblUnitPrice
							,intPriceCurrencyId
							,intPriceUOMId
							,dblAmount
							,ysnPrintScheduleInfo
							,ysnPrintLoadDirections
							,strVendorReference
							,intPSubLocationId
							,intNumberOfContainers
							)
						SELECT 1
							,@intLoadId
							,@intVendorEntityId
							,@intItemId
							,@intContractDetailId
							,@intCompanyLocationId
							,@dblQuantity
							,@intItemUOMId
							,@dblGrossWeight
							,0
							,@dblGrossWeight
							,@intWeightItemUOMId
							,@strPriceStatus
							,@dblUnitPrice
							,@intPriceCurrencyId
							,@intPriceUOMId
							,@dblAmount
							,1
							,1
							,@strVendorReference
							,@intPSubLocationId
							,@intPNumberOfContainers

						EXEC uspLGUpdateContractShippingInstructionQty @intContractDetailId = @intContractDetailId
							,@dblQuantityToUpdate = @dblQuantity
							,@intUserId = @intEntityId
							--INSERT INTO tblLGLoadDocuments (
							--	intConcurrencyId
							--	,intLoadId
							--	,intDocumentId
							--	,strDocumentType
							--	,intOriginal
							--	,intCopies
							--	)
							--SELECT 1
							--	,@intLoadId
							--	,CD.intDocumentId
							--	,CASE 
							--		WHEN ID.intDocumentType = 1
							--			THEN 'Contract'
							--		WHEN ID.intDocumentType = 2
							--			THEN 'Bill Of Lading'
							--		WHEN ID.intDocumentType = 3
							--			THEN 'Container'
							--		ELSE ''
							--		END COLLATE Latin1_General_CI_AS
							--	,0
							--	,0
							--FROM tblCTContractDocument CD
							--JOIN tblICDocument ID ON ID.intDocumentId = CD.intDocumentId
							--	AND CD.intContractHeaderId = @intContractHeaderId
					END
					ELSE
					BEGIN
						SELECT @dblOldDetailQuantity = dblQuantity
						FROM tblLGLoadDetail WITH (NOLOCK)
						WHERE intLoadId = @intLoadId
							AND intPContractDetailId = @intContractDetailId
							AND intItemId = @intItemId

						UPDATE tblLGLoadDetail
						SET intConcurrencyId = intConcurrencyId + 1
							,intVendorEntityId = @intVendorEntityId
							,intPCompanyLocationId = @intCompanyLocationId
							,dblQuantity = @dblQuantity
							,intItemUOMId = @intItemUOMId
							,dblGross = @dblGrossWeight
							,dblNet = @dblGrossWeight
							,intWeightItemUOMId = @intWeightItemUOMId
							,strPriceStatus = @strPriceStatus
							,dblUnitPrice = @dblUnitPrice
							,intPriceCurrencyId = @intPriceCurrencyId
							,intPriceUOMId = @intPriceUOMId
							,dblAmount = @dblAmount
							,strVendorReference = @strVendorReference
							,intPSubLocationId = @intPSubLocationId
							,intNumberOfContainers = @intPNumberOfContainers
						WHERE intLoadId = @intLoadId
							AND intPContractDetailId = @intContractDetailId
							AND intItemId = @intItemId

						IF @dblOldDetailQuantity <> @dblQuantity
						BEGIN
							DECLARE @dblDiffQty NUMERIC(18, 6)

							SELECT @dblDiffQty = @dblQuantity - @dblOldDetailQuantity

							IF @dblDiffQty <> 0
							BEGIN
								EXEC uspLGUpdateContractShippingInstructionQty @intContractDetailId = @intContractDetailId
									,@dblQuantityToUpdate = @dblDiffQty
									,@intUserId = @intEntityId
							END
						END
					END

					SELECT @intStageLoadDetailId = MIN(intStageLoadDetailId)
					FROM @tblLGLoadDetail
					WHERE intStageLoadDetailId > @intStageLoadDetailId
				END

				UPDATE @tblLGLoadDetailChanges
				SET dblNewQuantity = LD.dblQuantity
					,dblNewGross = LD.dblGross
				FROM @tblLGLoadDetailChanges OLD
				JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = OLD.intLoadDetailId

				-- Load Detail Audit Log
				DECLARE @details NVARCHAR(MAX) = ''

				WHILE EXISTS (
						SELECT TOP 1 NULL
						FROM @tblLGLoadDetailChanges
						)
				BEGIN
					SELECT @dblOldQuantity = NULL
						,@dblNewQuantity = NULL
						,@dblOldGross = NULL
						,@dblNewGross = NULL
						,@intAuditLoadDetailId = NULL
						,@strAuditLogInfo = NULL

					SELECT TOP 1 @dblOldQuantity = dblOldQuantity
						,@dblNewQuantity = dblNewQuantity
						,@dblOldGross = dblOldGross
						,@dblNewGross = dblNewGross
						,@intAuditLoadDetailId = intLoadDetailId
						,@strAuditLogInfo = strAuditLogInfo
					FROM @tblLGLoadDetailChanges

					SET @details = '{  
							"action":"Updated",
							"change":"Updated - Record: ' + LTRIM(@intLoadId) + '",
							"keyValue":' + LTRIM(@intLoadId) + ',
							"iconCls":"small-tree-modified",
							"children":[  
								{  
									"change":"tblLGLoadDetails",
									"children":[  
										{  
										"action":"Updated",
										"change":"Updated - Record: ' + LTRIM(@strAuditLogInfo) + '",
										"keyValue":' + LTRIM(@intAuditLoadDetailId) + ',
										"iconCls":"small-tree-modified",
										"children":
											[   
												'

					IF @dblOldQuantity <> @dblNewQuantity
						SET @details = @details + '
												{  
												"change":"dblQuantity",
												"from":"' + LTRIM(@dblOldQuantity) + '",
												"to":"' + LTRIM(@dblNewQuantity) + '",
												"leaf":true,
												"iconCls":"small-gear",
												"isField":true,
												"keyValue":' + LTRIM(@intAuditLoadDetailId) + ',
												"associationKey":"tblLGLoadDetails",
												"changeDescription":"Quantity",
												"hidden":false
												},'

					IF @dblOldGross <> @dblNewGross
						SET @details = @details + '
												{  
												"change":"dblGross",
												"from":"' + LTRIM(@dblOldGross) + '",
												"to":"' + LTRIM(@dblNewGross) + '",
												"leaf":true,
												"iconCls":"small-gear",
												"isField":true,
												"keyValue":' + LTRIM(@intAuditLoadDetailId) + ',
												"associationKey":"tblLGLoadDetails",
												"changeDescription":"Gross",
												"hidden":false
												},'

					IF RIGHT(@details, 1) = ','
						SET @details = SUBSTRING(@details, 0, LEN(@details))
					SET @details = @details + '
										]
									}
								],
								"iconCls":"small-tree-grid",
								"changeDescription":"Orders"
								}
							]
							}'

					IF @dblOldQuantity <> @dblNewQuantity
						OR @dblOldGross <> @dblNewGross
					BEGIN
						EXEC uspSMAuditLog @keyValue = @intLoadId
							,@screenName = 'Logistics.view.ShipmentSchedule'
							,@entityId = @intEntityId
							,@actionType = 'Updated'
							,@actionIcon = 'small-tree-modified'
							,@details = @details
					END

					DELETE
					FROM @tblLGLoadDetailChanges
					WHERE intLoadDetailId = @intAuditLoadDetailId
				END
			END

			-- Load Notify Parties
			IF (
					@strRowState = 'Added'
					OR @strRowState = 'Modified'
					)
				AND EXISTS (
					SELECT 1
					FROM tblIPLoadNotifyPartiesStage
					WHERE intStageLoadId = @intMinRowNo
						AND strPartyType IN (
							'CN'
							,'NI'
							,'NI1'
							)
					)
			BEGIN
				SELECT @intConsigneeCount = NULL
					,@intFirstNotifyCount = NULL
					,@intSecondNotifyCount = NULL

				SELECT @intConsigneeCount = COUNT(1)
				FROM tblIPLoadNotifyPartiesStage WITH (NOLOCK)
				WHERE intStageLoadId = @intMinRowNo
					AND strPartyType = 'CN'

				SELECT @intFirstNotifyCount = COUNT(1)
				FROM tblIPLoadNotifyPartiesStage WITH (NOLOCK)
				WHERE intStageLoadId = @intMinRowNo
					AND strPartyType = 'NI'

				SELECT @intSecondNotifyCount = COUNT(1)
				FROM tblIPLoadNotifyPartiesStage WITH (NOLOCK)
				WHERE intStageLoadId = @intMinRowNo
					AND strPartyType = 'NI1'

				IF @intConsigneeCount > 1
					OR @intFirstNotifyCount > 1
					OR @intSecondNotifyCount > 1
				BEGIN
					RAISERROR (
							'Same Notify Party Type received multiple times. '
							,16
							,1
							)
				END

				DELETE
				FROM @tblLGLoadNotifyParties

				DELETE
				FROM @tblLGLoadNotifyPartiesChanges

				DELETE
				FROM @tblLGLoadNotifyPartiesOrg

				INSERT INTO @tblLGLoadNotifyPartiesOrg (
					intLoadNotifyPartyId
					,strNotifyOrConsignee
					)
				SELECT LN.intLoadNotifyPartyId
					,LN.strNotifyOrConsignee
				FROM tblLGLoadNotifyParties LN WITH (NOLOCK)
				WHERE LN.intLoadId = @intLoadId

				INSERT INTO @tblLGLoadNotifyPartiesChanges (
					intLoadNotifyPartyId
					,strAction
					,strNotifyOrConsignee
					,intOldCompanySetupID
					,intOldEntityId
					,intOldEntityLocationId
					)
				SELECT LN.intLoadNotifyPartyId
					,'Updated'
					,LN.strNotifyOrConsignee
					,LN.intCompanySetupID
					,LN.intEntityId
					,LN.intEntityLocationId
				FROM tblLGLoadNotifyParties LN WITH (NOLOCK)
				WHERE LN.intLoadId = @intLoadId

				INSERT INTO @tblLGLoadNotifyParties (intStageLoadNotifyPartiesId)
				SELECT intStageLoadNotifyPartiesId
				FROM tblIPLoadNotifyPartiesStage WITH (NOLOCK)
				WHERE intStageLoadId = @intMinRowNo
					AND strPartyType IN (
						'CN'
						,'NI'
						,'NI1'
						)

				SELECT @intStageLoadNotifyPartiesId = MIN(intStageLoadNotifyPartiesId)
				FROM @tblLGLoadNotifyParties

				WHILE @intStageLoadNotifyPartiesId IS NOT NULL
				BEGIN
					SELECT @strNotifyPartyType = NULL
						,@strNotifyPartyName = NULL
						,@strNotifyPartyLocation = NULL
						,@intLoadNotifyPartyId = NULL

					SELECT @intNotifyEntityId = NULL
						,@intNotifyEntityLocationId = NULL
						,@intCompanySetupID = NULL
						,@strNotifyOrConsignee = NULL
						,@strType = NULL

					SELECT @strNotifyPartyType = strPartyType
						,@strNotifyPartyName = strPartyName
						,@strNotifyPartyLocation = strPartyLocation
					FROM tblIPLoadNotifyPartiesStage WITH (NOLOCK)
					WHERE intStageLoadNotifyPartiesId = @intStageLoadNotifyPartiesId

					IF @strNotifyPartyType = 'CN'
					BEGIN
						SELECT @strNotifyOrConsignee = 'Consignee'

						SELECT @intCompanySetupID = intEntityId
							,@strType = 'Company'
						FROM vyuLGNotifyParties WITH (NOLOCK)
						WHERE strEntity = 'Company'
							AND strName = @strNotifyPartyName

						IF ISNULL(@intCompanySetupID, 0) = 0
						BEGIN
							SELECT @intNotifyEntityId = intEntityId
								,@strType = 'Forwarding Agent'
							FROM vyuLGNotifyParties WITH (NOLOCK)
							WHERE strEntity = 'Forwarding Agent'
								AND strName = @strNotifyPartyName

							IF ISNULL(@intNotifyEntityId, 0) = 0
							BEGIN
								RAISERROR (
										'Invalid Consignee Party. '
										,16
										,1
										)
							END

							IF ISNULL(@strNotifyPartyLocation, '') <> ''
							BEGIN
								SELECT @intNotifyEntityLocationId = intEntityLocationId
								FROM vyuLGNotifyPartiesAddresses WITH (NOLOCK)
								WHERE strType = 'Forwarding Agent'
									AND intEntityId = @intNotifyEntityId
									AND strLocationName = @strNotifyPartyLocation

								IF ISNULL(@intNotifyEntityLocationId, 0) = 0
								BEGIN
									RAISERROR (
											'Invalid Consignee Party Location. '
											,16
											,1
											)
								END
							END
						END
					END
					ELSE IF @strNotifyPartyType = 'NI'
						OR @strNotifyPartyType = 'NI1'
					BEGIN
						IF @strNotifyPartyType = 'NI'
							SELECT @strNotifyOrConsignee = 'First Notify'
						ELSE IF @strNotifyPartyType = 'NI1'
							SELECT @strNotifyOrConsignee = 'Second Notify'

						SELECT @intNotifyEntityId = intEntityId
							,@strType = 'Forwarding Agent'
						FROM vyuLGNotifyParties WITH (NOLOCK)
						WHERE strEntity = 'Forwarding Agent'
							AND strName = @strNotifyPartyName

						IF ISNULL(@intNotifyEntityId, 0) = 0
						BEGIN
							RAISERROR (
									'Invalid First / Second Notify Party. '
									,16
									,1
									)
						END

						IF ISNULL(@strNotifyPartyLocation, '') <> ''
						BEGIN
							SELECT @intNotifyEntityLocationId = intEntityLocationId
							FROM vyuLGNotifyPartiesAddresses WITH (NOLOCK)
							WHERE strType = 'Forwarding Agent'
								AND intEntityId = @intNotifyEntityId
								AND strLocationName = @strNotifyPartyLocation

							IF ISNULL(@intNotifyEntityLocationId, 0) = 0
							BEGIN
								RAISERROR (
										'Invalid First / Second Notify Party Location. '
										,16
										,1
										)
							END
						END
					END
					ELSE
					BEGIN
						RAISERROR (
								'Invalid Notify Party Type. '
								,16
								,1
								)
					END

					IF @strRowState = 'Added'
					BEGIN
						INSERT INTO tblLGLoadNotifyParties (
							intConcurrencyId
							,intLoadId
							,strNotifyOrConsignee
							,strType
							,intEntityId
							,intCompanySetupID
							,intEntityLocationId
							)
						SELECT 1
							,@intLoadId
							,@strNotifyOrConsignee
							,@strType
							,@intNotifyEntityId
							,@intCompanySetupID
							,@intNotifyEntityLocationId

						SELECT @intLoadNotifyPartyId = SCOPE_IDENTITY()
					END
					ELSE
					BEGIN
						SELECT @intLoadNotifyPartyId = intLoadNotifyPartyId
						FROM tblLGLoadNotifyParties WITH (NOLOCK)
						WHERE intLoadId = @intLoadId
							AND strNotifyOrConsignee = @strNotifyOrConsignee

						IF ISNULL(@intLoadNotifyPartyId, 0) > 0
						BEGIN
							UPDATE tblLGLoadNotifyParties
							SET intConcurrencyId = intConcurrencyId + 1
								,strType = @strType
								,intEntityId = @intNotifyEntityId
								,intCompanySetupID = @intCompanySetupID
								,intEntityLocationId = @intNotifyEntityLocationId
							WHERE intLoadNotifyPartyId = @intLoadNotifyPartyId
						END
						ELSE
						BEGIN
							INSERT INTO tblLGLoadNotifyParties (
								intConcurrencyId
								,intLoadId
								,strNotifyOrConsignee
								,strType
								,intEntityId
								,intCompanySetupID
								,intEntityLocationId
								)
							SELECT 1
								,@intLoadId
								,@strNotifyOrConsignee
								,@strType
								,@intNotifyEntityId
								,@intCompanySetupID
								,@intNotifyEntityLocationId

							SELECT @intLoadNotifyPartyId = SCOPE_IDENTITY()
						END
					END

					SELECT @intStageLoadNotifyPartiesId = MIN(intStageLoadNotifyPartiesId)
					FROM @tblLGLoadNotifyParties
					WHERE intStageLoadNotifyPartiesId > @intStageLoadNotifyPartiesId
				END

				-- Delete the notify parties which are available in i21 but not in the XML
				DELETE
				FROM @tblDeleteNotifyParties

				INSERT INTO @tblDeleteNotifyParties (intLoadNotifyPartyId)
				SELECT LN.intLoadNotifyPartyId
				FROM tblLGLoadNotifyParties LN WITH (NOLOCK)
				WHERE LN.intLoadId = @intLoadId
					AND NOT EXISTS (
						SELECT 1
						FROM tblIPLoadNotifyPartiesStage LNS WITH (NOLOCK)
						WHERE LNS.intStageLoadId = @intMinRowNo
							AND LNS.strPartyType IN (
								'CN'
								,'NI'
								,'NI1'
								)
							AND LNS.strPartyType = (
								CASE 
									WHEN LN.strNotifyOrConsignee = 'Consignee'
										THEN 'CN'
									WHEN LN.strNotifyOrConsignee = 'First Notify'
										THEN 'NI'
									WHEN LN.strNotifyOrConsignee = 'Second Notify'
										THEN 'NI1'
									END
								)
						)

				--DELETE LN
				--FROM tblLGLoadNotifyParties LN
				--JOIN @tblDeleteNotifyParties DEL ON DEL.intLoadNotifyPartyId = LN.intLoadNotifyPartyId
				--	AND LN.intLoadId = @intLoadId

				INSERT INTO @tblLGLoadNotifyPartiesChanges (
					intLoadNotifyPartyId
					,strNotifyOrConsignee
					,strAction
					)
				SELECT LN.intLoadNotifyPartyId
					,LN.strNotifyOrConsignee
					,'Created'
				FROM tblLGLoadNotifyParties LN WITH (NOLOCK)
				WHERE LN.intLoadId = @intLoadId
					AND NOT EXISTS (
						SELECT 1
						FROM @tblLGLoadNotifyPartiesOrg LNO
						WHERE LNO.intLoadNotifyPartyId = LN.intLoadNotifyPartyId
						)

				UPDATE @tblLGLoadNotifyPartiesChanges
				SET strAction = 'Deleted'
				FROM @tblLGLoadNotifyPartiesChanges OLD
				JOIN @tblDeleteNotifyParties DEL ON DEL.intLoadNotifyPartyId = OLD.intLoadNotifyPartyId

				UPDATE @tblLGLoadNotifyPartiesChanges
				SET intNewCompanySetupID = LN.intCompanySetupID
					,intNewEntityId = LN.intEntityId
					,intNewEntityLocationId = LN.intEntityLocationId
				FROM @tblLGLoadNotifyPartiesChanges OLD
				JOIN tblLGLoadNotifyParties LN ON LN.intLoadNotifyPartyId = OLD.intLoadNotifyPartyId

				-- Load Notify Parties Audit Log
				IF @strRowState = 'Modified'
				BEGIN
					DECLARE @Notifydetails NVARCHAR(MAX) = ''
						,@AllNotifydetails NVARCHAR(MAX) = ''
					DECLARE @strNotifyAuditInfo NVARCHAR(MAX) = ''

					--DROP TABLE tblLGLoadNotifyPartiesChangesTest
					--SELECT * INTO tblLGLoadNotifyPartiesChangesTest FROM @tblLGLoadNotifyPartiesChanges
					WHILE EXISTS (
							SELECT TOP 1 NULL
							FROM @tblLGLoadNotifyPartiesChanges
							WHERE strAction = 'Updated'
							)
					BEGIN
						SELECT @intAuditLoadNotifyPartyId = NULL
							,@strAuditNotifyOrConsignee = NULL
							,@intNewEntityId = NULL
							,@intNewCompanySetupID = NULL
							,@intNewEntityLocationId = NULL
							,@intOldEntityId = NULL
							,@intOldCompanySetupID = NULL
							,@intOldEntityLocationId = NULL
							,@Notifydetails = NULL
							,@strNotifyAuditInfo = NULL

						SELECT @strNewEntityName = NULL
							,@strNewCompanyName = NULL
							,@strNewEntityLocationName = NULL
							,@strOldEntityName = NULL
							,@strOldCompanyName = NULL
							,@strOldEntityLocationName = NULL

						SELECT TOP 1 @intAuditLoadNotifyPartyId = intLoadNotifyPartyId
							,@strAuditNotifyOrConsignee = strNotifyOrConsignee
							,@intNewEntityId = intNewEntityId
							,@intNewCompanySetupID = intNewCompanySetupID
							,@intNewEntityLocationId = intNewEntityLocationId
							,@intOldEntityId = intOldEntityId
							,@intOldCompanySetupID = intOldCompanySetupID
							,@intOldEntityLocationId = intOldEntityLocationId
						FROM @tblLGLoadNotifyPartiesChanges
						WHERE strAction = 'Updated'

						SELECT @strNewEntityName = strName
						FROM vyuLGNotifyParties WITH (NOLOCK)
						WHERE strEntity = 'Forwarding Agent'
							AND intEntityId = @intNewEntityId

						SELECT @strOldEntityName = strName
						FROM vyuLGNotifyParties WITH (NOLOCK)
						WHERE strEntity = 'Forwarding Agent'
							AND intEntityId = @intOldEntityId

						SELECT @strNewCompanyName = strName
						FROM vyuLGNotifyParties WITH (NOLOCK)
						WHERE strEntity = 'Company'
							AND intEntityId = @intNewCompanySetupID

						SELECT @strOldCompanyName = strName
						FROM vyuLGNotifyParties WITH (NOLOCK)
						WHERE strEntity = 'Company'
							AND intEntityId = @intOldCompanySetupID

						SELECT @strNewEntityLocationName = strLocationName
						FROM vyuLGNotifyPartiesAddresses WITH (NOLOCK)
						WHERE strType = 'Forwarding Agent'
							AND intEntityLocationId = @intNewEntityLocationId

						SELECT @strOldEntityLocationName = strLocationName
						FROM vyuLGNotifyPartiesAddresses WITH (NOLOCK)
						WHERE strType = 'Forwarding Agent'
							AND intEntityLocationId = @intOldEntityLocationId

						SELECT @strNotifyAuditInfo = @strAuditNotifyOrConsignee + ' - ' + ISNULL(@strNewEntityName, @strNewCompanyName)

						SET @Notifydetails = '{  
								"action":"Updated",
								"change":"Updated - Record: ' + LTRIM(@intLoadId) + '",
								"keyValue":' + LTRIM(@intLoadId) + ',
								"iconCls":"small-tree-modified",
								"children":[  
									{  
										"change":"tblLGLoadNotifyParties",
										"children":[  
											{  
											"action":"Updated",
											"change":"Updated - Record: ' + LTRIM(@strNotifyAuditInfo) + '",
											"keyValue":' + LTRIM(@intAuditLoadNotifyPartyId) + ',
											"iconCls":"small-tree-modified",
											"children":
												[   
													'

						IF @intOldEntityId <> @intNewEntityId
							SET @Notifydetails = @Notifydetails + '
													{  
													"change":"strParty",
													"from":"' + LTRIM(@strOldEntityName) + '",
													"to":"' + LTRIM(@strNewEntityName) + '",
													"leaf":true,
													"iconCls":"small-gear",
													"isField":true,
													"keyValue":' + LTRIM(@intAuditLoadNotifyPartyId) + ',
													"associationKey":"tblLGLoadNotifyParties",
													"changeDescription":"Party",
													"hidden":false
													},'

						IF @intOldCompanySetupID <> @intNewCompanySetupID
							SET @Notifydetails = @Notifydetails + '
													{  
													"change":"strParty",
													"from":"' + LTRIM(@strOldCompanyName) + '",
													"to":"' + LTRIM(@strNewCompanyName) + '",
													"leaf":true,
													"iconCls":"small-gear",
													"isField":true,
													"keyValue":' + LTRIM(@intAuditLoadNotifyPartyId) + ',
													"associationKey":"tblLGLoadNotifyParties",
													"changeDescription":"Party",
													"hidden":false
													},'

						IF @intOldEntityLocationId <> @intNewEntityLocationId
							SET @Notifydetails = @Notifydetails + '
													{  
													"change":"strPartyLocation",
													"from":"' + LTRIM(@strOldEntityLocationName) + '",
													"to":"' + LTRIM(@strNewEntityLocationName) + '",
													"leaf":true,
													"iconCls":"small-gear",
													"isField":true,
													"keyValue":' + LTRIM(@intAuditLoadNotifyPartyId) + ',
													"associationKey":"tblLGLoadNotifyParties",
													"changeDescription":"Party Location",
													"hidden":false
													},'

						IF RIGHT(@Notifydetails, 1) = ','
							SET @Notifydetails = SUBSTRING(@Notifydetails, 0, LEN(@Notifydetails))
						SET @Notifydetails = @Notifydetails + '
											]
										}
									],
									"iconCls":"small-tree-grid",
									"changeDescription":"Notify Parties"
									}
								]
								}'

						IF @intOldEntityId <> @intNewEntityId
							OR @intOldCompanySetupID <> @intNewCompanySetupID
							OR @intOldEntityLocationId <> @intNewEntityLocationId
						BEGIN
							EXEC uspSMAuditLog @keyValue = @intLoadId
								,@screenName = 'Logistics.view.ShipmentSchedule'
								,@entityId = @intEntityId
								,@actionType = 'Updated'
								,@actionIcon = 'small-tree-modified'
								,@details = @Notifydetails
						END

						DELETE
						FROM @tblLGLoadNotifyPartiesChanges
						WHERE intLoadNotifyPartyId = @intAuditLoadNotifyPartyId
					END

					-- Audit Log for Inserted / Deleted Notify Parties
					WHILE EXISTS (
							SELECT TOP 1 NULL
							FROM @tblLGLoadNotifyPartiesChanges
							WHERE strAction <> 'Updated'
							)
					BEGIN
						SELECT @intAuditLoadNotifyPartyId = NULL
							,@strAuditNotifyOrConsignee = NULL
							,@intNewEntityId = NULL
							,@intNewCompanySetupID = NULL
							,@intOldEntityId = NULL
							,@intOldCompanySetupID = NULL
							,@strNotifyAuditInfo = NULL
							,@strAction = NULL

						SELECT @strNewEntityName = NULL
							,@strNewCompanyName = NULL
							,@strOldEntityName = NULL
							,@strOldCompanyName = NULL

						SELECT TOP 1 @intAuditLoadNotifyPartyId = intLoadNotifyPartyId
							,@strAuditNotifyOrConsignee = strNotifyOrConsignee
							,@strAction = strAction
							,@intNewEntityId = intNewEntityId
							,@intNewCompanySetupID = intNewCompanySetupID
							,@intOldEntityId = intOldEntityId
							,@intOldCompanySetupID = intOldCompanySetupID
						FROM @tblLGLoadNotifyPartiesChanges
						WHERE strAction <> 'Updated'

						SELECT @strNewEntityName = strName
						FROM vyuLGNotifyParties WITH (NOLOCK)
						WHERE strEntity = 'Forwarding Agent'
							AND intEntityId = @intNewEntityId

						SELECT @strOldEntityName = strName
						FROM vyuLGNotifyParties WITH (NOLOCK)
						WHERE strEntity = 'Forwarding Agent'
							AND intEntityId = @intOldEntityId

						SELECT @strNewCompanyName = strName
						FROM vyuLGNotifyParties WITH (NOLOCK)
						WHERE strEntity = 'Company'
							AND intEntityId = @intNewCompanySetupID

						SELECT @strOldCompanyName = strName
						FROM vyuLGNotifyParties WITH (NOLOCK)
						WHERE strEntity = 'Company'
							AND intEntityId = @intOldCompanySetupID

						IF @strAction = 'Created'
							SELECT @strNotifyAuditInfo = @strAuditNotifyOrConsignee + ' - ' + ISNULL(@strNewEntityName, @strNewCompanyName)

						IF @strAction = 'Deleted'
							SELECT @strNotifyAuditInfo = @strAuditNotifyOrConsignee + ' - ' + ISNULL(@strOldEntityName, @strOldCompanyName)

						IF @strAction = 'Created'
							SET @AllNotifydetails = @AllNotifydetails + '
													{  
													"action":"Created",
													"change":"Created - Record: ' + LTRIM(@strNotifyAuditInfo) + '",
													"keyValue":' + LTRIM(@intAuditLoadNotifyPartyId) + ',
													"iconCls":"small-new-plus",
													"leaf": true
													},'

						--IF @strAction = 'Deleted'
						--	SET @AllNotifydetails = @AllNotifydetails + '
						--							{  
						--							"action":"Deleted",
						--							"change":"Deleted - Record: ' + LTRIM(@strNotifyAuditInfo) + '",
						--							"keyValue":' + LTRIM(@intAuditLoadNotifyPartyId) + ',
						--							"iconCls":"small-new-minus",
						--							"leaf": true
						--							},'

						DELETE
						FROM @tblLGLoadNotifyPartiesChanges
						WHERE intLoadNotifyPartyId = @intAuditLoadNotifyPartyId
					END

					IF ISNULL(@AllNotifydetails, '') <> ''
					BEGIN
						IF RIGHT(@AllNotifydetails, 1) = ','
							SET @AllNotifydetails = SUBSTRING(@AllNotifydetails, 0, LEN(@AllNotifydetails))
						SET @Notifydetails = '{  
								"action":"Updated",
								"change":"Updated - Record: ' + LTRIM(@intLoadId) + '",
								"keyValue":' + LTRIM(@intLoadId) + ',
								"iconCls":"small-tree-modified",
								"children":[  
									{  
										"change":"tblLGLoadNotifyParties",
										"children":[  
													'
						SET @Notifydetails = @Notifydetails + @AllNotifydetails
						SET @Notifydetails = @Notifydetails + '
									],
									"iconCls":"small-tree-grid",
									"changeDescription":"Notify Parties"
									}
								]
								}'

						BEGIN
							EXEC uspSMAuditLog @keyValue = @intLoadId
								,@screenName = 'Logistics.view.ShipmentSchedule'
								,@entityId = @intEntityId
								,@actionType = 'Updated'
								,@actionIcon = 'small-tree-modified'
								,@details = @Notifydetails
						END
					END
				END
			END

			-- Load Documents
			IF (
					@strRowState = 'Added'
					OR @strRowState = 'Modified'
					)
				AND EXISTS (
					SELECT 1
					FROM tblIPLoadDocumentsStage
					WHERE intStageLoadId = @intMinRowNo
					)
			BEGIN
				DELETE
				FROM @tblLGLoadDocuments

				DELETE
				FROM @tblLGLoadDocumentsChanges

				DELETE
				FROM @tblLGLoadDocumentsOrg

				INSERT INTO @tblLGLoadDocumentsOrg (
					intLoadDocumentId
					,strDocumentName
					)
				SELECT LD.intLoadDocumentId
					,ID.strDocumentName
				FROM tblLGLoadDocuments LD WITH (NOLOCK)
				JOIN vyuLGGetInventoryDocumentList ID WITH (NOLOCK) ON ID.intDocumentId = LD.intDocumentId
				WHERE LD.intLoadId = @intLoadId

				INSERT INTO @tblLGLoadDocumentsChanges (
					intLoadDocumentId
					,strAction
					,strDocumentName
					,strOldDocumentType
					,intOldOriginal
					,intOldCopies
					)
				SELECT LD.intLoadDocumentId
					,'Updated'
					,ID.strDocumentName
					,ID.strDocumentType
					,LD.intOriginal
					,LD.intCopies
				FROM tblLGLoadDocuments LD WITH (NOLOCK)
				JOIN vyuLGGetInventoryDocumentList ID WITH (NOLOCK) ON ID.intDocumentId = LD.intDocumentId
				WHERE LD.intLoadId = @intLoadId

				INSERT INTO @tblLGLoadDocuments (intStageLoadDocumentsId)
				SELECT intStageLoadDocumentsId
				FROM tblIPLoadDocumentsStage WITH (NOLOCK)
				WHERE intStageLoadId = @intMinRowNo

				SELECT @intStageLoadDocumentsId = MIN(intStageLoadDocumentsId)
				FROM @tblLGLoadDocuments

				WHILE @intStageLoadDocumentsId IS NOT NULL
				BEGIN
					SELECT @strDocumentName = NULL
						,@intOriginal = NULL
						,@intCopies = NULL
						,@intLoadDocumentId = NULL

					SELECT @intDocumentId = NULL
						,@strDocumentType = NULL

					SELECT @strDocumentName = strName
						,@intOriginal = ISNULL(intOriginal, 0)
						,@intCopies = ISNULL(intCopies, 0)
					FROM tblIPLoadDocumentsStage WITH (NOLOCK)
					WHERE intStageLoadDocumentsId = @intStageLoadDocumentsId

					SELECT TOP 1 @intDocumentId = intDocumentId
						,@strDocumentType = strDocumentType
					FROM vyuLGGetInventoryDocumentList WITH (NOLOCK)
					WHERE strDocumentName = @strDocumentName

					IF ISNULL(@intDocumentId, 0) = 0
					BEGIN
						RAISERROR (
								'Invalid Document Name. '
								,16
								,1
								)
					END

					IF @strRowState = 'Added'
					BEGIN
						INSERT INTO tblLGLoadDocuments (
							intConcurrencyId
							,intLoadId
							,intDocumentId
							,strDocumentType
							,intOriginal
							,intCopies
							)
						SELECT 1
							,@intLoadId
							,@intDocumentId
							,@strDocumentType
							,@intOriginal
							,@intCopies

						SELECT @intLoadDocumentId = SCOPE_IDENTITY()
					END
					ELSE
					BEGIN
						SELECT @intLoadDocumentId = intLoadDocumentId
						FROM tblLGLoadDocuments WITH (NOLOCK)
						WHERE intLoadId = @intLoadId
							AND intDocumentId = @intDocumentId

						IF ISNULL(@intLoadDocumentId, 0) > 0
						BEGIN
							UPDATE tblLGLoadDocuments
							SET intConcurrencyId = intConcurrencyId + 1
								,strDocumentType = @strDocumentType
								,intOriginal = @intOriginal
								,intCopies = @intCopies
							WHERE intLoadDocumentId = @intLoadDocumentId
						END
						ELSE
						BEGIN
							INSERT INTO tblLGLoadDocuments (
								intConcurrencyId
								,intLoadId
								,intDocumentId
								,strDocumentType
								,intOriginal
								,intCopies
								)
							SELECT 1
								,@intLoadId
								,@intDocumentId
								,@strDocumentType
								,@intOriginal
								,@intCopies

							SELECT @intLoadDocumentId = SCOPE_IDENTITY()
						END
					END

					SELECT @intStageLoadDocumentsId = MIN(intStageLoadDocumentsId)
					FROM @tblLGLoadDocuments
					WHERE intStageLoadDocumentsId > @intStageLoadDocumentsId
				END

				-- Delete the documents which are available in i21 but not in the XML
				DELETE
				FROM @tblDeleteDocuments

				INSERT INTO @tblDeleteDocuments (intLoadDocumentId)
				SELECT LD.intLoadDocumentId
				FROM tblLGLoadDocuments LD WITH (NOLOCK)
				JOIN vyuLGGetInventoryDocumentList ID WITH (NOLOCK) ON ID.intDocumentId = LD.intDocumentId
				WHERE LD.intLoadId = @intLoadId
					AND NOT EXISTS (
						SELECT 1
						FROM tblIPLoadDocumentsStage LDS WITH (NOLOCK)
						WHERE LDS.intStageLoadId = @intMinRowNo
							AND LDS.strName = ID.strDocumentName
						)

				--DELETE LD
				--FROM tblLGLoadDocuments LD
				--JOIN @tblDeleteDocuments DEL ON DEL.intLoadDocumentId = LD.intLoadDocumentId
				--	AND LD.intLoadId = @intLoadId

				INSERT INTO @tblLGLoadDocumentsChanges (
					intLoadDocumentId
					,strDocumentName
					,strAction
					)
				SELECT LD.intLoadDocumentId
					,ID.strDocumentName
					,'Created'
				FROM tblLGLoadDocuments LD WITH (NOLOCK)
				JOIN vyuLGGetInventoryDocumentList ID WITH (NOLOCK) ON ID.intDocumentId = LD.intDocumentId
				WHERE LD.intLoadId = @intLoadId
					AND NOT EXISTS (
						SELECT 1
						FROM @tblLGLoadDocumentsOrg LDO
						WHERE LDO.intLoadDocumentId = LD.intLoadDocumentId
						)

				UPDATE @tblLGLoadDocumentsChanges
				SET strAction = 'Deleted'
				FROM @tblLGLoadDocumentsChanges OLD
				JOIN @tblDeleteDocuments DEL ON DEL.intLoadDocumentId = OLD.intLoadDocumentId

				UPDATE @tblLGLoadDocumentsChanges
				SET strNewDocumentType = LD.strDocumentType
					,intNewOriginal = LD.intOriginal
					,intNewCopies = LD.intCopies
				FROM @tblLGLoadDocumentsChanges OLD
				JOIN tblLGLoadDocuments LD ON LD.intLoadDocumentId = OLD.intLoadDocumentId

				-- Load Documents Audit Log
				IF @strRowState = 'Modified'
				BEGIN
					DECLARE @Documentdetails NVARCHAR(MAX) = ''
						,@AllDocumentdetails NVARCHAR(MAX) = ''
					DECLARE @strDocumentAuditInfo NVARCHAR(MAX) = ''

					--DROP TABLE tblLGLoadDocumentsChangesTest
					--SELECT * INTO tblLGLoadDocumentsChangesTest FROM @tblLGLoadDocumentsChanges
					WHILE EXISTS (
							SELECT TOP 1 NULL
							FROM @tblLGLoadDocumentsChanges
							WHERE strAction = 'Updated'
							)
					BEGIN
						SELECT @intAuditLoadDocumentId = NULL
							,@strAuditDocumentName = NULL
							,@strNewDocumentType = NULL
							,@intNewOriginal = NULL
							,@intNewCopies = NULL
							,@strOldDocumentType = NULL
							,@intOldOriginal = NULL
							,@intOldCopies = NULL
							,@Documentdetails = NULL
							,@strDocumentAuditInfo = NULL

						SELECT TOP 1 @intAuditLoadDocumentId = intLoadDocumentId
							,@strAuditDocumentName = strDocumentName
							,@strNewDocumentType = strNewDocumentType
							,@intNewOriginal = intNewOriginal
							,@intNewCopies = intNewCopies
							,@strOldDocumentType = strOldDocumentType
							,@intOldOriginal = intOldOriginal
							,@intOldCopies = intOldCopies
						FROM @tblLGLoadDocumentsChanges
						WHERE strAction = 'Updated'

						SELECT @strDocumentAuditInfo = @strAuditDocumentName + ' - ' + @strNewDocumentType

						SET @Documentdetails = '{  
								"action":"Updated",
								"change":"Updated - Record: ' + LTRIM(@intLoadId) + '",
								"keyValue":' + LTRIM(@intLoadId) + ',
								"iconCls":"small-tree-modified",
								"children":[  
									{  
										"change":"tblLGLoadDocuments",
										"children":[  
											{  
											"action":"Updated",
											"change":"Updated - Record: ' + LTRIM(@strDocumentAuditInfo) + '",
											"keyValue":' + LTRIM(@intAuditLoadDocumentId) + ',
											"iconCls":"small-tree-modified",
											"children":
												[   
													'

						IF @strOldDocumentType <> @strNewDocumentType
							SET @Documentdetails = @Documentdetails + '
													{  
													"change":"strDocumentType",
													"from":"' + LTRIM(@strOldDocumentType) + '",
													"to":"' + LTRIM(@strNewDocumentType) + '",
													"leaf":true,
													"iconCls":"small-gear",
													"isField":true,
													"keyValue":' + LTRIM(@intAuditLoadDocumentId) + ',
													"associationKey":"tblLGLoadDocuments",
													"changeDescription":"Document Type",
													"hidden":false
													},'

						IF @intOldOriginal <> @intNewOriginal
							SET @Documentdetails = @Documentdetails + '
													{  
													"change":"intOriginal",
													"from":"' + LTRIM(@intOldOriginal) + '",
													"to":"' + LTRIM(@intNewOriginal) + '",
													"leaf":true,
													"iconCls":"small-gear",
													"isField":true,
													"keyValue":' + LTRIM(@intAuditLoadDocumentId) + ',
													"associationKey":"tblLGLoadDocuments",
													"changeDescription":"Original",
													"hidden":false
													},'

						IF @intOldCopies <> @intNewCopies
							SET @Documentdetails = @Documentdetails + '
													{  
													"change":"intCopies",
													"from":"' + LTRIM(@intOldCopies) + '",
													"to":"' + LTRIM(@intNewCopies) + '",
													"leaf":true,
													"iconCls":"small-gear",
													"isField":true,
													"keyValue":' + LTRIM(@intAuditLoadDocumentId) + ',
													"associationKey":"tblLGLoadDocuments",
													"changeDescription":"Copies",
													"hidden":false
													},'

						IF RIGHT(@Documentdetails, 1) = ','
							SET @Documentdetails = SUBSTRING(@Documentdetails, 0, LEN(@Documentdetails))
						SET @Documentdetails = @Documentdetails + '
											]
										}
									],
									"iconCls":"small-tree-grid",
									"changeDescription":"Documents"
									}
								]
								}'

						IF @strOldDocumentType <> @strNewDocumentType
							OR @intOldOriginal <> @intNewOriginal
							OR @intOldCopies <> @intNewCopies
						BEGIN
							EXEC uspSMAuditLog @keyValue = @intLoadId
								,@screenName = 'Logistics.view.ShipmentSchedule'
								,@entityId = @intEntityId
								,@actionType = 'Updated'
								,@actionIcon = 'small-tree-modified'
								,@details = @Documentdetails
						END

						DELETE
						FROM @tblLGLoadDocumentsChanges
						WHERE intLoadDocumentId = @intAuditLoadDocumentId
					END

					-- Audit Log for Inserted / Deleted Documents
					WHILE EXISTS (
							SELECT TOP 1 NULL
							FROM @tblLGLoadDocumentsChanges
							WHERE strAction <> 'Updated'
							)
					BEGIN
						SELECT @intAuditLoadDocumentId = NULL
							,@strAuditDocumentName = NULL
							,@strNewDocumentType = NULL
							,@strOldDocumentType = NULL
							,@strDocumentAuditInfo = NULL
							,@strAction = NULL

						SELECT TOP 1 @intAuditLoadDocumentId = intLoadDocumentId
							,@strAuditDocumentName = strDocumentName
							,@strAction = strAction
							,@strNewDocumentType = strNewDocumentType
							,@strOldDocumentType = strOldDocumentType
						FROM @tblLGLoadDocumentsChanges
						WHERE strAction <> 'Updated'

						IF @strAction = 'Created'
							SELECT @strDocumentAuditInfo = @strAuditDocumentName + ' - ' + @strNewDocumentType

						IF @strAction = 'Deleted'
							SELECT @strDocumentAuditInfo = @strAuditDocumentName + ' - ' + @strOldDocumentType

						IF @strAction = 'Created'
							SET @AllDocumentdetails = @AllDocumentdetails + '
													{  
													"action":"Created",
													"change":"Created - Record: ' + LTRIM(@strDocumentAuditInfo) + '",
													"keyValue":' + LTRIM(@intAuditLoadDocumentId) + ',
													"iconCls":"small-new-plus",
													"leaf": true
													},'

						--IF @strAction = 'Deleted'
						--	SET @AllDocumentdetails = @AllDocumentdetails + '
						--							{  
						--							"action":"Deleted",
						--							"change":"Deleted - Record: ' + LTRIM(@strDocumentAuditInfo) + '",
						--							"keyValue":' + LTRIM(@intAuditLoadDocumentId) + ',
						--							"iconCls":"small-new-minus",
						--							"leaf": true
						--							},'

						DELETE
						FROM @tblLGLoadDocumentsChanges
						WHERE intLoadDocumentId = @intAuditLoadDocumentId
					END

					IF ISNULL(@AllDocumentdetails, '') <> ''
					BEGIN
						IF RIGHT(@AllDocumentdetails, 1) = ','
							SET @AllDocumentdetails = SUBSTRING(@AllDocumentdetails, 0, LEN(@AllDocumentdetails))
						SET @Documentdetails = '{  
								"action":"Updated",
								"change":"Updated - Record: ' + LTRIM(@intLoadId) + '",
								"keyValue":' + LTRIM(@intLoadId) + ',
								"iconCls":"small-tree-modified",
								"children":[  
									{  
										"change":"tblLGLoadDocuments",
										"children":[  
													'
						SET @Documentdetails = @Documentdetails + @AllDocumentdetails
						SET @Documentdetails = @Documentdetails + '
									],
									"iconCls":"small-tree-grid",
									"changeDescription":"Documents"
									}
								]
								}'

						BEGIN
							EXEC uspSMAuditLog @keyValue = @intLoadId
								,@screenName = 'Logistics.view.ShipmentSchedule'
								,@entityId = @intEntityId
								,@actionType = 'Updated'
								,@actionIcon = 'small-tree-modified'
								,@details = @Documentdetails
						END
					END
				END
			END

			-- Set Shipper in Contract and add audit log
			IF ISNULL(@intShipperId, 0) > 0
			BEGIN
				IF ISNULL(@intShipperId, 0) <> ISNULL(@intContractShipperId, 0)
				BEGIN
					SELECT @strContractPartyName = strName
					FROM tblEMEntity WITH (NOLOCK)
					WHERE intEntityId = @intContractShipperId

					UPDATE tblCTContractDetail
					SET intShipperId = @intShipperId
						,intConcurrencyId = intConcurrencyId + 1
					WHERE intContractDetailId = @intContractDetailId

					DECLARE @Shipperdetails NVARCHAR(MAX) = ''

					-- Shipper Audit Log
					SET @Shipperdetails = '{  
						"action":"Updated",
						"change":"Updated - Record: ' + LTRIM(@intMainContractHeaderId) + '",
						"keyValue":' + LTRIM(@intMainContractHeaderId) + ',
						"iconCls":"small-tree-modified",
						"children":[  
							{  
								"change":"tblCTContractDetails",
								"children":[  
									{  
									"action":"Updated",
									"change":"Updated - Record: Sequence - ' + LTRIM(@intContractSeq) + '",
									"keyValue":' + LTRIM(@intContractDetailId) + ',
									"iconCls":"small-tree-modified",
									"children":
										[   
											'
					SET @Shipperdetails = @Shipperdetails + '
											{  
											"change":"intShipperId",
											"from":"' + LTRIM(ISNULL(@intContractShipperId, '')) + '",
											"to":"' + LTRIM(ISNULL(@intShipperId, '')) + '",
											"leaf":true,
											"iconCls":"small-gear",
											"isField":true,
											"keyValue":' + LTRIM(@intContractDetailId) + ',
											"associationKey":"tblCTContractDetails",
											"hidden":true
											},'
					SET @Shipperdetails = @Shipperdetails + '
											{  
											"change":"strShipper",
											"from":"' + LTRIM(ISNULL(@strContractPartyName, '')) + '",
											"to":"' + LTRIM(@strPartyName) + '",
											"leaf":true,
											"iconCls":"small-gear",
											"isField":true,
											"keyValue":' + LTRIM(@intContractDetailId) + ',
											"associationKey":"tblCTContractDetails",
											"changeDescription":"Shipper",
											"hidden":false
											},'

					IF RIGHT(@Shipperdetails, 1) = ','
						SET @Shipperdetails = SUBSTRING(@Shipperdetails, 0, LEN(@Shipperdetails))
					SET @Shipperdetails = @Shipperdetails + '
									]
								}
							],
							"iconCls":"small-tree-grid",
							"changeDescription":"Details"
							}
						]
						}'

					EXEC uspSMAuditLog @keyValue = @intMainContractHeaderId
						,@screenName = 'ContractManagement.view.Contract'
						,@entityId = @intEntityId
						,@actionType = 'Updated'
						,@actionIcon = 'small-tree-modified'
						,@details = @Shipperdetails
				END
			END

			-- To set Contract Planned Availability Date and send Contract feed to SAP
			IF @strRowState = 'Added'
				OR @strRowState = 'Modified'
			BEGIN
				EXEC uspLGCreateLoadIntegrationLog @intLoadId = @intLoadId
					,@strRowState = @strRowState
					,@intShipmentType = 2 -- LSI
			END

			--Move to Archive
			INSERT INTO tblIPLoadArchive (
				strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETAPOD
				,dtmETAPOL
				,dtmDeadlineCargo
				,dtmETSPOL
				,strBookingReference
				,strServiceContractNumber
				,strBLNumber
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strPartyAlias
				,strPartyName
				,strPartyType
				,strLoadNumber
				,strAction
				,strFileName
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				,ysnDeadlockError
				)
			SELECT strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETAPOD
				,dtmETAPOL
				,dtmDeadlineCargo
				,dtmETSPOL
				,strBookingReference
				,strServiceContractNumber
				,strBLNumber
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strPartyAlias
				,strPartyName
				,strPartyType
				,strLoadNumber
				,strAction
				,strFileName
				,strTransactionType
				,''
				,'Success'
				,strSessionId
				,ysnDeadlockError
			FROM tblIPLoadStage
			WHERE intStageLoadId = @intMinRowNo

			SELECT @intNewStageLoadId = SCOPE_IDENTITY()

			INSERT INTO tblIPLoadDetailArchive (
				intStageLoadId
				,strCustomerReference
				,strCommodityCode
				,strItemNo
				,strContractItemName
				,dblQuantity
				,dblGrossWeight
				,strPackageType
				)
			SELECT @intNewStageLoadId
				,strCustomerReference
				,strCommodityCode
				,strItemNo
				,strContractItemName
				,dblQuantity
				,dblGrossWeight
				,strPackageType
			FROM tblIPLoadDetailStage
			WHERE intStageLoadId = @intMinRowNo

			INSERT INTO tblIPLoadNotifyPartiesArchive (
				intStageLoadId
				,strCustomerReference
				,strPartyType
				,strPartyName
				,strPartyLocation
				)
			SELECT @intNewStageLoadId
				,strCustomerReference
				,strPartyType
				,strPartyName
				,strPartyLocation
			FROM tblIPLoadNotifyPartiesStage
			WHERE intStageLoadId = @intMinRowNo

			INSERT INTO tblIPLoadDocumentsArchive (
				intStageLoadId
				,strCustomerReference
				,strTypeCode
				,strName
				,intOriginal
				,intCopies
				)
			SELECT @intNewStageLoadId
				,strCustomerReference
				,strTypeCode
				,strName
				,intOriginal
				,intCopies
			FROM tblIPLoadDocumentsStage
			WHERE intStageLoadId = @intMinRowNo

			DELETE
			FROM tblIPLoadStage
			WHERE intStageLoadId = @intMinRowNo

			COMMIT TRAN
		END TRY

		BEGIN CATCH
			IF XACT_STATE() != 0
				AND @@TRANCOUNT > 0
				ROLLBACK TRANSACTION

			SET @ErrMsg = ERROR_MESSAGE()
			SET @strFinalErrMsg = @strFinalErrMsg + @ErrMsg

			--Move to Error
			INSERT INTO tblIPLoadError (
				strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETAPOD
				,dtmETAPOL
				,dtmDeadlineCargo
				,dtmETSPOL
				,strBookingReference
				,strServiceContractNumber
				,strBLNumber
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strPartyAlias
				,strPartyName
				,strPartyType
				,strLoadNumber
				,strAction
				,strFileName
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				)
			SELECT strCustomerReference
				,strERPPONumber
				,strOriginPort
				,strDestinationPort
				,dtmETAPOD
				,dtmETAPOL
				,dtmDeadlineCargo
				,dtmETSPOL
				,strBookingReference
				,strServiceContractNumber
				,strBLNumber
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strPartyAlias
				,strPartyName
				,strPartyType
				,strLoadNumber
				,strAction
				,strFileName
				,strTransactionType
				,@ErrMsg
				,'Failed'
				,strSessionId
			FROM tblIPLoadStage
			WHERE intStageLoadId = @intMinRowNo

			SELECT @intNewStageLoadId = SCOPE_IDENTITY()

			INSERT INTO tblIPLoadDetailError (
				intStageLoadId
				,strCustomerReference
				,strCommodityCode
				,strItemNo
				,strContractItemName
				,dblQuantity
				,dblGrossWeight
				,strPackageType
				)
			SELECT @intNewStageLoadId
				,strCustomerReference
				,strCommodityCode
				,strItemNo
				,strContractItemName
				,dblQuantity
				,dblGrossWeight
				,strPackageType
			FROM tblIPLoadDetailStage
			WHERE intStageLoadId = @intMinRowNo

			INSERT INTO tblIPLoadNotifyPartiesError (
				intStageLoadId
				,strCustomerReference
				,strPartyType
				,strPartyName
				,strPartyLocation
				)
			SELECT @intNewStageLoadId
				,strCustomerReference
				,strPartyType
				,strPartyName
				,strPartyLocation
			FROM tblIPLoadNotifyPartiesStage
			WHERE intStageLoadId = @intMinRowNo

			INSERT INTO tblIPLoadDocumentsError (
				intStageLoadId
				,strCustomerReference
				,strTypeCode
				,strName
				,intOriginal
				,intCopies
				)
			SELECT @intNewStageLoadId
				,strCustomerReference
				,strTypeCode
				,strName
				,intOriginal
				,intCopies
			FROM tblIPLoadDocumentsStage
			WHERE intStageLoadId = @intMinRowNo

			DELETE
			FROM tblIPLoadStage
			WHERE intStageLoadId = @intMinRowNo
		END CATCH

		SELECT @intMinRowNo = Min(intStageLoadId)
		FROM tblIPLoadStage WITH (NOLOCK)
		WHERE intStageLoadId > @intMinRowNo
			AND ISNULL(strTransactionType, '') = 'ShippingInstruction'
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
