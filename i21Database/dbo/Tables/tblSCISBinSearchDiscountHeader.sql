CREATE TABLE tblSCISBinSearchDiscountHeader (

	intBinSearchDiscountHeaderId int identity(1,1) primary key

	, intBinSearchId int not null
	, intBinDiscountHeaderId int not null
	, intItemId int not null
	, intConcurrencyId int default(1) not null
	, constraint [FK_BinSearchDiscount_BinSearch_BinSearchId] foreign key ([intBinSearchId]) references [dbo].[tblSCISBinSearch](intBinSearchId) on delete cascade
	, constraint [FK_BinSearchDiscount_BinDiscountHeader_BinSearchId] foreign key (intBinDiscountHeaderId) references [dbo].[tblSCISBinDiscountHeader](intBinDiscountHeaderId) on delete cascade

	, constraint [FK_BinSearchDiscount_Item_ItemId] foreign key ([intItemId]) references [dbo].[tblICItem](intItemId) on delete cascade
	,constraint [UQ_BinSearchDiscountHeader_BinSearchHeader] unique nonclustered (intBinSearchId, intBinDiscountHeaderId)
	,constraint [UQ_BinSearchDiscountHeader_BinSearchHeaderItem] unique nonclustered (intBinSearchId, intBinDiscountHeaderId, intItemId)
)

GO