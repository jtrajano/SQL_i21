CREATE TABLE [dbo].[tblCFOptFilterParam] (
    [intOptFilterParamId] INT            IDENTITY (1, 1) NOT NULL,
    [strFilter]           NVARCHAR (MAX) NULL,
    [strDataType]         NVARCHAR (MAX) NULL,
    [strGuid]             NVARCHAR (MAX) NULL,
    CONSTRAINT [PK_tblCFOptFilterParam] PRIMARY KEY CLUSTERED ([intOptFilterParamId] ASC)
);

