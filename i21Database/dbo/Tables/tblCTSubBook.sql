CREATE TABLE [dbo].[tblCTSubBook]
(
	[intSubBookId] INT NOT NULL IDENTITY, 
	intBookId INT NOT NULL,
    [strSubBook] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strSubBookDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NOT NULL, 
    [ysnActive] BIT NOT NULL,
	CONSTRAINT [PK_tblCTSubBook_intSubBookId] PRIMARY KEY CLUSTERED ([intSubBookId] ASC), 
    CONSTRAINT [UK_tblCTSubBook_strSubBook] UNIQUE ([strSubBook]), 
    CONSTRAINT [FK_tblCTSubBook_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId])
)
