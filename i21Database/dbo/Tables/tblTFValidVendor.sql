CREATE TABLE [dbo].[tblTFValidVendor] (
    [intValidVendorId]              INT           IDENTITY (1, 1) NOT NULL,
    [intReportingComponentDetailId] INT           NOT NULL,
    [intVendorId]                   INT           NULL,
    [strVendorId]                   NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strFilter]                     NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]              INT           CONSTRAINT [DF_tblTFValidVendor_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFValidVendor] PRIMARY KEY CLUSTERED ([intValidVendorId] ASC),
    CONSTRAINT [FK_tblTFValidVendor_tblTFReportingComponentDetail] FOREIGN KEY ([intReportingComponentDetailId]) REFERENCES [dbo].[tblTFReportingComponentDetail] ([intReportingComponentDetailId]) ON DELETE CASCADE
);

