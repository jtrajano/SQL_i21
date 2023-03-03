CREATE PROCEDURE [dbo].[uspLGCreateLoadForDivertContainer]
	@intLoadId INT
	,@intEntityUserSecurityId INT
	,@intNewLoadId INT OUTPUT
AS
DECLARE @outputId AS Id
DECLARE @strLoadNumber NVARCHAR(100)
DECLARE @ysnIsPosted BIT

/* Check if there are any Container Quantity to Divert */
IF NOT EXISTS (SELECT 1 FROM tblLGLoadDetailContainerLink WHERE ISNULL(dblDivertQuantity, 0) > 0 AND intLoadId = @intLoadId)
BEGIN
	RAISERROR('No quantity specified for diversion.', 16, 1);
END

/* Check if any Divert Quantity exceeds quantity */
IF EXISTS (SELECT 1 FROM tblLGLoadDetailContainerLink WHERE ISNULL(dblDivertQuantity, 0) > dblQuantity AND intLoadId = @intLoadId)
BEGIN
	RAISERROR('Divert quantity cannot be greater than original quantity.', 16, 1);
END

/* Get Load Info */
SELECT
	@strLoadNumber = strLoadNumber
	,@ysnIsPosted = ysnPosted
FROM tblLGLoad 
WHERE intLoadId = @intLoadId

/* Generate New Load Number */
DECLARE @strNewLoadNumber NVARCHAR(100)
EXEC uspSMGetStartingNumber 39, @strNewLoadNumber OUTPUT

/* Append Serial Number to LS */
--DECLARE @intSerial INT = 1
--SELECT @strNewLoadNumber = strLoadNumber + '.' + CAST(@intSerial AS NVARCHAR(10)) FROM tblLGLoad WHERE intLoadId = @intLoadId

--WHILE EXISTS (SELECT 1 FROM tblLGLoad WHERE strLoadNumber = @strNewLoadNumber)
--BEGIN
--	IF (@intSerial < 20) --Loop Control, diversion shouldn't exceed 20
--	BEGIN
--		SELECT @strNewLoadNumber = @strLoadNumber + '.' + CAST(@intSerial AS NVARCHAR(10)), @intSerial = @intSerial + 1
--	END
--	ELSE
--	BEGIN
--		RAISERROR('Maximum number of diversions reached.', 16, 1);
--	END
--END

/* Unpost the Inbound (if posted) */
IF (@ysnIsPosted = 1)
	EXEC uspLGPostLoadSchedule @intLoadId, @intEntityUserSecurityId, 0, 0

/* Create New Drop Ship */
INSERT INTO tblLGLoad (
	strLoadNumber
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
	,dtmLoadExpiration
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
	,ysnLoadBased
	,intConcurrencyId
	,intLoadRefId)
OUTPUT inserted.intLoadId INTO @outputId(intId)
SELECT @strNewLoadNumber
	,intCompanyLocationId
	,intPurchaseSale = 3
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
	,intSourceType = 2
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
	,dtmLoadExpiration
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
	,intShipmentStatus = 1
	,ysnPosted = 0
	,dtmPostedDate = NULL
	,intTransUsedBy
	,intShipmentType
	,ysnLoadBased
	,intConcurrencyId = 1
	,intLoadRefId = intLoadId
FROM tblLGLoad
WHERE intLoadId = @intLoadId

IF EXISTS(SELECT TOP 1 1 FROM @outputId)
	SELECT TOP 1 @intNewLoadId = intId FROM @outputId

/* Get all Load Details where Divert Qty is specified */
SELECT 
	LD.intLoadDetailId
	,LD.intPContractDetailId
	,LD.dblQuantity
INTO #tmpLoadDetails 
FROM tblLGLoadDetail LD
CROSS APPLY 
	(SELECT dblTotalDivertQty = SUM(ISNULL(dblDivertQuantity, 0)) 
	FROM tblLGLoadDetailContainerLink
	WHERE intLoadDetailId = LD.intLoadDetailId
	AND ISNULL(dblDivertQuantity, 0) > 0) LDL
WHERE LD.intLoadId = @intLoadId AND LDL.dblTotalDivertQty > 0

