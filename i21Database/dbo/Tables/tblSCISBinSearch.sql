﻿CREATE TABLE tblSCISBinSearch (
	intBinSearchId int identity(1,1)

	,intStorageLocationId int not null
	,intCommodityId int not null
	,strBinType nvarchar(50)
	,strBinType2 nvarchar(50)
	,strBinNotes nvarchar(50)
	,strBinNotesColor nvarchar(50)
	,strBinNotesBackgroundColor nvarchar(50)
	,dtmTrackingDate datetime null
	, intConcurrencyId int default(1) not null
	
	,CONSTRAINT [PK_tblSCISBinSearch] PRIMARY KEY CLUSTERED ([intBinSearchId] ASC)
	,constraint [UQ_BinSearch_StorageLocation] unique nonclustered (intStorageLocationId)
)