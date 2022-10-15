CREATE TABLE [dbo].[tblTFReportingComponentCarrier]
(
	[intReportingComponentCarrierId] INT IDENTITY NOT NULL,
	[intReportingComponentId] INT NOT NULL,
	[intEntityId] INT NOT NULL,
	[strShipVia] NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
	[ysnInclude] [bit] NOT NULL,
	[intMasterId] INT NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NULL, 
    CONSTRAINT [PK_tblTFReportingComponentCarrier] PRIMARY KEY ([intReportingComponentCarrierId]), 
    CONSTRAINT [AK_tblTFReportingComponentCarrier] UNIQUE ([intReportingComponentId], [intEntityId]), 
    CONSTRAINT [FK_tblTFReportingComponentCarrier_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [tblTFReportingComponent]([intReportingComponentId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblTFReportingComponentCarrier_tblSMShipVia] FOREIGN KEY ([intEntityId]) REFERENCES [tblSMShipVia]([intEntityId])
)