﻿CREATE TABLE [dbo].[tblTFReportingComponentOriginState]
(
	[intReportingComponentOriginStateId] INT IDENTITY NOT NULL,
    [intReportingComponentId] INT NOT NULL,
    [intOriginDestinationStateId] INT NOT NULL,
    [strType] NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
	[intMasterId] INT NULL,
    [intConcurrencyId] INT DEFAULT((1)) NULL,
    CONSTRAINT [PK_tblTFReportingComponentOriginState] PRIMARY KEY ([intReportingComponentOriginStateId]),
	CONSTRAINT [AK_tblTFReportingComponentOriginState] UNIQUE ([intReportingComponentId], [intOriginDestinationStateId]), 
	CONSTRAINT [FK_tblTFReportingComponentOriginState_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId]) REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId]) ON DELETE CASCADE, 
    CONSTRAINT [FK_tblTFReportingComponentOriginState_tblTFOriginDestinationState] FOREIGN KEY ([intOriginDestinationStateId]) REFERENCES [tblTFOriginDestinationState]([intOriginDestinationStateId])
)
GO

CREATE INDEX [IX_tblTFReportingComponentOriginState_intMasterId] ON [dbo].[tblTFReportingComponentOriginState] ([intMasterId])
GO