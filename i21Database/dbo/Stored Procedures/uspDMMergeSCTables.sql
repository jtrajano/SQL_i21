CREATE PROCEDURE [dbo].[uspDMMergeSCTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';

BEGIN

    -- tblSCScaleSetup
    SET @SQLString = N'MERGE tblSCScaleSetup AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCScaleSetup]) AS Source
        ON (Target.intScaleSetupId = Source.intScaleSetupId)
        WHEN MATCHED THEN
            UPDATE SET Target.strStationShortDescription = Source.strStationShortDescription, Target.strStationDescription = Source.strStationDescription, Target.intStationType = Source.intStationType, Target.intTicketPoolId = Source.intTicketPoolId, Target.strAddress = Source.strAddress, Target.strZipCode = Source.strZipCode, Target.strCity = Source.strCity, Target.strState = Source.strState, Target.strCountry = Source.strCountry, Target.strPhone = Source.strPhone, Target.intLocationId = Source.intLocationId, Target.ysnAllowManualTicketNumber = Source.ysnAllowManualTicketNumber, Target.strScaleOperator = Source.strScaleOperator, Target.intScaleProcessing = Source.intScaleProcessing, Target.intTransferDelayMinutes = Source.intTransferDelayMinutes, Target.intBatchTransferInterval = Source.intBatchTransferInterval, Target.strLocalFilePath = Source.strLocalFilePath, Target.strServerPath = Source.strServerPath, Target.strWebServicePath = Source.strWebServicePath, Target.intMinimumPurgeDays = Source.intMinimumPurgeDays, Target.dtmLastPurgeDate = Source.dtmLastPurgeDate, Target.intLastPurgeUserId = Source.intLastPurgeUserId, Target.intInScaleDeviceId = Source.intInScaleDeviceId, Target.ysnDisableInScale = Source.ysnDisableInScale, Target.intOutScaleDeviceId = Source.intOutScaleDeviceId, Target.ysnDisableOutScale = Source.ysnDisableOutScale, Target.ysnShowOutScale = Source.ysnShowOutScale, Target.ysnAllowZeroWeights = Source.ysnAllowZeroWeights, Target.strWeightDescription = Source.strWeightDescription, Target.intUnitMeasureId = Source.intUnitMeasureId, Target.intGraderDeviceId = Source.intGraderDeviceId, Target.intAlternateGraderDeviceId = Source.intAlternateGraderDeviceId, Target.intLEDDeviceId = Source.intLEDDeviceId, Target.ysnCustomerFirst = Source.ysnCustomerFirst, Target.intAllowOtherLocationContracts = Source.intAllowOtherLocationContracts, Target.intWeightDisplayDelay = Source.intWeightDisplayDelay, Target.intTicketSelectionDelay = Source.intTicketSelectionDelay, Target.intFreightHaulerIDRequired = Source.intFreightHaulerIDRequired, Target.intBinNumberRequired = Source.intBinNumberRequired, Target.intDriverNameRequired = Source.intDriverNameRequired, Target.intTruckIDRequired = Source.intTruckIDRequired, Target.intTrackAxleCount = Source.intTrackAxleCount, Target.intRequireSpotSalePrice = Source.intRequireSpotSalePrice, Target.ysnTicketCommentRequired = Source.ysnTicketCommentRequired, Target.ysnAllowElectronicSpotPrice = Source.ysnAllowElectronicSpotPrice, Target.ysnRefreshContractsOnOpen = Source.ysnRefreshContractsOnOpen, Target.ysnTrackVariety = Source.ysnTrackVariety, Target.ysnManualGrading = Source.ysnManualGrading, Target.ysnLockStoredGrade = Source.ysnLockStoredGrade, Target.ysnAllowManualWeight = Source.ysnAllowManualWeight, Target.intStorePitInformation = Source.intStorePitInformation, Target.ysnReferenceNumberRequired = Source.ysnReferenceNumberRequired, Target.ysnDefaultDriverOffTruck = Source.ysnDefaultDriverOffTruck, Target.ysnAutomateTakeOutTicket = Source.ysnAutomateTakeOutTicket, Target.ysnDefaultDeductFreightFromFarmer = Source.ysnDefaultDeductFreightFromFarmer, Target.intStoreScaleOperator = Source.intStoreScaleOperator, Target.intDefaultStorageTypeId = Source.intDefaultStorageTypeId, Target.intGrainBankStorageTypeId = Source.intGrainBankStorageTypeId, Target.ysnRefreshLoadsOnOpen = Source.ysnRefreshLoadsOnOpen, Target.ysnRequireContractForInTransitTicket = Source.ysnRequireContractForInTransitTicket, Target.intDefaultFeeItemId = Source.intDefaultFeeItemId, Target.intFreightItemId = Source.intFreightItemId, Target.intConcurrencyId = Source.intConcurrencyId, Target.ysnMultipleWeights = Source.ysnMultipleWeights
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' '  + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'

    EXECUTE sp_executesql @SQLString;

    -- tblSCLastScaleSetup
    SET @SQLString = N'MERGE tblSCLastScaleSetup AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCLastScaleSetup]) AS Source
        ON (Target.intLastScaleSetupId = Source.intLastScaleSetupId)
        WHEN MATCHED THEN
            UPDATE SET Target.intScaleSetupId = Source.intScaleSetupId, Target.dtmScaleDate = Source.dtmScaleDate
			, Target.strScaleOperator = Source.strScaleOperator, Target.intConcurrencyId = Source.intConcurrencyId, Target.intEntityId = Source.intEntityId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intLastScaleSetupId, intScaleSetupId, dtmScaleDate, strScaleOperator, intConcurrencyId, intEntityId)
            VALUES (Source.intLastScaleSetupId, Source.intScaleSetupId, Source.dtmScaleDate, Source.strScaleOperator, Source.intConcurrencyId, Source.intEntityId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCLastScaleSetup ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCLastScaleSetup OFF

    -- tblSCTicketType
    SET @SQLString = N'MERGE tblSCTicketType AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketType]) AS Source
        ON (Target.intTicketTypeId = Source.intTicketTypeId)
        WHEN MATCHED THEN
            UPDATE SET Target.intTicketPoolId = Source.intTicketPoolId, Target.intListTicketTypeId = Source.intListTicketTypeId, Target.ysnTicketAllowed = Source.ysnTicketAllowed, Target.intNextTicketNumber = Source.intNextTicketNumber, Target.intDiscountSchedule = Source.intDiscountSchedule, Target.intDistributionMethod = Source.intDistributionMethod, Target.ysnSelectByPO = Source.ysnSelectByPO, Target.intSplitInvoiceOption = Source.intSplitInvoiceOption, Target.intContractRequired = Source.intContractRequired, Target.intOverrideTicketCopies = Source.intOverrideTicketCopies, Target.ysnPrintAtKiosk = Source.ysnPrintAtKiosk, Target.ynsVerifySplitMethods = Source.ynsVerifySplitMethods, Target.ysnOverrideSingleTicketSeries = Source.ysnOverrideSingleTicketSeries, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCTicketType ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketType OFF

    -- tblSCListTicketTypes
    SET @SQLString = N'MERGE tblSCListTicketTypes AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCListTicketTypes]) AS Source
        ON (Target.intTicketTypeId = Source.intTicketTypeId)
        WHEN MATCHED THEN
            UPDATE SET Target.intTicketType = Source.intTicketType, Target.strTicketType = Source.strTicketType, Target.strInOutIndicator = Source.strInOutIndicator, Target.ysnActive = Source.ysnActive, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblSCUncompletedTicketAlert
    SET @SQLString = N'MERGE tblSCUncompletedTicketAlert AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCUncompletedTicketAlert]) AS Source
        ON (Target.intUncompletedTicketAlertId = Source.intUncompletedTicketAlertId)
        WHEN MATCHED THEN
            UPDATE SET Target.intEntityId = Source.intEntityId, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.intTicketUncompletedDaysAlert = Source.intTicketUncompletedDaysAlert, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblSCDistributionOption
    SET @SQLString = N'MERGE tblSCDistributionOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCDistributionOption]) AS Source
        ON (Target.intDistributionOptionId = Source.intDistributionOptionId)
        WHEN MATCHED THEN
            UPDATE SET Target.strDistributionOption = Source.strDistributionOption
			, Target.intTicketPoolId = Source.intTicketPoolId
			, Target.intTicketTypeId = Source.intTicketTypeId
			, Target.ysnDistributionAllowed = Source.ysnDistributionAllowed
			, Target.ysnDefaultDistribution = Source.ysnDefaultDistribution
			, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCDistributionOption ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCDistributionOption OFF

    -- tblSCScaleDevice
    SET @SQLString = N'MERGE tblSCScaleDevice AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCScaleDevice]) AS Source
        ON (Target.intScaleDeviceId = Source.intScaleDeviceId)
        WHEN MATCHED THEN
            UPDATE SET Target.intPhysicalEquipmentId = Source.intPhysicalEquipmentId, Target.strDeviceDescription = Source.strDeviceDescription, Target.intDeviceTypeId = Source.intDeviceTypeId
			, Target.intConnectionMethod = Source.intConnectionMethod, Target.strFilePath = Source.strFilePath, Target.strFileName = Source.strFileName
			, Target.strIPAddress = Source.strIPAddress, Target.intIPPort = Source.intIPPort, Target.intComPort = Source.intComPort, Target.intBaudRate = Source.intBaudRate
			, Target.intDataBits = Source.intDataBits, Target.intStopBits = Source.intStopBits, Target.intParityBits = Source.intParityBits
			, Target.intFlowControl = Source.intFlowControl, Target.intGraderModel = Source.intGraderModel, Target.ysnVerifyCommodityCode = Source.ysnVerifyCommodityCode
			, Target.ysnVerifyDateTime = Source.ysnVerifyDateTime, Target.ysnDateTimeCheck = Source.ysnDateTimeCheck, Target.ysnDateTimeFixedLocation = Source.ysnDateTimeFixedLocation, Target.intDateTimeStartingLocation = Source.intDateTimeStartingLocation, Target.intDateTimeLength = Source.intDateTimeLength, Target.strDateTimeValidationString = Source.strDateTimeValidationString, Target.ysnMotionDetection = Source.ysnMotionDetection, Target.ysnMotionFixedLocation = Source.ysnMotionFixedLocation, Target.intMotionStartingLocation = Source.intMotionStartingLocation
			, Target.intMotionLength = Source.intMotionLength, Target.strMotionValidationString = Source.strMotionValidationString, Target.intWeightStabilityCheck = Source.intWeightStabilityCheck, Target.ysnWeightFixedLocation = Source.ysnWeightFixedLocation, Target.intWeightStartingLocation = Source.intWeightStartingLocation, Target.intWeightLength = Source.intWeightLength, Target.strNTEPCapacity = Source.strNTEPCapacity, Target.intConcurrencyId = Source.intConcurrencyId
		WHEN NOT MATCHED BY TARGET THEN
		INSERT(
			intScaleDeviceId
			,intPhysicalEquipmentId
			,strDeviceDescription
			,intDeviceTypeId
			,intConnectionMethod
			,strFilePath
			,strFileName
			,strIPAddress
			,intIPPort
			,intComPort
			,intBaudRate
			,intDataBits
			,intStopBits
			,intParityBits
			,intFlowControl
			,intGraderModel
			,ysnVerifyCommodityCode
			,ysnVerifyDateTime
			,ysnDateTimeCheck
			,ysnDateTimeFixedLocation
			,intDateTimeStartingLocation
			,intDateTimeLength
			,strDateTimeValidationString
			,ysnMotionDetection
			,ysnMotionFixedLocation
			,intMotionStartingLocation
			,intMotionLength
			,strMotionValidationString
			,intWeightStabilityCheck
			,ysnWeightFixedLocation
			,intWeightStartingLocation
			,intWeightLength
			,strNTEPCapacity
			,intConcurrencyId
		)
		VALUE(
			Source.intScaleDeviceId
			, Source.intPhysicalEquipmentId
			, Source.strDeviceDescription
			, Source.intDeviceTypeId
			, Source.intConnectionMethod
			, Source.strFilePath
			, Source.strFileName
			, Source.strIPAddress
			, Source.intIPPort
			, Source.intComPort
			, Source.intBaudRate
			, Source.intDataBits
			, Source.intStopBits
			, Source.intParityBits
			, Source.intFlowControl
			, Source.intGraderModel
			, Source.ysnVerifyCommodityCode
			, Source.ysnVerifyDateTime
			, Source.ysnDateTimeCheck
			, Source.ysnDateTimeFixedLocation
			, Source.intDateTimeStartingLocation
			, Source.intDateTimeLength
			, Source.strDateTimeValidationString
			, Source.ysnMotionDetection
			, Source.ysnMotionFixedLocation
			, Source.intMotionStartingLocation
			, Source.intMotionLength
			, Source.strMotionValidationString
			, Source.intWeightStabilityCheck
			, Source.ysnWeightFixedLocation
			, Source.intWeightStartingLocation
			, Source.intWeightLength
			, Source.strNTEPCapacity
			, Source.intConcurrencyId
		)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCScaleDevice ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCScaleDevice OFF

	--tblSCDeliverySheet
	SET @SQLString = N'MERGE tblSCDeliverySheet AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCDeliverySheet]) AS Source
        ON (Target.intDeliverySheetId = Source.intDeliverySheetId)
        WHEN MATCHED THEN
            UPDATE SET Target.intEntityId = Source.intEntityId, Target.intCompanyLocationId = Source.intCompanyLocationId, Target.intItemId = Source.intItemId, Target.intDiscountId = Source.intDiscountId
			, Target.strDeliverySheetNumber = Source.strDeliverySheetNumber, Target.dtmDeliverySheetDate = Source.dtmDeliverySheetDate, Target.intCurrencyId = Source.intCurrencyId
			, Target.intTicketTypeId = Source.intTicketTypeId, Target.intSplitId = Source.intSplitId, Target.intFarmFieldId = Source.intFarmFieldId, Target.ysnPost = Source.ysnPost
			, Target.intConcurrencyId = Source.intConcurrencyId, Target.strOfflineGuid = Source.strOfflineGuid
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intDeliverySheetId, intEntityId, intCompanyLocationId, intItemId, intDiscountId, strDeliverySheetNumber, dtmDeliverySheetDate
			, intCurrencyId, intTicketTypeId, intSplitId, intFarmFieldId, ysnPost, intConcurrencyId)
            VALUES (Source.intDeliverySheetId, Source.intEntityId, Source.intCompanyLocationId, Source.intItemId, Source.intDiscountId, Source.strDeliverySheetNumber, Source.dtmDeliverySheetDate, Source.intCurrencyId
			, Source.intTicketTypeId, Source.intSplitId, Source.intFarmFieldId, Source.ysnPost, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCDeliverySheet ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCDeliverySheet OFF

	 -- tblSCDeliverySheetSplit
    SET @SQLString = N'MERGE tblSCDeliverySheetSplit AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCDeliverySheetSplit]) AS Source
        ON (Target.intDeliverySheetSplitId = Source.intDeliverySheetSplitId)
        WHEN MATCHED THEN
            UPDATE SET Target.intDeliverySheetId = Source.intDeliverySheetId, Target.intEntityId = Source.intEntityId, Target.dblSplitPercent = Source.dblSplitPercent
			, Target.strDistributionOption = Source.strDistributionOption, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intDeliverySheetSplitId, intDeliverySheetId, intEntityId, dblSplitPercent, strDistributionOption, intConcurrencyId)
            VALUES (Source.intDeliverySheetSplitId, Source.intDeliverySheetId, Source.intEntityId, Source.dblSplitPercent, Source.strDistributionOption, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCDeliverySheetSplit ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCDeliverySheetSplit OFF

	-- tblSCDeliverySheetImportingTemplate
    SET @SQLString = N'MERGE tblSCDeliverySheetImportingTemplate AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCDeliverySheetImportingTemplate]) AS Source
        ON (Target.intImportingTemplateId = Source.intImportingTemplateId)
        WHEN MATCHED THEN
            UPDATE SET Target.strTemplateCode = Source.strTemplateCode, Target.strTemplateDescription = Source.strTemplateDescription, Target.intDelimiterId = Source.intDelimiterId
			, Target.strDelimiterType = Source.strDelimiterType, Target.ysnActive = Source.ysnActive, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intImportingTemplateId, strTemplateCode, strTemplateDescription, intDelimiterId, strDelimiterType, ysnActive, intConcurrencyId)
            VALUES (Source.intImportingTemplateId, Source.strTemplateCode, Source.strTemplateDescription, Source.intDelimiterId, Source.strDelimiterType, Source.ysnActive, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCDeliverySheetImportingTemplate ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCDeliverySheetImportingTemplate OFF

	-- tblSCDeliverySheetImportingTemplateDetail
    SET @SQLString = N'MERGE tblSCDeliverySheetImportingTemplateDetail AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCDeliverySheetImportingTemplateDetail]) AS Source
        ON (Target.intImportingTemplateDetailId = Source.intImportingTemplateDetailId)
        WHEN MATCHED THEN
            UPDATE SET Target.intImportingTemplateId = Source.intImportingTemplateId, Target.intFieldNameId = Source.intFieldNameId, Target.strFieldName = Source.strFieldName
			, Target.intFieldColumnNumber = Source.intFieldColumnNumber, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intImportingTemplateDetailId, intImportingTemplateId, intFieldNameId, intFieldColumnNumber, intConcurrencyId)
            VALUES (Source.intImportingTemplateDetailId, Source.intImportingTemplateId, Source.intFieldNameId, Source.intFieldColumnNumber, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCDeliverySheetImportingTemplateDetail ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCDeliverySheetImportingTemplateDetail OFF

    -- tblSCTicket
   -- SET @SQLString = N'MERGE tblSCTicket AS Target
   --     USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicket]) AS Source
   --     ON (Target.intTicketId = Source.intTicketId)
   --     WHEN MATCHED THEN
   --         UPDATE SET Target.strTicketStatus = Source.strTicketStatus, Target.strTicketNumber = Source.strTicketNumber, Target.intScaleSetupId = Source.intScaleSetupId, Target.intTicketPoolId = Source.intTicketPoolId, Target.intTicketLocationId = Source.intTicketLocationId, Target.intTicketType = Source.intTicketType, Target.strInOutFlag = Source.strInOutFlag, Target.dtmTicketDateTime = Source.dtmTicketDateTime, Target.dtmTicketTransferDateTime = Source.dtmTicketTransferDateTime, Target.dtmTicketVoidDateTime = Source.dtmTicketVoidDateTime, Target.intProcessingLocationId = Source.intProcessingLocationId, Target.strScaleOperatorUser = Source.strScaleOperatorUser, Target.intEntityScaleOperatorId = Source.intEntityScaleOperatorId, Target.strTruckName = Source.strTruckName, Target.strDriverName = Source.strDriverName, Target.ysnDriverOff = Source.ysnDriverOff, Target.ysnSplitWeightTicket = Source.ysnSplitWeightTicket, Target.ysnGrossManual = Source.ysnGrossManual, Target.dblGrossWeight = Source.dblGrossWeight, Target.dblGrossWeightOriginal = Source.dblGrossWeightOriginal, Target.dblGrossWeightSplit1 = Source.dblGrossWeightSplit1, Target.dblGrossWeightSplit2 = Source.dblGrossWeightSplit2, Target.dtmGrossDateTime = Source.dtmGrossDateTime, Target.intGrossUserId = Source.intGrossUserId, Target.ysnTareManual = Source.ysnTareManual, Target.dblTareWeight = Source.dblTareWeight, Target.dblTareWeightOriginal = Source.dblTareWeightOriginal, Target.dblTareWeightSplit1 = Source.dblTareWeightSplit1, Target.dblTareWeightSplit2 = Source.dblTareWeightSplit2, Target.dtmTareDateTime = Source.dtmTareDateTime, Target.intTareUserId = Source.intTareUserId, Target.dblGrossUnits = Source.dblGrossUnits, Target.dblNetUnits = Source.dblNetUnits, Target.strItemNumber = Source.strItemNumber, Target.strItemUOM = Source.strItemUOM, Target.intCustomerId = Source.intCustomerId, Target.intSplitId = Source.intSplitId, Target.strDistributionOption = Source.strDistributionOption, Target.intDiscountSchedule = Source.intDiscountSchedule, Target.strDiscountLocation = Source.strDiscountLocation, Target.dtmDeferDate = Source.dtmDeferDate, Target.strContractNumber = Source.strContractNumber, Target.intContractSequence = Source.intContractSequence, Target.strContractLocation = Source.strContractLocation, Target.dblUnitPrice = Source.dblUnitPrice, Target.dblUnitBasis = Source.dblUnitBasis, Target.dblTicketFees = Source.dblTicketFees, Target.intCurrencyId = Source.intCurrencyId, Target.dblCurrencyRate = Source.dblCurrencyRate, Target.strTicketComment = Source.strTicketComment, Target.strCustomerReference = Source.strCustomerReference, Target.ysnTicketPrinted = Source.ysnTicketPrinted, Target.ysnPlantTicketPrinted = Source.ysnPlantTicketPrinted, Target.ysnGradingTagPrinted = Source.ysnGradingTagPrinted, Target.intHaulerId = Source.intHaulerId, Target.intFreightCarrierId = Source.intFreightCarrierId, Target.dblFreightRate = Source.dblFreightRate, Target.dblFreightAdjustment = Source.dblFreightAdjustment, Target.intFreightCurrencyId = Source.intFreightCurrencyId, Target.dblFreightCurrencyRate = Source.dblFreightCurrencyRate, Target.strFreightCContractNumber = Source.strFreightCContractNumber, Target.ysnFarmerPaysFreight = Source.ysnFarmerPaysFreight, Target.strLoadNumber = Source.strLoadNumber, Target.intLoadLocationId = Source.intLoadLocationId, Target.intAxleCount = Source.intAxleCount, Target.strBinNumber = Source.strBinNumber, Target.strPitNumber = Source.strPitNumber, Target.intGradingFactor = Source.intGradingFactor, Target.strVarietyType = Source.strVarietyType, Target.strFarmNumber = Source.strFarmNumber, Target.strFieldNumber = Source.strFieldNumber, Target.strDiscountComment = Source.strDiscountComment, Target.strCommodityCode = Source.strCommodityCode, Target.intCommodityId = Source.intCommodityId, Target.intDiscountId = Source.intDiscountId, Target.intContractId = Source.intContractId, Target.intDiscountLocationId = Source.intDiscountLocationId, Target.intItemId = Source.intItemId, Target.intEntityId = Source.intEntityId, Target.intLoadId = Source.intLoadId, Target.intMatchTicketId = Source.intMatchTicketId, Target.intSubLocationId = Source.intSubLocationId, Target.intStorageLocationId = Source.intStorageLocationId, Target.intFarmFieldId = Source.intFarmFieldId, Target.intDistributionMethod = Source.intDistributionMethod, Target.intSplitInvoiceOption = Source.intSplitInvoiceOption, Target.intDriverEntityId = Source.intDriverEntityId, Target.intStorageScheduleId = Source.intStorageScheduleId, Target.intConcurrencyId = Source.intConcurrencyId, Target.dblNetWeightDestination = Source.dblNetWeightDestination, Target.ysnUseDestinationWeight = Source.ysnUseDestinationWeight, Target.ysnUseDestinationGrades = Source.ysnUseDestinationGrades, Target.ysnHasGeneratedTicketNumber = Source.ysnHasGeneratedTicketNumber, Target.intInventoryTransferId = Source.intInventoryTransferId, Target.intInventoryReceiptId = Source.intInventoryReceiptId, Target.dblShrink = Source.dblShrink, Target.dblConvertedUOMQty = Source.dblConvertedUOMQty
			--, Target.intItemUOMIdFrom = Source.intItemUOMIdFrom, Target.intItemUOMIdTo = Source.intItemUOMIdTo, Target.ysnCusVenPaysFees = Source.ysnCusVenPaysFees, Target.ysnRailCar = Source.ysnRailCar, Target.dtmGrossDateTime1 = Source.dtmGrossDateTime1, Target.dtmGrossDateTime2 = Source.dtmGrossDateTime2, Target.ysnGross1Manual = Source.ysnGross1Manual, Target.ysnGross2Manual = Source.ysnGross2Manual, Target.dtmTareDateTime1 = Source.dtmTareDateTime1, Target.dtmTareDateTime2 = Source.dtmTareDateTime2, Target.ysnTare1Manual = Source.ysnTare1Manual, Target.ysnTare2Manual = Source.ysnTare2Manual, Target.intDeliverySheetId = Source.intDeliverySheetId 
   --     WHEN NOT MATCHED BY TARGET THEN
   --         INSERT (intTicketId, strTicketStatus, strTicketNumber, intScaleSetupId, intTicketPoolId, intTicketLocationId, intTicketType, strInOutFlag, dtmTicketDateTime, dtmTicketTransferDateTime, dtmTicketVoidDateTime, intProcessingLocationId, strScaleOperatorUser, intEntityScaleOperatorId, strTruckName, strDriverName, ysnDriverOff, ysnSplitWeightTicket, ysnGrossManual, dblGrossWeight, dblGrossWeightOriginal, dblGrossWeightSplit1, dblGrossWeightSplit2, dtmGrossDateTime, intGrossUserId, ysnTareManual, dblTareWeight, dblTareWeightOriginal, dblTareWeightSplit1, dblTareWeightSplit2, dtmTareDateTime, intTareUserId, dblGrossUnits, dblNetUnits, strItemNumber, strItemUOM, intCustomerId, intSplitId, strDistributionOption, intDiscountSchedule, strDiscountLocation, dtmDeferDate, strContractNumber, intContractSequence, strContractLocation, dblUnitPrice, dblUnitBasis, dblTicketFees, intCurrencyId, dblCurrencyRate, strTicketComment, strCustomerReference, ysnTicketPrinted, ysnPlantTicketPrinted, ysnGradingTagPrinted, intHaulerId, intFreightCarrierId, dblFreightRate, dblFreightAdjustment, intFreightCurrencyId, dblFreightCurrencyRate, strFreightCContractNumber, ysnFarmerPaysFreight, strLoadNumber, intLoadLocationId, intAxleCount, strBinNumber, strPitNumber, intGradingFactor, strVarietyType, strFarmNumber, strFieldNumber, strDiscountComment, strCommodityCode, intCommodityId, intDiscountId, intContractId, intDiscountLocationId, intItemId, intEntityId, intLoadId, intMatchTicketId, intSubLocationId, intStorageLocationId, intFarmFieldId, intDistributionMethod, intSplitInvoiceOption, intDriverEntityId, intStorageScheduleId, intConcurrencyId, dblNetWeightDestination, ysnUseDestinationWeight, ysnUseDestinationGrades, ysnHasGeneratedTicketNumber, intInventoryTransferId, intInventoryReceiptId, dblShrink, dblConvertedUOMQty, intItemUOMIdFrom, intItemUOMIdTo, ysnCusVenPaysFees
   --         , ysnRailCar, dtmGrossDateTime1, dtmGrossDateTime2, ysnGross1Manual, ysnGross2Manual, dtmTareDateTime1, dtmTareDateTime2, ysnTare1Manual, ysnTare2Manual ,intDeliverySheetId , intLotId , strLotNumber)
   --         VALUES (Source.intTicketId, Source.strTicketStatus, Source.strTicketNumber, Source.intScaleSetupId, Source.intTicketPoolId, Source.intTicketLocationId, Source.intTicketType, Source.strInOutFlag, Source.dtmTicketDateTime, Source.dtmTicketTransferDateTime, Source.dtmTicketVoidDateTime, Source.intProcessingLocationId, Source.strScaleOperatorUser, Source.intEntityScaleOperatorId, Source.strTruckName, Source.strDriverName, Source.ysnDriverOff, Source.ysnSplitWeightTicket, Source.ysnGrossManual, Source.dblGrossWeight, Source.dblGrossWeightOriginal, Source.dblGrossWeightSplit1, Source.dblGrossWeightSplit2, Source.dtmGrossDateTime, Source.intGrossUserId, Source.ysnTareManual, Source.dblTareWeight, Source.dblTareWeightOriginal, Source.dblTareWeightSplit1, Source.dblTareWeightSplit2, Source.dtmTareDateTime, Source.intTareUserId, Source.dblGrossUnits, Source.dblNetUnits, Source.strItemNumber, Source.strItemUOM, Source.intCustomerId, Source.intSplitId, Source.strDistributionOption, Source.intDiscountSchedule, Source.strDiscountLocation, Source.dtmDeferDate, Source.strContractNumber, Source.intContractSequence, Source.strContractLocation, Source.dblUnitPrice, Source.dblUnitBasis, Source.dblTicketFees, Source.intCurrencyId, Source.dblCurrencyRate, Source.strTicketComment, Source.strCustomerReference, Source.ysnTicketPrinted, Source.ysnPlantTicketPrinted, Source.ysnGradingTagPrinted, Source.intHaulerId, Source.intFreightCarrierId, Source.dblFreightRate, Source.dblFreightAdjustment, Source.intFreightCurrencyId, Source.dblFreightCurrencyRate, Source.strFreightCContractNumber, Source.ysnFarmerPaysFreight, Source.strLoadNumber, Source.intLoadLocationId, Source.intAxleCount, Source.strBinNumber, Source.strPitNumber, Source.intGradingFactor, Source.strVarietyType, Source.strFarmNumber, Source.strFieldNumber, Source.strDiscountComment, Source.strCommodityCode, Source.intCommodityId, Source.intDiscountId, Source.intContractId, Source.intDiscountLocationId, Source.intItemId, Source.intEntityId, Source.intLoadId, Source.intMatchTicketId, Source.intSubLocationId, Source.intStorageLocationId, Source.intFarmFieldId, Source.intDistributionMethod, Source.intSplitInvoiceOption, Source.intDriverEntityId, Source.intStorageScheduleId, Source.intConcurrencyId, Source.dblNetWeightDestination, Source.ysnUseDestinationWeight, Source.ysnUseDestinationGrades, Source.ysnHasGeneratedTicketNumber, Source.intInventoryTransferId, Source.intInventoryReceiptId, Source.dblShrink, Source.dblConvertedUOMQty, Source.intItemUOMIdFrom, Source.intItemUOMIdTo, Source.ysnCusVenPaysFees
   --         , Source.ysnRailCar, Source.dtmGrossDateTime1, Source.dtmGrossDateTime2, Source.ysnGross1Manual, Source.ysnGross2Manual, Source.dtmTareDateTime1, Source.dtmTareDateTime2, Source.ysnTare1Manual, Source.ysnTare2Manual , Source.intDeliverySheetId , Source.intLotId , Source.strLotNumber)
   --     WHEN NOT MATCHED BY SOURCE THEN
   --         DELETE;';

   -- SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
   -- SET IDENTITY_INSERT tblSCTicket ON
   -- EXECUTE sp_executesql @SQLString;
   -- SET IDENTITY_INSERT tblSCTicket OFF

    -- tblSCTicketFormat
    SET @SQLString = N'MERGE tblSCTicketFormat AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketFormat]) AS Source
        ON (Target.intTicketFormatId = Source.intTicketFormatId)
        WHEN MATCHED THEN
            UPDATE SET Target.strTicketFormat = Source.strTicketFormat, Target.intTicketFormatSelection = Source.intTicketFormatSelection, Target.ysnSuppressCompanyName = Source.ysnSuppressCompanyName, Target.ysnFormFeedEachCopy = Source.ysnFormFeedEachCopy, Target.strTicketHeader = Source.strTicketHeader, Target.strTicketFooter = Source.strTicketFooter, Target.intConcurrencyId = Source.intConcurrencyId
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intTicketFormatId
			,strTicketFormat
			,intTicketFormatSelection
			,ysnSuppressCompanyName
			,ysnFormFeedEachCopy
			,intSuppressDiscountOptionId
			,strTicketHeader
			,strTicketFooter
			,intConcurrencyId
		)
		VALUES(
			Source.intTicketFormatId
			,Source.strTicketFormat
			,Source.intTicketFormatSelection
			,Source.ysnSuppressCompanyName
			,Source.ysnFormFeedEachCopy
			,Source.intSuppressDiscountOptionId
			,Source.strTicketHeader
			,Source.strTicketFooter
			,Source.intConcurrencyId
		)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblSCTicketPool
    SET @SQLString = N'MERGE tblSCTicketPool AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketPool]) AS Source
        ON (Target.intTicketPoolId = Source.intTicketPoolId)
        WHEN MATCHED THEN
            UPDATE SET Target.strTicketPool = Source.strTicketPool, Target.intNextTicketNumber = Source.intNextTicketNumber, Target.intConcurrencyId = Source.intConcurrencyId
		WHEN NOT MATCHED BY TARGET THEN
		INSERT(
			intTicketPoolId
			,strTicketPool
			,intNextTicketNumber
			,ysnActive
			,intConcurrencyId
		)
		VALUES(
			Source.intTicketPoolId
			,Source.strTicketPool
			,Source.intNextTicketNumber
			,Source.ysnActive
			,Source.intConcurrencyId
		)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblSCTicketPrintOption
    SET @SQLString = N'MERGE tblSCTicketPrintOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketPrintOption]) AS Source
        ON (Target.intTicketPrintOptionId = Source.intTicketPrintOptionId)
        WHEN MATCHED THEN
            UPDATE SET Target.intScaleSetupId = Source.intScaleSetupId, Target.intTicketFormatId = Source.intTicketFormatId, Target.strTicketPrintDescription = Source.strTicketPrintDescription, Target.ysnPrintCustomerCopy = Source.ysnPrintCustomerCopy, Target.ysnPrintEachSplit = Source.ysnPrintEachSplit, Target.intTicketPrintCopies = Source.intTicketPrintCopies, Target.intIssueCutCode = Source.intIssueCutCode, Target.strTicketPrinter = Source.strTicketPrinter, Target.intTicketTypeOption = Source.intTicketTypeOption, Target.strInOutIndicator = Source.strInOutIndicator, Target.intPrintingOption = Source.intPrintingOption, Target.intListTicketTypeId = Source.intListTicketTypeId, Target.intConcurrencyId = Source.intConcurrencyId
		WHEN NOT MATCHED BY TARGET THEN
		INSERT (
			intTicketPrintOptionId
			,intScaleSetupId
			,intTicketFormatId
			,strTicketPrintDescription
			,ysnPrintCustomerCopy
			,ysnPrintEachSplit
			,intTicketPrintCopies
			,intIssueCutCode
			,strTicketPrinter
			,intTicketTypeOption
			,strInOutIndicator
			,intPrintingOption
			,intListTicketTypeId
			,intConcurrencyId
		)
		VALUES(
			Source.intTicketPrintOptionId
			,Source.intScaleSetupId
			,Source.intTicketFormatId
			,Source.strTicketPrintDescription
			,Source.ysnPrintCustomerCopy
			,Source.ysnPrintEachSplit
			,Source.intTicketPrintCopies
			,Source.intIssueCutCode
			,Source.strTicketPrinter
			,Source.intTicketTypeOption
			,Source.strInOutIndicator
			,Source.intPrintingOption
			,Source.intListTicketTypeId
			,Source.intConcurrencyId
		)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

    -- tblSCTicketSplit
    SET @SQLString = N'MERGE tblSCTicketSplit AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketSplit]) AS Source
        ON (Target.intTicketSplitId = Source.intTicketSplitId)
        WHEN MATCHED THEN
            UPDATE SET Target.intTicketId = Source.intTicketId, Target.intCustomerId = Source.intCustomerId, Target.dblSplitPercent = Source.dblSplitPercent, Target.strDistributionOption = Source.strDistributionOption, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTicketSplitId, intTicketId, intCustomerId, dblSplitPercent, strDistributionOption, intConcurrencyId)
            VALUES (Source.intTicketSplitId, Source.intTicketId, Source.intCustomerId, Source.dblSplitPercent, Source.strDistributionOption, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCTicketSplit ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketSplit OFF

    -- tblSCTruckDriverReference
    SET @SQLString = N'MERGE tblSCTruckDriverReference AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTruckDriverReference]) AS Source
        ON (Target.intTruckDriverReferenceId = Source.intTruckDriverReferenceId)
        WHEN MATCHED THEN
            UPDATE SET Target.intEntityId = Source.intEntityId, Target.strRecordType = Source.strRecordType, Target.strData = Source.strData, Target.intConcurrencyId = Source.intConcurrencyId
        WHEN NOT MATCHED BY TARGET THEN
            INSERT (intTruckDriverReferenceId, intEntityId, strRecordType, strData, intConcurrencyId)
            VALUES (Source.intTruckDriverReferenceId, Source.intEntityId, Source.strRecordType, Source.strData, Source.intConcurrencyId)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCTruckDriverReference ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTruckDriverReference OFF

    -- tblSCTicketCost
    SET @SQLString = N'MERGE tblSCTicketCost AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketCost]) AS Source
        ON (Target.intTicketCostId = Source.intTicketCostId)
        WHEN MATCHED THEN
            UPDATE SET Target.intTicketId = Source.intTicketId, Target.intConcurrencyId = Source.intConcurrencyId, Target.intItemId = Source.intItemId, Target.intEntityVendorId = Source.intEntityVendorId, Target.strCostMethod = Source.strCostMethod, Target.dblRate = Source.dblRate, Target.intItemUOMId = Source.intItemUOMId, Target.ysnAccrue = Source.ysnAccrue, Target.ysnMTM = Source.ysnMTM, Target.ysnPrice = Source.ysnPrice
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    EXECUTE sp_executesql @SQLString;

END