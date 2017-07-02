﻿CREATE PROCEDURE uspLGLoadContractCopy @intOldLoadDetailId INT
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

	SELECT @intOldLoadId = intLoadId
	FROM tblLGLoadDetail
	WHERE intLoadDetailId = @intOldLoadDetailId

	EXEC uspSMGetStartingNumber 106
		,@strLoadSINumber OUTPUT
		,NULL

	INSERT INTO tblLGLoad (
		intConcurrencyId
		,strLoadNumber
		,intCompanyLocationId
		,intPurchaseSale
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
		)
	SELECT 1
		,@strLoadSINumber
		,intCompanyLocationId
		,intPurchaseSale
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
		,NULL
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
		,intPCompanyLocationId
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
		,intPSubLocationId
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
