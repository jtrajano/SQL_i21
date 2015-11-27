CREATE TABLE [dbo].[tblTFScheduleFormField](
	[intScheduleFormFieldId] [int] IDENTITY(1,1) NOT NULL,
	[intTaxAuthorityId] [int] NULL,
	[strFormCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] CONSTRAINT [DF_tblTFScheduleFormField_intConcurrencyId] DEFAULT ((1)) NULL,
 CONSTRAINT [PK_tblTFScheduleFormField] PRIMARY KEY CLUSTERED 
(
	[intScheduleFormFieldId] ASC
)
)


