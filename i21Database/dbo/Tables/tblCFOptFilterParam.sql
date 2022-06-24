CREATE TABLE [dbo].[tblCFOptFilterParam] (
    [intOptFilterParamId] INT            IDENTITY (1, 1) NOT NULL,
    [strFilter]           NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strDataType]         NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    [strGuid]             NVARCHAR (250) COLLATE Latin1_General_CI_AS NULL,
    CONSTRAINT [PK_tblCFOptFilterParam] PRIMARY KEY CLUSTERED ([intOptFilterParamId] ASC)
);