/* Loop through all details */
DECLARE @intLoadDetailId INT = NULL
DECLARE @intPContractDetailId INT = NULL
DECLARE @dblDivertQuantity NUMERIC(18, 6) = NULL
DECLARE @intNewLoadDetailId INT = NULL
DECLARE @intNewLoadContainerId INT = NULL
WHILE EXISTS(SELECT TOP 1 1 FROM #tmpLoadDetails)
BEGIN
	SELECT @intNewLoadDetailId = NULL, @intNewLoadContainerId = NULL, @dblDivertQuantity = NULL
	SELECT TOP 1 
		@intLoadDetailId = intLoadDetailId 
		,@intPContractDetailId = intPContractDetailId
	FROM #tmpLoadDetails

	/* Create New Load Details */
	DELETE FROM @outputId
	INSERT INTO tblLGLoadDetail (
		intLoadId
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
		,strTerminalReference
		,intAllocationDetailId
		,intPickLotDetailId
		,intSellerId
		,intSalespersonId
		,intPSubLocationId
		,intSSubLocationId
		,intPStorageLocationId
		,intSStorageLocationId
		,strExternalShipmentItemNumber
		,strExternalBatchNo
		,intLoadDetailRefId
		,intConcurrencyId)
	OUTPUT inserted.intLoadDetailId INTO @outputId(intId)
	SELECT 
		intLoadId = @intNewLoadId
		,intVendorEntityId
		,intVendorEntityLocationId
		,intCustomerEntityId = NULL
		,intCustomerEntityLocationId = NULL
		,intItemId
		,intPContractDetailId
		,intSContractDetailId = NULL
		,intPCompanyLocationId
		,intSCompanyLocationId = NULL
		,dblQuantity = dblTotalDivertQty
		,intItemUOMId = LD.intItemUOMId
		,dblGross = dblTotalDivertQty * ISNULL(dbo.fnCalculateQtyBetweenUOM(LD.intItemUOMId, LD.intWeightItemUOMId, 1), 1)
		,dblTare = 0
		,dblNet = dblTotalDivertQty * ISNULL(dbo.fnCalculateQtyBetweenUOM(LD.intItemUOMId, LD.intWeightItemUOMId, 1), 1)
		,intWeightItemUOMId
		,dblDeliveredQuantity = NULL
		,dblDeliveredGross = NULL
		,dblDeliveredTare = NULL
		,dblDeliveredNet = NULL
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
		,strCustomerReference = NULL
		,strTerminalReference
		,intAllocationDetailId = NULL
		,intPickLotDetailId
		,intSellerId
		,intSalespersonId
		,intPSubLocationId
		,intSSubLocationId = NULL
		,intPStorageLocationId
		,intSStorageLocationId = NULL
		,strExternalShipmentItemNumber
		,strExternalBatchNo
		,intLoadDetailRefId = LD.intLoadDetailId
		,intConcurrencyId = 1
	FROM tblLGLoadDetail LD
	CROSS APPLY 
		(SELECT dblTotalDivertQty = SUM(ISNULL(dblDivertQuantity, 0)) 
		FROM tblLGLoadDetailContainerLink 
		WHERE intLoadDetailId = LD.intLoadDetailId
		AND ISNULL(dblDivertQuantity, 0) > 0) LDL
	WHERE LD.intLoadDetailId = @intLoadDetailId

	IF EXISTS(SELECT TOP 1 1 FROM @outputId)
		SELECT TOP 1 @intNewLoadDetailId = intId FROM @outputId

	/* Move Contract Scheduled Qty */
	/* Reduce original LS scheduled qty by divert qty */
	SELECT @dblDivertQuantity = -(dblQuantity) FROM tblLGLoadDetail WHERE intLoadDetailId = @intNewLoadDetailId
	EXEC uspCTUpdateScheduleQuantity 
		@intContractDetailId = @intPContractDetailId
		,@dblQuantityToUpdate = @dblDivertQuantity
		,@intUserId = @intEntityUserSecurityId
		,@intExternalId = @intLoadDetailId
		,@strScreenName = 'Load Schedule'

	/* Increase new LS scheduled qty by divert qty */
	SELECT @dblDivertQuantity = ABS(@dblDivertQuantity)
	EXEC uspCTUpdateScheduleQuantity 
		@intContractDetailId = @intPContractDetailId
		,@dblQuantityToUpdate = @dblDivertQuantity
		,@intUserId = @intEntityUserSecurityId
		,@intExternalId = @intNewLoadDetailId
		,@strScreenName = 'Load Schedule'

	IF (@intNewLoadDetailId IS NOT NULL)
	BEGIN
		/* Check if Load contains Containers */
		IF (EXISTS (SELECT TOP 1 intLoadContainerId FROM tblLGLoadContainer WHERE intLoadId = @intLoadId)
			AND EXISTS (SELECT TOP 1 intLoadContainerId FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = @intLoadDetailId))
		BEGIN
			/* Create Load Containers - Check if container to insert is the same as the first one */
			DELETE FROM @outputId
			IF NOT EXISTS (SELECT 1 FROM tblLGLoadContainer NLC INNER JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = NLC.intLoadContainerRefId 
				WHERE NLC.intLoadId = @intNewLoadId AND LC.intLoadContainerId IN (SELECT TOP 1 intLoadContainerId FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = @intLoadDetailId))
			BEGIN
				INSERT INTO tblLGLoadContainer (
					intConcurrencyId
					,intLoadId
					,strContainerId
					,strContainerNumber
					,dblQuantity
					,intUnitMeasureId
					,dblGrossWt
					,dblTareWt
					,dblNetWt
					,intWeightUnitMeasureId
					,strComments
					,strSealNumber
					,strLotNumber
					,strMarks
					,strOtherMarks
					,ysnRejected
					,dtmUnloading
					,dtmCustoms
					,ysnCustomsHold
					,strCustomsComments
					,dtmFDA
					,ysnFDAHold
					,strFDAComments
					,dtmFreight
					,ysnDutyPaid
					,strFreightComments
					,dtmUSDA
					,ysnUSDAHold
					,strUSDAComments
					,dblUnitCost
					,intCostUOMId
					,intCurrencyId
					,dblTotalCost
					,ysnNewContainer
					,dblCustomsClearedQty
					,dblIntransitQty
					,strDocumentNumber
					,dtmClearanceDate
					,strClearanceMonth
					,dblDeclaredWeight
					,dblStaticValue
					,intStaticValueCurrencyId
					,dblAmount
					,intAmountCurrencyId
					,strRemarks
					,intLoadContainerRefId
					,intSort)
				OUTPUT inserted.intLoadContainerId INTO @outputId(intId)
				SELECT
					intConcurrencyId = 1
					,intLoadId = @intNewLoadId
					,strContainerId
					,strContainerNumber
					,dblQuantity = LDL.dblDivertQuantity
					,intUnitMeasureId
					,dblGrossWt = LDL.dblDivertQuantity * ISNULL(dbo.fnCalculateQtyBetweenUOM(LDL.intItemUOMId, LDL.intWeightItemUOMId, 1), 1)
					,dblTareWt = 0
					,dblNetWt = LDL.dblDivertQuantity * ISNULL(dbo.fnCalculateQtyBetweenUOM(LDL.intItemUOMId, LDL.intWeightItemUOMId, 1), 1)
					,intWeightUnitMeasureId
					,strComments
					,strSealNumber
					,strLotNumber
					,strMarks
					,strOtherMarks
					,ysnRejected
					,dtmUnloading
					,dtmCustoms
					,ysnCustomsHold
					,strCustomsComments
					,dtmFDA
					,ysnFDAHold
					,strFDAComments
					,dtmFreight
					,ysnDutyPaid
					,strFreightComments
					,dtmUSDA
					,ysnUSDAHold
					,strUSDAComments
					,LC.dblUnitCost
					,LC.intCostUOMId
					,LC.intCurrencyId
					,LC.dblTotalCost
					,ysnNewContainer
					,dblCustomsClearedQty
					,dblIntransitQty
					,strDocumentNumber
					,dtmClearanceDate
					,strClearanceMonth
					,dblDeclaredWeight
					,dblStaticValue
					,intStaticValueCurrencyId
					,LC.dblAmount
					,intAmountCurrencyId
					,strRemarks
					,intLoadContainerRefId = LC.intLoadContainerId
					,intSort
				FROM tblLGLoadContainer LC
				CROSS APPLY 
					(SELECT dblDivertQuantity = SUM(dblDivertQuantity)
						,LD.intItemUOMId, LD.intWeightItemUOMId
					FROM tblLGLoadDetailContainerLink LDCL
					INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
					WHERE LDCL.intLoadDetailId = @intLoadDetailId
					AND ISNULL(dblDivertQuantity, 0) > 0
					GROUP BY LD.intLoadDetailId, LD.intItemUOMId, LD.intWeightItemUOMId) LDL
				WHERE intLoadContainerId IN (SELECT TOP 1 intLoadContainerId FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = @intLoadDetailId)
					AND NOT EXISTS (SELECT 1 FROM tblLGLoadContainer WHERE strContainerNumber = LC.strContainerNumber AND intLoadId = @intNewLoadId)

				IF EXISTS(SELECT TOP 1 1 FROM @outputId)
					SELECT TOP 1 @intNewLoadContainerId = intId FROM @outputId
			END
			ELSE
			BEGIN
				SELECT @intNewLoadContainerId = NLC.intLoadContainerId 
				FROM tblLGLoadContainer NLC INNER JOIN tblLGLoadContainer LC ON LC.intLoadContainerId = NLC.intLoadContainerRefId 
				WHERE NLC.intLoadId = @intNewLoadId AND LC.intLoadContainerId IN (SELECT TOP 1 intLoadContainerId FROM tblLGLoadDetailContainerLink WHERE intLoadDetailId = @intLoadDetailId)

				UPDATE LC
				SET dblQuantity = dblQuantity + LDL.dblDivertQuantity
					,dblGrossWt = dblGrossWt + (LDL.dblDivertQuantity * ISNULL(dbo.fnCalculateQtyBetweenUOM(LDL.intItemUOMId, LDL.intWeightItemUOMId, 1), 1))
					,dblTareWt = 0
					,dblNetWt = dblNetWt + (LDL.dblDivertQuantity * ISNULL(dbo.fnCalculateQtyBetweenUOM(LDL.intItemUOMId, LDL.intWeightItemUOMId, 1), 1))
				FROM tblLGLoadContainer LC
				CROSS APPLY 
					(SELECT dblDivertQuantity = SUM(dblDivertQuantity)
						,LD.intItemUOMId, LD.intWeightItemUOMId
					FROM tblLGLoadDetailContainerLink LDCL
					INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
					WHERE LDCL.intLoadDetailId = @intLoadDetailId
					AND ISNULL(dblDivertQuantity, 0) > 0
					GROUP BY LD.intLoadDetailId, LD.intItemUOMId, LD.intWeightItemUOMId) LDL
				WHERE intLoadContainerId = @intNewLoadContainerId
			END
	
			IF (@intNewLoadContainerId IS NOT NULL)
			BEGIN
				/* Create Load Container Links */
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
					,dblUnitCost
					,intCostUOMId
					,intCurrencyId
					,dblTotalCost
					,strIntegrationNumber
					,dtmIntegrationRequested
					,strIntegrationOrderNumber
					,dblIntegrationOrderPrice
					,strExternalContainerId
					,ysnExported
					,dtmExportedDate
					,dtmIntegrationOrderDate
					,intLoadDetailContainerLinkRefId)
				SELECT
					intConcurrencyId = 1
					,intLoadId = @intNewLoadId
					,intLoadContainerId = @intNewLoadContainerId
					,intLoadDetailId = @intNewLoadDetailId
					,LD.dblQuantity
					,LD.intItemUOMId
					,dblReceivedQty = NULL
					,dblLinkGrossWt = LD.dblGross
					,dblLinkTareWt = LD.dblTare
					,dblLinkNetWt = LD.dblNet
					,dblUnitCost = LC.dblUnitCost
					,intCostUOMId = LC.intCostUOMId
					,intCurrencyId = LC.intCurrencyId
					,dblTotalCost = LC.dblTotalCost 
					,strIntegrationNumber = NULL
					,dtmIntegrationRequested = NULL
					,strIntegrationOrderNumber = NULL
					,dblIntegrationOrderPrice = NULL
					,strExternalContainerId = NULL
					,ysnExported = NULL
					,dtmExportedDate = NULL
					,dtmIntegrationOrderDate = NULL
					,intLoadDetailContainerLinkRefId = NULL
				FROM tblLGLoadDetail LD
				OUTER APPLY (SELECT TOP 1 * FROM tblLGLoadContainer WHERE intLoadContainerId = @intNewLoadContainerId) LC
				WHERE LD.intLoadDetailId = @intNewLoadDetailId
			END
		END
	END
	
	--Loop control
	DELETE FROM #tmpLoadDetails WHERE intLoadDetailId = @intLoadDetailId
