CREATE TABLE [dbo].[tblTFReportingComponentDestinationState](
	[intReportingComponentDestinationStateId] INT IDENTITY NOT NULL,
	[intReportingComponentId] INT NOT NULL,
	[intOriginDestinationStateId] INT NOT NULL,
	[strType] NVARCHAR(20) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] INT DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblTFReportingComponentDestinationState] PRIMARY KEY ([intReportingComponentDestinationStateId]),
	CONSTRAINT [AK_tblTFReportingComponentDestinationState] UNIQUE ([intReportingComponentId], [intOriginDestinationStateId]), 
	CONSTRAINT [FK_tblTFReportingComponentDestinationState_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTFReportingComponentDestinationState_tblTFOriginDestinationState] FOREIGN KEY ([intOriginDestinationStateId]) REFERENCES [tblTFOriginDestinationState]([intOriginDestinationStateId])
)

GO