CREATE PROCEDURE uspLGLoadContractCopy @intOldLoadDetailId INT
	,@intNewContractDetailId INT
	,@dblNewLoadDetailQuantity NUMERIC(18, 6)
	,@intNewLoadDetailItemUOMId INT
	,@intUserId INT
AS
BEGIN TRY

	DECLARE @strErrMsg NVARCHAR(MAX)
	DECLARE @strLoadSINumber NVARCHAR(MAX)
	DECLARE @intNewLoadId INT
	DECLARE @intOldLoadId INT
	DECLARE @intNewContractLocationId INT
	DECLARE @intNewContractSubLocationId INT
	DECLARE @intNewContractStorageLocationId INT
	DECLARE @intNewLoadingPortId INT
	DECLARE @intNewDestinationPortId INT
	DECLARE @intNewDestinationCityId INT
	DECLARE @strNewLoadingPort NVARCHAR(100)
	DECLARE @strNewDestinationPort NVARCHAR(100)
	DECLARE @strNewDestinationCity NVARCHAR(100)

	SELECT @intOldLoadId = intLoadId
	FROM tblLGLoadDetail
	WHERE intLoadDetailId = @intOldLoadDetailId

	SELECT @intNewContractLocationId = intCompanyLocationId, 
		   @intNewContractSubLocationId =  intSubLocationId, 
		   @intNewLoadingPortId =  intLoadingPortId, 
		   @intNewDestinationPortId = intDestinationPortId,
		   @intNewContractStorageLocationId = intStorageLocationId,
		   @intNewDestinationCityId = intDestinationCityId
	FROM tblCTContractDetail 
	WHERE intContractDetailId = @intNewContractDetailId

	SELECT @strNewLoadingPort = strCity 
	FROM tblSMCity 
	WHERE intCityId = @intNewLoadingPortId

	SELECT @strNewDestinationPort = strCity 
	FROM tblSMCity 
	WHERE intCityId = @intNewDestinationPortId

	SELECT @strNewDestinationCity = strCity 
	FROM tblSMCity 
	WHERE intCityId = @intNewDestinationCityId

	EXEC uspSMGetStartingNumber 106
		,@strLoadSINumber OUTPUT
		,NULL

	INSERT INTO tblLGLoad (
		intConcurrencyId
		,strLoadNumber
		,intCompanyLocationId
		,intPurchaseSale
		,intFreightTermId
		,intCurrencyId
		,dtmScheduledDate
		,strCustomerReference
		,strBookingReference
		,intEquipmentTypeId
		,intEntityId
		,intEntityLocationId
		,strComments
		,intHaulerEntityId
		,intTicketId
		,ysnInProgress
		,dblDeliveredQuantity
		,dtmDeliveredDate
		,intGenerateLoadId
		,intGenerateSequence
		,strTruckNo
		,strTrailerNo1
		,strTrailerNo2
		,strTrailerNo3
		,strCarNumber
		,strEmbargoNo
		,strEmbargoPermitNo
		,intUserSecurityId
		,strExternalLoadNumber
		,intTransportLoadId
		,intDriverEntityId
		,ysnDispatched
		,dtmDispatchedDate
		,intDispatcherId
		,ysnDispatchMailSent
		,dtmDispatchMailSent
		,dtmCancelDispatchMailSent
		,intLoadHeaderId
		,intSourceType
		,intPositionId
		,intWeightUnitMeasureId
		,strBLNumber
		,dtmBLDate
		,strOriginPort
		,strDestinationPort
		,strDestinationCity
		,intTerminalEntityId
		,intShippingLineEntityId
		,strServiceContractNumber
		,strPackingDescription
		,strMVessel
		,strMVoyageNumber
		,strFVessel
		,strFVoyageNumber
		,intForwardingAgentEntityId
		,strForwardingAgentRef
		,intInsurerEntityId
		,dblInsuranceValue
		,intInsuranceCurrencyId
		,dtmDocsToBroker
		,strMarks
		,strMarkingInstructions
		,strShippingMode
		,intNumberOfContainers
		,intContainerTypeId
		,intBLDraftToBeSentId
		,strBLDraftToBeSentType
		,strDocPresentationType
		,intDocPresentationId
		,dtmDocsReceivedDate
		,dtmETAPOL
		,dtmETSPOL
		,dtmETAPOD
		,dtmDeadlineCargo
		,dtmDeadlineBL
		,dtmISFReceivedDate
		,dtmISFFiledDate
		,dtmStuffingDate
		,dtmStartDate
		,dtmEndDate
		,dtmPlannedAvailabilityDate
		,strVessel1
		,strOriginPort1
		,strDestinationPort1
		,dtmETSPOL1
		,dtmETAPOD1
		,strVessel2
		,strOriginPort2
		,strDestinationPort2
		,dtmETSPOL2
		,dtmETAPOD2
		,strVessel3
		,strOriginPort3
		,strDestinationPort3
		,dtmETSPOL3
		,dtmETAPOD3
		,strVessel4
		,strOriginPort4
		,strDestinationPort4
		,dtmETSPOL4
		,dtmETAPOD4
		,dblDemurrage
		,intDemurrageCurrencyId
		,dblDespatch
		,intDespatchCurrencyId
		,dblLoadingRate
		,intLoadingUnitMeasureId
		,strLoadingPerUnit
		,dblDischargeRate
		,intDischargeUnitMeasureId
		,strDischargePerUnit
		,intTransportationMode
		,intShipmentStatus
		,ysnPosted
		,dtmPostedDate
		,intTransUsedBy
		,intShipmentType
		,intLoadShippingInstructionId
		,strExternalShipmentNumber
		,ysnLoadBased
		)
	SELECT 1
		,@strLoadSINumber
		,@intNewContractLocationId
		,intPurchaseSale
		,intFreightTermId
		,intCurrencyId
		,dtmScheduledDate
		,strCustomerReference
		,strBookingReference
		,intEquipmentTypeId
		,intEntityId
		,intEntityLocationId
		,strComments
		,intHaulerEntityId
		,intTicketId
		,ysnInProgress
		,dblDeliveredQuantity
		,dtmDeliveredDate
		,intGenerateLoadId
		,intGenerateSequence
		,strTruckNo
		,strTrailerNo1
		,strTrailerNo2
		,strTrailerNo3
		,strCarNumber
		,strEmbargoNo
		,strEmbargoPermitNo
		,intUserSecurityId
		,strExternalLoadNumber
		,intTransportLoadId
		,intDriverEntityId
		,ysnDispatched
		,dtmDispatchedDate
		,intDispatcherId
		,ysnDispatchMailSent
		,dtmDispatchMailSent
		,dtmCancelDispatchMailSent
		,intLoadHeaderId
		,intSourceType
		,intPositionId
		,intWeightUnitMeasureId
		,strBLNumber
		,dtmBLDate
		,@strNewLoadingPort
		,@strNewDestinationPort
		,@strNewDestinationCity
		,intTerminalEntityId
		,intShippingLineEntityId
		,strServiceContractNumber
		,strPackingDescription
		,strMVessel
		,strMVoyageNumber
		,strFVessel
		,strFVoyageNumber
		,intForwardingAgentEntityId
		,strForwardingAgentRef
		,intInsurerEntityId
		,dblInsuranceValue
		,intInsuranceCurrencyId
		,dtmDocsToBroker
		,strMarks
		,strMarkingInstructions
		,strShippingMode
		,intNumberOfContainers
		,intContainerTypeId
		,intBLDraftToBeSentId
		,strBLDraftToBeSentType
		,strDocPresentationType
		,intDocPresentationId
		,dtmDocsReceivedDate
		,dtmETAPOL
		,dtmETSPOL
		,dtmETAPOD
		,dtmDeadlineCargo
		,dtmDeadlineBL
		,dtmISFReceivedDate
		,dtmISFFiledDate
		,dtmStuffingDate
		,dtmStartDate
		,dtmEndDate
		,dtmPlannedAvailabilityDate
		,strVessel1
		,strOriginPort1
		,strDestinationPort1
		,dtmETSPOL1
		,dtmETAPOD1
		,strVessel2
		,strOriginPort2
		,strDestinationPort2
		,dtmETSPOL2
		,dtmETAPOD2
		,strVessel3
		,strOriginPort3
		,strDestinationPort3
		,dtmETSPOL3
		,dtmETAPOD3
		,strVessel4
		,strOriginPort4
		,strDestinationPort4
		,dtmETSPOL4
		,dtmETAPOD4
		,dblDemurrage
		,intDemurrageCurrencyId
		,dblDespatch
		,intDespatchCurrencyId
		,dblLoadingRate
		,intLoadingUnitMeasureId
		,strLoadingPerUnit
		,dblDischargeRate
		,intDischargeUnitMeasureId
		,strDischargePerUnit
		,intTransportationMode
		,intShipmentStatus = CASE WHEN (intShipmentType = 2) THEN 7 ELSE 1 END 
		,ysnPosted
		,dtmPostedDate
		,intTransUsedBy
		,intShipmentType
		,intLoadShippingInstructionId
		,NULL
		,ysnLoadBased
	FROM tblLGLoad
	WHERE intLoadId = @intOldLoadId

	SELECT @intNewLoadId = SCOPE_IDENTITY()

	INSERT INTO tblLGLoadDetail (
		intConcurrencyId
		,intLoadId
		,intVendorEntityId
		,intVendorEntityLocationId
		,intCustomerEntityId
		,intCustomerEntityLocationId
		,intItemId
		,intPContractDetailId
		,intSContractDetailId
		,intPCompanyLocationId
		,intSCompanyLocationId
		,dblQuantity
		,intItemUOMId
		,dblGross
		,dblTare
		,dblNet
		,intWeightItemUOMId
		,dblDeliveredQuantity
		,dblDeliveredGross
		,dblDeliveredTare
		,dblDeliveredNet
		,strLotAlias
		,strSupplierLotNumber
		,dtmProductionDate
		,strScheduleInfoMsg
		,ysnUpdateScheduleInfo
		,ysnPrintScheduleInfo
		,strLoadDirectionMsg
		,ysnUpdateLoadDirections
		,ysnPrintLoadDirections
		,strVendorReference
		,strCustomerReference
		,intAllocationDetailId
		,intPickLotDetailId
		,intPSubLocationId
		,intSSubLocationId
		,strExternalShipmentItemNumber
		,strExternalBatchNo
		)
	SELECT 1
		,@intNewLoadId
		,intVendorEntityId
		,intVendorEntityLocationId
		,intCustomerEntityId
		,intCustomerEntityLocationId
		,intItemId
		,@intNewContractDetailId
		,intSContractDetailId
		,@intNewContractLocationId
		,intSCompanyLocationId
		,@dblNewLoadDetailQuantity
		,intItemUOMId
		,dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,intWeightItemUOMId,@dblNewLoadDetailQuantity)
		,0
		,dbo.fnCTConvertQtyToTargetItemUOM(intItemUOMId,intWeightItemUOMId,@dblNewLoadDetailQuantity)
		,intWeightItemUOMId
		,dblDeliveredQuantity
		,dblDeliveredGross
		,dblDeliveredTare
		,dblDeliveredNet
		,strLotAlias
		,strSupplierLotNumber
		,dtmProductionDate
		,strScheduleInfoMsg
		,ysnUpdateScheduleInfo
		,ysnPrintScheduleInfo
		,strLoadDirectionMsg
		,ysnUpdateLoadDirections
		,ysnPrintLoadDirections
		,strVendorReference
		,strCustomerReference
		,intAllocationDetailId
		,intPickLotDetailId
		,@intNewContractSubLocationId
		,intSSubLocationId
		,NULL
		,NULL
	FROM tblLGLoadDetail
	WHERE intLoadDetailId = @intOldLoadDetailId

	IF EXISTS(SELECT 1 FROM tblLGLoadWarehouse WHERE intLoadId = @intOldLoadId)
	BEGIN
		INSERT INTO tblLGLoadWarehouse (
			 intLoadId
			,strDeliveryNoticeNumber
			,dtmDeliveryNoticeDate
			,intSubLocationId
			,intStorageLocationId
			,intHaulerEntityId
			,dtmPickupDate
			,dtmDeliveryDate
			,dtmLastFreeDate
			,dtmStrippingReportReceivedDate
			,dtmSampleAuthorizedDate
			,strStrippingReportComments
			,strFreightComments
			,strSampleComments
			,strOtherComments
			,intWarehouseRateMatrixHeaderId
			,intConcurrencyId
			)
		SELECT @intNewLoadId
			,strDeliveryNoticeNumber
			,dtmDeliveryNoticeDate
			,@intNewContractSubLocationId
			,@intNewContractStorageLocationId
			,intHaulerEntityId
			,dtmPickupDate
			,dtmDeliveryDate
			,dtmLastFreeDate
			,dtmStrippingReportReceivedDate
			,dtmSampleAuthorizedDate
			,strStrippingReportComments
			,strFreightComments
			,strSampleComments
			,strOtherComments
			,intWarehouseRateMatrixHeaderId
			,intConcurrencyId
		FROM tblLGLoadWarehouse WHERE intLoadId = @intOldLoadId
	END

	EXEC uspLGCreateLoadIntegrationLog @intNewLoadId,'Added',2

	IF (@intNewLoadId > 0)
	BEGIN
		DECLARE @StrDescription AS NVARCHAR(MAX) = 'Contract seq sliced.'

		EXEC uspSMAuditLog @keyValue = @intNewLoadId
			,@screenName = 'Logistics.view.ShipmentSchedule'
			,@entityId = @intUserId
			,@actionType = 'Created'
			,@actionIcon = 'small-new-plus'
			,@changeDescription = @StrDescription
			,@fromValue = ''
			,@toValue = @strLoadSINumber
	END

END TRY

BEGIN CATCH
	SET @strErrMsg = ERROR_MESSAGE()

	RAISERROR (@strErrMsg,16,1,'WITH NOWAIT'			)
END CATCH
