CREATE TABLE [dbo].[tblFRReportHierarchySecurity] (
    [intReportHierarchySecurityId]      INT             IDENTITY (1, 1) NOT NULL,
	[intReportHierarchyId]				INT				NULL,
    [intUserRoleID]						INT             NULL,
    [intConcurrencyId]					INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRReportHierarchySecurity_intReportHierarchySecurityId] PRIMARY KEY CLUSTERED ([intReportHierarchySecurityId] ASC), 
    CONSTRAINT [FK_tblFRReportHierarchySecurity_tblFRReportHierarchy] FOREIGN KEY([intReportHierarchyId])	REFERENCES [dbo].[tblFRReportHierarchy] ([intReportHierarchyId]) ON DELETE CASCADE

);
GO
