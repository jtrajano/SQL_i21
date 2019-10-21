CREATE TABLE [dbo].[tblBBRateItem](
	[intRateItemId] [int] IDENTITY(1,1) NOT NULL,
	[intItemId] INT NOT NULL, 
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBRateItem_intConcurrencyId]  DEFAULT ((0)),
	[intProgramChargeId] INT NOT NULL, 
    [dtmBeginDate] DATETIME NOT NULL, 
    [dtmEndDate] DATETIME NULL, 
    [dblRatePerUnit] NUMERIC(18, 6) NOT NULL CONSTRAINT [DF_tblBBRateItem_dblRatePerUnit]  DEFAULT ((0)), 
    CONSTRAINT [PK_tblBBRateItem] PRIMARY KEY CLUSTERED ([intRateItemId] ASC),
	CONSTRAINT [FK_tblBBRateItem_tblBBProgramCharge] FOREIGN KEY (intProgramChargeId) REFERENCES [tblBBProgramCharge]([intProgramChargeId]), 
)
GO
