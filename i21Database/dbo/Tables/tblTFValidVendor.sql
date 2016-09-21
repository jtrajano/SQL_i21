CREATE TABLE [dbo].[tblTFValidVendor]
(
	[intValidVendorId]              INT           IDENTITY (1, 1) NOT NULL,
    [intReportingComponentId] INT           NOT NULL,
    [intVendorId]                   INT           NULL,
    [strVendorId]                   NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [strFilter]                     NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]              INT           CONSTRAINT [DF_tblTFValidVendor_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFValidVendor] PRIMARY KEY CLUSTERED ([intValidVendorId] ASC),
    CONSTRAINT [FK_tblTFValidVendor_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE
)
