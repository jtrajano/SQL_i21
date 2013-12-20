CREATE TABLE [dbo].[tblRMDatasources] (
    [intDatasourceId]   INT            IDENTITY (1, 1) NOT NULL,
    [strName]           NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intReportId]       INT            NOT NULL,
    [intConnectionId]   INT            NOT NULL,
    [strQuery]          NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intDataSourceType] INT            NOT NULL,
    CONSTRAINT [PK_dbo.Datasources] PRIMARY KEY CLUSTERED ([intDatasourceId] ASC)
);

