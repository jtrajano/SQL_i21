CREATE TABLE [dbo].[tblFRMapping] (
    [intMapId]        INT           IDENTITY (1, 1) NOT NULL,
    [strMapName]      NVARCHAR (70) COLLATE Latin1_General_CI_AS NULL,
    [intConnectionId] INT           NULL,
    CONSTRAINT [PK_tblFRMapping] PRIMARY KEY CLUSTERED ([intMapId] ASC)
);

