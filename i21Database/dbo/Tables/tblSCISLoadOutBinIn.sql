CREATE TABLE [dbo].[tblSCISLoadOutBinIn]
(
	[intLoadOutBinInId] INT NOT NULL PRIMARY KEY IDENTITY(1,1)
	,intLoadOutBinId int not null
	,intStorageLocationId int not null
	,dblUnits NUMERIC(38, 20)
	,[intUnitMeasureId] int not null
	,dtmTransactionDate datetime not null default(getdate())
	,intConcurrencyId int not null default(1)

	,constraint FK_LoadOutBinIn_LoadOutBin_intLoadOutBinId foreign key (intLoadOutBinId) references tblSCISLoadOutBin(intLoadOutBinId) on delete cascade 
	,constraint FK_LoadOutBinIn_StorageLocation_intStorageLocationId foreign key (intStorageLocationId) references tblICStorageLocation(intStorageLocationId)
	,constraint FK_LoadOutBinIn_UnitMeasure_intUnitMeasureId FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])

	
)
