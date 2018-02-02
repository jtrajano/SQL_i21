CREATE TABLE [dbo].[tblBBProgramCharge](
	[intProgramChargeId] [int] IDENTITY(1,1) NOT NULL,
	[intProgramId] INT NOT NULL,
	[strCharge] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NOT NULL CONSTRAINT [DF_tblBBProgramCharge_intConcurrencyId]  DEFAULT ((0)), 
    CONSTRAINT [PK_tblBBProgramCharge] PRIMARY KEY ([intProgramChargeId]), 
    CONSTRAINT [FK_tblBBProgramCharge_tblBBProgram] FOREIGN KEY (intProgramId) REFERENCES [tblBBProgram]([intProgramId]) ON DELETE CASCADE, 
    
)
GO
