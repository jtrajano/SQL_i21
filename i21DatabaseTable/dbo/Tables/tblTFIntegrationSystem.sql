CREATE TABLE [dbo].[tblTFIntegrationSystem](
	[intIntegrationSystemId] [int] IDENTITY(1,1) NOT NULL,
	[str3rdPartyCompany] [nvarchar](150) COLLATE Latin1_General_CI_AS NOT NULL,
	[strSystem] [nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFIntegrationSystem] PRIMARY KEY CLUSTERED 
(
	[intIntegrationSystemId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]

GO

ALTER TABLE [dbo].[tblTFIntegrationSystem] ADD  CONSTRAINT [DF_tblTFIntegrationSystem_intConcurrencyId]  DEFAULT ((1)) FOR [intConcurrencyId]
GO

