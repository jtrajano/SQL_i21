CREATE TABLE [dbo].[tblARTerritory] (
    [intTerritoryId]   INT            IDENTITY (1, 1) NOT NULL,
    [strDescription]   NVARCHAR (255) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            NOT NULL,
    CONSTRAINT [PK_tblARTerritory_intTerritoryId] PRIMARY KEY CLUSTERED ([intTerritoryId] ASC)
);




GO
CREATE UNIQUE NONCLUSTERED INDEX [UQ_tblARTerritory_strDescription]
    ON [dbo].[tblARTerritory]([strDescription] ASC);

