CREATE TABLE [dbo].[tblRKOptionsMatchPnSHeader]
(
	[intOptionsMatchPnSHeaderId] INT IDENTITY(1,1) NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
	CONSTRAINT [PK_tblRKOptionsMatchPnSHeader_intOptionsMatchPnSHeaderId] PRIMARY KEY (intOptionsMatchPnSHeaderId)
)