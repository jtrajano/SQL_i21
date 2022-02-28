CREATE TABLE [dbo].[tblFRReportHierarchySchedule] (
    [intHierarchyScheduleId]		INT             IDENTITY (1, 1) NOT NULL,
    [intReportId]		            INT             NOT NULL,
    [intReportHierarchyId]		    INT             NOT NULL,
    [dtmAsOfDate]			        DATETIME        NULL,
    [ysnReportIsSuccess]            BIT             NULL,
    [dtmScheduleDate]			    DATETIME        NULL,
    [intConcurrencyId]			INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRReportHierarchySchedule] PRIMARY KEY CLUSTERED ([intHierarchyScheduleId] ASC )
);
