CREATE TABLE [dbo].[tblTFValidAccountStatusCode] (
    [intValidAccountStatusCodeId]   INT           IDENTITY (1, 1) NOT NULL,
    [intReportingComponentDetailId] INT           NOT NULL,
    [intAccountStatusCodeId]        INT           NULL,
    [strAccountStatusCode]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strFilter]                     NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]              INT           CONSTRAINT [DF_tblTFAccountStatusCode_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFAccountStatusCode] PRIMARY KEY CLUSTERED ([intValidAccountStatusCodeId] ASC),
    CONSTRAINT [FK_tblTFValidAccountStatusCode_tblTFReportingComponentDetail] FOREIGN KEY ([intReportingComponentDetailId]) REFERENCES [dbo].[tblTFReportingComponentDetail] ([intReportingComponentDetailId]) ON DELETE CASCADE
);

