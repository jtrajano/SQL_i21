﻿CREATE VIEW [dbo].[vyuSCISLoadOutLoadIn]
	AS 


	
	select 

		BinIn.intLoadOutBinInId
		,BinIn.intLoadOutBinId
		,BinIn.intStorageLocationId
		,StorageUnit.strName as strStorageUnit
		,BinIn.intUnitMeasureId
		,BinInUnitMeasure.strUnitMeasure
		,BinIn.dblUnits
		,BinIn.dtmTransactionDate
		,BinIn.intConcurrencyId
		
		,case when BinIn.intUnitMeasureId is not null and BinIn.intUnitMeasureId != UnitMeasure.intUnitMeasureId then 
				dbo.fnGRConvertQuantityToTargetItemUOM(
					LoadOutBin.intItemId
					, BinIn.intUnitMeasureId
					, UnitMeasure.intUnitMeasureId
					, BinIn.dblUnits) 
			else 
				BinIn.dblUnits
			end as dblConvertedUnits
	from tblSCISLoadOutBin LoadOutBin
	join tblSCISLoadOutBinIn BinIn
		on LoadOutBin.intLoadOutBinId = BinIn.intLoadOutBinId
	--join tblICStorageLocation StorageUnit
	--	on BinDeduct.intStorageLocationId = StorageUnit.intStorageLocationId			
	join tblICUnitMeasure UnitMeasure
		on LoadOutBin.intUnitMeasureId = UnitMeasure.intUnitMeasureId
	join tblICStorageLocation StorageUnit
		on BinIn.intStorageLocationId = StorageUnit.intStorageLocationId		
	join tblICUnitMeasure BinInUnitMeasure
		on BinIn.intUnitMeasureId = BinInUnitMeasure.intUnitMeasureId

	where (LoadOutBin.dtmStartTrackingDate is null or (BinIn.dtmTransactionDate >= LoadOutBin.dtmStartTrackingDate and BinIn.dtmTransactionDate < LoadOutBin.dtmEndTrackingDate ))
	