CREATE TABLE [dbo].[tblGLChangeAccountCategoryDetail]
(
	[intTransactionDetailId]	INT IDENTITY(1, 1)	NOT NULL,
	[intTransactionId]			INT					NOT NULL,
	[intAccountId]				INT					NOT NULL,
	[intAccountCategoryId]		INT					NOT NULL,
	[intNewAccountCategoryId]	INT					NULL,
	[dtmDate]					DATETIME			NOT NULL,
	[dblGLBalance]				NUMERIC(18,6)		NOT NULL,
	[intEntityId]				INT					NULL,
	[intConcurrencyId]			INT DEFAULT 1		NOT NULL,

	CONSTRAINT [PK_tblGLChangeAccountCategoryDetail] PRIMARY KEY CLUSTERED ([intTransactionDetailId] ASC),
	CONSTRAINT [FK_tblGLChangeAccountCategoryDetail_tblGLChangeAccountCategory] FOREIGN KEY ([intTransactionId]) REFERENCES [dbo].[tblGLChangeAccountCategory]([intTransactionId]) ON DELETE CASCADE
)
