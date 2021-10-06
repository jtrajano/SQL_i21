
CREATE TABLE tblICItemCache (
	intItemCacheId INT NOT NULL IDENTITY(1, 1),
	dtmDateLastUpdated DATETIME NOT NULL,
	intItemId INT NOT NULL,
	CONSTRAINT [PK_tblICItemCache] PRIMARY KEY ([intItemCacheId])
)

GO

	CREATE NONCLUSTERED INDEX [IX_tblICItemCache]
	ON [dbo].[tblICItemCache]([intItemId] ASC)
GO