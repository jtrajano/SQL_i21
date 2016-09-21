CREATE TABLE [dbo].[tblTFValidOriginState]
(
	[intValidOriginStateId] INT            IDENTITY (1, 1) NOT NULL,
    [intReportingComponentId]    INT            NOT NULL,
    [intOriginDestinationStateId]      INT            NULL,
    [strOriginState]        NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strType]                          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strFilter]                        NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]                 INT NULL,
    CONSTRAINT [PK_tblTFValidOriginState] PRIMARY KEY CLUSTERED 
(
	[intValidOriginStateId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFValidOriginState]  WITH CHECK ADD  CONSTRAINT [FK_tblTFValidOriginState_tblTFReportingComponent] FOREIGN KEY([intReportingComponentId])
REFERENCES [dbo].[tblTFReportingComponent] ([intReportingComponentId])
ON DELETE CASCADE
GO

ALTER TABLE [dbo].[tblTFValidOriginState] CHECK CONSTRAINT [FK_tblTFValidOriginState_tblTFReportingComponent]
GO


