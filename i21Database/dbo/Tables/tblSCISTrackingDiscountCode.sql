create table dbo.tblSCISTrackingDiscountCode
(
	intTrackingDiscountCodeId int identity(1,1) primary key
	,intItemId int not null
	,intConcurrencyId int default(1)



	,constraint [FK_TrackingDiscountCode_Item] foreign key (intItemId) references tblICItem(intItemId) on delete cascade
	,constraint [UQ_TrackingDiscountCode_ItemId] unique (intItemId)
	
)
