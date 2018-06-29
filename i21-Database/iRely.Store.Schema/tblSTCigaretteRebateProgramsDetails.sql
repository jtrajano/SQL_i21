CREATE TABLE [dbo].[tblSTCigaretteRebateProgramsDetails]
(
       [intCigaretteRebateProgramDetailId] INT NOT NULL IDENTITY,
       [intCigaretteRebateProgramId] INT NOT NULL,
       [intItemUOMId] INT NULL,
       [strUpcDescription] NVARCHAR(250) COLLATE Latin1_General_CI_AS NULL,
       --[intUpcModifier] INT NULL,
       [dblRetailPrice] NUMERIC(18, 6) NULL,
	   [intConcurrencyId] INT NOT NULL,
    CONSTRAINT [PK_tblSTCigaretteRebateProgramsDetails] PRIMARY KEY CLUSTERED ([intCigaretteRebateProgramDetailId] ASC),
    CONSTRAINT [FK_tblSTCigaretteRebateProgramsDetails_tblSTCigaretteRebatePrograms_intCigaretteRebateProgramId] FOREIGN KEY ([intCigaretteRebateProgramId]) REFERENCES [tblSTCigaretteRebatePrograms]([intCigaretteRebateProgramId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblSTCigaretteRebateProgramsDetails_tblICItemUOM_intItemUOMId] FOREIGN KEY ([intItemUOMId]) REFERENCES [tblICItemUOM]([intItemUOMId]),
)
