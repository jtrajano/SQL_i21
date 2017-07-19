
CREATE TABLE [dbo].tblGLDeletedAccount(
	[intDeletedAccountId] [int] IDENTITY(1,1) NOT NULL,
	[intAccountId] [int] NOT NULL,
	[strAccountId] [nvarchar](40)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strDescription] [nvarchar](255)  COLLATE Latin1_General_CI_AS NOT NULL,
	[strNote] [ntext]  COLLATE Latin1_General_CI_AS NULL,
	[intAccountGroupId] [int] NULL,
	[ysnIsUsed] [bit] ,
	[intConcurrencyId] [int] NOT NULL DEFAULT ((1)),
	[intAccountUnitId] [int] NULL,
	[strComments] [nvarchar](255)  COLLATE Latin1_General_CI_AS NULL,
	[ysnActive] [bit] NULL,
	[ysnSystem] [bit] NULL,
	[ysnRevalue] [bit] NULL,
	[strCashFlow] [nvarchar](50)  COLLATE Latin1_General_CI_AS NULL,
	[intEntityIdLastModified] [int] NULL,
	[intCurrencyID] [int] NULL,
	[intCurrencyExchangeRateTypeId] [int] NULL,
 CONSTRAINT [PK_GLAccountDeleted_AccountId] PRIMARY KEY CLUSTERED 
(
	[intDeletedAccountId] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, FILLFACTOR = 80) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]

GO
