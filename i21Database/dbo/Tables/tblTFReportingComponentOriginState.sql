CREATE TABLE [dbo].[tblTFReportingComponentOriginState]
(
	[intReportingComponentOriginStateId] INT IDENTITY NOT NULL,
    [intReportingComponentId] INT NOT NULL,
    [intOriginDestinationStateId] INT NOT NULL,
    [strType] NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT DEFAULT((1)) NULL,
    CONSTRAINT [PK_tblTFReportingComponentOriginState] PRIMARY KEY ([intReportingComponentOriginStateId]),
	CONSTRAINT [AK_tblTFReportingComponentOriginState] UNIQUE ([intReportingComponentId], [intOriginDestinationStateId]), 
	CONSTRAINT [FK_tblTFReportingComponentOriginState_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblTFReportingComponentOriginState_tblTFOriginDestinationState] FOREIGN KEY ([intOriginDestinationStateId]) REFERENCES [tblTFOriginDestinationState]([intOriginDestinationStateId])
)