CREATE TABLE [dbo].[tblFRGroupsDetail] (
    [intGroupDetailId]		INT				IDENTITY(1,1) NOT NULL,
	[intGroupId]			INT				NOT NULL,
	[intReportId]			INT				NULL,
	[strReportDescription]	NVARCHAR(255)	COLLATE Latin1_General_CI_AS NULL,
	[ysnShowReportSettings] BIT				NULL,
	[intSegmentCode]		INT				NULL,
	[intConcurrencyId]		INT				DEFAULT 1 NOT NULL,
    
    CONSTRAINT [PK_tblFRGroupsDetail] PRIMARY KEY CLUSTERED ([intGroupDetailId] ASC, [intGroupId] ASC)
);
