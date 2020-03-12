CREATE TABLE [dbo].[tblFRReportHierarchyDetail] (
    [intReportHierarchyDetailId]        INT             IDENTITY (1, 1) NOT NULL,
	[intReportHierarchyId]				INT				NULL,
    [strLevel]							NVARCHAR (50)   COLLATE Latin1_General_CI_AS NULL,
	[strFilterString]					NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
    [intParentGroupId]					INT             NULL,
    [intSort]							INT             NULL,
    [intConcurrencyId]					INT             DEFAULT 1 NOT NULL,
    CONSTRAINT [PK_tblFRReportHierarchyDetail_intReportHierarchyDetailId] PRIMARY KEY CLUSTERED ([intReportHierarchyDetailId] ASC), 
    CONSTRAINT [FK_tblFRReportHierarchyDetail_tblFRReportHierarchy] FOREIGN KEY([intReportHierarchyId])	REFERENCES [dbo].[tblFRReportHierarchy] ([intReportHierarchyId]) ON DELETE CASCADE

);
GO
