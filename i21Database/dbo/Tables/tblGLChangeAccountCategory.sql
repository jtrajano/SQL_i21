CREATE TABLE [dbo].[tblGLChangeAccountCategory]
(
	[intTransactionId]			INT IDENTITY(1, 1)	NOT NULL,
	[strTransactionId]			NVARCHAR (20)		COLLATE Latin1_General_CI_AS NULL,
	[intAccountId]				INT					NOT NULL,
	[intAccountCategoryId]		INT					NOT NULL,
	[intNewAccountCategoryId]	INT					NULL,
	[ysnChanged]				BIT DEFAULT 0		NOT NULL,
	[intEntityId]				INT					NULL,
	[intConcurrencyId]			INT DEFAULT 1		NOT NULL,

	CONSTRAINT [PK_tblGLChangeAccountCategory] PRIMARY KEY CLUSTERED ([intTransactionId] ASC),
)
