CREATE TABLE [dbo].[tblFRMappingDetail] (
    [intMapDetailId]      INT            IDENTITY (1, 1) NOT NULL,
    [intMapId]            INT            NOT NULL,
    [strTableName]        NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strTableSourceName]  NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strColumnType]       NCHAR (25)     COLLATE Latin1_General_CI_AS NULL,
    [strColumnName]       NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strColumnSourceName] NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]	  INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRMappingDetail] PRIMARY KEY CLUSTERED ([intMapDetailId] ASC),
    CONSTRAINT [FK_tblFRMappingDetail_tblFRMapping] FOREIGN KEY([intMapId]) REFERENCES [dbo].[tblFRMapping] ([intMapId]) ON DELETE CASCADE
);
