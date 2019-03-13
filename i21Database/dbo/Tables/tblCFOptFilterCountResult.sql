CREATE TABLE [dbo].[tblCFOptFilterCountResult] (
    [intOptFilterCountResultId] INT            IDENTITY (1, 1) NOT NULL,
    [intOptFilterParamId]       INT            NULL,
    [strFilter]                 NVARCHAR (MAX) NULL,
    [strDataType]               NVARCHAR (MAX) NULL,
    [strGuid]                   NVARCHAR (MAX) NULL,
    [intRecordCount]            INT            NULL,
    CONSTRAINT [PK_tblCFOptFilterCountResult] PRIMARY KEY CLUSTERED ([intOptFilterCountResultId] ASC)
);

