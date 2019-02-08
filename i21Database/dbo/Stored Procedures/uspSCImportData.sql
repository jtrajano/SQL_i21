﻿CREATE PROCEDURE [dbo].[uspSCImportData]
	@xmlParam1 NVARCHAR(MAX) = NULL,
	@xmlParam2  NVARCHAR(MAX) = NULL,
	@xmlParam3  NVARCHAR(MAX) = NULL,
	@ysnDeliverySheet BIT
AS
BEGIN TRY
	DECLARE @ErrMsg NVARCHAR(MAX)
	DECLARE @xmlDocumentId INT;

	IF LTRIM(RTRIM(@xmlParam1)) = ''
		SET @xmlParam1 = NULL
	IF LTRIM(RTRIM(@xmlParam2)) = ''
		SET @xmlParam2 = NULL
	IF LTRIM(RTRIM(@xmlParam3)) = ''
		SET @xmlParam3 = NULL

	IF @ysnDeliverySheet = 0
	BEGIN
		--SCALE TICKET
		DECLARE @temp_xml_table TABLE 
		(
			[intTicketId] INT NOT NULL , 
			[strTicketStatus] NVARCHAR COLLATE Latin1_General_CI_AS NOT NULL, 
			[strTicketNumber] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
			[intScaleSetupId] INT NOT NULL,
			[intTicketPoolId] INT NOT NULL,
			[intTicketLocationId] INT NOT NULL, 
			[intTicketType] INT NOT NULL, 
			[strInOutFlag] NVARCHAR COLLATE Latin1_General_CI_AS NOT NULL, 
			[dtmTicketDateTime] DATETIME NULL, 
			[dtmTicketTransferDateTime] DATETIME NULL, 
			[dtmTicketVoidDateTime] DATETIME NULL, 
			[intProcessingLocationId] INT NULL, 
			[intTransferLocationId] INT NULL,
			[strScaleOperatorUser] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
			[intEntityScaleOperatorId] INT NULL, 
			[strTruckName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
			[strDriverName] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL, 
			[ysnDriverOff] BIT NULL, 
			[ysnSplitWeightTicket] BIT NULL, 
			[ysnGrossManual] BIT NULL, 
			[ysnGross1Manual] BIT NULL, 
			[ysnGross2Manual] BIT NULL, 
			[dblGrossWeight] DECIMAL(13, 3) NULL, 
			[dblGrossWeight1] DECIMAL(13, 3) NULL, 
			[dblGrossWeight2] DECIMAL(13, 3) NULL, 
			[dblGrossWeightOriginal] DECIMAL(13, 3) NULL, 
			[dblGrossWeightSplit1] DECIMAL(13, 3) NULL, 
			[dblGrossWeightSplit2] DECIMAL(13, 3) NULL, 
			[dtmGrossDateTime] DATETIME NULL, 
			[dtmGrossDateTime1] DATETIME NULL, 
			[dtmGrossDateTime2] DATETIME NULL, 
			[intGrossUserId] INT NULL, 
			[ysnTareManual] BIT NULL, 
			[ysnTare1Manual] BIT NULL, 
			[ysnTare2Manual] BIT NULL, 
			[dblTareWeight] DECIMAL(13, 3) NULL, 
			[dblTareWeight1] DECIMAL(13, 3) NULL, 
			[dblTareWeight2] DECIMAL(13, 3) NULL, 
			[dblTareWeightOriginal] DECIMAL(13, 3) NULL, 
			[dblTareWeightSplit1] DECIMAL(13, 3) NULL, 
			[dblTareWeightSplit2] DECIMAL(13, 3) NULL, 
			[dtmTareDateTime] DATETIME NULL, 
			[dtmTareDateTime1] DATETIME NULL, 
			[dtmTareDateTime2] DATETIME NULL, 
			[intTareUserId] INT NULL, 
			[dblGrossUnits] NUMERIC(38, 20) NULL, 
			[dblShrink] NUMERIC(38, 20) NULL,
			[dblNetUnits] NUMERIC(38, 20) NULL, 
			[strItemUOM] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
			[intCustomerId] INT NULL, 
			[intSplitId] INT NULL, 
			[strDistributionOption] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
			[intDiscountSchedule] INT NULL, 
			[strDiscountLocation] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL, 
			[dtmDeferDate] DATETIME NULL, 
			[strContractNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
			[intContractSequence] INT NULL, 
			[strContractLocation] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
			[dblUnitPrice] NUMERIC(38, 20) NULL, 
			[dblUnitBasis] NUMERIC(38, 20) NULL, 
			[dblTicketFees] NUMERIC(38, 20) NULL, 
			[intCurrencyId] INT NULL, 
			[dblCurrencyRate] NUMERIC(38, 20) NULL, 
			[strTicketComment] NVARCHAR(80) COLLATE Latin1_General_CI_AS NULL, 
			[strCustomerReference] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL, 
			[ysnTicketPrinted] BIT NULL, 
			[ysnPlantTicketPrinted] BIT NULL, 
			[ysnGradingTagPrinted] BIT NULL, 
			[intHaulerId] INT NULL, 
			[intFreightCarrierId] INT NULL, 
			[dblFreightRate] NUMERIC(38, 20) NULL, 
			[ysnFarmerPaysFreight] BIT NULL, 
			[ysnCusVenPaysFees] BIT NOT NULL, 
			[strLoadNumber] NVARCHAR(8) COLLATE Latin1_General_CI_AS NULL, 
			[intLoadLocationId] INT NULL, 
			[intAxleCount] INT NULL, 
			[strPitNumber] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
			[intGradingFactor] INT NULL, 
			[strVarietyType] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
			[strFarmNumber] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
			[strFieldNumber] NVARCHAR(10) COLLATE Latin1_General_CI_AS NULL, 
			[strDiscountComment] NVARCHAR(40) COLLATE Latin1_General_CI_AS NULL,
			[intCommodityId] INT NULL,
			[intDiscountId] INT NULL,
			[intContractId] INT NULL,
			[intContractCostId] INT NULL,
			[intDiscountLocationId] INT NULL,
			[intItemId] INT NULL,
			[intEntityId] INT NULL,
			[intLoadId] INT NULL,
			[intMatchTicketId] INT NULL,
			[intSubLocationId] INT NULL,
			[intStorageLocationId] INT NULL,
			[intSubLocationToId] INT NULL,
			[intStorageLocationToId] INT NULL,
			[intFarmFieldId] INT NULL,
			[intDistributionMethod] INT NULL, 
			[intSplitInvoiceOption] INT NULL, 
			[intDriverEntityId] INT NULL,
			[intStorageScheduleId] INT NULL,
			[dblNetWeightDestination] NUMERIC(38, 20) NULL, 
			[ysnHasGeneratedTicketNumber] BIT NULL, 
			[dblScheduleQty] DECIMAL(13, 6) NULL,
			[dblConvertedUOMQty] NUMERIC(38, 20) NULL,
			[dblContractCostConvertedUOM] NUMERIC(38, 20) NULL,
			[intItemUOMIdFrom] INT NULL, 
			[intItemUOMIdTo] INT NULL,
			[intTicketTypeId] INT NULL,
			[intStorageScheduleTypeId] INT NULL,
			[strFreightSettlement]  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
			[strCostMethod]  NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
			[intGradeId] INT NULL,
			[intWeightId] INT NULL,
			[intDeliverySheetId] INT NULL,
			[intCommodityAttributeId] INT NULL,
			[strElevatorReceiptNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
			[ysnRailCar] BIT DEFAULT 0 NOT NULL,
			[intLotId] INT NULL, 
			[strLotNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL DEFAULT '',
			[intSalesOrderId] INT NULL, 
			[strPlateNumber] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
			[blbPlateNumber] VARBINARY(MAX) NULL,
			[ysnDestinationWeightGradePost] BIT NOT NULL DEFAULT 0, 
			[ysnReadyToTransfer] BIT NOT NULL DEFAULT 0, 
			[ysnExport] BIT NOT NULL DEFAULT 0
		)
		EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam1
	
		INSERT INTO @temp_xml_table
		SELECT *
		FROM OPENXML(@xmlDocumentId, 'DocumentElement/tblSCTicket', 2) WITH 
		(
			[intTicketId] INT, 
			[strTicketStatus] NVARCHAR, 
			[strTicketNumber] NVARCHAR(40), 
			[intScaleSetupId] INT,
			[intTicketPoolId] INT,
			[intTicketLocationId] INT, 
			[intTicketType] INT, 
			[strInOutFlag] NVARCHAR, 
			[dtmTicketDateTime] DATETIME, 
			[dtmTicketTransferDateTime] DATETIME, 
			[dtmTicketVoidDateTime] DATETIME, 
			[intProcessingLocationId] INT, 
			[intTransferLocationId] INT,
			[strScaleOperatorUser] NVARCHAR(40), 
			[intEntityScaleOperatorId] INT, 
			[strTruckName] NVARCHAR(40), 
			[strDriverName] NVARCHAR(40), 
			[ysnDriverOff] BIT, 
			[ysnSplitWeightTicket] BIT, 
			[ysnGrossManual] BIT, 
			[ysnGross1Manual] BIT, 
			[ysnGross2Manual] BIT, 
			[dblGrossWeight] DECIMAL(13, 3), 
			[dblGrossWeight1] DECIMAL(13, 3), 
			[dblGrossWeight2] DECIMAL(13, 3), 
			[dblGrossWeightOriginal] DECIMAL(13, 3), 
			[dblGrossWeightSplit1] DECIMAL(13, 3), 
			[dblGrossWeightSplit2] DECIMAL(13, 3), 
			[dtmGrossDateTime] DATETIME, 
			[dtmGrossDateTime1] DATETIME, 
			[dtmGrossDateTime2] DATETIME, 
			[intGrossUserId] INT, 
			[ysnTareManual] BIT, 
			[ysnTare1Manual] BIT, 
			[ysnTare2Manual] BIT, 
			[dblTareWeight] DECIMAL(13, 3), 
			[dblTareWeight1] DECIMAL(13, 3), 
			[dblTareWeight2] DECIMAL(13, 3), 
			[dblTareWeightOriginal] DECIMAL(13, 3), 
			[dblTareWeightSplit1] DECIMAL(13, 3), 
			[dblTareWeightSplit2] DECIMAL(13, 3), 
			[dtmTareDateTime] DATETIME, 
			[dtmTareDateTime1] DATETIME, 
			[dtmTareDateTime2] DATETIME, 
			[intTareUserId] INT, 
			[dblGrossUnits] NUMERIC(38, 20), 
			[dblShrink] NUMERIC(38, 20),
			[dblNetUnits] NUMERIC(38, 20), 
			[strItemUOM] NVARCHAR(50),
			[intCustomerId] INT, 
			[intSplitId] INT, 
			[strDistributionOption] NVARCHAR(30), 
			[intDiscountSchedule] INT, 
			[strDiscountLocation] NVARCHAR(3), 
			[dtmDeferDate] DATETIME, 
			[strContractNumber] NVARCHAR(50), 
			[intContractSequence] INT, 
			[strContractLocation] NVARCHAR(50), 
			[dblUnitPrice] NUMERIC(38, 20), 
			[dblUnitBasis] NUMERIC(38, 20), 
			[dblTicketFees] NUMERIC(38, 20), 
			[intCurrencyId] INT, 
			[dblCurrencyRate] NUMERIC(38, 20), 
			[strTicketComment] NVARCHAR(80), 
			[strCustomerReference] NVARCHAR(20), 
			[ysnTicketPrinted] BIT, 
			[ysnPlantTicketPrinted] BIT, 
			[ysnGradingTagPrinted] BIT, 
			[intHaulerId] INT, 
			[intFreightCarrierId] INT, 
			[dblFreightRate] NUMERIC(38, 20), 
			[ysnFarmerPaysFreight] BIT, 
			[ysnCusVenPaysFees] BIT, 
			[strLoadNumber] NVARCHAR(8), 
			[intLoadLocationId] INT, 
			[intAxleCount] INT, 
			[strPitNumber] NVARCHAR(100), 
			[intGradingFactor] INT, 
			[strVarietyType] NVARCHAR(10), 
			[strFarmNumber] NVARCHAR(10), 
			[strFieldNumber] NVARCHAR(10), 
			[strDiscountComment] NVARCHAR(40),
			[intCommodityId] INT,
			[intDiscountId] INT,
			[intContractId] INT,
			[intContractCostId] INT,
			[intDiscountLocationId] INT,
			[intItemId] INT,
			[intEntityId] INT,
			[intLoadId] INT,
			[intMatchTicketId] INT,
			[intSubLocationId] INT,
			[intStorageLocationId] INT,
			[intSubLocationToId] INT,
			[intStorageLocationToId] INT,
			[intFarmFieldId] INT,
			[intDistributionMethod] INT, 
			[intSplitInvoiceOption] INT, 
			[intDriverEntityId] INT,
			[intStorageScheduleId] INT,
			[dblNetWeightDestination] NUMERIC(38, 20), 
			[ysnHasGeneratedTicketNumber] BIT, 
			[dblScheduleQty] DECIMAL(13, 6),
			[dblConvertedUOMQty] NUMERIC(38, 20),
			[dblContractCostConvertedUOM] NUMERIC(38, 20),
			[intItemUOMIdFrom] INT, 
			[intItemUOMIdTo] INT,
			[intTicketTypeId] INT,
			[intStorageScheduleTypeId] INT,
			[strFreightSettlement] NVARCHAR(100),
			[strCostMethod] NVARCHAR(100),
			[intGradeId] INT,
			[intWeightId] INT,
			[intDeliverySheetId] INT,
			[intCommodityAttributeId] INT,
			[strElevatorReceiptNumber] NVARCHAR(50),
			[ysnRailCar] BIT,
			[intLotId] INT, 
			[strLotNumber] NVARCHAR(50),
			[intSalesOrderId] INT, 
			[strPlateNumber] NVARCHAR(50),
			[blbPlateNumber] VARBINARY(MAX),
			[ysnDestinationWeightGradePost] BIT, 
			[ysnReadyToTransfer] BIT, 
			[ysnExport] BIT
		)
	
		INSERT INTO tblSCTicket (
			[strTicketStatus]
			,[strTicketNumber] 
			,[intScaleSetupId]
			,[intTicketPoolId]
			,[intTicketLocationId] 
			,[intTicketType] 
			,[strInOutFlag]
			,[dtmTicketDateTime]
			,[dtmTicketTransferDateTime]
			,[dtmTicketVoidDateTime]
			,[intProcessingLocationId] 
			,[intTransferLocationId]
			,[strScaleOperatorUser] 
			,[intEntityScaleOperatorId] 
			,[strTruckName] 
			,[strDriverName] 
			,[ysnDriverOff]
			,[ysnSplitWeightTicket]
			,[ysnGrossManual]
			,[ysnGross1Manual]
			,[ysnGross2Manual]
			,[dblGrossWeight] 
			,[dblGrossWeight1] 
			,[dblGrossWeight2] 
			,[dblGrossWeightOriginal] 
			,[dblGrossWeightSplit1] 
			,[dblGrossWeightSplit2] 
			,[dtmGrossDateTime]
			,[dtmGrossDateTime1]
			,[dtmGrossDateTime2]
			,[intGrossUserId] 
			,[ysnTareManual]
			,[ysnTare1Manual]
			,[ysnTare2Manual]
			,[dblTareWeight] 
			,[dblTareWeight1] 
			,[dblTareWeight2] 
			,[dblTareWeightOriginal] 
			,[dblTareWeightSplit1] 
			,[dblTareWeightSplit2] 
			,[dtmTareDateTime]
			,[dtmTareDateTime1]
			,[dtmTareDateTime2]
			,[intTareUserId] 
			,[dblGrossUnits] 
			,[dblShrink]
			,[dblNetUnits] 
			,[strItemUOM]
			,[intCustomerId] 
			,[intSplitId] 
			,[strDistributionOption] 
			,[intDiscountSchedule] 
			,[strDiscountLocation] 
			,[dtmDeferDate]
			,[strContractNumber] 
			,[intContractSequence] 
			,[strContractLocation] 
			,[dblUnitPrice] 
			,[dblUnitBasis] 
			,[dblTicketFees] 
			,[intCurrencyId] 
			,[dblCurrencyRate] 
			,[strTicketComment] 
			,[strCustomerReference] 
			,[ysnTicketPrinted]
			,[ysnPlantTicketPrinted]
			,[ysnGradingTagPrinted]
			,[intHaulerId] 
			,[intFreightCarrierId] 
			,[dblFreightRate] 
			,[ysnFarmerPaysFreight]
			,[ysnCusVenPaysFees]
			,[strLoadNumber] 
			,[intLoadLocationId] 
			,[intAxleCount] 
			,[strPitNumber] 
			,[intGradingFactor] 
			,[strVarietyType] 
			,[strFarmNumber] 
			,[strFieldNumber] 
			,[strDiscountComment]
			,[intCommodityId]
			,[intDiscountId]
			,[intContractId]
			,[intContractCostId]
			,[intDiscountLocationId]
			,[intItemId]
			,[intEntityId]
			,[intLoadId]
			,[intMatchTicketId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[intSubLocationToId]
			,[intStorageLocationToId]
			,[intFarmFieldId]
			,[intDistributionMethod] 
			,[intSplitInvoiceOption] 
			,[intDriverEntityId]
			,[intStorageScheduleId]
			,[dblNetWeightDestination] 
			,[ysnHasGeneratedTicketNumber]
			,[dblScheduleQty]
			,[dblConvertedUOMQty]
			,[dblContractCostConvertedUOM]
			,[intItemUOMIdFrom] 
			,[intItemUOMIdTo]
			,[intTicketTypeId]
			,[intStorageScheduleTypeId]
			,[strFreightSettlement]
			,[strCostMethod]
			,[intGradeId]
			,[intWeightId]
			,[intDeliverySheetId]
			,[intCommodityAttributeId]
			,[strElevatorReceiptNumber]
			,[ysnRailCar]
			,[intLotId] 
			,[strLotNumber]
			,[intSalesOrderId] 
			,[strPlateNumber]
			,[blbPlateNumber]
			,[ysnDestinationWeightGradePost]
			,[ysnReadyToTransfer]
			,[ysnExport] 
			,[intConcurrencyId]
		)
		SELECT 
			[strTicketStatus]
			,[strTicketNumber] 
			,[intScaleSetupId]
			,[intTicketPoolId]
			,[intTicketLocationId] 
			,[intTicketType] 
			,[strInOutFlag]
			,[dtmTicketDateTime]
			,[dtmTicketTransferDateTime]
			,[dtmTicketVoidDateTime]
			,[intProcessingLocationId] 
			,[intTransferLocationId]
			,[strScaleOperatorUser] 
			,[intEntityScaleOperatorId] 
			,[strTruckName] 
			,[strDriverName] 
			,[ysnDriverOff]
			,[ysnSplitWeightTicket]
			,[ysnGrossManual]
			,[ysnGross1Manual]
			,[ysnGross2Manual]
			,[dblGrossWeight] 
			,[dblGrossWeight1] 
			,[dblGrossWeight2] 
			,[dblGrossWeightOriginal] 
			,[dblGrossWeightSplit1] 
			,[dblGrossWeightSplit2] 
			,[dtmGrossDateTime]
			,[dtmGrossDateTime1]
			,[dtmGrossDateTime2]
			,[intGrossUserId] 
			,[ysnTareManual]
			,[ysnTare1Manual]
			,[ysnTare2Manual]
			,[dblTareWeight] 
			,[dblTareWeight1] 
			,[dblTareWeight2] 
			,[dblTareWeightOriginal] 
			,[dblTareWeightSplit1] 
			,[dblTareWeightSplit2] 
			,[dtmTareDateTime]
			,[dtmTareDateTime1]
			,[dtmTareDateTime2]
			,[intTareUserId] 
			,[dblGrossUnits] 
			,[dblShrink]
			,[dblNetUnits] 
			,[strItemUOM]
			,[intCustomerId] 
			,[intSplitId] 
			,[strDistributionOption] 
			,[intDiscountSchedule] 
			,[strDiscountLocation] 
			,[dtmDeferDate]
			,[strContractNumber] 
			,[intContractSequence] 
			,[strContractLocation] 
			,[dblUnitPrice] 
			,[dblUnitBasis] 
			,[dblTicketFees] 
			,[intCurrencyId] 
			,[dblCurrencyRate] 
			,[strTicketComment] 
			,[strCustomerReference] 
			,[ysnTicketPrinted]
			,[ysnPlantTicketPrinted]
			,[ysnGradingTagPrinted]
			,[intHaulerId] 
			,[intFreightCarrierId] 
			,[dblFreightRate] 
			,[ysnFarmerPaysFreight]
			,[ysnCusVenPaysFees]
			,[strLoadNumber] 
			,[intLoadLocationId] 
			,[intAxleCount] 
			,[strPitNumber] 
			,[intGradingFactor] 
			,[strVarietyType] 
			,[strFarmNumber] 
			,[strFieldNumber] 
			,[strDiscountComment]
			,[intCommodityId]
			,[intDiscountId]
			,[intContractId]
			,[intContractCostId]
			,[intDiscountLocationId]
			,[intItemId]
			,[intEntityId]
			,[intLoadId]
			,[intMatchTicketId]
			,[intSubLocationId]
			,[intStorageLocationId]
			,[intSubLocationToId]
			,[intStorageLocationToId]
			,[intFarmFieldId]
			,[intDistributionMethod] 
			,[intSplitInvoiceOption] 
			,[intDriverEntityId]
			,[intStorageScheduleId]
			,[dblNetWeightDestination] 
			,[ysnHasGeneratedTicketNumber]
			,[dblScheduleQty]
			,[dblConvertedUOMQty]
			,[dblContractCostConvertedUOM]
			,[intItemUOMIdFrom] 
			,[intItemUOMIdTo]
			,[intTicketTypeId]
			,[intStorageScheduleTypeId]
			,[strFreightSettlement]
			,[strCostMethod]
			,[intGradeId]
			,[intWeightId]
			,[intDeliverySheetId]
			,[intCommodityAttributeId]
			,[strElevatorReceiptNumber]
			,[ysnRailCar]
			,[intLotId] 
			,[strLotNumber]
			,[intSalesOrderId] 
			,[strPlateNumber]
			,[blbPlateNumber]
			,[ysnDestinationWeightGradePost]
			,[ysnReadyToTransfer]
			,[ysnExport] 
			,1
		FROM @temp_xml_table	
	
		--SCALE TICKET DISCOUNT
		DECLARE @temp_xml_qmtable TABLE 
		(
			[intTicketDiscountId] INT NOT NULL,
			[dblGradeReading] DECIMAL(24, 10) NULL, 
			[strCalcMethod] NVARCHAR COLLATE Latin1_General_CI_AS NULL,
			[strShrinkWhat] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
			[dblShrinkPercent] DECIMAL(24, 10) NULL,  
			[dblDiscountAmount] DECIMAL(24, 10) NULL,
			[dblDiscountDue] DECIMAL(24, 10) NULL,
			[dblDiscountPaid] DECIMAL(24, 10) NULL,
			[ysnGraderAutoEntry] BIT NULL, 
			[intDiscountScheduleCodeId] INT NULL,
			[dtmDiscountPaidDate] DATETIME NULL, 	 
			[intTicketId] INT NULL, 
			[intTicketFileId] INT NULL, 
			[strSourceType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
			[intSort] INT NULL ,
			[strDiscountChargeType] NVARCHAR(30)  COLLATE Latin1_General_CI_AS NULL
		)
		EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam2

		INSERT INTO @temp_xml_qmtable
		SELECT *
		FROM OPENXML(@xmlDocumentId, 'DocumentElement/tblQMTicketDiscount', 2) WITH 
		(
			[intTicketDiscountId] INT,
			[dblGradeReading] DECIMAL(24, 10),
			[strCalcMethod] NVARCHAR,
			[strShrinkWhat] NVARCHAR(50), 
			[dblShrinkPercent] DECIMAL(24, 10),  
			[dblDiscountAmount] DECIMAL(24, 10),
			[dblDiscountDue] DECIMAL(24, 10),
			[dblDiscountPaid] DECIMAL(24, 10),
			[ysnGraderAutoEntry] BIT, 
			[intDiscountScheduleCodeId] INT,
			[dtmDiscountPaidDate] DATETIME, 	 
			[intTicketId] INT, 
			[intTicketFileId] INT, 
			[strSourceType] NVARCHAR(30),
			[intSort] INT,
			[strDiscountChargeType] NVARCHAR(30)
		)

		INSERT INTO tblQMTicketDiscount
		(
			[dblGradeReading]
			,[strCalcMethod]
			,[strShrinkWhat] 
			,[dblShrinkPercent]
			,[dblDiscountAmount]
			,[dblDiscountDue]
			,[dblDiscountPaid]
			,[ysnGraderAutoEntry] 
			,[intDiscountScheduleCodeId]
			,[dtmDiscountPaidDate] 	 
			,[intTicketId]
			,[intTicketFileId]
			,[strSourceType]
			,[intSort]
			,[strDiscountChargeType]
			,[intConcurrencyId]
		)
		SELECT  
			[dblGradeReading]					= QM.dblGradeReading
			,[strCalcMethod]					= QM.strCalcMethod			
			,[strShrinkWhat]					= QM.strShrinkWhat 
			,[dblShrinkPercent]					= QM.dblShrinkPercent
			,[dblDiscountAmount]				= QM.dblDiscountAmount
			,[dblDiscountDue]					= QM.dblDiscountDue
			,[dblDiscountPaid]					= QM.dblDiscountPaid
			,[ysnGraderAutoEntry] 				= QM.ysnGraderAutoEntry
			,[intDiscountScheduleCodeId]		= QM.intDiscountScheduleCodeId
			,[dtmDiscountPaidDate] 	 			= QM.dtmDiscountPaidDate
			,[intTicketId]						= SC.intTicketId
			,[intTicketFileId]					= NULL
			,[strSourceType]					= QM.strSourceType
			,[intSort]							= QM.intSort
			,[strDiscountChargeType]			= QM.strDiscountChargeType
			,[intConCurrencyId]					= 1
		FROM @temp_xml_qmtable QM
		INNER JOIN @temp_xml_table SCT ON SCT.intTicketId = QM.intTicketId
		INNER JOIN tblSCTicket SC ON SC.strTicketNumber = SCT.strTicketNumber 
		AND SC.intTicketPoolId = SCT.intTicketPoolId
		AND SC.intTicketType = SCT.intTicketType
		AND SC.strInOutFlag = SCT.strInOutFlag
		AND SC.intEntityId = SCT.intEntityId
		AND SC.intProcessingLocationId = SCT.intProcessingLocationId

		--SCALE TICKET SPLIT
		DECLARE @temp_xml_splittable TABLE 
		(
			[intTicketSplitId] INT NOT NULL, 
			[intTicketId] INT NOT NULL, 
			[intCustomerId] INT NOT NULL, 
			[dblSplitPercent] DECIMAL(18, 6) NOT NULL, 
			[intStorageScheduleTypeId] INT NULL,
			[strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
			[intStorageScheduleId] INT NULL
		)
		EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam3

		INSERT INTO @temp_xml_splittable
		SELECT *
		FROM OPENXML(@xmlDocumentId, 'DocumentElement/tblSCTicketSplit', 2) WITH 
		(
			[intTicketSplitId] INT, 
			[intTicketId] INT, 
			[intCustomerId] INT, 
			[dblSplitPercent] DECIMAL(18, 6), 
			[intStorageScheduleTypeId] INT,
			[strDistributionOption] NVARCHAR(3),
			[intStorageScheduleId] INT
		)

		INSERT INTO tblSCTicketSplit(
			[intTicketId], 
			[intCustomerId], 
			[dblSplitPercent], 
			[intStorageScheduleTypeId],
			[strDistributionOption],
			[intStorageScheduleId],
			[intConcurrencyId]
		)
		SELECT 
			[intTicketId]					= SC.intTicketId 
			,[intCustomerId]				= SCS.intCustomerId 
			,[dblSplitPercent]				= SCS.dblSplitPercent 
			,[intStorageScheduleTypeId]		= SCS.intStorageScheduleTypeId
			,[strDistributionOption]		= SCS.strDistributionOption
			,[intStorageScheduleId]			= SCS.intStorageScheduleId
			,[intConcurrencyId]				= 1
		FROM @temp_xml_splittable SCS
		INNER JOIN @temp_xml_table SCT ON SCT.intTicketId = SCS.intTicketId
		INNER JOIN tblSCTicket SC ON SC.strTicketNumber = SCT.strTicketNumber 
		AND SC.intTicketPoolId = SCT.intTicketPoolId
		AND SC.intTicketType = SCT.intTicketType
		AND SC.strInOutFlag = SCT.strInOutFlag
		AND SC.intEntityId = SCT.intEntityId
		AND SC.intProcessingLocationId = SCT.intProcessingLocationId
	END
	ELSE
	BEGIN
		--DELIVERY SHEET
		DECLARE @temp_xml_deliverysheet TABLE 
		(
			[intDeliverySheetId] INT NOT NULL,
			[intEntityId] INT NOT NULL, 
			[intCompanyLocationId] INT NOT NULL, 
			[intItemId] INT NULL, 
			[intDiscountId] INT NULL, 
			[strDeliverySheetNumber] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL,
			[dtmDeliverySheetDate] DATETIME NULL DEFAULT GETDATE(), 
			[intCurrencyId] INT NULL,
			[intTicketTypeId] INT NULL, 
			[intSplitId] INT NULL, 
			[strSplitDescription] NVARCHAR(255) COLLATE Latin1_General_CI_AS NOT NULL DEFAULT '',
			[intFarmFieldId] INT NULL,
			[dblGross] NUMERIC(38, 20) NULL DEFAULT ((0)),
			[dblShrink] NUMERIC(38, 20) NULL DEFAULT ((0)),
			[dblNet] NUMERIC(38, 20) NULL DEFAULT ((0)),
			[intStorageScheduleRuleId] INT NULL, 
			[intCompanyId] INT NULL,
			[ysnPost] BIT NULL DEFAULT (0),
			[ysnLockSummaryGrid] BIT NULL DEFAULT (0),
			[ysnExport] BIT NULL DEFAULT (0),
			[strCountyProducer] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		)
		EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam1

		INSERT INTO @temp_xml_deliverysheet
		SELECT *
		FROM OPENXML(@xmlDocumentId, 'DocumentElement/tblSCDeliverySheet', 2) WITH 
		(
			[intDeliverySheetId] INT,
			[intEntityId] INT, 
			[intCompanyLocationId] INT, 
			[intItemId] INT, 
			[intDiscountId] INT, 
			[strDeliverySheetNumber] NVARCHAR(MAX),
			[dtmDeliverySheetDate] DATETIME, 
			[intCurrencyId] INT,
			[intTicketTypeId] INT, 
			[intSplitId] INT, 
			[strSplitDescription] NVARCHAR(255),
			[intFarmFieldId] INT,
			[dblGross] NUMERIC(38, 20),
			[dblShrink] NUMERIC(38, 20),
			[dblNet] NUMERIC(38, 20),
			[intStorageScheduleRuleId] INT, 
			[intCompanyId] INT,
			[ysnPost] BIT,
			[ysnLockSummaryGrid] BIT,
			[ysnExport] BIT,
			[strCountyProducer] NVARCHAR(MAX)
		)

		INSERT INTO tblSCDeliverySheet (
			[intEntityId]
			,[intCompanyLocationId]
			,[intItemId]
			,[intDiscountId]
			,[strDeliverySheetNumber]
			,[dtmDeliverySheetDate]
			,[intCurrencyId]
			,[intTicketTypeId]
			,[intSplitId]
			,[strSplitDescription]
			,[intFarmFieldId]
			,[dblGross]
			,[dblShrink]
			,[dblNet]
			,[intStorageScheduleRuleId]
			,[intCompanyId]
			,[ysnPost]
			,[ysnLockSummaryGrid]
			,[ysnExport]
			,[strCountyProducer]
			,[intConcurrencyId]
		)
		SELECT  
			[intEntityId]							= SCD.intEntityId
			,[intCompanyLocationId]					= SCD.intCompanyLocationId
			,[intItemId]							= SCD.intItemId
			,[intDiscountId]						= SCD.intDiscountId
			,[strDeliverySheetNumber]				= SCD.strDeliverySheetNumber
			,[dtmDeliverySheetDate]					= SCD.dtmDeliverySheetDate
			,[intCurrencyId]						= SCD.intCurrencyId
			,[intTicketTypeId]						= SCD.intTicketTypeId
			,[intSplitId]							= SCD.intSplitId
			,[strSplitDescription]					= SCD.strSplitDescription
			,[intFarmFieldId]						= SCD.intFarmFieldId
			,[dblGross]								= SCD.dblGross
			,[dblShrink]							= SCD.dblShrink
			,[dblNet]								= SCD.dblNet
			,[intStorageScheduleRuleId]				= SCD.intStorageScheduleRuleId
			,[intCompanyId]							= SCD.intCompanyId
			,[ysnPost]								= SCD.ysnPost
			,[ysnLockSummaryGrid]					= SCD.ysnLockSummaryGrid
			,[ysnExport]							= SCD.ysnExport
			,[strCountyProducer]					= SCD.strCountyProducer
			,[intConcurrencyId]						= 1
		FROM @temp_xml_deliverysheet SCD

		--DELIVERY SHEET DISCOUNT
		DECLARE @temp_xml_qmdstable TABLE 
		(
			[intTicketDiscountId] INT NOT NULL,
			[dblGradeReading] DECIMAL(24, 10) NULL, 
			[strCalcMethod] NVARCHAR COLLATE Latin1_General_CI_AS NULL,
			[strShrinkWhat] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
			[dblShrinkPercent] DECIMAL(24, 10) NULL,  
			[dblDiscountAmount] DECIMAL(24, 10) NULL,
			[dblDiscountDue] DECIMAL(24, 10) NULL,
			[dblDiscountPaid] DECIMAL(24, 10) NULL,
			[ysnGraderAutoEntry] BIT NULL, 
			[intDiscountScheduleCodeId] INT NULL,
			[dtmDiscountPaidDate] DATETIME NULL, 	 
			[intTicketId] INT NULL, 
			[intTicketFileId] INT NULL, 
			[strSourceType] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL,
			[intSort] INT NULL ,
			[strDiscountChargeType] NVARCHAR(30)  COLLATE Latin1_General_CI_AS NULL
		)
		EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam2

		INSERT INTO @temp_xml_qmdstable
		SELECT *
		FROM OPENXML(@xmlDocumentId, 'DocumentElement/tblQMTicketDiscount', 2) WITH 
		(
			[intTicketDiscountId] INT,
			[dblGradeReading] DECIMAL(24, 10),
			[strCalcMethod] NVARCHAR,
			[strShrinkWhat] NVARCHAR(50), 
			[dblShrinkPercent] DECIMAL(24, 10),  
			[dblDiscountAmount] DECIMAL(24, 10),
			[dblDiscountDue] DECIMAL(24, 10),
			[dblDiscountPaid] DECIMAL(24, 10),
			[ysnGraderAutoEntry] BIT, 
			[intDiscountScheduleCodeId] INT,
			[dtmDiscountPaidDate] DATETIME, 	 
			[intTicketId] INT, 
			[intTicketFileId] INT, 
			[strSourceType] NVARCHAR(30),
			[intSort] INT,
			[strDiscountChargeType] NVARCHAR(30)
		)

		INSERT INTO tblQMTicketDiscount
		(
			[dblGradeReading]
			,[strCalcMethod]
			,[strShrinkWhat] 
			,[dblShrinkPercent]
			,[dblDiscountAmount]
			,[dblDiscountDue]
			,[dblDiscountPaid]
			,[ysnGraderAutoEntry] 
			,[intDiscountScheduleCodeId]
			,[dtmDiscountPaidDate] 	 
			,[intTicketId]
			,[intTicketFileId]
			,[strSourceType]
			,[intSort]
			,[strDiscountChargeType]
			,[intConcurrencyId]
		)
		SELECT  
			[dblGradeReading]					= QM.dblGradeReading
			,[strCalcMethod]					= QM.strCalcMethod			
			,[strShrinkWhat]					= QM.strShrinkWhat 
			,[dblShrinkPercent]					= QM.dblShrinkPercent
			,[dblDiscountAmount]				= QM.dblDiscountAmount
			,[dblDiscountDue]					= QM.dblDiscountDue
			,[dblDiscountPaid]					= QM.dblDiscountPaid
			,[ysnGraderAutoEntry] 				= QM.ysnGraderAutoEntry
			,[intDiscountScheduleCodeId]		= QM.intDiscountScheduleCodeId
			,[dtmDiscountPaidDate] 	 			= QM.dtmDiscountPaidDate
			,[intTicketId]						= NULL
			,[intTicketFileId]					= SCD.intDeliverySheetId
			,[strSourceType]					= QM.strSourceType
			,[intSort]							= QM.intSort
			,[strDiscountChargeType]			= QM.strDiscountChargeType
			,[intConcurrencyId]					= 1
		FROM @temp_xml_qmdstable QM
		INNER JOIN @temp_xml_deliverysheet SCD ON SCD.intDeliverySheetId = QM.intTicketFileId
		INNER JOIN tblSCDeliverySheet DS ON DS.strDeliverySheetNumber = SCD.strDeliverySheetNumber 

		--DELIVERY SHEET SUMMARY
		DECLARE @temp_xml_splitdstable TABLE 
		(
			[intDeliveySheetSplitId] INT NOT NULL,
			[intDeliverySheetId] INT NOT NULL, 
			[intEntityId] INT NOT NULL, 
			[dblSplitPercent] DECIMAL(18, 6) NOT NULL, 
			[intStorageScheduleTypeId] INT NULL,
			[strDistributionOption] NVARCHAR(3) COLLATE Latin1_General_CI_AS NULL,
			[intStorageScheduleRuleId] INT NULL
		)
		EXEC sp_xml_preparedocument @xmlDocumentId OUTPUT,@xmlParam3
		
		INSERT INTO @temp_xml_splitdstable
		SELECT *
		FROM OPENXML(@xmlDocumentId, 'DocumentElement/tblSCDeliverySheetSplit', 2) WITH 
		(
			[intDeliveySheetSplitId] INT, 
			[intDeliverySheetId] INT,
			[intEntityId] INT, 
			[dblSplitPercent] DECIMAL(18, 6), 
			[intStorageScheduleTypeId] INT,
			[strDistributionOption] NVARCHAR(3),
			[intStorageScheduleRuleId] INT
		)

		INSERT INTO tblSCDeliverySheetSplit(
			[intDeliverySheetId],
			[intEntityId], 
			[dblSplitPercent], 
			[intStorageScheduleTypeId],
			[strDistributionOption],
			[intStorageScheduleRuleId],
			[intConcurrencyId]
		)
		SELECT 
			[intDeliverySheetId]			= DS.intDeliverySheetId 
			,[intEntityId]					= SCDS.intEntityId 
			,[dblSplitPercent]				= SCDS.dblSplitPercent 
			,[intStorageScheduleTypeId]		= SCDS.intStorageScheduleTypeId
			,[strDistributionOption]		= SCDS.strDistributionOption
			,[intStorageScheduleRuleId]		= SCDS.intStorageScheduleRuleId
			,[intConcurrencyId]				= 1
		FROM @temp_xml_splitdstable SCDS
		INNER JOIN @temp_xml_deliverysheet SCD ON SCD.intDeliverySheetId = SCDS.intDeliverySheetId
		INNER JOIN tblSCDeliverySheet DS ON DS.strDeliverySheetNumber = SCD.strDeliverySheetNumber 
	END


END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,18,1,'WITH NOWAIT')
END CATCH