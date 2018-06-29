CREATE TABLE [dbo].[tblBBRateUOM](
	[intRateUOMId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBRateUOM_intConcurrencyId]  DEFAULT ((0)),
	[intProgramChargeId] INT NOT NULL, 
    [intUnitMeasureId] INT NOT NULL, 
    [dtmBeginDate] DATETIME NOT NULL, 
    [dtmEndDate] DATETIME NULL, 
    [dblRatePerUnit] NUMERIC(18, 6) NOT NULL CONSTRAINT [DF_tblBBRateUOM_dblRatePerUnit]  DEFAULT ((0)), 
    CONSTRAINT [PK_tblBBRateUOM] PRIMARY KEY CLUSTERED ([intRateUOMId] ASC),
	CONSTRAINT [FK_tblBBRateUOM_tblBBProgramCharge] FOREIGN KEY (intProgramChargeId) REFERENCES [tblBBProgramCharge]([intProgramChargeId]), 
)
GO
