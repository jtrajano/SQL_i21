CREATE TABLE [dbo].[tblTFReportingComponentVendor]
(
	[intReportingComponentVendorId] INT IDENTITY NOT NULL,
    [intReportingComponentId] INT NOT NULL,
    [intVendorId] INT NOT NULL,
	[strVendorName] NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
    [ysnInclude] [bit] NOT NULL,
    [intConcurrencyId] INT DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFReportingComponentVendor] PRIMARY KEY CLUSTERED ([intReportingComponentVendorId] ASC),
    CONSTRAINT [FK_tblTFReportingComponentVendor_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE
)
