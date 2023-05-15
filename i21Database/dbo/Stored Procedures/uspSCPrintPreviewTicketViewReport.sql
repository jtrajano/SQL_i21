/*
DEVELOPER'S NOTEBOOK
JIRA - SC-4751
REASON - 
	1. Procedure is faster the direct view in the reporting
	2. Please take a look at the linked jira in SC-4751. We allow printing of ticket from different scale station. 
	   Unfortunately a modification blocks that. One of the modification in the linked jira restrict printing a ticket
	   outside the selected station. That specific field is intTicketPrintOptionId, this id is one a scale station level,
	   but the view is on the scale station level also but to the scale station it is created from.
	   In order to address that, the view must be modified to use the current selected station and not the station of the ticket.
	   Only the Ticket Printing Option section of the view is changed.
	   

*/
CREATE PROCEDURE [dbo].[uspSCPrintPreviewTicketViewReport]
	@intTicketId INT = NULL
	, @intScaleSetupId INT = NULL
	, @intTicketFormatId INT = NULL
	, @intTicketPrintOptionId INT = NULL
AS

BEGIN
	IF @intTicketId = NULL
	BEGIN
		SELECT
			* 
		FROM
			vyuSCPrintPreviewTicketView
		WHERE 1 = 0

	END
	ELSE
	BEGIN		
		DECLARE @PRINT_RELATED_TABLE TABLE(
			intTicketId INT
			, intScaleSetupId INT
			, intTicketFormatId INT
			, intTicketPrintOptionId INT

			, [ysnSuppressCashPrice] BIT NULL 
			, [ysnSuppressCompanyName] BIT NULL
			, [ysnSuppressSplit] BIT NULL

			, [strTicketHeader] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
			, [strTicketFooter] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL

			, [intSuppressDiscountOptionId] INT NULL
		)

		--PUT THE VARIABLE IN THE TEMP TABLE
		--USE THE PARAMETER AS THE VALUE
		INSERT INTO @PRINT_RELATED_TABLE(intTicketId, intScaleSetupId, intTicketFormatId, intTicketPrintOptionId)
		SELECT @intTicketId, @intScaleSetupId, ISNULL(@intTicketFormatId, -1), ISNULL(@intTicketPrintOptionId, -1)
		
		IF (@intTicketPrintOptionId IS NOT NULL AND @intTicketPrintOptionId > 0)
		BEGIN
			--UPDATE THE PRINTING OPTION VALUE BASED ON THE TICKET FORMAT ID PASSED 
			UPDATE 
				PRINT_RELATED_TABLE
					SET ysnSuppressCashPrice = TICKET_FORMAT.ysnSuppressCashPrice
						, ysnSuppressCompanyName = TICKET_FORMAT.ysnSuppressCompanyName
						, ysnSuppressSplit = TICKET_FORMAT.ysnSuppressSplit

						, strTicketFooter = TICKET_FORMAT.strTicketFooter
						, strTicketHeader = TICKET_FORMAT.strTicketHeader

						, intSuppressDiscountOptionId = TICKET_FORMAT.intSuppressDiscountOptionId

			FROM @PRINT_RELATED_TABLE PRINT_RELATED_TABLE
				JOIN tblSCTicketFormat TICKET_FORMAT
					ON PRINT_RELATED_TABLE.intTicketFormatId = TICKET_FORMAT.intTicketFormatId
		END
	
		SELECT
			PRINT_PREVIEW.intTicketId
			, strTicketStatusDescription
			, strTicketStatus
			, strTicketNumber
			, PRINT_PREVIEW.intScaleSetupId
			, intTicketPoolId
			, intTicketLocationId
			, intTicketType
			, strInOutFlag
			, dtmTicketDateTime
			, dtmTicketTransferDateTime
			, dtmTicketVoidDateTime
			, intProcessingLocationId
			, strScaleOperatorUser
			, intEntityScaleOperatorId
			, strTruckName
			, ysnDriverOff
			, ysnSplitWeightTicket
			, ysnGrossManual
			, ysnGross1Manual
			, ysnGross2Manual
			, dblGrossWeight
			, dblGrossWeight1
			, dblGrossWeight2
			, dblGrossWeightOriginal
			, dblGrossWeightSplit1
			, dblGrossWeightSplit2
			, dtmGrossDateTime
			, dtmGrossDateTime1
			, dtmGrossDateTime2
			, intGrossUserId
			, ysnTareManual
			, ysnTare1Manual
			, ysnTare2Manual
			, dblTareWeight
			, dblTareWeight1
			, dblTareWeight2
			, dblTareWeightOriginal
			, dblTareWeightSplit1
			, dblTareWeightSplit2
			, dtmTareDateTime
			, dtmTareDateTime1
			, dtmTareDateTime2
			, intTareUserId
			, dblGrossUnits
			, dblNetUnits
			, strItemUOM
			, intCustomerId
			, intSplitId
			, strDistributionOption
			, intDiscountSchedule
			, strDiscountLocation
			, dtmDeferDate
			, strContractNumber
			, intContractSequence
			, strContractLocation
			, dblUnitPrice
			, dblUnitBasis
			, dblTicketFees
			, intCurrencyId
			, dblCurrencyRate
			, strTicketComment
			, strCustomerReference
			, ysnTicketPrinted
			, ysnPlantTicketPrinted
			, ysnGradingTagPrinted
			, intHaulerId
			, intFreightCarrierId
			, dblFreightRate
			, dblFreightAdjustment
			, intFreightCurrencyId
			, dblFreightCurrencyRate
			, strFreightCContractNumber
			, strFreightSettlement
			, ysnFarmerPaysFreight
			, strLoadNumber
			, intLoadLocationId
			, intAxleCount
			, intAxleCount1
			, intAxleCount2
			, strPitNumber
			, intGradingFactor
			, strVarietyType
			, strFarmNumber
			, strFieldNumber
			, strDiscountComment
			, intCommodityId
			, intDiscountId
			, intContractId
			, intDiscountLocationId
			, intItemId
			, intEntityId
			, intLoadId
			, intMatchTicketId
			, intSubLocationId
			, intStorageLocationId
			, intFarmFieldId
			, intDistributionMethod
			, intSplitInvoiceOption
			, intDriverEntityId
			, intStorageScheduleId
			, intConcurrencyId
			, dblNetWeightDestination
			, ysnHasGeneratedTicketNumber
			, intInventoryTransferId
			, dblShrink
			, dblConvertedUOMQty
			, strCostMethod
			, strElevatorReceiptNumber
			, dblCashPrice
			, intSalesOrderId
			, intDeliverySheetId
			, dtmTransactionDateTime
			, strDriverName
			, strStorageTypeDescription
			, strTicketType
			, strStationShortDescription
			, strWeightDescription
			, ysnMultipleWeights
			, ISNULL(PRINT_PREVIEW.strTicketFooter ,PRINT_RELATED_TABLE.strTicketFooter) AS strTicketFooter
			, ISNULL(PRINT_PREVIEW.strTicketHeader ,PRINT_RELATED_TABLE.strTicketHeader) AS strTicketHeader
			, ISNULL(PRINT_PREVIEW.ysnSuppressCompanyName ,PRINT_RELATED_TABLE.ysnSuppressCompanyName) AS ysnSuppressCompanyName
			, ISNULL(PRINT_PREVIEW.intSuppressDiscountOptionId ,PRINT_RELATED_TABLE.intSuppressDiscountOptionId) AS intSuppressDiscountOptionId
			, ISNULL(PRINT_PREVIEW.ysnSuppressSplit ,PRINT_RELATED_TABLE.ysnSuppressSplit) AS ysnSuppressSplit
			, ISNULL(PRINT_PREVIEW.intTicketFormatId ,PRINT_RELATED_TABLE.intTicketFormatId) AS intTicketFormatId
			, strTicketPool
			, strScaleMatchTicket
			, strMatchTicketNumber
			, strMatchLocation
			, strDeliverySheetNumber
			, strSplitDescription
			, strName
			, strEntityNo
			, strSplitNumber
			, strHaulerName
			, strLocationName
			, strSubLocationName
			, strDiscountId
			, strDescription
			, strScheduleId
			, strItemNumber
			, strItemDescription
			, strPickListComments
			, strCommodityCode
			, strCommodityDescription
			, strGrade
			, intInventoryReceiptId
			, strReceiptNumber
			, intInventoryShipmentId
			, strShipmentNumber
			, strLotNumber
			, strBinNumber
			, strSalesOrderNumber
			, strCompanyName
			, strScaleLocationName
			, strAddress
			, blbSignature
			, intUserId
			, intDecimalPrecision
			, ISNULL(PRINT_PREVIEW.ysnSuppressCashPrice ,PRINT_RELATED_TABLE.ysnSuppressCashPrice) AS ysnSuppressCashPrice 
			, strSealNumbers
			, strTimezone
			, strTrailerId
			, ISNULL(PRINT_PREVIEW.intTicketPrintOptionId, PRINT_RELATED_TABLE.intTicketPrintOptionId) AS intTicketPrintOptionId
			, strDestinationLocationName
			, strDestinationSubLocation
			, strDestinationStorageLocation


			, strLoadAddress
			, strEntityDefaultLocationAddress
			, ysnShowLoadOutAddressForFullSheetTicket

		FROM
			vyuSCPrintPreviewTicketView PRINT_PREVIEW
		JOIN @PRINT_RELATED_TABLE PRINT_RELATED_TABLE
			ON PRINT_PREVIEW.intTicketId = PRINT_RELATED_TABLE.intTicketId
		WHERE PRINT_PREVIEW.intTicketId = @intTicketId
	END
	
END
