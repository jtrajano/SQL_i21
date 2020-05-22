CREATE VIEW vyuMFCompanyPreference
AS
SELECT CP.intCompanyPreferenceId
	,CP.ysnEnableParentLot
	,CP.intDefaultGanttChartViewDuration
	,CP.intDefaultMaterialRequirementDuration
	,CP.intConcurrencyId
	,CP.ysnConsiderSumOfChangeoverTime
	,CP.intStandardSetUpDuration
	,CP.strDefaultStatusForSanitizedLot
	,CP.intDefaultStatusForSanitizedLot
	,CP.ysnSanitizationInboundPutaway
	,CP.ysnBlendRequirementRequired
	,CP.ysnBlendSheetRequired
	,CP.ysnSanitizationProcessEnabled
	,CP.ysnWIPStagingProcessEnabled
	,CP.ysnAutoPriorityOrderByDemandRatio
	,CP.ysnDisplayNewOrderByExpectedDate
	,CP.ysnCheckCrossContamination
	,CP.dtmWorkOrderCreateDate
	,CP.strSchedulingCutOffTime
	,CP.strScheduleType
	,CP.intForecastFirstEditableMonth
	,CP.dblDefaultResidueQty
	,CP.strDefaultRecipeCost
	,CP.ysnLotHistoryByStorageLocation
	,CP.ysnShowCostInSalesOrderPickList
	,CP.ysnShowAddOnItemQtyInSalesOrderPickList
	,CP.intWastageWorkOrderDuration
	,CP.intDefaultShipmentStagingLocation
	,CP.intDefaultShipmentDockDoorLocation
	,CP.ysnPickByLotCode
	,CP.ysnGenerateInvShipmentStagingOrder
	,CP.intLotCodeStartingPosition
	,CP.intLotCodeNoOfDigits
	,CP.ysnDisplayRecipeTitleByItem
	,CP.ysnPickByItemOwner
	,CP.ysnDisplayLotIdAsPalletId
	,CP.strLotTextInReport
	,CP.strParentLotTextInReport
	,CP.intBondStatusId
	,CP.ysnSetExpiryDateByParentLot
	,CP.ysnAddQtyOnExistingLot
	,CP.ysnNotifyInventoryShortOnCreateWorkOrder
	,CP.ysnNotifyInventoryShortOnReleaseWorkOrder
	,CP.ysnSetDefaultQtyOnHandheld
	,CP.ysnEnableStagingBOL
	,CP.strBOLReportName
	,CP.ysnReserveOnStage
	,CP.ysnGenerateNewParentLotOnChangeItem
	,CP.intNoOfDecimalPlacesOnConsumption
	,CP.ysnConsumptionByRatio
	,CP.ysnSetDefaultQty
	,CP.ysnLoadProcessEnabled
	,CP.ysnSplitLotOnPartialQty
	,CP.ysnProducedQtyByUnitCount
	,CP.intDamagedStatusId
	,CP.intIRParentLotNumberPatternId
	,CP.ysnAllowMoveAssignedTask
	,CP.intAllowablePickDayRange
	,CP.ysnGTINCaseCodeMandatory
	,CP.intMaximumPalletsOnForklift
	,CP.ysnAllowLotMoveacrossLocations
	,CP.ysnChangeLotStatusOnLotMoveByStorageLocationRestrictionType
	,CP.intLotDueDays
	,CP.ysnLifeTimeByEndOfMonth
	,CP.ysnSendEDIOnRepost
	,CP.ysnGenerateTaskOnCreatePickOrder
	,CP.ysnLotSnapshotByFiscalMonth
	,CP.intPreProductionControlPointId
	,CP.dblDemandUsageDays
	,CP.strStartDayOfTheWeekForDemandPlanning
	,CP.ysnConsiderCurrentWeekForDemandPlanning
	,CP.dblAverageWeekTransitPeriodForDemandPlanning
	,CP.ysnMergeOnMove
	,CP.ysnEnableInventoryAsOfDateBySnapshot
	,CP.strDemandImportDateTimeFormat
	,CP.intMinimumDemandMonth
	,CP.intMaximumDemandMonth
	,CP.strSupplyTarget
	,CP.ysnSupplyTargetbyAverage
	,CP.intNoofWeeksorMonthstoCalculateSupplyTarget
	,CP.intNoofWeekstoCalculateSupplyTargetbyAverage
	,CP.intContainerTypeId
	,CP.ysnCalculateNoOfContainerByBagQty
	,CP.dblDemandGrowthPerc
	,CP.ysnComputeDemandUsingRecipe
	,CP.ysnDisplayDemandWithItemNoAndDescription
	,CP.ysnDisplayRestrictedBookInDemandView
	,SL.strName AS strShipmentStagingLocation
	,SL1.strName AS strShipmentDockDoorLocation
	,LS.strSecondaryStatus AS strBondLotStatus
	,LS1.strSecondaryStatus AS strDamagedLotStatus
	,LS2.strSecondaryStatus AS strSanitizedLotStatus
	,C.strControlPointName AS strPreProductionControlPointName
	,CT.strContainerType
FROM tblMFCompanyPreference CP
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = CP.intDefaultShipmentStagingLocation
LEFT JOIN tblICStorageLocation SL1 ON SL1.intStorageLocationId = CP.intDefaultShipmentDockDoorLocation
LEFT JOIN tblICLotStatus LS ON LS.intLotStatusId = CP.intBondStatusId
LEFT JOIN tblICLotStatus LS1 ON LS1.intLotStatusId = CP.intDamagedStatusId
LEFT JOIN tblICLotStatus LS2 ON LS2.intLotStatusId = CP.intDefaultStatusForSanitizedLot
LEFT JOIN tblQMControlPoint C ON C.intControlPointId = CP.intPreProductionControlPointId
LEFT JOIN tblLGContainerType CT ON CT.intContainerTypeId = CP.intContainerTypeId
