CREATE TABLE [dbo].[tblTFReportingComponentDetail] (
    [intReportingComponentDetailId] INT IDENTITY (1, 1) NOT NULL,
    [intReportingComponentId]       INT NULL,
    CONSTRAINT [PK_tblTFReportingComponentDetail] PRIMARY KEY CLUSTERED ([intReportingComponentDetailId] ASC)
);

