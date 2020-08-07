CREATE VIEW vyuSCTicketLVSearch
AS SELECT 
	   SC.intTicketLVStagingId
      ,SC.strTicketNumber
      ,SC.intTicketType
      ,SC.intTicketTypeId
      ,SC.strTicketType
      ,SC.strInOutFlag
      ,SC.dtmTicketDateTime
      ,SC.strTicketStatus
      ,SC.intEntityId
      ,SC.intItemId
      ,SC.intCommodityId
      ,SC.intCompanyLocationId
      ,SC.dblGrossWeight
      ,SC.dtmGrossDateTime
      ,SC.dblTareWeight
      ,SC.dtmTareDateTime
      ,SC.dblGrossUnits
      ,SC.dblNetUnits
      ,SC.dblUnitPrice
      ,SC.dblUnitBasis
      ,SC.strTicketComment
      ,SC.intDiscountId
      ,SC.dblFreightRate
      ,SC.intHaulerId
      ,SC.dblTicketFees
      ,SC.ysnFarmerPaysFreight
      ,SC.intCurrencyId
      ,SC.strCurrency
      ,SC.strBinNumber
      ,SC.intContractId
      ,SC.strContractNumber
      ,SC.intContractSequence
      ,SC.strScaleOperatorUser
      ,SC.strTruckName
      ,SC.strDriverName
      ,SC.strCustomerReference
      ,SC.intAxleCount
      ,SC.ysnDriverOff
      ,SC.ysnGrossManual
      ,SC.ysnTareManual
      ,SC.intStorageScheduleTypeId
      ,SC.strDistributionOption
      ,SC.strPitNumber
      ,SC.intTicketPoolId
      ,SC.intScaleSetupId
      ,SC.intSplitId
      ,SC.strSplitNumber
      ,SC.strItemUOM
      ,SC.ysnSplitWeightTicket
      ,SC.intOriginTicketId
      ,SC.intItemUOMIdFrom
      ,SC.intItemUOMIdTo
      ,SC.strCostMethod
      ,SC.strDiscountComment
      ,SC.strSourceType
	  ,EM.strName
	  ,ICI.strItemNo
	  ,SM.strLocationName
	  ,GRD.strDiscountId
	  ,SCS.strStationShortDescription
      ,SC.ysnProcessedData   
      ,SC.strImportFailedReason
FROM tblSCTicketLVStaging SC
LEFT JOIN tblEMEntity EM ON EM.intEntityId = SC.intEntityId
LEFT JOIN tblICItem ICI ON ICI.intItemId = SC.intItemId
LEFT JOIN tblSMCompanyLocation SM ON SM.intCompanyLocationId = SC.intCompanyLocationId
LEFT JOIN tblICCommodity ICC ON ICC.intCommodityId = SC.intCommodityId
LEFT JOIN tblGRDiscountId GRD on GRD.intDiscountId = SC.intDiscountId
LEFT JOIN tblGRStorageType GRS on GRS.intStorageScheduleTypeId = SC.intStorageScheduleTypeId
LEFT JOIN tblSCScaleSetup SCS ON SCS.intScaleSetupId = SC.intScaleSetupId