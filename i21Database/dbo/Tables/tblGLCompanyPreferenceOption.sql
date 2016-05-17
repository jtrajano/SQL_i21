CREATE TABLE [dbo].[tblGLCompanyPreferenceOption]
(
	[intCompanyPreferenceOptionId] [int] IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] [int] NULL,
	[PostRemind_Users] [nvarchar](500) NULL,
	[PostRemind_BeforeAfter] [nvarchar](10) NULL,
	[PostRemind_Days] [int]  NULL
    CONSTRAINT [PK_tblGLCompanyPreferenceOption] PRIMARY KEY ([intCompanyPreferenceOptionId])
)
