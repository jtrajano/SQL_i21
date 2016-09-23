CREATE TABLE [dbo].[tblTFReportingComponent] (
    [intReportingComponentId] INT           IDENTITY (1, 1) NOT NULL,
    [intTaxAuthorityId]       INT           NOT NULL,
    [strFormCode]             NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strFormName]             NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strScheduleCode]         NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strScheduleName]         NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strType]                 NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strNote]                 NVARCHAR (300) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType]      NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intPositionId]           INT           NULL,
    [strSPInventory]        NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strSPInvoice] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strSPRunReport] NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblTFReportingComponent] PRIMARY KEY CLUSTERED 
(
	[intReportingComponentId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO
ALTER TABLE [dbo].[tblTFReportingComponent] ADD  CONSTRAINT [DF_tblTFReportingComponent_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO



