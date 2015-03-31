CREATE TABLE [dbo].[tblICInventoryAdjustment]
(
	[intInventoryAdjustmentId] INT NOT NULL IDENTITY, 
    [intLocationId] INT NOT NULL, 
    [dtmAdjustmentDate] DATETIME NOT NULL DEFAULT (getdate()), 
    [intAdjustmentType] INT NOT NULL, 
    [strAdjustmentNo] NVARCHAR(50) NOT NULL, 
    [strDescription] NVARCHAR(100) NULL, 
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblICInventoryAdjustment] PRIMARY KEY ([intInventoryAdjustmentId]), 
    CONSTRAINT [AK_tblICInventoryAdjustment_strAdjustmentNo] UNIQUE ([strAdjustmentNo]), 
    CONSTRAINT [FK_tblICInventoryAdjustment_tblSMCompanyLocation] FOREIGN KEY ([intLocationId]) REFERENCES [tblSMCompanyLocation]([intCompanyLocationId]) 
)
