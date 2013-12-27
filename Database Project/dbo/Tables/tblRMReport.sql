CREATE TABLE [dbo].[tblRMReport] (
    [intReportId]              INT             IDENTITY (1, 1) NOT NULL,
    [blbLayout]                VARBINARY (MAX) NULL,
    [strName]                  NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strGroup]                 NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strBuilderServiceAddress] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [strWebViewerAddress]      NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [ysnAllowChangeFieldname]  BIT             NOT NULL,
    [ysnAllowRemoveFieldname]  BIT             NOT NULL,
    [ysnAllowAddFieldname]     BIT             NOT NULL,
    [ysnUseAllAndOperator]     BIT             NOT NULL,
    [ysnShowQuery]             BIT             NOT NULL,
    [strDescription]           NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intCompanyInformationId]  INT             NULL,
    [intGroupSort]             INT             NULL,
    [intNameSort]              INT             NULL,
    CONSTRAINT [PK_dbo.Reports] PRIMARY KEY CLUSTERED ([intReportId] ASC)
);

