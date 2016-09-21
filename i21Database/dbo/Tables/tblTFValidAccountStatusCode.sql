CREATE TABLE [dbo].[tblTFValidAccountStatusCode] (
    [intValidAccountStatusCodeId]   INT           IDENTITY (1, 1) NOT NULL,
    [intReportingComponentId] INT           NOT NULL,
    [intAccountStatusCodeId]        INT           NULL,
    [strAccountStatusCode]          NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strFilter]                     NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]              INT           CONSTRAINT [DF_tblTFAccountStatusCode_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFAccountStatusCode] PRIMARY KEY CLUSTERED ([intValidAccountStatusCodeId] ASC),
    CONSTRAINT [FK_tblTFValidAccountStatusCode_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE
);

