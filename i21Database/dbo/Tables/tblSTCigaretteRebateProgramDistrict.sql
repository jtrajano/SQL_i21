CREATE TABLE [dbo].[tblSTCigaretteRebateProgramDistrict]
(
	[intCigaretteRebateProgramDistrictId] INT NOT NULL IDENTITY,
    [intCigaretteRebateProgramId] INT NOT NULL,
    [strDistrict] NVARCHAR(150) NOT NULL,
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSTCigaretteRebateProgramDistrict] PRIMARY KEY ([intCigaretteRebateProgramDistrictId]),
    CONSTRAINT [FK_tblSTCigaretteRebateProgramDistrict_tblSTCigaretteRebatePrograms_intCigaretteRebateProgramId] FOREIGN KEY ([intCigaretteRebateProgramId]) REFERENCES [dbo].[tblSTCigaretteRebatePrograms] (intCigaretteRebateProgramId) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_tblSTCigaretteRebateProgramDistrict_intCigaretteRebateProgramId] ON [dbo].[tblSTCigaretteRebateProgramDistrict] ([intCigaretteRebateProgramId] ASC)
GO 
