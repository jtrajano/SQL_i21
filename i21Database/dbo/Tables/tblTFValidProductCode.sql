CREATE TABLE [dbo].[tblTFValidProductCode](
	[intValidProductCodeId] [int] IDENTITY(1,1) NOT NULL,
	[intReportingComponentId] [int] NOT NULL,
	[intProductCode] [int] NULL,
	[strProductCode] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[strFilter] [nvarchar](50) COLLATE Latin1_General_CI_AS NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFValidProductCode] PRIMARY KEY CLUSTERED 
(
	[intValidProductCodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFValidProductCode] ADD  CONSTRAINT [DF_tblTFValidProductCode_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO
