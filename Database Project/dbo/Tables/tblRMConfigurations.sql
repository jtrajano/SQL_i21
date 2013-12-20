CREATE TABLE [dbo].[tblRMConfigurations] (
    [intConfigurationId] INT            IDENTITY (1, 1) NOT NULL,
    [ysnPrintDirect]     BIT            NOT NULL,
    [strPrinterName]     NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intRecordsPerPage]  INT            NOT NULL,
    [ysnShowPrintDialog] BIT            NOT NULL,
    [intNumberOfCopies]  INT            NOT NULL,
    [intReportId]        INT            NOT NULL,
    CONSTRAINT [PK_dbo.Configurations] PRIMARY KEY CLUSTERED ([intConfigurationId] ASC)
);

