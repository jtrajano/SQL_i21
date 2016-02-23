﻿CREATE VIEW [dbo].[vyuSCTicketView]
	AS select "tblSCTicket"."intTicketId",
       "tblSCTicket"."strTicketStatus",
       "tblSCTicket"."strTicketNumber",
       "tblSCTicket"."intScaleSetupId",
       "tblSCTicket"."intTicketPoolId",
       "tblSCTicket"."intTicketLocationId",
       "tblSCTicket"."intTicketType",
       "tblSCTicket"."strInOutFlag",
       "tblSCTicket"."dtmTicketDateTime",
       "tblSCTicket"."dtmTicketTransferDateTime",
       "tblSCTicket"."dtmTicketVoidDateTime",
       "tblSCTicket"."intProcessingLocationId",
       "tblSCTicket"."strScaleOperatorUser",
       "tblSCTicket"."intScaleOperatorId",
       "tblSCTicket"."strPurchaseOrderNumber",
       "tblSCTicket"."strTruckName",
       "tblSCTicket"."strDriverName",
       "tblSCTicket"."ysnDriverOff",
       "tblSCTicket"."ysnSplitWeightTicket",
       "tblSCTicket"."ysnGrossManual",
       "tblSCTicket"."dblGrossWeight",
       "tblSCTicket"."dblGrossWeightOriginal",
       "tblSCTicket"."dblGrossWeightSplit1",
       "tblSCTicket"."dblGrossWeightSplit2",
       "tblSCTicket"."dtmGrossDateTime",
       "tblSCTicket"."intGrossUserId",
       "tblSCTicket"."ysnTareManual",
       "tblSCTicket"."dblTareWeight",
       "tblSCTicket"."dblTareWeightOriginal",
       "tblSCTicket"."dblTareWeightSplit1",
       "tblSCTicket"."dblTareWeightSplit2",
       "tblSCTicket"."dtmTareDateTime",
       "tblSCTicket"."intTareUserId",
       "tblSCTicket"."dblGrossUnits",
       "tblSCTicket"."dblNetUnits",
       "tblSCTicket"."strItemNumber",
       "tblSCTicket"."strItemUOM",
       "tblSCTicket"."intCustomerId",
       "tblSCTicket"."intSplitId",
       "tblSCTicket"."strDistributionOption",
       "tblSCTicket"."intDiscountSchedule",
       "tblSCTicket"."strDiscountLocation",
       "tblSCTicket"."dtmDeferDate",
       "tblSCTicket"."strContractNumber",
       "tblSCTicket"."intContractSequence",
       "tblSCTicket"."strContractLocation",
       "tblSCTicket"."dblUnitPrice",
       "tblSCTicket"."dblUnitBasis",
       "tblSCTicket"."dblTicketFees",
       "tblSCTicket"."intCurrencyId",
       "tblSCTicket"."dblCurrencyRate",
       "tblSCTicket"."strTicketComment",
       "tblSCTicket"."strCustomerReference",
       "tblSCTicket"."ysnTicketPrinted",
       "tblSCTicket"."ysnPlantTicketPrinted",
       "tblSCTicket"."ysnGradingTagPrinted",
       "tblSCTicket"."intHaulerId",
       "tblSCTicket"."intFreightCarrierId",
       "tblSCTicket"."dblFreightRate",
       "tblSCTicket"."dblFreightAdjustment",
       "tblSCTicket"."intFreightCurrencyId",
       "tblSCTicket"."dblFreightCurrencyRate",
       "tblSCTicket"."strFreightCContractNumber",
       "tblSCTicket"."ysnFarmerPaysFreight",
       "tblSCTicket"."strLoadNumber",
       "tblSCTicket"."intLoadLocationId",
       "tblSCTicket"."intAxleCount",
       "tblSCTicket"."strBinNumber",
       "tblSCTicket"."strPitNumber",
       "tblSCTicket"."intGradingFactor",
       "tblSCTicket"."strVarietyType",
       "tblSCTicket"."strFarmNumber",
       "tblSCTicket"."strFieldNumber",
       "tblSCTicket"."strDiscountComment",
       "tblSCTicket"."strCommodityCode",
       "tblSCTicket"."intCommodityId",
       "tblSCTicket"."intDiscountId",
       "tblSCTicket"."intContractId",
       "tblSCTicket"."intDiscountLocationId",
       "tblSCTicket"."intItemId",
       "tblSCTicket"."intEntityId",
       "tblSCTicket"."intLoadId",
       "tblSCTicket"."intMatchTicketId",
       "tblSCTicket"."intSubLocationId",
       "tblSCTicket"."intStorageLocationId",
       "tblSCTicket"."intFarmFieldId",
       "tblSCTicket"."intDistributionMethod",
       "tblSCTicket"."intSplitInvoiceOption",
       "tblSCTicket"."intDriverEntityId",
       "tblSCTicket"."intStorageScheduleId",
       "tblSCTicket"."intConcurrencyId",
       "tblSCTicket"."dblNetWeightDestination",
       "tblSCTicket"."ysnUseDestinationWeight",
       "tblSCTicket"."ysnUseDestinationGrades",
       "tblSCTicket"."ysnHasGeneratedTicketNumber",
       "tblSCTicket"."intInventoryTransferId",
       "tblSCTicket"."intInventoryReceiptId",
       "tblSCTicket"."dblGross",
       "tblSCTicket"."dblShrink",
       "tblSCTicket"."dblConvertedUOMQty",
       "tblEntity"."strName",
       "tblSCListTicketTypes"."strTicketType",
	   "tblSMCompanyLocation"."strLocationName",
	   "tblSMCompanyLocationSubLocation"."strSubLocationName",
	   "tblGRStorageType"."strStorageTypeDescription"
  from (("dbo"."tblSCTicket" "tblSCTicket"
  inner join "dbo"."tblEntity" "tblEntity"
       on ("tblEntity"."intEntityId" = "tblSCTicket"."intEntityId")
  inner join "dbo"."tblSMCompanyLocation"
       "tblSMCompanyLocation"
       on ("tblSMCompanyLocation"."intCompanyLocationId" = "tblSCTicket"."intProcessingLocationId"))
  inner join "dbo"."tblSCListTicketTypes"
       "tblSCListTicketTypes"
       on ("tblSCListTicketTypes"."intTicketType" = "tblSCTicket"."intTicketType" AND "tblSCListTicketTypes".strInOutIndicator = "tblSCTicket".strInOutFlag)
  full join "dbo"."tblGRStorageType"
       "tblGRStorageType"
       on ("tblGRStorageType"."strStorageTypeCode" = "tblSCTicket"."strDistributionOption")
  inner join "dbo"."tblSMCompanyLocationSubLocation"
       "tblSMCompanyLocationSubLocation"
       on ("tblSMCompanyLocationSubLocation".intCompanyLocationId = "tblSCTicket"."intProcessingLocationId"))
