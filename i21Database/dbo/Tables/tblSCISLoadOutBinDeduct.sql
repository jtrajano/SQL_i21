CREATE TABLE [dbo].[tblSCISLoadOutBinDeduct]
(
	[intLoadOutBinDeductId] INT NOT NULL PRIMARY KEY IDENTITY(1,1)
	,intLoadOutBinId int not null
	,intStorageLocationId int not null
	,intConcurrencyId int not null


	,constraint FK_LoadOutBinDeduct_LoadOutBin_intLoadOutBinId foreign key (intLoadOutBinId) references tblSCISLoadOutBin(intLoadOutBinId) on delete cascade 
	,constraint FK_LoadOutBinDeduct_StorageLocation_intStorageLocationId foreign key (intStorageLocationId) references tblICStorageLocation(intStorageLocationId)
	,constraint [UQ_LoadOutBinDeduct_LoadOutBin_StorageLocation] unique nonclustered (intLoadOutBinId, intStorageLocationId)
)
