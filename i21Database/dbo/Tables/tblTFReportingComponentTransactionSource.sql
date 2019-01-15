CREATE TABLE [dbo].[tblTFReportingComponentTransactionSource]
(
	[intReportingComponentTransactionSourceId] INT IDENTITY NOT NULL,
    [intReportingComponentId] INT NOT NULL,
	[intMasterId] INT NULL,
	[ysnInclude] [bit] NOT NULL,
    [intConcurrencyId] INT DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblTFReportingComponentTransactionSource] PRIMARY KEY ([intReportingComponentTransactionSourceId] ASC),
	CONSTRAINT [FK_tblTFReportingComponentTransactionSource_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE
)
GO

CREATE INDEX [IX_tblTFReportingComponentTransactionSource_intMasterId] ON [dbo].[tblTFReportingComponentTransactionSource] ([intMasterId])
GO
