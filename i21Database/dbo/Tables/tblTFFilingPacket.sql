CREATE TABLE [dbo].[tblTFFilingPacket]
(
	[intFilingPacketId] INT IDENTITY NOT NULL,
	[intTaxAuthorityId] INT NOT NULL,
	[intReportingComponentId] INT NOT NULL,
	[ysnStatus] BIT NULL DEFAULT ((1)),
	[intFrequency] INT NOT NULL,
	[intConcurrencyId] INT NULL DEFAULT((1)),
	CONSTRAINT [PK_tblTFFilingPacket] PRIMARY KEY ([intFilingPacketId]),
	CONSTRAINT [FK_tblTFFilingPacket_tblTFTaxAuthority] FOREIGN KEY([intTaxAuthorityId]) REFERENCES [tblTFTaxAuthority] ([intTaxAuthorityId]),
	CONSTRAINT [FK_tblTFFilingPacket_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId]) REFERENCES [tblTFReportingComponent] ([intReportingComponentId])
	ON DELETE CASCADE
)

GO