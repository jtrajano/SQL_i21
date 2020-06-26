CREATE PROCEDURE uspIPProcessSAPShipment_CA @strInfo1 NVARCHAR(MAX) = '' OUT
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
		,@strBLNumber NVARCHAR(100)
		,@strMVessel NVARCHAR(200)
		,@strMVoyageNumber NVARCHAR(100)
		,@strShippingMode NVARCHAR(100)
		,@dtmBLDate DATETIME
		,@strShippingLine NVARCHAR(100)
		,@intNumberOfContainers INT
		,@strContainerType NVARCHAR(50)
	DECLARE @strLoadNumber NVARCHAR(100)
		,@intLoadId INT
		,@intContractDetailId INT
		,@intOriginPortId INT
		,@intDestinationPortId INT
		,@intShippingModeId INT
		,@intShippingLineEntityId INT
		,@intContainerTypeId INT
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
		,@ysnPosted BIT
		,@intLoadShippingInstructionId INT
		,@strContainerErrMsg NVARCHAR(MAX)
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
		,@strOldBLNumber NVARCHAR(100)
		,@strOldMVessel NVARCHAR(200)
		,@strOldMVoyageNumber NVARCHAR(100)
		,@strOldShippingMode NVARCHAR(100)
		,@dtmOldBLDate DATETIME
		,@strOldShippingLine NVARCHAR(100)
		,@intOldShippingLineEntityId INT
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
		,@intLoadDetailId INT
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
	DECLARE @tblLGLoadContainer TABLE (intStageLoadContainerId INT)
	DECLARE @intStageLoadContainerId INT
		,@strContainerNumber NVARCHAR(100)
		,@dblGrossWt NUMERIC(18, 6)
		,@dblTareWt NUMERIC(18, 6)
		,@dblCONQuantity NUMERIC(18, 6)
	DECLARE @intCONUnitMeasureId INT
		,@intCONWeightUnitMeasureId INT
		,@intLoadContainerId INT
	DECLARE @strDeliveryNoticeNumber NVARCHAR(100)
		,@intSubLocationId INT
		,@intStorageLocationId INT
		,@intSort INT
	DECLARE @tblDeleteContainer TABLE (intLoadContainerId INT)
	DECLARE @tblLGLoadContainerChanges TABLE (
		intLoadContainerId INT
		,strAction NVARCHAR(50)
		,strContainerNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		,dblNewCONQuantity NUMERIC(18, 6)
		,dblOldCONQuantity NUMERIC(18, 6)
		,dblNewGrossWt NUMERIC(18, 6)
		,dblOldGrossWt NUMERIC(18, 6)
		,dblNewTareWt NUMERIC(18, 6)
		,dblOldTareWt NUMERIC(18, 6)
		,dblNewNetWt NUMERIC(18, 6)
		,dblOldNetWt NUMERIC(18, 6)
		)
	DECLARE @intAuditLoadContainerId INT
		,@strAuditContainerNumber NVARCHAR(100)
		,@dblNewCONQuantity NUMERIC(18, 6)
		,@dblOldCONQuantity NUMERIC(18, 6)
		,@dblNewGrossWt NUMERIC(18, 6)
		,@dblOldGrossWt NUMERIC(18, 6)
		,@dblNewTareWt NUMERIC(18, 6)
		,@dblOldTareWt NUMERIC(18, 6)
		,@dblNewNetWt NUMERIC(18, 6)
		,@dblOldNetWt NUMERIC(18, 6)
		,@strAction NVARCHAR(50)
	DECLARE @tblLGLoadContainerOrg TABLE (
		intLoadContainerId INT
		,strContainerNumber NVARCHAR(100) COLLATE Latin1_General_CI_AS
		)

	SELECT @intMinRowNo = Min(intStageLoadId)
	FROM tblIPLoadStage WITH (NOLOCK)
	WHERE ISNULL(strTransactionType, '') = 'Shipment'

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
				,@strBLNumber = NULL
				,@strMVessel = NULL
				,@strMVoyageNumber = NULL
				,@strShippingMode = NULL
				,@dtmBLDate = NULL
				,@strShippingLine = NULL
				,@intNumberOfContainers = NULL
				,@strContainerType = NULL

			SELECT @strLoadNumber = NULL
				,@intLoadId = NULL
				,@intContractDetailId = NULL
				,@intOriginPortId = NULL
				,@intDestinationPortId = NULL
				,@intShippingModeId = NULL
				,@intShippingLineEntityId = NULL
				,@intContainerTypeId = NULL
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
				,@dtmStartDate = NULL
				,@dtmEndDate = NULL
				,@dtmPlannedAvailabilityDate = NULL
				,@intLocationId = NULL
				,@ysnPosted = NULL
				,@intLoadShippingInstructionId = NULL
				,@strContainerErrMsg = ''

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
				,@strOldBLNumber = NULL
				,@strOldMVessel = NULL
				,@strOldMVoyageNumber = NULL
				,@strOldShippingMode = NULL
				,@dtmOldBLDate = NULL
				,@strOldShippingLine = NULL
				,@intOldShippingLineEntityId = NULL
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
				,@strBLNumber = strBLNumber
				,@strMVessel = strMVessel
				,@strMVoyageNumber = strMVoyageNumber
				,@strShippingMode = strShippingMode
				,@dtmBLDate = dtmBLDate
				,@strShippingLine = strShippingLine
				,@intNumberOfContainers = ISNULL(intNumberOfContainers, 0)
				,@strContainerType = strContainerType
			FROM tblIPLoadStage WITH (NOLOCK)
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

			SELECT @intLoadShippingInstructionId = L.intLoadId
			FROM tblLGLoad L WITH (NOLOCK)
			JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LD.intLoadId = L.intLoadId
				AND LD.intPContractDetailId = @intContractDetailId
				AND L.intShipmentType = 2
				AND L.intShipmentStatus <> 10
				--AND L.strCustomerReference = @strCustomerReference

			IF ISNULL(@intLoadShippingInstructionId, 0) = 0
			BEGIN
				RAISERROR (
						'Shipping Instruction is not available. '
						,16
						,1
						)
			END

			--IF NOT EXISTS (
			--		SELECT 1
			--		FROM tblLGLoad L WITH (NOLOCK)
			--		WHERE intLoadId = @intLoadShippingInstructionId
			--			AND strCustomerReference = @strCustomerReference
			--		)
			--BEGIN
			--	RAISERROR (
			--			'Customer Reference is not matching with Shipping Instruction. '
			--			,16
			--			,1
			--			)
			--END

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
			IF @dtmETAPOD IS NULL
			BEGIN
				SELECT @dtmETAPOD = @dtmDeadlineCargo
			END

			IF @dtmETAPOL IS NULL
			BEGIN
				RAISERROR (
						'Invalid Act. ETD. '
						,16
						,1
						)
			END

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

			-- Should not go based on Customer Ref since it will clash with Slicing logic
			SELECT TOP 1 @strLoadNumber = L.strLoadNumber
				,@intLoadId = L.intLoadId
				,@ysnPosted = ISNULL(ysnPosted, 0)
			FROM tblLGLoad L WITH (NOLOCK)
			JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LD.intLoadId = L.intLoadId
				AND L.intShipmentType = 1
				AND LD.intPContractDetailId = @intContractDetailId
				AND L.intShipmentStatus <> 10
				--AND L.strCustomerReference = @strCustomerReference

			SELECT @intShipmentType = 1
				,@intShipmentStatus = 1
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
					,@strPackingDescription = CD.strPackingDescription
					,@dtmStartDate = CD.dtmStartDate
					,@dtmEndDate = CD.dtmEndDate
					,@dtmPlannedAvailabilityDate = CD.dtmPlannedAvailabilityDate
					,@intLocationId = CD.intCompanyLocationId
					,@intShipmentStatus = L.intShipmentStatus
				FROM tblLGLoad L WITH (NOLOCK)
				JOIN tblLGLoadDetail LD WITH (NOLOCK) ON LD.intLoadId = L.intLoadId
					AND L.intLoadId = @intLoadId
				JOIN tblCTContractDetail CD WITH (NOLOCK) ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblCTContractHeader CH WITH (NOLOCK) ON CH.intContractHeaderId = CD.intContractHeaderId
			END

			UPDATE tblIPLoadStage
			SET strAction = @strRowState
			WHERE intStageLoadId = @intMinRowNo

			SELECT @intEntityId = intEntityId
			FROM tblSMUserSecurity WITH (NOLOCK)
			WHERE strUserName = 'IRELYADMIN'

			IF @intShipmentStatus = 10
			BEGIN
				RAISERROR (
						'Shipment cannot update since it is already cancelled. '
						,16
						,1
						)
			END

			BEGIN TRAN

			-- Shipment Create / Update
			IF @strRowState = 'Added'
			BEGIN
				EXEC uspSMGetStartingNumber 39
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
					,strBLNumber
					,dtmBLDate
					,intShippingLineEntityId
					,strMVessel
					,strMVoyageNumber
					,strShippingMode
					,intNumberOfContainers
					,intContainerTypeId
					,intLoadShippingInstructionId
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
					,@strBLNumber
					,@dtmBLDate
					,@intShippingLineEntityId
					,@strMVessel
					,@strMVoyageNumber
					,@strShippingMode
					,@intNumberOfContainers
					,@intContainerTypeId
					,@intLoadShippingInstructionId

				SELECT @intLoadId = SCOPE_IDENTITY()

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
					,@strOldBLNumber = strBLNumber
					,@strOldMVessel = strMVessel
					,@strOldMVoyageNumber = strMVoyageNumber
					,@strOldShippingMode = strShippingMode
					,@dtmOldBLDate = dtmBLDate
					,@intOldShippingLineEntityId = intShippingLineEntityId
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
					,strBLNumber = @strBLNumber
					,dtmBLDate = @dtmBLDate
					,intShippingLineEntityId = @intShippingLineEntityId
					,strMVessel = @strMVessel
					,strMVoyageNumber = @strMVoyageNumber
					,strShippingMode = @strShippingMode
					,intNumberOfContainers = @intNumberOfContainers
					,intContainerTypeId = @intContainerTypeId
					,strCustomerReference = @strCustomerReference
					,intLoadShippingInstructionId = @intLoadShippingInstructionId
				WHERE intLoadId = @intLoadId

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

					IF (@strOldBLNumber <> @strBLNumber)
						SET @strDetails += '{"change":"strBLNumber","iconCls":"small-gear","from":"' + LTRIM(@strOldBLNumber) + '","to":"' + LTRIM(@strBLNumber) + '","leaf":true,"changeDescription":"BOL No."},'

					IF (@strOldMVessel <> @strMVessel)
						SET @strDetails += '{"change":"strMVessel","iconCls":"small-gear","from":"' + LTRIM(@strOldMVessel) + '","to":"' + LTRIM(@strMVessel) + '","leaf":true,"changeDescription":"MV Name"},'

					IF (@strOldMVoyageNumber <> @strMVoyageNumber)
						SET @strDetails += '{"change":"strMVoyageNumber","iconCls":"small-gear","from":"' + LTRIM(@strOldMVoyageNumber) + '","to":"' + LTRIM(@strMVoyageNumber) + '","leaf":true,"changeDescription":"MV Voyage No."},'

					IF (@strOldShippingMode <> @strShippingMode)
						SET @strDetails += '{"change":"strShippingMode","iconCls":"small-gear","from":"' + LTRIM(@strOldShippingMode) + '","to":"' + LTRIM(@strShippingMode) + '","leaf":true,"changeDescription":"Shipping Mode"},'

					IF (CONVERT(DATETIME, CONVERT(NVARCHAR, @dtmOldBLDate, 101)) <> CONVERT(DATETIME, CONVERT(NVARCHAR, @dtmBLDate, 101)))
						SET @strDetails += '{"change":"dtmBLDate","iconCls":"small-gear","from":"' + LTRIM(ISNULL(@dtmOldBLDate, '')) + '","to":"' + LTRIM(ISNULL(@dtmBLDate, '')) + '","leaf":true,"changeDescription":"BOL Date"},'

					IF (@intOldShippingLineEntityId <> @intShippingLineEntityId)
						SET @strDetails += '{"change":"strShippingLine","iconCls":"small-gear","from":"' + LTRIM(@strOldShippingLine) + '","to":"' + LTRIM(@strShippingLine) + '","leaf":true,"changeDescription":"Shipping Line"},'

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
				FROM tblLGLoadDetail LD
				JOIN tblCTContractDetail CD ON CD.intContractDetailId = LD.intPContractDetailId
				JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
				JOIN tblICItem IM ON IM.intItemId = CD.intItemId
				LEFT JOIN tblICItemContract IC ON IC.intItemContractId = CD.intItemContractId
				WHERE LD.intLoadId = @intLoadId

				INSERT INTO @tblLGLoadDetail (intStageLoadDetailId)
				SELECT intStageLoadDetailId
				FROM tblIPLoadDetailStage
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
						,@intLoadDetailId = NULL
						,@dblOldDetailQuantity = NULL
						,@intContractHeaderId = NULL

					SELECT @strCommodityCode = strCommodityCode
						,@strItemNo = strItemNo
						,@strContractItemName = strContractItemName
						,@dblQuantity = ISNULL(dblQuantity, 0)
						,@dblGrossWeight = ISNULL(dblGrossWeight, 0)
						,@strPackageType = strPackageType
					FROM tblIPLoadDetailStage
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

					SELECT @intItemContractId = t.intItemContractId
					FROM tblICItemContract t WITH (NOLOCK)
					JOIN tblICItemLocation IL ON IL.intItemLocationId = t.intItemLocationId
						AND IL.intLocationId = @intLocationId
						AND t.intItemId = @intItemId
						AND t.strContractItemName = @strContractItemName
						AND t.strStatus = 'Active'

					IF ISNULL(@intItemContractId, 0) = 0
					BEGIN
						RAISERROR (
								'Invalid Contract Item. '
								,16
								,1
								)
					END

					IF NOT EXISTS (
							SELECT 1
							FROM tblCTContractDetail t WITH (NOLOCK)
							WHERE t.intContractDetailId = @intContractDetailId
								AND t.intItemId = @intItemId
								AND t.intItemContractId = @intItemContractId
							)
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
					LEFT JOIN tblCTPricingType PT ON PT.intPricingTypeId = CD.intPricingTypeId

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

						SELECT @intLoadDetailId = SCOPE_IDENTITY()

						EXEC uspCTUpdateScheduleQuantityUsingUOM @intContractDetailId = @intContractDetailId
							,@dblQuantityToUpdate = @dblQuantity
							,@intUserId = @intEntityId
							,@intExternalId = @intLoadDetailId
							,@strScreenName = 'Load Schedule'
							,@intSourceItemUOMId = @intItemUOMId

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
							,CD.intDocumentId
							,CASE WHEN ID.intDocumentType = 1 THEN 'Contract'
									WHEN ID.intDocumentType = 2	THEN 'Bill Of Lading'
									WHEN ID.intDocumentType = 3	THEN 'Container'
									ELSE ''
								END COLLATE Latin1_General_CI_AS
							--,ISNULL(ID.intOriginal, 0)
							--,ISNULL(ID.intCopies, 0)
							,0
							,0
						FROM tblCTContractDocument CD
						JOIN tblICDocument ID ON ID.intDocumentId = CD.intDocumentId
							AND CD.intContractHeaderId = @intContractHeaderId
					END
					ELSE
					BEGIN
						SELECT @intLoadDetailId = intLoadDetailId
							,@dblOldDetailQuantity = dblQuantity
						FROM tblLGLoadDetail
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
								EXEC uspCTUpdateScheduleQuantityUsingUOM @intContractDetailId = @intContractDetailId
									,@dblQuantityToUpdate = @dblDiffQty
									,@intUserId = @intEntityId
									,@intExternalId = @intLoadDetailId
									,@strScreenName = 'Load Schedule'
									,@intSourceItemUOMId = @intItemUOMId
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

			-- Load Container
			IF ISNULL(@ysnPosted, 0) = 0
				AND EXISTS (
					SELECT 1
					FROM tblIPLoadContainerStage
					WHERE intStageLoadId = @intMinRowNo
					)
				AND (
					@strRowState = 'Added'
					OR @strRowState = 'Modified'
					)
			BEGIN
				SELECT @strDeliveryNoticeNumber = NULL
					,@intSubLocationId = NULL
					,@intStorageLocationId = NULL
					,@intSort = 0

				DELETE
				FROM @tblLGLoadContainer

				DELETE
				FROM @tblLGLoadContainerChanges

				DELETE
				FROM @tblLGLoadContainerOrg

				INSERT INTO @tblLGLoadContainerOrg (
					intLoadContainerId
					,strContainerNumber
					)
				SELECT LC.intLoadContainerId
					,LC.strContainerNumber
				FROM tblLGLoadContainer LC
				WHERE LC.intLoadId = @intLoadId

				INSERT INTO @tblLGLoadContainerChanges (
					intLoadContainerId
					,strAction
					,strContainerNumber
					,dblOldCONQuantity
					,dblOldGrossWt
					,dblOldTareWt
					,dblOldNetWt
					)
				SELECT LC.intLoadContainerId
					,'Updated'
					,LC.strContainerNumber
					,LC.dblQuantity
					,LC.dblGrossWt
					,LC.dblTareWt
					,LC.dblNetWt
				FROM tblLGLoadContainer LC
				WHERE LC.intLoadId = @intLoadId

				INSERT INTO @tblLGLoadContainer (intStageLoadContainerId)
				SELECT intStageLoadContainerId
				FROM tblIPLoadContainerStage
				WHERE intStageLoadId = @intMinRowNo

				SELECT @intStageLoadContainerId = MIN(intStageLoadContainerId)
				FROM @tblLGLoadContainer

				WHILE @intStageLoadContainerId IS NOT NULL
				BEGIN
					SELECT @strContainerNumber = NULL
						,@dblGrossWt = NULL
						,@dblTareWt = NULL
						,@dblCONQuantity = NULL
						,@intLoadContainerId = NULL

					SELECT @intCONUnitMeasureId = NULL
						,@intCONWeightUnitMeasureId = NULL

					SELECT @strContainerNumber = strContainerNumber
						,@dblGrossWt = ISNULL(dblGrossWt, 0)
						,@dblTareWt = ISNULL(dblTareWt, 0)
						,@dblCONQuantity = ISNULL(dblQuantity, 0)
					FROM tblIPLoadContainerStage
					WHERE intStageLoadContainerId = @intStageLoadContainerId

					--IF @strRowState = 'Added'
					--BEGIN
					--	IF EXISTS (
					--			SELECT 1
					--			FROM tblLGLoadContainer t WITH (NOLOCK)
					--			WHERE t.strContainerNumber = @strContainerNumber
					--			)
					--	BEGIN
					--		SET @ErrMsg = 'Container No. ' + @strContainerNumber + ' already exists. '

					--		RAISERROR (
					--				@ErrMsg
					--				,16
					--				,1
					--				)
					--	END
					--END

					IF @dblGrossWt <= 0
					BEGIN
						RAISERROR (
								'Invalid Gross Weight. '
								,16
								,1
								)
					END

					IF @dblCONQuantity <= 0
					BEGIN
						RAISERROR (
								'Invalid Container Quantity. '
								,16
								,1
								)
					END

					SELECT @intCONUnitMeasureId = IUOM.intUnitMeasureId
						,@intCONWeightUnitMeasureId = IUOM1.intUnitMeasureId
						,@intItemUOMId = CD.intItemUOMId
					FROM tblCTContractDetail CD WITH (NOLOCK)
					JOIN tblICItemUOM IUOM ON IUOM.intItemUOMId = CD.intItemUOMId
						AND CD.intContractDetailId = @intContractDetailId
					JOIN tblICItemUOM IUOM1 ON IUOM1.intItemUOMId = CD.intNetWeightUOMId

					IF @strRowState = 'Added'
					BEGIN
						SELECT @intSort = @intSort + 1

						INSERT INTO tblLGLoadContainer (
							intConcurrencyId
							,intLoadId
							,strContainerNumber
							,dblQuantity
							,intUnitMeasureId
							,dblGrossWt
							,dblTareWt
							,dblNetWt
							,intWeightUnitMeasureId
							,ysnNewContainer
							,intSort
							)
						SELECT 1
							,@intLoadId
							,@strContainerNumber
							,@dblCONQuantity
							,@intCONUnitMeasureId
							,@dblGrossWt
							,@dblTareWt
							,(@dblGrossWt - @dblTareWt)
							,@intCONWeightUnitMeasureId
							,1
							,@intSort

						SELECT @intLoadContainerId = SCOPE_IDENTITY()

						-- Load Detail Container Link
						INSERT INTO tblLGLoadDetailContainerLink (
							intConcurrencyId
							,intLoadId
							,intLoadContainerId
							,intLoadDetailId
							,dblQuantity
							,intItemUOMId
							,dblReceivedQty
							,dblLinkGrossWt
							,dblLinkTareWt
							,dblLinkNetWt
							,strExternalContainerId
							)
						SELECT 1
							,LC.intLoadId
							,LC.intLoadContainerId
							,LD.intLoadDetailId
							,LC.dblQuantity
							,LD.intItemUOMId
							,NULL
							,LC.dblGrossWt
							,LC.dblTareWt
							,LC.dblNetWt
							,NULL
						FROM tblLGLoadContainer LC
						JOIN tblLGLoadDetail LD ON LD.intLoadId = LC.intLoadId
							AND LC.intLoadId = @intLoadId
							AND LC.intLoadContainerId = @intLoadContainerId

						-- Load Warehouse
						IF NOT EXISTS (
								SELECT 1
								FROM tblLGLoadWarehouse
								WHERE intLoadId = @intLoadId
								)
						BEGIN
							SELECT @intSubLocationId = intSubLocationId
								,@intStorageLocationId = intStorageLocationId
							FROM tblCTContractDetail
							WHERE intContractDetailId = @intContractDetailId

							EXEC uspSMGetStartingNumber 86
								,@strDeliveryNoticeNumber OUT

							INSERT INTO tblLGLoadWarehouse (
								intConcurrencyId
								,intLoadId
								,strDeliveryNoticeNumber
								,dtmDeliveryNoticeDate
								,intSubLocationId
								,intStorageLocationId
								)
							SELECT 1
								,@intLoadId
								,@strDeliveryNoticeNumber
								,GETDATE()
								,@intSubLocationId
								,@intStorageLocationId
						END

						-- Load Warehouse Container
						INSERT INTO tblLGLoadWarehouseContainer (
							intConcurrencyId
							,intLoadWarehouseId
							,intLoadContainerId
							)
						SELECT TOP 1 1
							,LW.intLoadWarehouseId
							,@intLoadContainerId
						FROM tblLGLoadWarehouse LW
						WHERE intLoadId = @intLoadId
					END
					ELSE
					BEGIN
						SELECT @intLoadContainerId = intLoadContainerId
						FROM tblLGLoadContainer
						WHERE intLoadId = @intLoadId
							AND strContainerNumber = @strContainerNumber

						IF ISNULL(@intLoadContainerId, 0) > 0
						BEGIN
							UPDATE tblLGLoadContainer
							SET intConcurrencyId = intConcurrencyId + 1
								,dblQuantity = @dblCONQuantity
								,intUnitMeasureId = @intCONUnitMeasureId
								,dblGrossWt = @dblGrossWt
								,dblTareWt = @dblTareWt
								,dblNetWt = (@dblGrossWt - @dblTareWt)
								,intWeightUnitMeasureId = @intCONWeightUnitMeasureId
							WHERE intLoadContainerId = @intLoadContainerId

							UPDATE tblLGLoadDetailContainerLink
							SET intConcurrencyId = intConcurrencyId + 1
								,dblQuantity = @dblCONQuantity
								,intItemUOMId = @intItemUOMId
								,dblLinkGrossWt = @dblGrossWt
								,dblLinkTareWt = @dblTareWt
								,dblLinkNetWt = (@dblGrossWt - @dblTareWt)
							WHERE intLoadContainerId = @intLoadContainerId
						END
						ELSE
						BEGIN
							SELECT @intSort = ISNULL(MAX(intSort), 0) + 1
							FROM tblLGLoadContainer
							WHERE intLoadId = @intLoadId

							INSERT INTO tblLGLoadContainer (
								intConcurrencyId
								,intLoadId
								,strContainerNumber
								,dblQuantity
								,intUnitMeasureId
								,dblGrossWt
								,dblTareWt
								,dblNetWt
								,intWeightUnitMeasureId
								,ysnNewContainer
								,intSort
								)
							SELECT 1
								,@intLoadId
								,@strContainerNumber
								,@dblCONQuantity
								,@intCONUnitMeasureId
								,@dblGrossWt
								,@dblTareWt
								,(@dblGrossWt - @dblTareWt)
								,@intCONWeightUnitMeasureId
								,1
								,@intSort

							SELECT @intLoadContainerId = SCOPE_IDENTITY()

							-- Load Detail Container Link
							INSERT INTO tblLGLoadDetailContainerLink (
								intConcurrencyId
								,intLoadId
								,intLoadContainerId
								,intLoadDetailId
								,dblQuantity
								,intItemUOMId
								,dblReceivedQty
								,dblLinkGrossWt
								,dblLinkTareWt
								,dblLinkNetWt
								,strExternalContainerId
								)
							SELECT 1
								,LC.intLoadId
								,LC.intLoadContainerId
								,LD.intLoadDetailId
								,LC.dblQuantity
								,LD.intItemUOMId
								,NULL
								,LC.dblGrossWt
								,LC.dblTareWt
								,LC.dblNetWt
								,NULL
							FROM tblLGLoadContainer LC
							JOIN tblLGLoadDetail LD ON LD.intLoadId = LC.intLoadId
								AND LC.intLoadId = @intLoadId
								AND LC.intLoadContainerId = @intLoadContainerId

							-- Load Warehouse
							IF NOT EXISTS (
									SELECT 1
									FROM tblLGLoadWarehouse
									WHERE intLoadId = @intLoadId
									)
							BEGIN
								SELECT @intSubLocationId = intSubLocationId
									,@intStorageLocationId = intStorageLocationId
								FROM tblCTContractDetail
								WHERE intContractDetailId = @intContractDetailId

								EXEC uspSMGetStartingNumber 86
									,@strDeliveryNoticeNumber OUT

								INSERT INTO tblLGLoadWarehouse (
									intConcurrencyId
									,intLoadId
									,strDeliveryNoticeNumber
									,dtmDeliveryNoticeDate
									,intSubLocationId
									,intStorageLocationId
									)
								SELECT 1
									,@intLoadId
									,@strDeliveryNoticeNumber
									,GETDATE()
									,@intSubLocationId
									,@intStorageLocationId
							END

							-- Load Warehouse Container
							INSERT INTO tblLGLoadWarehouseContainer (
								intConcurrencyId
								,intLoadWarehouseId
								,intLoadContainerId
								)
							SELECT TOP 1 1
								,LW.intLoadWarehouseId
								,@intLoadContainerId
							FROM tblLGLoadWarehouse LW
							WHERE intLoadId = @intLoadId
						END
					END

					SELECT @intStageLoadContainerId = MIN(intStageLoadContainerId)
					FROM @tblLGLoadContainer
					WHERE intStageLoadContainerId > @intStageLoadContainerId
				END

				-- Delete the containers which are available in i21 but not in the XML
				DELETE
				FROM @tblDeleteContainer

				INSERT INTO @tblDeleteContainer (intLoadContainerId)
				SELECT LC.intLoadContainerId
				FROM tblLGLoadContainer LC
				WHERE LC.intLoadId = @intLoadId
					AND NOT EXISTS (
						SELECT 1
						FROM tblIPLoadContainerStage LCS
						WHERE LCS.intStageLoadId = @intMinRowNo
							AND LCS.strContainerNumber = LC.strContainerNumber
						)

				DELETE LWC
				FROM tblLGLoadWarehouseContainer LWC
				JOIN @tblDeleteContainer DEL ON DEL.intLoadContainerId = LWC.intLoadContainerId

				DELETE LCL
				FROM tblLGLoadDetailContainerLink LCL
				JOIN @tblDeleteContainer DEL ON DEL.intLoadContainerId = LCL.intLoadContainerId
					AND LCL.intLoadId = @intLoadId

				DELETE LC
				FROM tblLGLoadContainer LC
				JOIN @tblDeleteContainer DEL ON DEL.intLoadContainerId = LC.intLoadContainerId
					AND LC.intLoadId = @intLoadId

				INSERT INTO @tblLGLoadContainerChanges (
					intLoadContainerId
					,strContainerNumber
					,strAction
					)
				SELECT LC.intLoadContainerId
					,LC.strContainerNumber
					,'Created'
				FROM tblLGLoadContainer LC
				WHERE intLoadId = @intLoadId
					AND NOT EXISTS (
						SELECT 1
						FROM @tblLGLoadContainerOrg LCS
						WHERE LCS.intLoadContainerId = LC.intLoadContainerId
						)

				UPDATE @tblLGLoadContainerChanges
				SET strAction = 'Deleted'
				FROM @tblLGLoadContainerChanges OLD
				JOIN @tblDeleteContainer DEL ON DEL.intLoadContainerId = OLD.intLoadContainerId

				UPDATE @tblLGLoadContainerChanges
				SET dblNewCONQuantity = LC.dblQuantity
					,dblNewGrossWt = LC.dblGrossWt
					,dblNewTareWt = LC.dblTareWt
					,dblNewNetWt = LC.dblNetWt
				FROM @tblLGLoadContainerChanges OLD
				JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = OLD.intLoadContainerId

				-- Load Container Audit Log
				IF @strRowState = 'Modified'
				BEGIN
					DECLARE @Condetails NVARCHAR(MAX) = ''
						,@AllCondetails NVARCHAR(MAX) = ''

					-- DROP TABLE tblLGLoadContainerChangesTest
					--SELECT * INTO tblLGLoadContainerChangesTest FROM @tblLGLoadContainerChanges
					WHILE EXISTS (
							SELECT TOP 1 NULL
							FROM @tblLGLoadContainerChanges
							WHERE strAction = 'Updated'
							)
					BEGIN
						SELECT @intAuditLoadContainerId = NULL
							,@strAuditContainerNumber = NULL
							,@dblNewCONQuantity = NULL
							,@dblOldCONQuantity = NULL
							,@dblNewGrossWt = NULL
							,@dblOldGrossWt = NULL
							,@dblNewTareWt = NULL
							,@dblOldTareWt = NULL
							,@dblNewNetWt = NULL
							,@dblOldNetWt = NULL
							,@Condetails = NULL

						SELECT TOP 1 @intAuditLoadContainerId = intLoadContainerId
							,@strAuditContainerNumber = strContainerNumber
							,@dblNewCONQuantity = dblNewCONQuantity
							,@dblOldCONQuantity = dblOldCONQuantity
							,@dblNewGrossWt = dblNewGrossWt
							,@dblOldGrossWt = dblOldGrossWt
							,@dblNewTareWt = dblNewTareWt
							,@dblOldTareWt = dblOldTareWt
							,@dblNewNetWt = dblNewNetWt
							,@dblOldNetWt = dblOldNetWt
						FROM @tblLGLoadContainerChanges
						WHERE strAction = 'Updated'

						SET @Condetails = '{  
								"action":"Updated",
								"change":"Updated - Record: ' + LTRIM(@intLoadId) + '",
								"keyValue":' + LTRIM(@intLoadId) + ',
								"iconCls":"small-tree-modified",
								"children":[  
									{  
										"change":"tblLGLoadContainers",
										"children":[  
											{  
											"action":"Updated",
											"change":"Updated - Record: ' + LTRIM(@strAuditContainerNumber) + '",
											"keyValue":' + LTRIM(@intAuditLoadContainerId) + ',
											"iconCls":"small-tree-modified",
											"children":
												[   
													'

						IF @dblOldCONQuantity <> @dblNewCONQuantity
							SET @Condetails = @Condetails + '
													{  
													"change":"dblQuantity",
													"from":"' + LTRIM(@dblOldCONQuantity) + '",
													"to":"' + LTRIM(@dblNewCONQuantity) + '",
													"leaf":true,
													"iconCls":"small-gear",
													"isField":true,
													"keyValue":' + LTRIM(@intAuditLoadContainerId) + ',
													"associationKey":"tblLGLoadContainers",
													"changeDescription":"Quantity",
													"hidden":false
													},'

						IF @dblOldGrossWt <> @dblNewGrossWt
							SET @Condetails = @Condetails + '
													{  
													"change":"dblGrossWt",
													"from":"' + LTRIM(@dblOldGrossWt) + '",
													"to":"' + LTRIM(@dblNewGrossWt) + '",
													"leaf":true,
													"iconCls":"small-gear",
													"isField":true,
													"keyValue":' + LTRIM(@intAuditLoadContainerId) + ',
													"associationKey":"tblLGLoadContainers",
													"changeDescription":"Gross Wt.",
													"hidden":false
													},'

						IF @dblOldTareWt <> @dblNewTareWt
							SET @Condetails = @Condetails + '
													{  
													"change":"dblTareWt",
													"from":"' + LTRIM(@dblOldTareWt) + '",
													"to":"' + LTRIM(@dblNewTareWt) + '",
													"leaf":true,
													"iconCls":"small-gear",
													"isField":true,
													"keyValue":' + LTRIM(@intAuditLoadContainerId) + ',
													"associationKey":"tblLGLoadContainers",
													"changeDescription":"Tare Wt.",
													"hidden":false
													},'

						IF @dblOldNetWt <> @dblNewNetWt
							SET @Condetails = @Condetails + '
													{  
													"change":"dblNetWt",
													"from":"' + LTRIM(@dblOldNetWt) + '",
													"to":"' + LTRIM(@dblNewNetWt) + '",
													"leaf":true,
													"iconCls":"small-gear",
													"isField":true,
													"keyValue":' + LTRIM(@intAuditLoadContainerId) + ',
													"associationKey":"tblLGLoadContainers",
													"changeDescription":"Net Wt.",
													"hidden":false
													},'

						IF RIGHT(@Condetails, 1) = ','
							SET @Condetails = SUBSTRING(@Condetails, 0, LEN(@Condetails))
						SET @Condetails = @Condetails + '
											]
										}
									],
									"iconCls":"small-tree-grid",
									"changeDescription":"Container Information"
									}
								]
								}'

						IF @dblOldCONQuantity <> @dblNewCONQuantity
							OR @dblOldGrossWt <> @dblNewGrossWt
							OR @dblOldTareWt <> @dblNewTareWt
							OR @dblOldNetWt <> @dblNewNetWt
						BEGIN
							EXEC uspSMAuditLog @keyValue = @intLoadId
								,@screenName = 'Logistics.view.ShipmentSchedule'
								,@entityId = @intEntityId
								,@actionType = 'Updated'
								,@actionIcon = 'small-tree-modified'
								,@details = @Condetails
						END

						DELETE
						FROM @tblLGLoadContainerChanges
						WHERE intLoadContainerId = @intAuditLoadContainerId
					END

					-- Audit Log for Inserted / Deleted Cotainers
					WHILE EXISTS (
							SELECT TOP 1 NULL
							FROM @tblLGLoadContainerChanges
							WHERE strAction <> 'Updated'
							)
					BEGIN
						SELECT @intAuditLoadContainerId = NULL
							,@strAuditContainerNumber = NULL
							,@strAction = NULL

						SELECT TOP 1 @intAuditLoadContainerId = intLoadContainerId
							,@strAuditContainerNumber = strContainerNumber
							,@strAction = strAction
						FROM @tblLGLoadContainerChanges
						WHERE strAction <> 'Updated'

						IF @strAction = 'Created'
							SET @AllCondetails = @AllCondetails + '
													{  
													"action":"Created",
													"change":"Created - Record: ' + LTRIM(@strAuditContainerNumber) + '",
													"keyValue":' + LTRIM(@intAuditLoadContainerId) + ',
													"iconCls":"small-new-plus",
													"leaf": true
													},'

						IF @strAction = 'Deleted'
							SET @AllCondetails = @AllCondetails + '
													{  
													"action":"Deleted",
													"change":"Deleted - Record: ' + LTRIM(@strAuditContainerNumber) + '",
													"keyValue":' + LTRIM(@intAuditLoadContainerId) + ',
													"iconCls":"small-new-minus",
													"leaf": true
													},'

						DELETE
						FROM @tblLGLoadContainerChanges
						WHERE intLoadContainerId = @intAuditLoadContainerId
					END

					IF ISNULL(@AllCondetails, '') <> ''
					BEGIN
						IF RIGHT(@AllCondetails, 1) = ','
							SET @AllCondetails = SUBSTRING(@AllCondetails, 0, LEN(@AllCondetails))

						SET @Condetails = '{  
								"action":"Updated",
								"change":"Updated - Record: ' + LTRIM(@intLoadId) + '",
								"keyValue":' + LTRIM(@intLoadId) + ',
								"iconCls":"small-tree-modified",
								"children":[  
									{  
										"change":"tblLGLoadContainers",
										"children":[  
													'
						SET @Condetails = @Condetails + @AllCondetails
						SET @Condetails = @Condetails + '
									],
									"iconCls":"small-tree-grid",
									"changeDescription":"Container Information"
									}
								]
								}'

						BEGIN
							EXEC uspSMAuditLog @keyValue = @intLoadId
								,@screenName = 'Logistics.view.ShipmentSchedule'
								,@entityId = @intEntityId
								,@actionType = 'Updated'
								,@actionIcon = 'small-tree-modified'
								,@details = @Condetails
						END
					END
				END
			END

			IF ISNULL(@ysnPosted, 0) = 1
				AND EXISTS (
					SELECT 1
					FROM tblIPLoadContainerStage
					WHERE intStageLoadId = @intMinRowNo
					)
			BEGIN
				SELECT @strContainerErrMsg = ''

				-- Container table with Staging container table
				IF EXISTS (
					SELECT strContainerNumber
						,ISNULL(dblQuantity, 0) dblQuantity
						,ISNULL(dblGrossWt, 0) dblGrossWt
						,ISNULL(dblTareWt, 0) dblTareWt
					FROM tblLGLoadContainer LC
					WHERE LC.intLoadId = @intLoadId

					EXCEPT

					SELECT strContainerNumber
						,ISNULL(dblQuantity, 0) dblQuantity
						,ISNULL(dblGrossWt, 0) dblGrossWt
						,ISNULL(dblTareWt, 0) dblTareWt
					FROM tblIPLoadContainerStage
					WHERE intStageLoadId = @intMinRowNo
					)
				BEGIN
					SELECT @strContainerErrMsg = 'Container mismatch is there. '
				END

				-- Staging container table with Container table
				IF EXISTS (
					SELECT strContainerNumber
						,ISNULL(dblQuantity, 0) dblQuantity
						,ISNULL(dblGrossWt, 0) dblGrossWt
						,ISNULL(dblTareWt, 0) dblTareWt
					FROM tblIPLoadContainerStage
					WHERE intStageLoadId = @intMinRowNo

					EXCEPT

					SELECT strContainerNumber
						,ISNULL(dblQuantity, 0) dblQuantity
						,ISNULL(dblGrossWt, 0) dblGrossWt
						,ISNULL(dblTareWt, 0) dblTareWt
					FROM tblLGLoadContainer LC
					WHERE LC.intLoadId = @intLoadId
					)
				BEGIN
					SELECT @strContainerErrMsg = 'Container mismatch is there. '
				END
			END

			-- To set Contract Planned Availability Date and send Contract feed to SAP
			-- Also it sends Shipment feed to SAP
			IF @strRowState = 'Added'
				OR @strRowState = 'Modified'
			BEGIN
				EXEC uspLGCreateLoadIntegrationLog @intLoadId = @intLoadId
					,@strRowState = @strRowState
					,@intShipmentType = 1 -- LS
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
				,strBLNumber
				,dtmBLDate
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strLoadNumber
				,strAction
				,strFileName
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				,strInternalErrorMessage
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
				,strBLNumber
				,dtmBLDate
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strLoadNumber
				,strAction
				,strFileName
				,strTransactionType
				,''
				,'Success'
				,strSessionId
				,@strContainerErrMsg
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

			INSERT INTO tblIPLoadContainerArchive (
				intStageLoadId
				,strCustomerReference
				,strContainerNumber
				,strContainerType
				,dblGrossWt
				,dblTareWt
				,dblQuantity
				)
			SELECT @intNewStageLoadId
				,strCustomerReference
				,strContainerNumber
				,strContainerType
				,dblGrossWt
				,dblTareWt
				,dblQuantity
			FROM tblIPLoadContainerStage
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
				,strBLNumber
				,dtmBLDate
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strLoadNumber
				,strAction
				,strFileName
				,strTransactionType
				,strErrorMessage
				,strImportStatus
				,strSessionId
				,strInternalErrorMessage
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
				,strBLNumber
				,dtmBLDate
				,strShippingLine
				,strMVessel
				,strMVoyageNumber
				,strShippingMode
				,intNumberOfContainers
				,strContainerType
				,strLoadNumber
				,strAction
				,strFileName
				,strTransactionType
				,@ErrMsg
				,'Failed'
				,strSessionId
				,@strContainerErrMsg
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

			INSERT INTO tblIPLoadContainerError (
				intStageLoadId
				,strCustomerReference
				,strContainerNumber
				,strContainerType
				,dblGrossWt
				,dblTareWt
				,dblQuantity
				)
			SELECT @intNewStageLoadId
				,strCustomerReference
				,strContainerNumber
				,strContainerType
				,dblGrossWt
				,dblTareWt
				,dblQuantity
			FROM tblIPLoadContainerStage
			WHERE intStageLoadId = @intMinRowNo

			DELETE
			FROM tblIPLoadStage
			WHERE intStageLoadId = @intMinRowNo
		END CATCH

		SELECT @intMinRowNo = Min(intStageLoadId)
		FROM tblIPLoadStage WITH (NOLOCK)
		WHERE intStageLoadId > @intMinRowNo
			AND ISNULL(strTransactionType, '') = 'Shipment'
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
