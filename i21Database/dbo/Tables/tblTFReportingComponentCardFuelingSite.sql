CREATE TABLE [dbo].[tblTFReportingComponentCardFuelingSite]
(
	[intReportingComponentCardFuelingSiteId] INT IDENTITY NOT NULL,
	[intReportingComponentId] INT NOT NULL,
	[intSiteId] INT NOT NULL,
	[strSiteNumber] NVARCHAR (150) COLLATE Latin1_General_CI_AS NULL,
	[ysnInclude] [bit] NOT NULL,
	[intMasterId] INT NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NULL, 
    CONSTRAINT [PK_tblTFReportingComponentCardFuelingSite] PRIMARY KEY ([intReportingComponentCardFuelingSiteId]), 
    CONSTRAINT [AK_tblTFReportingComponentCardFuelingSite] UNIQUE ([intReportingComponentId], [intSiteId]), 
    CONSTRAINT [FK_tblTFReportingComponentCardFuelingSite_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [tblTFReportingComponent]([intReportingComponentId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblTFReportingComponentCardFuelingSite_tblCFSite] FOREIGN KEY ([intSiteId]) REFERENCES [tblCFSite]([intSiteId])
)