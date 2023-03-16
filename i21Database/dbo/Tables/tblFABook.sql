﻿CREATE TABLE [dbo].[tblFABook]
(
	[intBookId] INT IDENTITY(1, 1) NOT NULL,
	[strBook] NVARCHAR(100) COLLATE Latin1_General_CI_AS NOT NULL,
	[intConcurrencyId] INT DEFAULT 1 NOT NULL

	CONSTRAINT [PK_tblFABook] PRIMARY KEY CLUSTERED ([intBookId] ASC)
)