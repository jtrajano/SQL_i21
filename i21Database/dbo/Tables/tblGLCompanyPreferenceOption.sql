CREATE TABLE [dbo].[tblGLCompanyPreferenceOption]
(
	[intCompanyPreferenceOptionId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NULL,
	[PostRemind_Users] NVARCHAR (MAX)  COLLATE Latin1_General_CI_AS NULL,
	[PostRemind_BeforeAfter] NVARCHAR(10)  COLLATE Latin1_General_CI_AS NULL,
	[PostRemind_Days] INT NULL,
	[OriginConversion_OffsetAccountId] INT NULL,
	[ysnConsolidatingParent] [bit] NULL,
	[intDefaultVisibleOldAccountSystemId] INT NULL
    CONSTRAINT [PK_tblGLCompanyPreferenceOption] PRIMARY KEY ([intCompanyPreferenceOptionId])
)
