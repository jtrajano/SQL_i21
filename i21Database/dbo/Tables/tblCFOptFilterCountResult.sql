CREATE TABLE [dbo].[tblCFOptFilterCountResult] (
    [intOptFilterCountResultId] INT            IDENTITY (1, 1) NOT NULL,
    [intOptFilterParamId]       INT            NULL,
    [strFilter]                 NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strDataType]               NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strGuid]                   NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [intRecordCount]            INT            NULL,
    CONSTRAINT [PK_tblCFOptFilterCountResult] PRIMARY KEY CLUSTERED ([intOptFilterCountResultId] ASC)
);

