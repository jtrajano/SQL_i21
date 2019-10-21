CREATE TABLE [dbo].[tblICItemBook]
(
	intItemBookId INT NOT NULL IDENTITY(1,1),
	intItemId INT NOT NULL,
	intBookId INT NOT NULL,
	intSubBookId INT NULL,
	intCompanyId INT NULL,
	dtmDateCreated DATETIME NULL,
	dtmDateModified DATETIME NULL,
	intModifiedByUserId INT NULL,
	intCreatedByUserId INT NULL,
	intConcurrencyId INT NULL,
	CONSTRAINT [FK_tblICItemBook_tblICItem_intItemId] FOREIGN KEY ([intItemId]) REFERENCES [tblICItem]([intItemId]) ON DELETE CASCADE,
	CONSTRAINT [FK_tblICItemBook_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]),
	CONSTRAINT [PK_tblICItemBook_intItemBookId] PRIMARY KEY ([intItemBookId]),
	CONSTRAINT [AK_tblICItemBook_intItemId_intBookId_intSubBookId] UNIQUE ([intItemId], [intBookId], [intSubBookId])
)

GO