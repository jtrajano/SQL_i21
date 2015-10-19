CREATE TABLE [dbo].[tblSMLetter]
(
	[intLetterId] INT NOT NULL IDENTITY, 
    [strName] NVARCHAR(50) COLLATE Latin1_General_CI_AS NOT NULL, 
    [strDescription] NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL, 
    [blbMessage] VARBINARY(MAX) NULL, 
    [intConcurrencyId] INT NOT NULL, 
    CONSTRAINT [PK_tblSMLetter] PRIMARY KEY ([intLetterId]) 
)
