CREATE TABLE [dbo].[tblBBProgramCharge](
	[intProgramChargeId] [int] IDENTITY(1,1) NOT NULL,
	[intProgramId] INT NOT NULL,
	[intItemId] INT NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBProgramCharge_intConcurrencyId]  DEFAULT ((0)), 
    CONSTRAINT [PK_tblBBProgramCharge] PRIMARY KEY ([intProgramChargeId]), 
    CONSTRAINT [FK_tblBBProgramCharge_tblBBProgram] FOREIGN KEY (intProgramId) REFERENCES [tblBBProgram]([intProgramId]), 
	CONSTRAINT [FK_tblBBProgramCharge_tblICItem] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]),
    
)
GO
