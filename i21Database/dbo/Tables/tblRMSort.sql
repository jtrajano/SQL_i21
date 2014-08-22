CREATE TABLE [dbo].[tblRMSort] (
    [intSortId]            INT            IDENTITY (1, 1) NOT NULL,
    [strSortField]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intReportId]          INT            NULL,
    [intSortDirection]     INT            NULL,
    [intUserId]            INT            NULL,
    [ysnRequired]          BIT            NULL,
    [ysnDefault]           BIT            NULL,
    [ysnCanned]            BIT            NULL,
    [intSortConcurrencyId] INT            NULL,
    [intConcurrencyId]     INT            CONSTRAINT [DF__tblRMSort__intCo__7405149D] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dbo.Sorts] PRIMARY KEY CLUSTERED ([intSortId] ASC),
    CONSTRAINT [FK_tblRMSort_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [dbo].[tblRMReport] ([intReportId]) ON DELETE CASCADE
);





