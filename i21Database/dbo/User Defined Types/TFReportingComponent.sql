CREATE TYPE [dbo].[TFReportingComponent] AS TABLE (
	[intId] INT IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] INT           NOT NULL,
    [strFormCode]             NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strFormName]             NVARCHAR (100) COLLATE Latin1_General_CI_AS NULL,
    [strScheduleCode]         NVARCHAR (20)  COLLATE Latin1_General_CI_AS NULL,
    [strScheduleName]         NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strType]                 NVARCHAR (200) COLLATE Latin1_General_CI_AS NULL,
    [strNote]                 NVARCHAR (300) COLLATE Latin1_General_CI_AS NULL,
	[strTransactionType]      NVARCHAR (50) COLLATE Latin1_General_CI_AS NULL,
    [intPositionId]           INT           NULL,
    [strSPInventory]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strSPInvoice]			NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL,
    [strSPRunReport]		NVARCHAR(100) COLLATE Latin1_General_CI_AS NULL
)