CREATE TABLE [dbo].[tblRMSubreportSetting] (
    [intSubreportSettingId] INT            IDENTITY (1, 1) NOT NULL,
    [intReportId]           INT            NOT NULL,
    [intSubreportId]        INT            NOT NULL,
    [strControlName]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intType]               INT            NOT NULL,
    [strParentField]        NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strParentDataType]     NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strChildField]         NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [strChildDataType]      NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]      INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_dbo.SubreportSettings] PRIMARY KEY CLUSTERED ([intSubreportSettingId] ASC),
    CONSTRAINT [FK_dbo.SubreportSettings_dbo.Reports_intReportId] FOREIGN KEY ([intReportId]) REFERENCES [dbo].[tblRMReport] ([intReportId]) ON DELETE CASCADE
);

