CREATE TABLE [dbo].[tblTFReportingComponentDestinationState](
	[intReportingComponentDestinationStateId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] [int] NOT NULL,
	[intOriginDestinationStateId] [int] NOT NULL,
	[strType] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] DEFAULT ((1)) NULL,
	CONSTRAINT [PK_tblTFReportingComponentDestinationState] PRIMARY KEY ([intReportingComponentDestinationStateId]),
	CONSTRAINT [AK_tblTFReportingComponentDestinationState] UNIQUE ([intReportingComponentId], [intOriginDestinationStateId]), 
	CONSTRAINT [FK_tblTFReportingComponentDestinationState_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblTFReportingComponentDestinationState_tblTFOriginDestinationState] FOREIGN KEY ([intOriginDestinationStateId]) REFERENCES [tblTFOriginDestinationState]([intOriginDestinationStateId])
)