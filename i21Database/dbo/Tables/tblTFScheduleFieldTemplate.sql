CREATE TABLE [dbo].[tblTFScheduleFieldTemplate](
	[intScheduleFieldTemplateId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] [int] NOT NULL,
	[strColumn] [nvarchar](MAX) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] CONSTRAINT [DF_tblTFScheduleFieldTemplate_intConcurrencyId] DEFAULT ((1)) NULL,
 CONSTRAINT [PK_tblTFScheduleFieldsTemplate] PRIMARY KEY CLUSTERED 
(
	[intScheduleFieldTemplateId] ASC
))
