CREATE TABLE [dbo].[tblFRMappingDetails] (
    [intMapDetailID]      INT            IDENTITY (1, 1) NOT NULL,
    [intMapID]            INT            NOT NULL,
    [strTableName]        NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strTableSourceName]  NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strColumnType]       NCHAR (25)     COLLATE Latin1_General_CI_AS NULL,
    [strColumnName]       NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strColumnSourceName] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblFRMapping_1] PRIMARY KEY CLUSTERED ([intMapDetailID] ASC)
);

