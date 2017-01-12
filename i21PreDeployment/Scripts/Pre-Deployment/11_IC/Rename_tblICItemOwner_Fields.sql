
-- Rename tblICItemOwner.ysnActive to ysnDefault
IF NOT EXISTS (
	SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnDefault' 
	AND OBJECT_ID = OBJECT_ID(N'tblICItemOwner')
) 
AND EXISTS (
	SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'ysnActive' 
	AND OBJECT_ID = OBJECT_ID(N'tblICItemOwner')
)
BEGIN
	--  - [ysnActive] BIT NULL
	--  + [ysnDefault] BIT NULL
    EXEC sp_rename 'tblICItemOwner.ysnActive', 'ysnDefault' , 'COLUMN'
END
GO