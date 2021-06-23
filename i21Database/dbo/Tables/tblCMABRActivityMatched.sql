
CREATE TABLE [dbo].[tblCMABRActivityMatched]
(
    [strActivityMatched] NVARCHAR(20),
	[intABRActivityMatchedId] INT IDENTITY(1,1) NOT NULL,
    [dtmDateEntered] DATETIME,
    [intEntityId] INT NOT NULL,
    CONSTRAINT [PK_tblCMABRActivityMatched] PRIMARY KEY ([intABRActivityMatchedId]), 
)
