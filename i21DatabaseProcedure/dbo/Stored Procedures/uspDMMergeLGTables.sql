﻿CREATE PROCEDURE [dbo].[uspDMMergeLGTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

BEGIN

   -- tblLGLoad
    SET @SQLString = N'MERGE tblLGLoad AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblLGLoad]) AS Source
        ON (Target.intLoadId = Source.intLoadId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.strLoadNumber = Source.strLoadNumber, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.intPurchaseSale = Source.intPurchaseSale, Target.intItemId = Source.intItemId, Target.dblQuantity = Source.dblQuantity, Target.intUnitMeasureId = Source.intUnitMeasureId, Target.dtmScheduledDate = Source.dtmScheduledDate, Target.strCustomerReference = Source.strCustomerReference, Target.intEquipmentTypeId = Source.intEquipmentTypeId, Target.intEntityId = Source.intEntityId, Target.intEntityLocationId = Source.intEntityLocationId, Target.intContractDetailId = Source.intContractDetailId, Target.strComments = Source.strComments, Target.intHaulerEntityId = Source.intHaulerEntityId, Target.intTicketId = Source.intTicketId, Target.ysnInProgress = Source.ysnInProgress, Target.dblDeliveredQuantity = Source.dblDeliveredQuantity, Target.dtmDeliveredDate = Source.dtmDeliveredDate, Target.intGenerateLoadId = Source.intGenerateLoadId, Target.intGenerateSequence = Source.intGenerateSequence, Target.strTruckNo = Source.strTruckNo, Target.strTrailerNo1 = Source.strTrailerNo1, Target.strTrailerNo2 = Source.strTrailerNo2, Target.strTrailerNo3 = Source.strTrailerNo3, Target.intUserSecurityId = Source.intUserSecurityId, Target.strExternalLoadNumber = Source.strExternalLoadNumber, Target.intTransportLoadId = Source.intTransportLoadId, Target.intDriverEntityId = Source.intDriverEntityId, Target.ysnDispatched = Source.ysnDispatched, Target.dtmDispatchedDate = Source.dtmDispatchedDate, Target.intDispatcherId = Source.intDispatcherId, Target.ysnDispatchMailSent = Source.ysnDispatchMailSent, Target.dtmDispatchMailSent = Source.dtmDispatchMailSent, Target.dtmCancelDispatchMailSent = Source.dtmCancelDispatchMailSent, Target.intLoadHeaderId = Source.intLoadHeaderId, Target.intSourceType = Source.intSourceType, Target.intPositionId = Source.intPositionId, Target.intWeightUnitMeasureId = Source.intWeightUnitMeasureId, Target.strBLNumber = Source.strBLNumber, Target.dtmBLDate = Source.dtmBLDate, Target.strOriginPort = Source.strOriginPort, Target.strDestinationPort = Source.strDestinationPort, Target.strDestinationCity = Source.strDestinationCity, Target.intTerminalEntityId = Source.intTerminalEntityId, Target.intShippingLineEntityId = Source.intShippingLineEntityId, Target.strServiceContractNumber = Source.strServiceContractNumber, Target.strPackingDescription = Source.strPackingDescription, Target.strMVessel = Source.strMVessel, Target.strMVoyageNumber = Source.strMVoyageNumber, Target.strFVessel = Source.strFVessel, Target.strFVoyageNumber = Source.strFVoyageNumber, Target.intForwardingAgentEntityId = Source.intForwardingAgentEntityId, Target.strForwardingAgentRef = Source.strForwardingAgentRef, Target.intInsurerEntityId = Source.intInsurerEntityId, Target.dblInsuranceValue = Source.dblInsuranceValue, Target.intInsuranceCurrencyId = Source.intInsuranceCurrencyId, Target.dtmDocsToBroker = Source.dtmDocsToBroker, Target.strMarks = Source.strMarks, Target.strMarkingInstructions = Source.strMarkingInstructions, Target.strShippingMode = Source.strShippingMode, Target.intNumberOfContainers = Source.intNumberOfContainers, Target.intContainerTypeId = Source.intContainerTypeId, Target.intBLDraftToBeSentId = Source.intBLDraftToBeSentId, Target.strBLDraftToBeSentType = Source.strBLDraftToBeSentType, Target.strDocPresentationType = Source.strDocPresentationType, Target.intDocPresentationId = Source.intDocPresentationId, Target.dtmDocsReceivedDate = Source.dtmDocsReceivedDate, Target.dtmETAPOL = Source.dtmETAPOL, Target.dtmETSPOL = Source.dtmETSPOL, Target.dtmETAPOD = Source.dtmETAPOD, Target.dtmDeadlineCargo = Source.dtmDeadlineCargo, Target.dtmDeadlineBL = Source.dtmDeadlineBL, Target.dtmISFReceivedDate = Source.dtmISFReceivedDate, Target.dtmISFFiledDate = Source.dtmISFFiledDate, Target.dblDemurrage = Source.dblDemurrage, Target.intDemurrageCurrencyId = Source.intDemurrageCurrencyId, Target.dblDespatch = Source.dblDespatch, Target.intDespatchCurrencyId = Source.intDespatchCurrencyId, Target.dblLoadingRate = Source.dblLoadingRate, Target.intLoadingUnitMeasureId = Source.intLoadingUnitMeasureId, Target.strLoadingPerUnit = Source.strLoadingPerUnit, Target.dblDischargeRate = Source.dblDischargeRate, Target.intDischargeUnitMeasureId = Source.intDischargeUnitMeasureId, Target.strDischargePerUnit = Source.strDischargePerUnit, Target.intTransportationMode = Source.intTransportationMode, Target.intShipmentStatus = Source.intShipmentStatus, Target.ysnPosted = Source.ysnPosted, Target.dtmPostedDate = Source.dtmPostedDate, Target.intTransUsedBy = Source.intTransUsedBy
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblLGLoadAllocationDetail
    --SET @SQLString = N'MERGE tblLGLoadAllocationDetail AS Target
    --    USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblLGLoadAllocationDetail]) AS Source
    --    ON (Target.intLoadAllocationDetailId = Source.intLoadAllocationDetailId)
    --    WHEN MATCHED THEN
    --        UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intGenerateLoadId = Source.intGenerateLoadId, Target.intPLoadId = Source.intPLoadId, Target.intSLoadId = Source.intSLoadId, Target.dblPAllocatedQty = Source.dblPAllocatedQty, Target.dblSAllocatedQty = Source.dblSAllocatedQty, Target.intPUnitMeasureId = Source.intPUnitMeasureId, Target.intSUnitMeasureId = Source.intSUnitMeasureId, Target.dtmAllocatedDate = Source.dtmAllocatedDate, Target.intUserSecurityId = Source.intUserSecurityId, Target.strComments = Source.strComments
    --    WHEN NOT MATCHED BY SOURCE THEN
    --        DELETE;';

    --SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    --EXECUTE sp_executesql @SQLString;

    -- tblLGLoadCost
    SET @SQLString = N'MERGE tblLGLoadCost AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblLGLoadCost]) AS Source
        ON (Target.intLoadCostId = Source.intLoadCostId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intLoadId = Source.intLoadId, Target.intItemId = Source.intItemId, Target.intVendorId = Source.intVendorId, Target.strCostMethod = Source.strCostMethod, Target.dblRate = Source.dblRate, Target.intItemUOMId = Source.intItemUOMId, Target.ysnAccrue = Source.ysnAccrue, Target.ysnMTM = Source.ysnMTM, Target.ysnPrice = Source.ysnPrice
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblLGLoadDetail
    SET @SQLString = N'MERGE tblLGLoadDetail AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblLGLoadDetail]) AS Source
        ON (Target.intLoadDetailId = Source.intLoadDetailId)
        WHEN MATCHED THEN
            UPDATE SET Target.intConcurrencyId = Source.intConcurrencyId, Target.intLoadId = Source.intLoadId, Target.intVendorEntityId = Source.intVendorEntityId, Target.intVendorEntityLocationId = Source.intVendorEntityLocationId, Target.intCustomerEntityId = Source.intCustomerEntityId, Target.intCustomerEntityLocationId = Source.intCustomerEntityLocationId, Target.intItemId = Source.intItemId, Target.intPContractDetailId = Source.intPContractDetailId, Target.intSContractDetailId = Source.intSContractDetailId, Target.intPCompanyLocationId = Source.intPCompanyLocationId, Target.intSCompanyLocationId = Source.intSCompanyLocationId, Target.dblQuantity = Source.dblQuantity, Target.intItemUOMId = Source.intItemUOMId, Target.dblGross = Source.dblGross, Target.dblTare = Source.dblTare, Target.dblNet = Source.dblNet, Target.intWeightItemUOMId = Source.intWeightItemUOMId, Target.dblDeliveredQuantity = Source.dblDeliveredQuantity, Target.dblDeliveredGross = Source.dblDeliveredGross, Target.dblDeliveredTare = Source.dblDeliveredTare, Target.dblDeliveredNet = Source.dblDeliveredNet, Target.strLotAlias = Source.strLotAlias, Target.strSupplierLotNumber = Source.strSupplierLotNumber, Target.dtmProductionDate = Source.dtmProductionDate, Target.strScheduleInfoMsg = Source.strScheduleInfoMsg, Target.ysnUpdateScheduleInfo = Source.ysnUpdateScheduleInfo, Target.ysnPrintScheduleInfo = Source.ysnPrintScheduleInfo, Target.strLoadDirectionMsg = Source.strLoadDirectionMsg, Target.ysnUpdateLoadDirections = Source.ysnUpdateLoadDirections, Target.ysnPrintLoadDirections = Source.ysnPrintLoadDirections, Target.strVendorReference = Source.strVendorReference, Target.strCustomerReference = Source.strCustomerReference, Target.intAllocationDetailId = Source.intAllocationDetailId, Target.intPickLotDetailId = Source.intPickLotDetailId, Target.intPSubLocationId = Source.intPSubLocationId, Target.intSSubLocationId = Source.intSSubLocationId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

END