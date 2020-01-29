CREATE TABLE [dbo].[tblRKOptionsMatchPnSHeaderBook]
(
	intOptionsMatchPnSHeaderBookId INT IDENTITY(1,1) NOT NULL,
	intOptionsMatchPnSHeaderId INT NOT NULL,
	intBookId INT NOT NULL,
	CONSTRAINT [PK_tblRKOptionsMatchPnSHeaderBook_intOptionsMatchPnSHeaderBookId] PRIMARY KEY (intOptionsMatchPnSHeaderBookId)
)
