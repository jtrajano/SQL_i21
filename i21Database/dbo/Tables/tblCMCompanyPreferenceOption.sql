CREATE TABLE [dbo].[tblCMCompanyPreferenceOption](
	[intCompanyPreferenceOptionId] [int] IDENTITY(1,1) NOT NULL,
	[intUTCOffset] [int] NULL,
	[intConcurrencyId] [int] NULL,
 CONSTRAINT [PK_tblCMCompanyPreferenceOption] PRIMARY KEY CLUSTERED 
(
	[intCompanyPreferenceOptionId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON) ON [PRIMARY]
) ON [PRIMARY]
GO

