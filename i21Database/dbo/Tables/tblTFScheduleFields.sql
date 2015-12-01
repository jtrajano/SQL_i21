CREATE TABLE [dbo].[tblTFScheduleFields](
	[intScheduleColumnId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentDetailId] [int] NULL,
	[strColumn] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strCaption] [nvarchar](max) COLLATE Latin1_General_CI_AS NULL,
	[strFormat] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFooter] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intWidth] [int] NULL,
	[intScheduleFieldTemplateId] [int] NULL,
	[intConcurrencyId] [int] CONSTRAINT [DF_tblTFScheduleFields_intConcurrencyId] DEFAULT ((1)) NULL,
 CONSTRAINT [PK_tblTFScheduleFields] PRIMARY KEY CLUSTERED 
(
	[intScheduleColumnId] ASC
)
)
