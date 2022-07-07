CREATE VIEW [dbo].[vyuSCRailSheetGet]
	AS 

select 
	RailSheet.intRailSheetId
	,RailSheet.strRailSheetNo
	,RailSheet.intConcurrencyId
	,RailSheet.dtmDate
	,RailSheet.intCurrencyId
	,RailSheet.strBOLNo
	,RailSheet.dtmBOLDate
	,RailSheet.strLeadCarNo
	,isnull(RailSheet.ysnPosted, 0) as ysnPosted

	,ScaleSetup.intScaleSetupId
	,ScaleSetup.strStationShortDescription
	,ScaleSetup.intTicketPoolId
	
	

	,CompanyLocation.intCompanyLocationId
	,CompanyLocation.strLocationName

	,Item.intItemId
	,Item.strItemNo
	,Commodity.intCommodityId
	,Commodity.strCommodityCode

	,TicketType.intTicketTypeId
	,TicketType.intTicketType
	,TicketType.strInOutIndicator
	,TicketType.strTicketType

	,Entity.intEntityId
	,Entity.strName as strEntityName

	,EntityScaleOperator.intEntityId as intEntityScaleOperatorId
	,EntityScaleOperator.strName as strScaleOperatorUser
	
	,Discount.intDiscountId
	,Discount.strDiscountId

	,null as intStorageScheduleRuleId
	,'' as strScheduleDescription
	--,* 



	
	,LoadingPortCity.intCityId as intCityLoadingPortId
	,LoadingPortCity.strCity as strLoadingPortCity

	,DestinationPortCity.intCityId as intCityDestinationPortId
	,DestinationPortCity.strCity as strDestinationPortCity

	,DestinationCity.intCityId as intCityDestinationCityId
	,DestinationCity.strCity as strDestinationCity
	
	,EntityTerminal.intEntityId as intEntityTerminalId 
	,EntityTerminal.strName as strEntityTerminalName


	from tblSCRailSheet	RailSheet
		join tblSCScaleSetup ScaleSetup
			on RailSheet.intScaleSetupId = ScaleSetup.intScaleSetupId
		join tblSMCompanyLocation CompanyLocation
			on ScaleSetup.intLocationId = CompanyLocation.intCompanyLocationId
		join tblICItem Item
			on RailSheet.intItemId = Item.intItemId
		join tblICCommodity Commodity
			on Item.intCommodityId = Commodity.intCommodityId
		join tblSCListTicketTypes TicketType
			on RailSheet.intTicketTypeId = TicketType.intTicketTypeId
		join tblEMEntity Entity
			on RailSheet.intEntityId = Entity.intEntityId
		join tblEMEntity EntityScaleOperator
			on RailSheet.intEntityScaleOperatorId = EntityScaleOperator.intEntityId
		join tblGRDiscountId Discount
			on RailSheet.intDiscountId = Discount.intDiscountId
		--join tblGRStorageScheduleRule StorageScheduleRule
		--	on RailSheet.intStorageScheduleRuleId = StorageScheduleRule.intStorageScheduleRuleId

		left join tblSMCity LoadingPortCity
			on RailSheet.intCityLoadingPortId = LoadingPortCity.intCityId
				and LoadingPortCity.ysnPort = 1

		left join tblSMCity DestinationPortCity
			on RailSheet.intCityDestinationPortId = DestinationPortCity.intCityId
				and DestinationPortCity.ysnPort = 1

		left join tblSMCity DestinationCity
			on RailSheet.intCityDestinationCityId = DestinationCity.intCityId
				and DestinationCity.ysnPort = 1

		left join tblEMEntity EntityTerminal
			on RailSheet.intEntityTerminalId = EntityTerminal.intEntityId
				
	
go