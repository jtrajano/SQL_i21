CREATE TABLE [dbo].[tblMFPickList]
(
	[intPickListId] INT NOT NULL IDENTITY, 
    [strPickListNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strWorkOrderNo] NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intKitStatusId] INT NOT NULL, 
    [intAssignedToId] INT NOT NULL, 
    [intLocationId] INT NOT NULL,
	[intSalesOrderId] INT NULL,
	[dtmCreated] DATETIME NULL, 
    [intCreatedUserId] INT NULL,
	[dtmLastModified] DATETIME NULL, 
    [intLastModifiedUserId] INT NULL,
	[intConcurrencyId] INT NULL CONSTRAINT [DF_tblMFKitPickListHeader_intConcurrencyId] DEFAULT 0, 
	CONSTRAINT [PK_tblMFPickList_intPickListId] PRIMARY KEY (intPickListId),
	CONSTRAINT [UQ_tblMFPickList_strPickListNo] UNIQUE ([strPickListNo]),
	CONSTRAINT [FK_tblMFPickList_tblMFWorkOrderStatus_intKitStatusId] FOREIGN KEY ([intKitStatusId]) REFERENCES [tblMFWorkOrderStatus]([intStatusId]),
	CONSTRAINT [FK_tblMFPickList_tblSMCompanyLocation_intLocationId] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
)
