CREATE TABLE [dbo].[tblRMDefaultFilter] (
    [intDefaultFilterId]     INT            IDENTITY (1, 1) NOT NULL,
    [strBeginGroup]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strEndGroup]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strJoin]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intReportId]            INT            NOT NULL,
    [strFieldName]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDescription]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strFrom]                NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strTo]                  NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strCondition]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strDataType]            NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intSortId]              INT            NOT NULL,
    [intFilterConcurrencyId] INT            NULL,
    [intUserId]              INT            NOT NULL,
    [intConcurrencyId]       INT            CONSTRAINT [DF_tblRMDefaultFilter_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblRMDefaultFilter] PRIMARY KEY CLUSTERED ([intDefaultFilterId] ASC),
    CONSTRAINT [FK_tblRMDefaultFilter_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [dbo].[tblRMReport] ([intReportId])
);

