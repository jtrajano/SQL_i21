CREATE TABLE [dbo].[tblSTCigaretteRebateProgramStore]
(
	[intCigaretteRebateProgramStoreId] INT NOT NULL IDENTITY,
    [intCigaretteRebateProgramId] INT NOT NULL,
    [intStoreId] INT NOT NULL,
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTCigaretteRebateProgramStore] PRIMARY KEY ([intCigaretteRebateProgramStoreId]),
    CONSTRAINT [FK_tblSTCigaretteRebateProgramStore_tblSTCigaretteRebatePrograms_intCigaretteRebateProgramId] FOREIGN KEY ([intCigaretteRebateProgramId]) REFERENCES [dbo].[tblSTCigaretteRebatePrograms] (intCigaretteRebateProgramId) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSTCigaretteRebateProgramStore_tblSTStore_intStoreId] FOREIGN KEY ([intStoreId]) REFERENCES [dbo].[tblSTStore] (intStoreId)
)
GO

CREATE INDEX [IX_tblSTCigaretteRebateProgramStore_intCigaretteRebateProgramId] ON [dbo].[tblSTCigaretteRebateProgramStore] ([intCigaretteRebateProgramId] ASC)
GO 
