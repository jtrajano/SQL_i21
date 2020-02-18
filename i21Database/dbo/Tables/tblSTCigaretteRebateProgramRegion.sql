CREATE TABLE [dbo].[tblSTCigaretteRebateProgramRegion]
(
	[intCigaretteRebateProgramRegionId] INT NOT NULL IDENTITY,
    [intCigaretteRebateProgramId] INT NOT NULL,
    [strRegion] NVARCHAR(150) NOT NULL,
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTCigaretteRebateProgramRegion] PRIMARY KEY ([intCigaretteRebateProgramRegionId]),
    CONSTRAINT [FK_tblSTCigaretteRebateProgramRegion_tblSTCigaretteRebatePrograms_intCigaretteRebateProgramId] FOREIGN KEY ([intCigaretteRebateProgramId]) REFERENCES [dbo].[tblSTCigaretteRebatePrograms] (intCigaretteRebateProgramId) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_tblSTCigaretteRebateProgramRegion_intCigaretteRebateProgramId] ON [dbo].[tblSTCigaretteRebateProgramStore] ([intCigaretteRebateProgramId] ASC)
GO 
