CREATE TABLE [dbo].[tblTFValidDestinationState](
	[intValidDestinationStateId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] [int] NOT NULL,
	[intOriginDestinationStateId] [int] NOT NULL,
	[strDestinationState] [nvarchar](10) COLLATE Latin1_General_CI_AS NOT NULL,
	[strStatus] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFValidDestinationState] PRIMARY KEY CLUSTERED 
(
	[intValidDestinationStateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFValidDestinationState]  WITH CHECK ADD  CONSTRAINT [FK_tblTFValidDestinationState_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId])
REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblTFValidDestinationState] CHECK CONSTRAINT [FK_tblTFValidDestinationState_tblTFReportingComponent]
GO




