CREATE TABLE [dbo].[tblSCISLoadOutBin]
(
	[intLoadOutBinId] INT NOT NULL PRIMARY KEY IDENTITY(1,1)
	,intCompanyLocationId int not null
	,intItemId int not null
	,[intUnitMeasureId] int not null
	,[dblEffectiveDepth] NUMERIC(18, 6) DEFAULT ((0))
	,[dblUnitPerFoot] NUMERIC(18, 6) DEFAULT ((0))
	,intConcurrencyId int not null default(1)

	-- ,constraint FK_LoadOutBin_StorageLocation_intStorageLocationId foreign key (intStorageLocationId) references tblICStorageLocation(intStorageLocationId) on delete cascade
	,constraint FK_LoadOutBin_CompanyLocation_intCompanyLocationId FOREIGN KEY ([intCompanyLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) on delete cascade
	,constraint FK_LoadOutBin_Item_intItemId foreign key (intItemId) references tblICItem(intItemId)
	,constraint FK_LoadOutBin_UnitMeasure_intUnitMeasureId FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
	
	

)
