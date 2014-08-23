CREATE TABLE [dbo].[tblRMFilter] (
    [intFilterId]            INT            IDENTITY (1, 1) NOT NULL,
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
    [ysnDefault]             BIT            NULL,
    [intUserId]              INT            NOT NULL,
    [intConcurrencyId]       INT            CONSTRAINT [DF__tblRMFilt__intCo__6F405F80] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dbo.Filters] PRIMARY KEY CLUSTERED ([intFilterId] ASC),
    CONSTRAINT [FK_tblRMFilter_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [dbo].[tblRMReport] ([intReportId])
);





