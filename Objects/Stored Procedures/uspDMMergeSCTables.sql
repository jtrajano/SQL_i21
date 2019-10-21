CREATE PROCEDURE [dbo].[uspDMMergeSCTables]
    @remoteDB NVARCHAR(MAX)
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON

DECLARE @SQLString NVARCHAR(MAX) = '';
DECLARE @Columns NVARCHAR(MAX),
		@InsertColumns NVARCHAR(MAX),
		@ValueColumns NVARCHAR(MAX);

BEGIN
	-- tblSCScaleSetup
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCScaleSetup' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCScaleSetup'
    
    SET @SQLString = N'MERGE tblSCScaleSetup AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCScaleSetup]) AS Source
        ON (Target.intScaleSetupId = Source.intScaleSetupId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
				)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCScaleSetup ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCScaleSetup OFF

	-- tblSCTicketPrintOption
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketPrintOption' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketPrintOption'
	
    SET @SQLString = N'MERGE tblSCTicketPrintOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketPrintOption]) AS Source
        ON (Target.intTicketPrintOptionId = Source.intTicketPrintOptionId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCTicketPrintOption ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketPrintOption OFF

	-- tblSCTicketEmailOption
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketEmailOption' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketEmailOption'
	
    SET @SQLString = N'MERGE tblSCTicketEmailOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketEmailOption]) AS Source
        ON (Target.intTicketEmailOptionId = Source.intTicketEmailOptionId)
       WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCTicketEmailOption ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketEmailOption OFF

    -- tblSCLastScaleSetup
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCLastScaleSetup' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCLastScaleSetup'

    SET @SQLString = N'MERGE tblSCLastScaleSetup AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCLastScaleSetup]) AS Source
        ON (Target.intLastScaleSetupId = Source.intLastScaleSetupId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCLastScaleSetup ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCLastScaleSetup OFF

    -- tblSCTicketType
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketType' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketType'

    SET @SQLString = N'MERGE tblSCTicketType AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketType]) AS Source
        ON (Target.intTicketTypeId = Source.intTicketTypeId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCTicketType ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketType OFF

    -- tblSCListTicketTypes
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCListTicketTypes' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCListTicketTypes'

    SET @SQLString = N'MERGE tblSCListTicketTypes AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCListTicketTypes]) AS Source
        ON (Target.intTicketTypeId = Source.intTicketTypeId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

	SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCListTicketTypes ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCListTicketTypes OFF

    -- tblSCUncompletedTicketAlert
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCUncompletedTicketAlert' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCUncompletedTicketAlert'

    SET @SQLString = N'MERGE tblSCUncompletedTicketAlert AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCUncompletedTicketAlert]) AS Source
        ON (Target.intUncompletedTicketAlertId = Source.intUncompletedTicketAlertId)
       WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCUncompletedTicketAlert ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCUncompletedTicketAlert OFF

    -- tblSCDistributionOption
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCDistributionOption' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCDistributionOption'

    SET @SQLString = N'MERGE tblSCDistributionOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCDistributionOption]) AS Source
        ON (Target.intDistributionOptionId = Source.intDistributionOptionId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';
			
    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCDistributionOption ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCDistributionOption OFF

	-- tblSCScaleDevice
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCScaleDevice' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCScaleDevice'

    SET @SQLString = N'MERGE tblSCScaleDevice AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCScaleDevice]) AS Source
        ON (Target.intScaleDeviceId = Source.intScaleDeviceId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				'+@InsertColumns+'
				
			)
			VALUES(
				'+@ValueColumns+'
				)
        WHEN NOT MATCHED BY SOURCE THEN
             DELETE;';

    SET @SQLString = 'Exec('' '  + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'

    SET IDENTITY_INSERT tblSCScaleDevice ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCScaleDevice OFF

	-- tblSCDeliverySheet
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCDeliverySheet' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCDeliverySheet'

	SET @SQLString = N'MERGE tblSCDeliverySheet AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCDeliverySheet]) AS Source
        ON (Target.intDeliverySheetId = Source.intDeliverySheetId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCDeliverySheet ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCDeliverySheet OFF

	 -- tblSCDeliverySheetSplit
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCDeliverySheetSplit' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCDeliverySheetSplit'

    SET @SQLString = N'MERGE tblSCDeliverySheetSplit AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCDeliverySheetSplit]) AS Source
        ON (Target.intDeliverySheetSplitId = Source.intDeliverySheetSplitId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCDeliverySheetSplit ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCDeliverySheetSplit OFF

	-- tblSCDeliverySheetImportingTemplate
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCDeliverySheetImportingTemplate' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCDeliverySheetImportingTemplate'

    SET @SQLString = N'MERGE tblSCDeliverySheetImportingTemplate AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCDeliverySheetImportingTemplate]) AS Source
        ON (Target.intImportingTemplateId = Source.intImportingTemplateId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCDeliverySheetImportingTemplate ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCDeliverySheetImportingTemplate OFF

	-- tblSCDeliverySheetImportingTemplateDetail
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCDeliverySheetImportingTemplateDetail' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCDeliverySheetImportingTemplateDetail'

    SET @SQLString = N'MERGE tblSCDeliverySheetImportingTemplateDetail AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCDeliverySheetImportingTemplateDetail]) AS Source
        ON (Target.intImportingTemplateDetailId = Source.intImportingTemplateDetailId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
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
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketFormat' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketFormat'

    SET @SQLString = N'MERGE tblSCTicketFormat AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketFormat]) AS Source
        ON (Target.intTicketFormatId = Source.intTicketFormatId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

	SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCTicketFormat ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketFormat OFF

    -- tblSCTicketPool
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketPool' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketPool'

    SET @SQLString = N'MERGE tblSCTicketPool AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketPool]) AS Source
        ON (Target.intTicketPoolId = Source.intTicketPoolId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

	SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCTicketPool ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketPool OFF

    -- tblSCTicketPrintOption
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketPrintOption' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketPrintOption'

    SET @SQLString = N'MERGE tblSCTicketPrintOption AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketPrintOption]) AS Source
        ON (Target.intTicketPrintOptionId = Source.intTicketPrintOptionId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

   
	SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCTicketPrintOption ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketPrintOption OFF

    -- tblSCTicketSplit
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketSplit' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketSplit'

    SET @SQLString = N'MERGE tblSCTicketSplit AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketSplit]) AS Source
        ON (Target.intTicketSplitId = Source.intTicketSplitId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCTicketSplit ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTicketSplit OFF

    -- tblSCTruckDriverReference
	SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTruckDriverReference' AND ORDINAL_POSITION > 1
	SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
			@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTruckDriverReference'

    SET @SQLString = N'MERGE tblSCTruckDriverReference AS Target
        USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTruckDriverReference]) AS Source
        ON (Target.intTruckDriverReferenceId = Source.intTruckDriverReferenceId)
        WHEN MATCHED THEN
            UPDATE SET ' + @Columns + '
		WHEN NOT MATCHED BY TARGET THEN
			INSERT (
				' + @InsertColumns + '
			)
			VALUES(
				' + @ValueColumns + '
			)
        WHEN NOT MATCHED BY SOURCE THEN
            DELETE;';

    SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
    SET IDENTITY_INSERT tblSCTruckDriverReference ON
    EXECUTE sp_executesql @SQLString;
    SET IDENTITY_INSERT tblSCTruckDriverReference OFF

    -- tblSCTicketCost
	--SELECT	@Columns = NULL, @InsertColumns = NULL, @ValueColumns = NULL
	--SELECT	@Columns = COALESCE(@Columns + ',', '') + 'Target.' + COLUMN_NAME + ' = Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketCost' AND ORDINAL_POSITION > 1
	--SELECT	@InsertColumns	=	COALESCE(@InsertColumns + ',', '') + COLUMN_NAME ,
	--		@ValueColumns	=	COALESCE(@ValueColumns + ',', '') + 'Source.' + COLUMN_NAME FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'tblSCTicketCost'

 --   SET @SQLString = N'MERGE tblSCTicketCost AS Target
 --       USING (SELECT * FROM REMOTEDBSERVER.[repDB].[dbo].[tblSCTicketCost]) AS Source
 --       ON (Target.intTicketCostId = Source.intTicketCostId)
 --       WHEN MATCHED THEN
 --           UPDATE SET ' + @Columns + '
	--	WHEN NOT MATCHED BY TARGET THEN
	--		INSERT (
	--			' + @InsertColumns + '
	--		)
	--		VALUES(
	--			' + @ValueColumns + '
	--		)
 --       WHEN NOT MATCHED BY SOURCE THEN
 --           DELETE;';

 --   SET @SQLString = 'Exec('' ' + Replace(@SQLString, 'repDB', @remoteDB) + ' '')'
 --   EXECUTE sp_executesql @SQLString;

END