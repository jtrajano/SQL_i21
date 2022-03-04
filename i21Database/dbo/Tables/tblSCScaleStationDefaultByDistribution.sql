CREATE TABLE [dbo].[tblSCScaleStationDefaultByDistribution]
(
	intScaleStationDefaultByDistributionId int identity(1,1)  primary key not null
	,intScaleSetupId int not null
	,intTicketTypeId int not null
	,intDistributionOptionId int null
	,intItemId int not null
	,intStorageLocationId int null
	,intStorageUnitId int null
	
	,intConcurrencyId int not null default(0)



	, constraint [FK_ScaleStationDefaultByDistribution_ScaleSetup_ScaleSetupId] foreign key ([intScaleSetupId]) references dbo.[tblSCScaleSetup]([intScaleSetupId])
	, constraint [FK_ScaleStationDefaultByDistribution_TicketType_TicketTypeId] foreign key ([intTicketTypeId]) references dbo.[tblSCTicketType]([intTicketTypeId])
	, constraint [FK_ScaleStationDefaultByDistribution_DistributionOption_DistributionOptionId] foreign key (intDistributionOptionId ) references dbo.[tblSCDistributionOption](intDistributionOptionId )
	, constraint [FK_ScaleStationDefaultByDistribution_Item_ItemId] foreign key ([intItemId]) references dbo.[tblICItem]([intItemId])
	, constraint [FK_ScaleStationDefaultByDistribution_CompanyLocationSubLocation_StorageLocationId] foreign key ([intStorageLocationId]) references dbo.[tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId])
	, constraint [FK_ScaleStationDefaultByDistribution_StorageLocation_StorageUnitId] foreign key ([intStorageUnitId]) references dbo.[tblICStorageLocation]([intStorageLocationId])
)
