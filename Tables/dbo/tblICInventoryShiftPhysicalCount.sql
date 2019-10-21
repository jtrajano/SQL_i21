/*
 Use this table to generate the shift physical report. 
 It is populated and updated when posting or unposting the inventory count. 
 Qty and cost/price are all in stock units. 
*/
CREATE TABLE [dbo].[tblICInventoryShiftPhysicalHistory]
(
	[intInventoryShiftPhysicalCountId] INT NOT NULL IDENTITY, 	
	[intCountGroupId] INT NULL,
	[intItemId] INT NULL,
	[strShiftNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intLocationId] INT NOT NULL,	
	[intSubLocationId] INT NULL,
	[intStorageLocationId] INT NULL,
	[dtmDate] DATETIME NOT NULL, 
	[dblSystemCount] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
	[dblQtyReceived] NUMERIC(38, 20) NOT NULL DEFAULT 0, 
	[dblQtySold] NUMERIC(38, 20) NOT NULL DEFAULT 0, 	
	[dblPhysicalCount] NUMERIC(38, 20) NOT NULL DEFAULT 0, 	
	[dblSalesPrice] NUMERIC(38, 20) NULL DEFAULT 0, 	
	[intTransactionId] INT NOT NULL, 
	[strTransactionId] NVARCHAR(40) COLLATE Latin1_General_CI_AS NOT NULL, 
	[intTransactionDetailId] INT NULL, 
	[ysnIsUnposted] BIT NULL,
	[dtmCreated] DATETIME NOT NULL DEFAULT GETDATE(), 
	[intCreatedEntityId] INT NULL, 
	[intCompanyId] INT NULL, 
	[intConcurrencyId] INT NOT NULL DEFAULT 1, 		
	CONSTRAINT [PK_tblICInventoryShiftPhysicalCount] PRIMARY KEY ([intInventoryShiftPhysicalCountId]),
	CONSTRAINT [FK_tblICInventoryShiftPhysicalCount_tblICCountGroup] FOREIGN KEY ([intCountGroupId]) REFERENCES [tblICCountGroup]([intCountGroupId]),
	CONSTRAINT [FK_tblICInventoryShiftPhysicalCount_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]),
	CONSTRAINT [FK_tblICInventoryShiftPhysicalCount_tblSMCompanyLocationSubLocation] FOREIGN KEY ([intSubLocationId]) REFERENCES [tblSMCompanyLocationSubLocation]([intCompanyLocationSubLocationId]),
	CONSTRAINT [FK_tblICInventoryShiftPhysicalCount_tblICStorageLocation] FOREIGN KEY ([intStorageLocationId]) REFERENCES [tblICStorageLocation]([intStorageLocationId])
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryShiftPhysicalHistory_intCountGroupId]
	ON [dbo].[tblICInventoryShiftPhysicalHistory]([intCountGroupId] ASC);

GO 