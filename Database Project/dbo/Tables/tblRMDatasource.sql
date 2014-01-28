CREATE TABLE [dbo].[tblRMDatasource] (
    [intDatasourceId]   INT            IDENTITY (1, 1) NOT NULL,
    [strName]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intReportId]       INT            NOT NULL,
    [intConnectionId]   INT            NOT NULL,
    [strQuery]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intDataSourceType] INT            NOT NULL,
    [intConcurrencyId]  INT             NOT NULL DEFAULT 1,
    CONSTRAINT [PK_dbo.Datasources] PRIMARY KEY CLUSTERED ([intDatasourceId] ASC),
    CONSTRAINT [FK_dbo.Datasources_dbo.Connections_intConnectionId] FOREIGN KEY ([intConnectionId]) REFERENCES [dbo].[tblRMConnection] ([intConnectionId]),
    CONSTRAINT [FK_dbo.Datasources_dbo.Reports_intReportId] FOREIGN KEY ([intReportId]) REFERENCES [dbo].[tblRMReport] ([intReportId]) ON DELETE CASCADE
);



