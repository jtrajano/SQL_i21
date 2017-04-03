CREATE TABLE [dbo].[tblLGWarehouseInstructionDetail]
(
	[intWarehouseInstructionDetailId] INT NOT NULL IDENTITY(1, 1),
    [intConcurrencyId] INT NOT NULL,
	[intWarehouseInstructionHeaderId] INT NOT NULL,
	[strCategory] NVARCHAR(300) COLLATE Latin1_General_CI_AS NOT NULL,
	[strActivity] NVARCHAR(1024) COLLATE Latin1_General_CI_AS NOT NULL,
	[intType] INT NOT NULL,
	[dblUnitRate] NUMERIC(18, 6) NOT NULL,
	[intCommodityUnitMeasureId] INT NOT NULL,
	[dblQuantity] NUMERIC(18, 6) NULL,
	[dblCalculatedAmount] NUMERIC(18, 6) NULL,
	[dblActualAmount] NUMERIC(18, 6) NULL,
	[ysnChargeCustomer] [bit] NULL,
	[dblBillAmount] NUMERIC(18, 6) NULL,
	[ysnPrint] [bit] NOT NULL,
	[intSort] INT NOT NULL,
	[dtmCreatedDate] DATETIME NOT NULL,
    [intUserSecurityId] INT NOT NULL,
    [strComments] NVARCHAR(300) COLLATE Latin1_General_CI_AS NULL,
	[intItemId] [int] NULL,
	
    CONSTRAINT [PK_tblLGWarehouseInstructionDetail] PRIMARY KEY ([intWarehouseInstructionDetailId]),
    CONSTRAINT [FK_tblLGWarehouseInstructionDetail_tblLGWarehouseInstructionHeader_intWarehouseInstructionHeaderId] FOREIGN KEY ([intWarehouseInstructionHeaderId]) REFERENCES [tblLGWarehouseInstructionHeader]([intWarehouseInstructionHeaderId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblLGWarehouseInstructionDetail_tblICCommodityUnitMeasure_intCommodityUnitMeasureId] FOREIGN KEY ([intCommodityUnitMeasureId]) REFERENCES [tblICCommodityUnitMeasure]([intCommodityUnitMeasureId]),
    CONSTRAINT [FK_tblLGWarehouseInstructionDetail_tblSMUserSecurity_intUserSecurityId] FOREIGN KEY ([intUserSecurityId]) REFERENCES [tblSMUserSecurity]([intEntityId]),
	CONSTRAINT [FK_tblLGWarehouseInstructionDetail_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId])
)
