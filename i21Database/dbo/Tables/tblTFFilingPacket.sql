CREATE TABLE [dbo].[tblTFFilingPacket] (
    [intFilingPacketId]       INT IDENTITY (1, 1) NOT NULL,
    [intTaxAuthorityId]       INT NOT NULL,
    [intReportingComponentId] INT NOT NULL,
    [ysnStatus]               BIT NULL,
    [intFrequency]            INT NOT NULL,
    [intConcurrencyId]        INT CONSTRAINT [DF_tblTFFilingPAckety_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFFilingPAckety] PRIMARY KEY CLUSTERED ([intFilingPacketId] ASC),
    CONSTRAINT [FK_tblTFFilingPacket_tblTFFrequency] FOREIGN KEY ([intFrequency]) REFERENCES [dbo].[tblTFFrequency] ([intFrequencyId]),
    CONSTRAINT [FK_tblTFFilingPacket_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]),
    CONSTRAINT [FK_tblTFFilingPacket_tblTFTaxAuthority] FOREIGN KEY ([intTaxAuthorityId]) REFERENCES [dbo].[tblTFTaxAuthority] ([intTaxAuthorityId])
);