END

/* Reduce the Order and Container Qty. */
UPDATE LD
SET dblQuantity = (dblQuantity - dblDivertQuantity)
	,dblGross = (dblQuantity - dblDivertQuantity) * (ISNULL(dbo.fnCalculateQtyBetweenUOM(LDL.intItemUOMId, LDL.intWeightItemUOMId, 1), 1))
	,dblTare = (dblQuantity - dblDivertQuantity) * ISNULL(dbo.fnCalculateQtyBetweenUOM(LDL.intItemUOMId, LDL.intWeightItemUOMId, 1), 1)
	,dblNet = (dblQuantity - dblDivertQuantity) * ISNULL(dbo.fnCalculateQtyBetweenUOM(LDL.intItemUOMId, LDL.intWeightItemUOMId, 1), 1)
FROM tblLGLoadDetail LD
CROSS APPLY 
	(SELECT dblDivertQuantity = SUM(dblDivertQuantity)
		,LD.intItemUOMId, LD.intWeightItemUOMId
	FROM tblLGLoadDetailContainerLink LDCL
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
	WHERE LDCL.intLoadDetailId = @intLoadDetailId
	AND ISNULL(dblDivertQuantity, 0) > 0
	GROUP BY LD.intLoadDetailId, LD.intItemUOMId, LD.intWeightItemUOMId) LDL
