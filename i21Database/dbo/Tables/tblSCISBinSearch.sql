CREATE TABLE tblSCISBinSearch (

	intBinSearchId int identity(1,1)
	,intStorageLocationId int not null
	,intCommodityId int not null
	-- ,intItemId int null
	,strBinType nvarchar(50)
	,strBinType2 nvarchar(50)
	,strBinNotes nvarchar(50)
	,strBinNotesColor nvarchar(50)
	,strBinNotesBackgroundColor nvarchar(50)
	,strComBinNotesColor nvarchar(50)
	,strComBinNotesBackgroundColor nvarchar(50)
	,dtmTrackingDate datetime null
	,intUnitMeasureId int null

	,[dblCapacityT] DECIMAL(24, 10) NULL
	,[dblEffectiveDepthT] DECIMAL(24, 10) NULL
	,[dblBuFtT] DECIMAL(24, 10) NULL
	,[dblBasePackT] DECIMAL(24, 10) NULL


	,[dblCapacityB] DECIMAL(24, 10) NULL
	,[dblEffectiveDepthB] DECIMAL(24, 10) NULL
	,[dblBuFtB] DECIMAL(24, 10) NULL
	,[dblBasePackB] DECIMAL(24, 10) NULL
	



	,intConcurrencyId int default(1) not null
	
	,CONSTRAINT [PK_tblSCISBinSearch] PRIMARY KEY CLUSTERED ([intBinSearchId] ASC)
	,constraint [UQ_BinSearch_StorageLocation] unique nonclustered (intStorageLocationId)
	-- ,CONSTRAINT [FK_tblSCISBinSearch_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
	,CONSTRAINT [FK_tblSCISBinSearch_tblICCommodity_intCommodityId] FOREIGN KEY ([intCommodityId]) REFERENCES [tblICCommodity]([intCommodityId])
	,CONSTRAINT [FK_tblSCISBinSearch_tblICUnitMeasure] FOREIGN KEY ([intUnitMeasureId]) REFERENCES [tblICUnitMeasure]([intUnitMeasureId])
)