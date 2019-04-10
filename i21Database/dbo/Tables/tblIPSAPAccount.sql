CREATE TABLE [dbo].[tblIPSAPAccount]
(
	[intAccountId] INT IDENTITY(1, 1),
	[strSAPAccountNo] NVARCHAR(50) COLLATE Latin1_General_CI_AS,
	[intCommodityId] INT,
	[ysnGLAccount] BIT NULL,

	CONSTRAINT [PK_tblIPSAPAccount_intAccountId] PRIMARY KEY ([intAccountId]) 
)
