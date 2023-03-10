﻿CREATE PROCEDURE [dbo].[uspLGCreateLoadForDivertLot]
	@intLoadId INT
	,@intEntityUserSecurityId INT
	,@intNewLoadId INT OUTPUT
AS
DECLARE @outputId AS Id

/* Check if there are any Lot Quantity to Divert */
IF NOT EXISTS (SELECT 1 FROM tblLGLoadDetailLot WHERE ISNULL(dblDivertQuantity, 0) > 0
	AND intLoadDetailId IN (SELECT intLoadDetailId FROM tblLGLoadDetail WHERE intLoadId = @intLoadId))
BEGIN
	RAISERROR('No quantity specified for diversion.', 16, 1);
END

/* Unpost the Transfer */
EXEC uspLGPostLoadSchedule @intLoadId, @intEntityUserSecurityId, 0, 0

DECLARE @strNewLoadNumber NVARCHAR(100)
EXEC uspSMGetStartingNumber 39, @strNewLoadNumber OUTPUT

/* Create New Outbound Load */
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
	,intPurchaseSale = 2
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
	,intSourceType = 6
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
SELECT LD.intLoadDetailId 
INTO #tmpLoadDetails 
FROM tblLGLoadDetail LD
CROSS APPLY 
	(SELECT dblTotalDivertQty = SUM(ISNULL(dblDivertQuantity, 0)) 
	FROM tblLGLoadDetailLot 
	WHERE intLoadDetailId = LD.intLoadDetailId
	AND ISNULL(dblDivertQuantity, 0) > 0) LDL
WHERE LD.intLoadId = @intLoadId AND LDL.dblTotalDivertQty > 0

