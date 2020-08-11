CREATE TABLE [dbo].[tblICInventoryAdjustment]
(
	[intInventoryAdjustmentId] INT NOT NULL IDENTITY, 
    [intLocationId] INT NOT NULL, 
    [dtmAdjustmentDate] DATETIME NOT NULL DEFAULT (getdate()), 
    [intAdjustmentType] INT NOT NULL, 
    [strAdjustmentNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NULL, 
	[ysnPosted] BIT NULL DEFAULT ((0)),
	[intEntityId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	[dtmPostedDate] DATETIME NULL, 
	[dtmUnpostedDate] DATETIME NULL, 
	[intSourceId] INT NULL, 
	[intSourceTransactionTypeId] INT NULL, 
	[intCompanyId] INT NULL, 
	[dtmCreated] DATETIME NULL DEFAULT (GETDATE()),
	[dtmDateCreated] DATETIME NULL,
	[dtmDateModified] DATETIME NULL,
	[intCreatedByUserId] INT NULL,
	[intModifiedByUserId] INT NULL,
    [strDataSource] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
	[intInventoryShipmentId] INT NULL,
	[intInventoryReceiptId] INT NULL,
	[intTicketId] INT NULL,
	[intInvoiceId] INT NULL,
	[strIntegrationDocNo] NVARCHAR(150) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblICInventoryAdjustment] PRIMARY KEY ([intInventoryAdjustmentId]), 
    CONSTRAINT [AK_tblICInventoryAdjustment_strAdjustmentNo] UNIQUE ([strAdjustmentNo]), 
    CONSTRAINT [FK_tblICInventoryAdjustment_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) 
)
GO

CREATE NONCLUSTERED INDEX [IX_tblICInventoryAdjustment_strAdjustmentNo]
	ON [dbo].[tblICInventoryAdjustment]([strAdjustmentNo] ASC)

GO