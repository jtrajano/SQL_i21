CREATE TABLE [dbo].[tblCTBook]
(
	[intBookId] INT NOT NULL IDENTITY, 
    [strBook] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strBookDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [ysnActive] BIT NOT NULL,
	[intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblCTBook_intBookId] PRIMARY KEY CLUSTERED ([intBookId] ASC), 
    CONSTRAINT [UK_tblCTBook_strBook] UNIQUE ([strBook])
)
