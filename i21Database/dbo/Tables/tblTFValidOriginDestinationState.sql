CREATE TABLE [dbo].[tblTFValidOriginDestinationState] (
    [intValidOriginDestinationStateId] INT            IDENTITY (1, 1) NOT NULL,
    [intReportingComponentDetailId]    INT            NOT NULL,
    [intOriginDestinationStateId]      INT            NULL,
    [strOriginDestinationState]        NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strType]                          NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [strFilter]                        NVARCHAR (50)  COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]                 INT            CONSTRAINT [DF_tblTFOriginDestinationState_intConcurrencyId] DEFAULT ((1)) NULL,
    CONSTRAINT [PK_tblTFOriginDestinationState] PRIMARY KEY CLUSTERED ([intValidOriginDestinationStateId] ASC),
    CONSTRAINT [FK_tblTFValidOriginDestinationState_tblTFReportingComponentDetail] FOREIGN KEY ([intReportingComponentDetailId]) REFERENCES [dbo].[tblTFReportingComponentDetail] ([intReportingComponentDetailId]) ON DELETE CASCADE
);