WHERE LD.intLoadId = @intLoadId AND LDL.dblDivertQuantity > 0

UPDATE LDCL
SET dblQuantity = (LDCL.dblQuantity - LDCL.dblDivertQuantity)
	,dblLinkGrossWt = (LDCL.dblQuantity - LDCL.dblDivertQuantity) * (ISNULL(dbo.fnCalculateQtyBetweenUOM(LDL.intItemUOMId, LDL.intWeightItemUOMId, 1), 1))
	,dblLinkTareWt = (LDCL.dblQuantity - LDCL.dblDivertQuantity) * ISNULL(dbo.fnCalculateQtyBetweenUOM(LDL.intItemUOMId, LDL.intWeightItemUOMId, 1), 1)
	,dblLinkNetWt = (LDCL.dblQuantity - LDCL.dblDivertQuantity) * ISNULL(dbo.fnCalculateQtyBetweenUOM(LDL.intItemUOMId, LDL.intWeightItemUOMId, 1), 1)
	,dblDivertQuantity = NULL
FROM tblLGLoadDetailContainerLink LDCL
CROSS APPLY 
	(SELECT dblDivertQuantity = SUM(dblDivertQuantity)
		,LD.intItemUOMId, LD.intWeightItemUOMId
	FROM tblLGLoadDetailContainerLink LDCL
	INNER JOIN tblLGLoadDetail LD ON LD.intLoadDetailId = LDCL.intLoadDetailId
	WHERE LDCL.intLoadDetailId = @intLoadDetailId
	AND ISNULL(dblDivertQuantity, 0) > 0
	GROUP BY LD.intLoadDetailId, LD.intItemUOMId, LD.intWeightItemUOMId) LDL
