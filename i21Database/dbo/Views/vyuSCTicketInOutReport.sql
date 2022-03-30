CREATE VIEW [dbo].[vyuSCTicketInOutReport]
	AS 
	/*
		-- Dev Note 
		column strStationUnitMeasure is not referring to scale station uom but to company preference uom since SC-4512
	*/
	select 

		Ticket.strTicketNumber
		,Entity.strName
		,CompanyLocation.strLocationName
		, case when StorageType.strStorageTypeDescription = 'Split' then coalesce(DeliverySheet.strDeliverySheetNumber, StorageType.strStorageTypeDescription) else StorageType.strStorageTypeDescription  end as strStorageTypeDescription 
		,case when Ticket.strInOutFlag = 'I' then 'Inbound' 
				when Ticket.strInOutFlag = 'O' then 'Outbound'
			else ''
		end
			as strIndicator
		, Ticket.dblGrossUnits
		, Ticket.intTicketType
		, TicketType.strTicketType
		, Ticket.dtmTicketDateTime
		, StorageType.strStorageTypeDescription  + ' ' +
			case when Ticket.strInOutFlag = 'I' then 'Inbound' 
				when Ticket.strInOutFlag = 'O' then 'Outbound'
			else ''
		end as strGroupIndicator
		, Ticket.intProcessingLocationId
		, Item.strItemNo
		, Commodity.strCommodityCode
		, UOM.strUnitMeasure

		,case when ScaleSetupUOM.intUnitMeasureId is not null and 
			ScaleSetupUOM.intUnitMeasureId != UOM.intUnitMeasureId then
			round(dbo.fnGRConvertQuantityToTargetItemUOM(
									Ticket.intItemId
									, UOM.intUnitMeasureId
									, ScaleSetupUOM.intUnitMeasureId
									, Ticket.dblGrossUnits) , 4)
		else
			Ticket.dblGrossUnits
		end as dblComputedGrossUnits

		,isnull(ScaleSetupUOM.strUnitMeasure, UOM.strUnitMeasure) as strStationUnitMeasure

		from tblSCTicket Ticket
			join tblICItem Item
				on Ticket.intItemId = Item.intItemId
			join tblICCommodity Commodity
				on Item.intCommodityId = Commodity.intCommodityId
			join tblEMEntity Entity
				on Ticket.intEntityId = Entity.intEntityId
			join tblSMCompanyLocation CompanyLocation
				on Ticket.intProcessingLocationId = CompanyLocation.intCompanyLocationId
			join tblGRStorageType StorageType
				on Ticket.intStorageScheduleTypeId = StorageType.intStorageScheduleTypeId
			join tblSCListTicketTypes TicketType
				on Ticket.intTicketTypeId = TicketType.intTicketTypeId

			join tblICItemUOM ItemUOM
					on Ticket.intItemUOMIdTo = ItemUOM.intItemUOMId
						and Ticket.intItemId = ItemUOM.intItemId

			join tblICUnitMeasure UOM
					on ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
			outer apply(
				select ScaleSetupUOM.strUnitMeasure, Pref.intUnitMeasureId from	
					tblGRCompanyPreference Pref
						join tblICUnitMeasure ScaleSetupUOM
							on Pref.intUnitMeasureId = ScaleSetupUOM.intUnitMeasureId
			) ScaleSetupUOM
			

			left join tblSCDeliverySheet DeliverySheet
				on Ticket.intDeliverySheetId = DeliverySheet.intDeliverySheetId
	where Ticket.intTicketType = 1
		and CompanyLocation.ysnLicensed = 1
		--and dtmTicketDateTime between '2021-10-15' and '2021-10-22'

	union all
	select 

		Ticket.strTicketNumber
		, EntityCompanyLocation.strLocationName as strName
		,CompanyLocation.strLocationName
		,'Transfer' as strStorageTypeDescription
		,'Outbound' as strIndicator
		, Ticket.dblGrossUnits * -1
		, Ticket.intTicketType
		, TicketType.strTicketType
		, Ticket.dtmTicketDateTime
		, 'Transfer Outbound' as strGroupIndicator
		, Ticket.intProcessingLocationId
		, Item.strItemNo
		, Commodity.strCommodityCode
		, UOM.strUnitMeasure

		,case when ScaleSetupUOM.intUnitMeasureId is not null and 
			ScaleSetupUOM.intUnitMeasureId != UOM.intUnitMeasureId then
			dbo.fnGRConvertQuantityToTargetItemUOM(
									Ticket.intItemId
									, UOM.intUnitMeasureId
									, ScaleSetupUOM.intUnitMeasureId
									, Ticket.dblGrossUnits)
		else
			Ticket.dblGrossUnits
		end as dblComputedGrossUnits

		,isnull(ScaleSetupUOM.strUnitMeasure, UOM.strUnitMeasure) as strStationUnitMeasure
		from tblSCTicket Ticket	
			join tblICItem Item
				on Ticket.intItemId = Item.intItemId
			join tblICCommodity Commodity
				on Item.intCommodityId = Commodity.intCommodityId		
			join tblSMCompanyLocation CompanyLocation
				on Ticket.intProcessingLocationId = CompanyLocation.intCompanyLocationId
			join tblSMCompanyLocation EntityCompanyLocation
				on Ticket.intTransferLocationId= EntityCompanyLocation.intCompanyLocationId	
			join tblSCListTicketTypes TicketType
				on Ticket.intTicketTypeId = TicketType.intTicketTypeId

			join tblICItemUOM ItemUOM
					on Ticket.intItemUOMIdTo = ItemUOM.intItemUOMId
						and Ticket.intItemId = ItemUOM.intItemId			

			join tblICUnitMeasure UOM
					on ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
			outer apply(
				select ScaleSetupUOM.strUnitMeasure, Pref.intUnitMeasureId from	
					tblGRCompanyPreference Pref
						join tblICUnitMeasure ScaleSetupUOM
							on Pref.intUnitMeasureId = ScaleSetupUOM.intUnitMeasureId
			) ScaleSetupUOM
			
	where Ticket.intTicketType = 7
		and CompanyLocation.ysnLicensed = 1
		and EntityCompanyLocation.ysnLicensed = 1
		--and dtmTicketDateTime between '2021-10-15' and '2021-10-22'

	union all
	select 

		Ticket.strTicketNumber
		, EntityCompanyLocation.strLocationName as strName
		,CompanyLocation.strLocationName
		,'Transfer' as strStorageTypeDescription
		,'Inbound' as strIndicator
		, Ticket.dblGrossUnits
		, Ticket.intTicketType
		, TicketType.strTicketType
		, Ticket.dtmTicketDateTime
		, 'Transfer Inbound' as strGroupIndicator
		, Ticket.intTransferLocationId
		, Item.strItemNo
		, Commodity.strCommodityCode
		, UOM.strUnitMeasure

		,case when ScaleSetupUOM.intUnitMeasureId is not null and 
			ScaleSetupUOM.intUnitMeasureId != UOM.intUnitMeasureId then
			dbo.fnGRConvertQuantityToTargetItemUOM(
									Ticket.intItemId
									, UOM.intUnitMeasureId
									, ScaleSetupUOM.intUnitMeasureId
									, Ticket.dblGrossUnits)
		else
			Ticket.dblGrossUnits
		end as dblComputedGrossUnits

		,isnull(ScaleSetupUOM.strUnitMeasure, UOM.strUnitMeasure) as strStationUnitMeasure
		from tblSCTicket Ticket		
			join tblICItem Item
				on Ticket.intItemId = Item.intItemId
			join tblICCommodity Commodity
				on Item.intCommodityId = Commodity.intCommodityId	
			join tblSMCompanyLocation CompanyLocation
				on Ticket.intTransferLocationId = CompanyLocation.intCompanyLocationId		
			join tblSMCompanyLocation EntityCompanyLocation
				on Ticket.intProcessingLocationId= EntityCompanyLocation.intCompanyLocationId		
			join tblSCListTicketTypes TicketType
				on Ticket.intTicketTypeId = TicketType.intTicketTypeId

			join tblICItemUOM ItemUOM
					on Ticket.intItemUOMIdTo = ItemUOM.intItemUOMId
						and Ticket.intItemId = ItemUOM.intItemId					

			join tblICUnitMeasure UOM
					on ItemUOM.intUnitMeasureId = UOM.intUnitMeasureId
			outer apply(
				select ScaleSetupUOM.strUnitMeasure, Pref.intUnitMeasureId from	
					tblGRCompanyPreference Pref
						join tblICUnitMeasure ScaleSetupUOM
							on Pref.intUnitMeasureId = ScaleSetupUOM.intUnitMeasureId
			) ScaleSetupUOM

	where Ticket.intTicketType = 7
		and CompanyLocation.ysnLicensed = 1		
		and EntityCompanyLocation.ysnLicensed = 1
		--and dtmTicketDateTime between '2021-10-15' and '2021-10-22'
GO


