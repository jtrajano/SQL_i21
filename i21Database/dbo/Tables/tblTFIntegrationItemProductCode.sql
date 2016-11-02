CREATE TABLE [dbo].[tblTFIntegrationItemProductCode](
	[intIntegrationItemProductCodeId] [int] IDENTITY(1,1) NOT NULL,
	[strSourceRecordConcatKey] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strItemNumber] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[strTaxAuthority] [nvarchar](5) COLLATE Latin1_General_CI_AS NOT NULL,
	[strProductCode] [nvarchar](10) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFIntegrationItemProductCode] PRIMARY KEY CLUSTERED 
(
	[intIntegrationItemProductCodeId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFIntegrationItemProductCode] ADD  CONSTRAINT [DF_tblTFIntegrationItemProductCode_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO
