CREATE TABLE [dbo].[tblFRReportGroupDetail] (
    [intGroupDetailId]			INT				IDENTITY(1,1) NOT NULL,
	[intReportId]				INT				NOT NULL,
	[intReportDetailId]			INT				NULL,
	[intSegmentFilterGroupId]	INT				NULL,
	[intConcurrencyId]			INT				DEFAULT 1 NOT NULL,	    
    CONSTRAINT [PK_tblFRReportGroupDetail] PRIMARY KEY CLUSTERED ([intGroupDetailId] ASC),
    CONSTRAINT [FK_tblFRReportGroupDetail_tblFRReport] FOREIGN KEY([intReportId]) REFERENCES [dbo].[tblFRReport] ([intReportId]) ON DELETE CASCADE,
    CONSTRAINT [FK_tblFRReportGroupDetail_tblFRReport1] FOREIGN KEY([intReportDetailId]) REFERENCES [dbo].[tblFRReport] ([intReportId])	
);
