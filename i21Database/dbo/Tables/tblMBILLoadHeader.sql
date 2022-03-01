Create table tblMBILLoadHeader
(
intLoadHeaderId int identity(1,1),
intLoadId int NULL,
strType nvarchar(100)COLLATE Latin1_General_CI_AS NULL,
strLoadNumber nvarchar(100)COLLATE Latin1_General_CI_AS NULL,
intDriverId int,
intTruckId int,
intHaulerId int,
strTrailerNo nvarchar(100)COLLATE Latin1_General_CI_AS NULL,
dtmScheduledDate datetime,
ysnPosted bit default (0),
intConcurrencyId int default(0)
CONSTRAINT PK_tblMBILLoadHeaderHeader PRIMARY KEY CLUSTERED(intLoadHeaderId)
)