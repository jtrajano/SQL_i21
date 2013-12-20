CREATE TABLE [dbo].[tblFRMapping] (
    [intMapID]        INT           IDENTITY (1, 1) NOT NULL,
    [strMapName]      NVARCHAR (70) COLLATE Latin1_General_CI_AS NULL,
    [intConnectionID] INT           NULL,
    CONSTRAINT [PK_tblFRMapping1] PRIMARY KEY CLUSTERED ([intMapID] ASC)
);

