CREATE TABLE [dbo].[tblICInventoryAdjustment]
(
	[intInventoryAdjustmentId] INT NOT NULL IDENTITY, 
    [intLocationId] INT NOT NULL, 
    [dtmAdjustmentDate] DATETIME NOT NULL DEFAULT (getdate()), 
    [intAdjustmentType] INT NOT NULL, 
    [strAdjustmentNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL, 
    [intSort] INT NULL, 
	[ysnPosted] BIT NULL DEFAULT ((0)),
	[intEntityId] INT NULL,
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
	[dtmPostedDate] DATETIME NULL, 
	[dtmUnpostedDate] DATETIME NULL, 
    CONSTRAINT [PK_tblICInventoryAdjustment] PRIMARY KEY ([intInventoryAdjustmentId]), 
    CONSTRAINT [AK_tblICInventoryAdjustment_strAdjustmentNo] UNIQUE ([strAdjustmentNo]), 
    CONSTRAINT [FK_tblICInventoryAdjustment_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) 
)