WHERE LDCL.intLoadId = @intLoadId AND LDL.dblDivertQuantity > 0

UPDATE LC
	SET dblQuantity = LDCL.dblQuantity
		,dblGrossWt = LDCL.dblGross
		,dblTareWt = LDCL.dblTare
		,dblNetWt = LDCL.dblNet
FROM tblLGLoadContainer LC
OUTER APPLY (
	SELECT dblQuantity = SUM(dblQuantity)
		,dblGross = SUM(dblLinkGrossWt)
		,dblTare = SUM(dblLinkTareWt)
		,dblNet = SUM(dblLinkNetWt)
FROM tblLGLoadDetailContainerLink WHERE intLoadContainerId = LC.intLoadContainerId) LDCL
WHERE LC.intLoadId = @intLoadId

/* If Reduction causes the Qty to drop to zero, remove the record entirely. */
DELETE FROM tblLGLoadDetailContainerLink WHERE intLoadId = @intLoadId AND dblQuantity <= 0
DELETE FROM tblLGLoadWarehouseContainer WHERE intLoadContainerId IN 
	(SELECT intLoadContainerId FROM tblLGLoadContainer WHERE intLoadId = @intLoadId AND dblQuantity <= 0)
DELETE FROM tblLGLoadContainer WHERE intLoadId = @intLoadId AND dblQuantity <= 0
DELETE FROM tblLGLoadDetail WHERE intLoadId = @intLoadId AND dblQuantity <= 0

/* Repost the Transfer */
IF (@ysnIsPosted = 1 AND EXISTS(SELECT 1 FROM tblLGLoadDetail WHERE intLoadId = @intLoadId))
	EXEC uspLGPostLoadSchedule @intLoadId, @intEntityUserSecurityId, 1, 0

GO
