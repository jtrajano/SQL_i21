CREATE TABLE [dbo].[tblAPBalance]
(
	[intBalanceId] INT NOT NULL PRIMARY KEY IDENTITY(1,1),
	[dblAPBalance] DECIMAL(18,6) NULL,
	[dblGLBalance] DECIMAL(18,6) NULL,
	[ysnBalance] BIT NULL,
	[intConcurrencyId] INT DEFAULT(0) NOT NULL 
)
