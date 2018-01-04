﻿CREATE TABLE [dbo].[tblCTSubBook]
(
	[intSubBookId] INT NOT NULL IDENTITY, 
	intBookId INT NOT NULL,
    [strSubBook] NVARCHAR(10) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strSubBookDescription] NVARCHAR(30) COLLATE Latin1_General_CI_AS NULL, 
    [ysnActive] BIT NOT NULL,	
	[intConcurrencyId] INT NULL, 
    CONSTRAINT [PK_tblCTSubBook_intSubBookId] PRIMARY KEY CLUSTERED ([intSubBookId] ASC), 
    CONSTRAINT [UK_tblCTSubBook_strSubBook_intBookId] UNIQUE ([strSubBook],[intBookId]), 
    CONSTRAINT [FK_tblCTSubBook_tblCTBook_intBookId] FOREIGN KEY ([intBookId]) REFERENCES [tblCTBook]([intBookId]) ON DELETE CASCADE
)
