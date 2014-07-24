CREATE TABLE [dbo].[tblRMDatasource] (
    [intDatasourceId]   INT            IDENTITY (1, 1) NOT NULL,
    [strName]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intReportId]       INT            NOT NULL,
    [intConnectionId]   INT            NOT NULL,
    [strQuery]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intDataSourceType] INT            NOT NULL,
    [intConcurrencyId]  INT            DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_dbo.Datasources] PRIMARY KEY CLUSTERED ([intDatasourceId] ASC),
    CONSTRAINT [FK_tblRMDatasource_tblRMConnection] FOREIGN KEY ([intConnectionId]) REFERENCES [dbo].[tblRMConnection] ([intConnectionId]),
    CONSTRAINT [FK_tblRMDatasource_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [dbo].[tblRMReport] ([intReportId]) ON DELETE CASCADE
);



