CREATE TABLE [dbo].[tblTFIntegrationError](
	[intIntegrationErrorId] [int] IDENTITY(1,1) NOT NULL,
	[strSourceRecordConcatKey] [nvarchar](100) COLLATE Latin1_General_CI_AS NOT NULL,
	[strErrorMessage] [nvarchar](1000) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblTFIntegrationError] PRIMARY KEY CLUSTERED 
(
	[intIntegrationErrorId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
