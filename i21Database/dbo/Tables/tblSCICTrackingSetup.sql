create table dbo.tblSCICTrackingSetup
(
	intTrackingSetup int identity(1,1) primary key
	,dtmStartTrackingDate datetime
	,intConcurrencyId int default(1)

)