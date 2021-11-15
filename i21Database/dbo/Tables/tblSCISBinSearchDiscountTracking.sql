CREATE TABLE [dbo].[tblSCISBinSearchDiscountTracking](

	intBinSearchDiscountTrackingId int identity(1,1) primary key

	, intBinSearchId int not null	
	, intItemId int not null
	, intConcurrencyId int default(1) not null
	
	, constraint [FK_BinSearchDiscountTracking_BinSearch_BinSearchId] foreign key ([intBinSearchId]) references [dbo].[tblSCISBinSearch](intBinSearchId) on delete cascade
	, constraint [FK_BinSearchDiscountTracking_Item_ItemId] foreign key ([intItemId]) references [dbo].[tblICItem](intItemId) on delete cascade	
	, constraint [UQ_BinSearchDiscountTracking_BinSearchHeaderItem] unique nonclustered (intBinSearchId, intItemId)
)