Create table tblMBILLoadHeader
(
intLoadHeaderId int identity(1,1),
intLoadId int NULL,
strType nvarchar(100)COLLATE Latin1_General_CI_AS NULL,
strLoadNumber nvarchar(100)COLLATE Latin1_General_CI_AS NULL,
intDriverId int,
intTruckId int,
intHaulerId int,
intDispatchOrderId int NULL,
intTrailerId int NULL,
strTrailerNo nvarchar(100)COLLATE Latin1_General_CI_AS NULL,
dtmScheduledDate datetime,
ysnPosted bit default (0),
ysnDiversion bit default(0),
strDiversionNumber NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
intStateId int,
intConcurrencyId int default(0)
CONSTRAINT PK_tblMBILLoadHeaderHeader PRIMARY KEY CLUSTERED(intLoadHeaderId), 
    [ysnDispatched] BIT NULL DEFAULT (1)
)