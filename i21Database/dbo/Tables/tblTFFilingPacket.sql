CREATE TABLE [dbo].[tblTFFilingPacket](
	[intFilingPacketId] [int] IDENTITY(1,1) NOT NULL,
	[intTaxAuthorityId] [int] NOT NULL,
	[intReportingComponentId] [int] NOT NULL,
	[ysnStatus] [bit] NULL,
	[intFrequency] [int] NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFFilingPAckety] PRIMARY KEY CLUSTERED 
(
	[intFilingPacketId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFFilingPacket] ADD  CONSTRAINT [DF_tblTFFilingPAckety_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO

ALTER TABLE [dbo].[tblTFFilingPacket]  WITH CHECK ADD  CONSTRAINT [FK_tblTFFilingPacket_tblTFFilingPacket] FOREIGN KEY([intFilingPacketId])
REFERENCES [dbo].[tblTFFilingPacket] ([intFilingPacketId])
GO

ALTER TABLE [dbo].[tblTFFilingPacket] CHECK CONSTRAINT [FK_tblTFFilingPacket_tblTFFilingPacket]
GO

ALTER TABLE [dbo].[tblTFFilingPacket]  WITH CHECK ADD  CONSTRAINT [FK_tblTFFilingPacket_tblTFFrequency] FOREIGN KEY([intFrequency])
REFERENCES [dbo].[tblTFFrequency] ([intFrequencyId])
GO

ALTER TABLE [dbo].[tblTFFilingPacket] CHECK CONSTRAINT [FK_tblTFFilingPacket_tblTFFrequency]
GO

ALTER TABLE [dbo].[tblTFFilingPacket]  WITH CHECK ADD  CONSTRAINT [FK_tblTFFilingPacket_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId])
REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblTFFilingPacket] CHECK CONSTRAINT [FK_tblTFFilingPacket_tblTFReportingComponent]
GO

ALTER TABLE [dbo].[tblTFFilingPacket]  WITH CHECK ADD  CONSTRAINT [FK_tblTFFilingPacket_tblTFTaxAuthority] FOREIGN KEY([intTaxAuthorityId])
REFERENCES [dbo].[tblTFTaxAuthority] ([intTaxAuthorityId])
GO

ALTER TABLE [dbo].[tblTFFilingPacket] CHECK CONSTRAINT [FK_tblTFFilingPacket_tblTFTaxAuthority]
GO


