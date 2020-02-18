CREATE TABLE [dbo].[tblSTCigaretteRebateProgramState]
(
	[intCigaretteRebateProgramStateId] INT NOT NULL IDENTITY,
    [intCigaretteRebateProgramId] INT NOT NULL,
	[strState] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT NOT NULL,
	CONSTRAINT [PK_tblSTCigaretteRebateProgramState] PRIMARY KEY ([intCigaretteRebateProgramStateId]),
    CONSTRAINT [FK_tblSTCigaretteRebateProgramState_tblSTCigaretteRebatePrograms_intCigaretteRebateProgramId] FOREIGN KEY ([intCigaretteRebateProgramId]) REFERENCES [dbo].[tblSTCigaretteRebatePrograms] (intCigaretteRebateProgramId) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_tblSTCigaretteRebateProgramState_intCigaretteRebateProgramId] ON [dbo].[tblSTCigaretteRebateProgramState] ([intCigaretteRebateProgramId] ASC)
GO 

