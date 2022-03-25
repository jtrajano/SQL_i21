CREATE VIEW [dbo].[vyuSCISLoadOutHistory]
	AS 


	select Ticket.strTicketNumber
		, Ticket.dblNetUnits 
		, StorageUnit.strName as strStorageUnit
		, UnitMeasure.strUnitMeasure
		, Ticket.dtmTicketDateTime
		, BinDeduct.intLoadOutBinId
		, Ticket.intTicketId


		,case when LoadOutBin.intUnitMeasureId is not null and LoadOutBin.intUnitMeasureId != UnitMeasure.intUnitMeasureId then 
				dbo.fnGRConvertQuantityToTargetItemUOM(
					Ticket.intItemId
					, UnitMeasure.intUnitMeasureId
					, LoadOutBin.intUnitMeasureId
					, Ticket.dblNetUnits) 
			else 
				Ticket.dblNetUnits
			end as dblConvertedUnits
	from tblSCISLoadOutBinDeduct  BinDeduct
	join tblSCISLoadOutBin LoadOutBin
		on BinDeduct.intLoadOutBinId = LoadOutBin.intLoadOutBinId
	join tblICStorageLocation StorageUnit
		on BinDeduct.intStorageLocationId = StorageUnit.intStorageLocationId
	join tblSCTicket Ticket
		on BinDeduct.intStorageLocationId = Ticket.intStorageLocationId
			and Ticket.strTicketStatus = 'C'
			and strInOutFlag = 'O'
	join tblGRStorageType StorageType
		on Ticket.intStorageScheduleTypeId = StorageType.intStorageScheduleTypeId
			and StorageType.ysnCustomerStorage = 0
	join tblICItemUOM ItemUOM
		on Ticket.intItemId = ItemUOM.intItemId
			and Ticket.intItemUOMIdTo = ItemUOM.intItemUOMId
	join tblICUnitMeasure UnitMeasure
		on ItemUOM.intUnitMeasureId = UnitMeasure.intUnitMeasureId
	
	where (LoadOutBin.dtmStartTrackingDate is null or (Ticket.dtmTicketDateTime >= LoadOutBin.dtmStartTrackingDate and Ticket.dtmTicketDateTime < LoadOutBin.dtmEndTrackingDate ))
	