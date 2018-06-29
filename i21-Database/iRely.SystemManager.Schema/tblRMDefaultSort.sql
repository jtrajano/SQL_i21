CREATE TABLE [dbo].[tblRMDefaultSort] (
    [intDefaultSortId]     INT            IDENTITY (1, 1) NOT NULL,
    [strSortField]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intReportId]          INT            NULL,
    [intSortDirection]     INT            NULL,
    [intUserId]            INT            NULL,
    [ysnRequired]          BIT            NULL,
    [ysnCanned]            BIT            NULL,
    [intSortConcurrencyId] INT            NULL,
    [intConcurrencyId]     INT            CONSTRAINT [DF_tblRMDefaultSort_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblRMDefaultSort] PRIMARY KEY CLUSTERED ([intDefaultSortId] ASC),
    CONSTRAINT [FK_tblRMDefaultSort_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [dbo].[tblRMReport] ([intReportId])
);

