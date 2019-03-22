CREATE TABLE [dbo].[tblRMSubreportSetting] (
    [intSubreportSettingId] INT            IDENTITY (1, 1) NOT NULL,
    [intReportId]           INT            NULL,
    [strControlName]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intSubreportId]        INT            NULL,
    [intConcurrencyId]      INT            CONSTRAINT [DF_tblRMSubreportSetting_intConcurrencyId] DEFAULT ((1)) NOT NULL,
    CONSTRAINT [PK_tblRMSubreportSetting] PRIMARY KEY CLUSTERED ([intSubreportSettingId] ASC),
    CONSTRAINT [FK_tblRMSubreportSetting_tblRMReport] FOREIGN KEY ([intReportId]) REFERENCES [dbo].[tblRMReport] ([intReportId])
);



