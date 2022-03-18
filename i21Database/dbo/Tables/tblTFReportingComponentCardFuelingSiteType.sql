CREATE TABLE [dbo].[tblTFReportingComponentCardFuelingSiteType]
(
	[intReportingComponentCardFuelingSiteTypeId] INT IDENTITY NOT NULL,
	[intReportingComponentId] INT NOT NULL,
	[strTransactionType] NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
	[ysnInclude] [bit] NOT NULL,
	[intMasterId] INT NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NULL, 
    CONSTRAINT [PK_tblTFReportingComponentCardFuelingSiteType] PRIMARY KEY ([intReportingComponentCardFuelingSiteTypeId]), 
    CONSTRAINT [AK_tblTFReportingComponentCardFuelingSiteType] UNIQUE ([intReportingComponentId], [strTransactionType]), 
    CONSTRAINT [FK_tblTFReportingComponentCardFuelingSiteType_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [tblTFReportingComponent]([intReportingComponentId]) ON DELETE CASCADE
)
