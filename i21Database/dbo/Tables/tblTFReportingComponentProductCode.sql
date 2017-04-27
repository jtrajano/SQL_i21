CREATE TABLE [dbo].[tblTFReportingComponentProductCode](
	[intReportingComponentProductCodeId] INT IDENTITY NOT NULL,
	[intReportingComponentId] INT NOT NULL,
	[intProductCodeId] INT NOT NULL,
	[strType] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT DEFAULT((1)) NULL, 
	CONSTRAINT [PK_tblTFReportingComponentProductCode] PRIMARY KEY ([intReportingComponentProductCodeId]), 
	CONSTRAINT [AK_tblTFReportingComponentProductCode] UNIQUE ([intReportingComponentId], [intProductCodeId]), 
    CONSTRAINT [FK_tblTFReportingComponentProductCode_tblTFReportingComponent] FOREIGN KEY ([intReportingComponentId]) REFERENCES [tblTFReportingComponent]([intReportingComponentId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblTFReportingComponentProductCode_tblTFProductCode] FOREIGN KEY ([intProductCodeId]) REFERENCES [tblTFProductCode]([intProductCodeId])
)