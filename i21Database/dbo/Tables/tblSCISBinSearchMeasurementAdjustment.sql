CREATE TABLE [dbo].[tblSCISBinSearchMeasurementAdjustment]
(
	intBinSearchMeasurementAdjustmentId int identity(1,1) primary key

	, intBinSearchId int not null	
	
	, dtmMeasurement datetime not null
	, [dblAirspaceMeasurementT] DECIMAL(24, 10) not NULL
	, [dblAirspaceMeasurementB] DECIMAL(24, 10) not NULL
	, [dblTestPackFactorT] DECIMAL(24, 10) not NULL
	, [dblTestPackFactorB] DECIMAL(24, 10) not NULL

	, intConcurrencyId int default(1) not null
	
	, constraint [FK_BinSearchMeasurementAdjustment_BinSearch_BinSearchId] foreign key ([intBinSearchId]) references [dbo].[tblSCISBinSearch](intBinSearchId) on delete cascade

	
)
