CREATE TABLE [dbo].[tblFRReportHierarchySchedule] (
    [intHierarchyScheduleId]		INT             IDENTITY (1, 1) NOT NULL,
    [intReportId]		            INT             NOT NULL,
    [intReportHierarchyId]		    INT             NOT NULL,
    [dtmAsOfDate]			        DATETIME        NULL,
    [ysnReportIsSuccess]            BIT             NULL,
    [dtmScheduleDate]			    DATETIME        NULL,
    [intConcurrencyId]			    INT            DEFAULT 1 NOT NULL,
    [ysnRepeatMonthly]				BIT             NULL,
    [strJobsId]		                NVARCHAR (100)  COLLATE Latin1_General_CI_AS NULL,
    [ysnPublish]				    BIT             NULL,
    CONSTRAINT [PK_tblFRReportHierarchySchedule] PRIMARY KEY CLUSTERED ([intHierarchyScheduleId] ASC )
);
