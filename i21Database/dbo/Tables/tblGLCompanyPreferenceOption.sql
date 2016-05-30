CREATE TABLE [dbo].[tblGLCompanyPreferenceOption]
(
	[intCompanyPreferenceOptionId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NULL,
	[PostRemind_Users] NVARCHAR (MAX) NULL,
	[PostRemind_BeforeAfter] NVARCHAR(10) NULL,
	[PostRemind_Days] INT NULL,
	[OriginConversion_OffsetAccountId] INT NULL,
    CONSTRAINT [PK_tblGLCompanyPreferenceOption] PRIMARY KEY ([intCompanyPreferenceOptionId])
)
