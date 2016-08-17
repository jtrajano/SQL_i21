﻿CREATE VIEW [dbo].[vyuSCTicketAlertView]
	AS SELECT 
	SCTicket.intTicketId
	,SCAlert.intTicketUncompletedDaysAlert
	,SCAlert.intEntityId AS intUserId
	,SCAlert.intCompanyLocationId
	,SCTicket.strTicketStatusDescription
	,SCTicket.strTicketStatus
    ,SCTicket.strTicketNumber
    ,SCTicket.intScaleSetupId
    ,SCTicket.intTicketPoolId
    ,SCTicket.intTicketLocationId
    ,SCTicket.intTicketType
    ,SCTicket.strInOutFlag
    ,SCTicket.dtmTicketDateTime
    ,SCTicket.dtmTicketTransferDateTime
    ,SCTicket.dtmTicketVoidDateTime
    ,SCTicket.intProcessingLocationId
    ,SCTicket.strScaleOperatorUser
    ,SCTicket.intScaleOperatorId
    ,SCTicket.strPurchaseOrderNumber
    ,SCTicket.strTruckName
    ,SCTicket.strDriverName
    ,SCTicket.ysnDriverOff
    ,SCTicket.ysnSplitWeightTicket
    ,SCTicket.ysnGrossManual
    ,SCTicket.dblGrossWeight
    ,SCTicket.dblGrossWeightOriginal
    ,SCTicket.dblGrossWeightSplit1
    ,SCTicket.dblGrossWeightSplit2
    ,SCTicket.dtmGrossDateTime
    ,SCTicket.intGrossUserId
    ,SCTicket.ysnTareManual
    ,SCTicket.dblTareWeight
    ,SCTicket.dblTareWeightOriginal
    ,SCTicket.dblTareWeightSplit1
    ,SCTicket.dblTareWeightSplit2
    ,SCTicket.dtmTareDateTime
    ,SCTicket.intTareUserId
    ,SCTicket.dblGrossUnits
    ,SCTicket.dblNetUnits
	,SCTicket.dblNetWeight
    ,SCTicket.strItemNumber
    ,SCTicket.strItemUOM
    ,SCTicket.intCustomerId
    ,SCTicket.intSplitId
    ,SCTicket.strDistributionOption
    ,SCTicket.intDiscountSchedule
    ,SCTicket.strDiscountLocation
    ,SCTicket.dtmDeferDate
    ,SCTicket.strContractNumber
    ,SCTicket.intContractSequence
    ,SCTicket.strContractLocation
    ,SCTicket.dblUnitPrice
    ,SCTicket.dblUnitBasis
    ,SCTicket.dblTicketFees
    ,SCTicket.intCurrencyId
    ,SCTicket.dblCurrencyRate
    ,SCTicket.strTicketComment
    ,SCTicket.strCustomerReference
    ,SCTicket.ysnTicketPrinted
    ,SCTicket.ysnPlantTicketPrinted
    ,SCTicket.ysnGradingTagPrinted
    ,SCTicket.intHaulerId
    ,SCTicket.intFreightCarrierId
    ,SCTicket.dblFreightRate
    ,SCTicket.dblFreightAdjustment
    ,SCTicket.intFreightCurrencyId
    ,SCTicket.dblFreightCurrencyRate
    ,SCTicket.strFreightCContractNumber
    ,SCTicket.ysnFarmerPaysFreight
    ,SCTicket.strLoadNumber
    ,SCTicket.intLoadLocationId
    ,SCTicket.intAxleCount
    ,SCTicket.strBinNumber
    ,SCTicket.strPitNumber
    ,SCTicket.intGradingFactor
    ,SCTicket.strVarietyType
    ,SCTicket.strFarmNumber
    ,SCTicket.strFieldNumber
    ,SCTicket.strDiscountComment
    ,SCTicket.strCommodityCode
    ,SCTicket.intCommodityId
    ,SCTicket.intDiscountId
    ,SCTicket.intContractId
    ,SCTicket.intDiscountLocationId
    ,SCTicket.intItemId
    ,SCTicket.intEntityId
    ,SCTicket.intLoadId
    ,SCTicket.intMatchTicketId
    ,SCTicket.intSubLocationId
    ,SCTicket.intStorageLocationId
    ,SCTicket.intFarmFieldId
    ,SCTicket.intDistributionMethod
    ,SCTicket.intSplitInvoiceOption
    ,SCTicket.intDriverEntityId
    ,SCTicket.intStorageScheduleId
    ,SCTicket.intConcurrencyId
    ,SCTicket.dblNetWeightDestination
    ,SCTicket.ysnUseDestinationWeight
    ,SCTicket.ysnUseDestinationGrades
    ,SCTicket.ysnHasGeneratedTicketNumber
    ,SCTicket.intInventoryTransferId
    ,SCTicket.dblShrink
    ,SCTicket.dblConvertedUOMQty
	,SCTicket.strStorageTypeDescription
    ,SCTicket.strName
    ,SCTicket.strTicketType
	,SCTicket.strLocationName
	,SCTicket.strSubLocationName
	,SCTicket.strStationShortDescription
	,SCTicket.strSplitNumber
	,SCTicket.strTicketPool
	,SCTicket.strDiscountId
	,SCTicket.strDescription
	,SCTicket.strScheduleId
	,SCTicket.intInventoryReceiptId
	,SCTicket.strReceiptNumber
	,SCTicket.intInventoryShipmentId
	,SCTicket.strShipmentNumber
	,SCTicket.strFreightSettlement
	FROM tblSCUncompletedTicketAlert SCAlert,vyuSCTicketView SCTicket
	WHERE DATEDIFF(day,dtmTicketDateTime,GETDATE()) >= SCAlert.intTicketUncompletedDaysAlert
	AND ysnHasGeneratedTicketNumber = 1
	AND (SCTicket.strTicketStatus = 'O' OR SCTicket.strTicketStatus = 'A')