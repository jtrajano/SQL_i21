CREATE TABLE [dbo].[tblMBConsignmentRateDetail]
(
	[intConsignmentRateDetailId] INT NOT NULL IDENTITY, 
    [intConsignmentRateId] INT NOT NULL, 
    [intItemId] INT NOT NULL, 
    [dblBasePumpPrice] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [dblBaseRate] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [dblIntervalPumpPrice] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [dblIntervalRate] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
    [dblConsignmentFloor] NUMERIC(18, 6) NOT NULL DEFAULT ((0)), 
	[strRateType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
    [intSort] INT NULL, 
    [intConcurrencyId] INT NULL DEFAULT ((0)), 
    CONSTRAINT [PK_tblMBConsignmentRateDetail] PRIMARY KEY ([intConsignmentRateDetailId]), 
    CONSTRAINT [FK_tblMBConsignmentRateDetail_tblMBConsignmentRate] FOREIGN KEY ([intConsignmentRateId]) REFERENCES [tblMBConsignmentRate]([intConsignmentRateId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblMBConsignmentRateDetail_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]), 
    CONSTRAINT [AK_tblMBConsignmentRateDetail] UNIQUE ([intConsignmentRateId], [intItemId])
)
