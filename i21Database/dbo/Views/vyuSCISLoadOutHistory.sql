CREATE VIEW [dbo].[vyuSCISLoadOutHistory]
	AS 


	select Ticket.strTicketNumber
		, Ticket.dblNetUnits 
		, StorageUnit.strName as strStorageUnit
		, UnitMeasure.strUnitMeasure
		, Ticket.dtmTicketDateTime
		, BinDeduct.intLoadOutBinId
		, Ticket.intTicketId


		,case when LoadOUtBin.intUnitMeasureId is not null and LoadOUtBin.intUnitMeasureId != UnitMeasure.intUnitMeasureId then 
				dbo.fnGRConvertQuantityToTargetItemUOM(
					Ticket.intItemId
					, UnitMeasure.intUnitMeasureId
					, LoadOUtBin.intUnitMeasureId
					, Ticket.dblNetUnits) 
			else 
				Ticket.dblNetUnits
			end as dblConvertedUnits
	from tblSCISLoadOutBinDeduct  BinDeduct
	join tblSCISLoadOutBin LoadOUtBin
		on BinDeduct.intLoadOutBinId = LoadOUtBin.intLoadOutBinId
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
	

	