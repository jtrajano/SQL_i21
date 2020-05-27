CREATE TABLE [dbo].[tblFRReportHierarchy] (
    [intReportHierarchyId]		INT            IDENTITY (1, 1) NOT NULL,
    [strReportHierarchyName]	NVARCHAR (MAX) COLLATE Latin1_General_CI_AS NULL,
    [intConcurrencyId]			INT            DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRReportHierarchy] PRIMARY KEY CLUSTERED ([intReportHierarchyId] ASC)
);

