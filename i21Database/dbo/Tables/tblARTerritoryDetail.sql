CREATE TABLE [dbo].[tblARTerritoryDetail] (
    [intTerritoryDetailId] INT            IDENTITY (1, 1) NOT NULL,
    [intTerritoryId]       INT            NOT NULL,
    [strState]             NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strStartZip]          NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strEndZip]            NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]     INT            NOT NULL,
    CONSTRAINT [PK_tblARTerritoryDetail] PRIMARY KEY CLUSTERED ([intTerritoryDetailId] ASC)
);

