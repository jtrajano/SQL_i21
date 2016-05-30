CREATE TABLE [dbo].[tblTFValidOriginState]
(
	[intValidOriginStateId] INT            IDENTITY (1, 1) NOT NULL,
    [intReportingComponentDetailId]    INT            NOT NULL,
    [intOriginDestinationStateId]      INT            NULL,
    [strOriginState]        NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strType]                          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strFilter]                        NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]                 INT NULL,
    CONSTRAINT [PK_tblTFValidOriginState] PRIMARY KEY CLUSTERED ([intValidOriginStateId] ASC),
    CONSTRAINT [FK_tblTFValidOriginState_tblTFReportingComponentDetail] FOREIGN KEY ([intReportingComponentDetailId]) REFERENCES [dbo].[tblTFReportingComponentDetail] ([intReportingComponentDetailId]) ON DELETE CASCADE
)
