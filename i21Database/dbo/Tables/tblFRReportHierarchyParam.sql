CREATE TABLE [dbo].[tblFRReportHierarchyParam](
	[intParamId]					INT             IDENTITY (1, 1) NOT NULL,
	[strParm]						NVARCHAR (MAX)	COLLATE Latin1_General_CI_AS NULL,
	CONSTRAINT [PK_tblFRReportHierarchyParam] PRIMARY KEY CLUSTERED ([intParamId] ASC)
);