CREATE TABLE [dbo].[tblTFReportingComponentItem](
	[intReportingComponentItemId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] [int] NULL,
	[intItemId] [int] NOT NULL,
	[intMasterId] INT NULL,
	[intConcurrencyId] INT NULL DEFAULT((0))
) ON [PRIMARY]

GO