/* Loop through all details */
DECLARE @intLoadDetailId INT = NULL
DECLARE @intNewLoadDetailId INT = NULL
DECLARE @intNewLoadContainerId INT = NULL
WHILE EXISTS(SELECT TOP 1 1 FROM #tmpLoadDetails)
BEGIN
	SELECT @intNewLoadDetailId = NULL, @intNewLoadContainerId = NULL
	SELECT TOP 1 @intLoadDetailId = intLoadDetailId FROM #tmpLoadDetails

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
		,intVendorEntityId = NULL
		,intVendorEntityLocationId = NULL
		,intCustomerEntityId = NULL
		,intCustomerEntityLocationId = NULL
		,intItemId
		,intPContractDetailId = NULL
		,intSContractDetailId = NULL
		,intPCompanyLocationId = NULL
		,intSCompanyLocationId = NULL
		,dblQuantity = dblTotalDivertQty
		,intItemUOMId = LD.intItemUOMId
		,dblGross = dblTotalDivertQty * (ISNULL(LDLV.dblWeightPerUnit, 1) + ISNULL(LDLV.dblTarePerQty, 1))
		,dblTare = dblTotalDivertQty * ISNULL(LDLV.dblTarePerQty, 1)
		,dblNet = dblTotalDivertQty * ISNULL(LDLV.dblWeightPerUnit, 1)
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
		,strCustomerReference
		,strTerminalReference
		,intAllocationDetailId
		,intPickLotDetailId
		,intSellerId
		,intSalespersonId
		,intPSubLocationId = NULL
		,intSSubLocationId = NULL
		,intPStorageLocationId = NULL
		,intSStorageLocationId = NULL
		,strExternalShipmentItemNumber
		,strExternalBatchNo
		,intLoadDetailRefId = LD.intLoadDetailId
		,intConcurrencyId = 1
	FROM tblLGLoadDetail LD
	INNER JOIN vyuLGLoadDetailLotsView LDLV ON LDLV.intLoadDetailId = LD.intLoadDetailId
	CROSS APPLY 
		(SELECT dblTotalDivertQty = SUM(ISNULL(dblDivertQuantity, 0)) 
		FROM vyuLGLoadDetailLotsView 
		WHERE intLoadDetailId = LD.intLoadDetailId
		AND ISNULL(dblDivertQuantity, 0) > 0) LDL
	WHERE LD.intLoadDetailId = @intLoadDetailId

	IF EXISTS(SELECT TOP 1 1 FROM @outputId)
		SELECT TOP 1 @intNewLoadDetailId = intId FROM @outputId

	IF (@intNewLoadDetailId IS NOT NULL)
	BEGIN
		/* Create New Load Detail Lots */
		INSERT INTO tblLGLoadDetailLot (
			intLoadDetailId
			,intLotId
			,dblLotQuantity
			,intItemUOMId
			,dblGross
			,dblTare
			,dblNet
			,intWeightUOMId
			,strWarehouseCargoNumber
			,intSort
			,intLoadDetailLotRefId
			,intNewLotId
			,strNewLotNumber
			,strID1
			,strID2
			,strID3
			,dblDivertQuantity
			,intConcurrencyId)
		SELECT
			intLoadDetailId = @intNewLoadDetailId
			,LDL.intLotId
			,dblLotQuantity = LDL.dblDivertQuantity
			,LDL.intItemUOMId
			,dblGross = LDL.dblDivertQuantity * (ISNULL(LDLV.dblWeightPerUnit, 1) + ISNULL(LDLV.dblTarePerQty, 1))
			,dblTare = LDL.dblDivertQuantity * ISNULL(LDLV.dblTarePerQty, 1)
			,dblNet = LDL.dblDivertQuantity * ISNULL(LDLV.dblWeightPerUnit, 1)
			,LDL.intWeightUOMId
			,LDL.strWarehouseCargoNumber
			,LDL.intSort
			,intLoadDetailLotRefId = LDL.intLoadDetailLotId
			,intNewLotId = NULL
			,strNewLotNumber = NULL
			,strID1 = LDL.strID1
			,strID2 = LDL.strID2
			,strID3 = LDL.strID3
			,dblDivertQuantity = NULL
			,intConcurrencyId = 1
		FROM tblLGLoadDetailLot LDL
		INNER JOIN vyuLGLoadDetailLotsView LDLV ON LDLV.intLoadDetailLotId = LDL.intLoadDetailLotId
		WHERE LDL.intLoadDetailId = @intLoadDetailId

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
					,dblGrossWt = LDL.dblDivertQuantity * (ISNULL(LDL.dblWeightPerUnit, 1) + ISNULL(LDL.dblTarePerQty, 1))
					,dblTareWt = LDL.dblDivertQuantity * ISNULL(LDL.dblTarePerQty, 1)
					,dblNetWt = LDL.dblDivertQuantity * ISNULL(LDL.dblWeightPerUnit, 1)
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
						,dblWeightPerUnit = SUM(dblWeightPerUnit)
						,dblTarePerQty = SUM(dblTarePerQty)
					FROM vyuLGLoadDetailLotsView 
					WHERE intLoadDetailId = @intLoadDetailId
					AND ISNULL(dblDivertQuantity, 0) > 0
					GROUP BY intLoadDetailId) LDL
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
					,dblGrossWt = dblGrossWt + (LDL.dblDivertQuantity * (ISNULL(LDL.dblWeightPerUnit, 1) + ISNULL(LDL.dblTarePerQty, 1)))
					,dblTareWt = dblTareWt + (LDL.dblDivertQuantity * ISNULL(LDL.dblTarePerQty, 1))
					,dblNetWt = dblNetWt + (LDL.dblDivertQuantity * ISNULL(LDL.dblWeightPerUnit, 1))
				FROM tblLGLoadContainer LC
				CROSS APPLY 
					(SELECT dblDivertQuantity = SUM(dblDivertQuantity)
						,dblWeightPerUnit = SUM(dblWeightPerUnit)
						,dblTarePerQty = SUM(dblTarePerQty)
					FROM vyuLGLoadDetailLotsView 
					WHERE intLoadDetailId = @intLoadDetailId
					AND ISNULL(dblDivertQuantity, 0) > 0
					GROUP BY intLoadDetailId) LDL
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

