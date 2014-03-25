CREATE TABLE [dbo].[tblARTerritory] (
    [intTerritoryId]   INT            IDENTITY (1, 1) NOT NULL,
    [strDescription]   NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT            NOT NULL,
    CONSTRAINT [PK_tblARTerritory] PRIMARY KEY CLUSTERED ([intTerritoryId] ASC)
);

