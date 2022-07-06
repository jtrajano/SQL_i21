CREATE TABLE [dbo].[tblFRReportHierarchyScheduleDetails] (
	[intHierarchyScheduleDetailId]      INT             IDENTITY (1, 1) NOT NULL,
	[intReportId]				INT             NULL,
	[intHierarchyScheduleId]			INT				NULL,
    [intReportHierarchyId]				INT             NULL,
	[intReportHierarchyDetailId]		INT				NULL,	
	[dtmAsOfDate]                       DATETIME        NULL,
	[dtmSchedDate]                       DATETIME        NULL,
	[ysnIsSuccess]						BIT             DEFAULT 0,    
	[strError]							NVARCHAR (255)  COLLATE Latin1_General_CI_AS NULL,
	[intJobsId]							INT             DEFAULT 1 NOT NULL,    
    [intConcurrencyId]					INT             DEFAULT 1 NOT NULL,    
    CONSTRAINT [PK_tblFRReportHierarchyScheduleDetails_intHierarchyScheduleDetailId] PRIMARY KEY CLUSTERED ([intHierarchyScheduleDetailId] ASC), 
);
GO