/* Reduce the Lot, Order, Container Qty. */
UPDATE LD
SET dblQuantity = (dblQuantity - LDL.dblDivertQuantity)
	,dblGross = (dblQuantity - LDL.dblDivertQuantity) * (dblWeightPerUnit + dblTarePerQty)
	,dblTare = (dblQuantity - LDL.dblDivertQuantity) * dblTarePerQty
	,dblNet = (dblQuantity - LDL.dblDivertQuantity) * dblWeightPerUnit
FROM tblLGLoadDetail LD
CROSS APPLY 
	(SELECT dblDivertQuantity = SUM(dblDivertQuantity)
		,dblWeightPerUnit = SUM(dblWeightPerUnit)
		,dblTarePerQty = SUM(dblTarePerQty)
	FROM vyuLGLoadDetailLotsView 
	WHERE intLoadDetailId = LD.intLoadDetailId
	AND ISNULL(dblDivertQuantity, 0) > 0
	GROUP BY intLoadDetailId) LDL
WHERE LD.intLoadId = @intLoadId AND LDL.dblDivertQuantity > 0

UPDATE LDCL
SET dblQuantity = (LDCL.dblQuantity - LDL.dblDivertQuantity)
	,dblLinkGrossWt = (LDCL.dblQuantity - LDL.dblDivertQuantity) * (dblWeightPerUnit + dblTarePerQty)
	,dblLinkTareWt = (LDCL.dblQuantity - LDL.dblDivertQuantity) * dblTarePerQty
	,dblLinkNetWt = (LDCL.dblQuantity - LDL.dblDivertQuantity) * dblWeightPerUnit
FROM tblLGLoadDetailContainerLink LDCL
CROSS APPLY 
	(SELECT dblDivertQuantity = SUM(dblDivertQuantity)
		,dblWeightPerUnit = SUM(dblWeightPerUnit)
		,dblTarePerQty = SUM(dblTarePerQty)
	FROM vyuLGLoadDetailLotsView 
	WHERE intLoadDetailId = LDCL.intLoadDetailId
	AND ISNULL(dblDivertQuantity, 0) > 0
	GROUP BY intLoadDetailId) LDL
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

UPDATE LDL
SET dblLotQuantity = LDL.dblLotQuantity - LDL.dblDivertQuantity
	,dblGross = (LDL.dblLotQuantity - LDL.dblDivertQuantity) * (dblWeightPerUnit + dblTarePerQty)
	,dblTare = (LDL.dblLotQuantity - LDL.dblDivertQuantity) * dblTarePerQty
	,dblNet = (LDL.dblLotQuantity - LDL.dblDivertQuantity) * dblWeightPerUnit
	,dblDivertQuantity = NULL
FROM tblLGLoadDetailLot LDL
INNER JOIN vyuLGLoadDetailLotsView LDLV ON LDLV.intLoadDetailLotId = LDL.intLoadDetailLotId
WHERE ISNULL(LDL.dblDivertQuantity, 0) > 0 
	AND LDL.intLoadDetailId IN (SELECT intLoadDetailId FROM tblLGLoadDetail WHERE intLoadId = @intLoadId)

/* If Reduction causes the Qty to drop to zero, remove the record entirely. */
DELETE FROM tblLGLoadDetailContainerLink WHERE intLoadId = @intLoadId AND dblQuantity <= 0
DELETE FROM tblLGLoadWarehouseContainer WHERE intLoadContainerId IN 
	(SELECT intLoadContainerId FROM tblLGLoadContainer WHERE intLoadId = @intLoadId AND dblQuantity <= 0)
DELETE FROM tblLGLoadContainer WHERE intLoadId = @intLoadId AND dblQuantity <= 0
DELETE FROM tblLGLoadDetail WHERE intLoadId = @intLoadId AND dblQuantity <= 0
DELETE FROM tblLGLoadDetailLot WHERE dblLotQuantity <= 0
	AND intLoadDetailId IN (SELECT intLoadDetailId FROM tblLGLoadDetail WHERE intLoadId = @intLoadId)

/* Repost the Transfer */
EXEC uspLGPostLoadSchedule @intLoadId, @intEntityUserSecurityId, 1, 0

GO
