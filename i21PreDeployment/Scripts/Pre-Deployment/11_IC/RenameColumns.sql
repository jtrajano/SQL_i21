
-- Rename tblICItem.intHazmatMessage to tblICItem.intHazmatTag
IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICItem]') AND type in (N'U')) 
BEGIN 
    IF	NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHazmatTag' AND OBJECT_ID = OBJECT_ID(N'tblICItem')) 
		AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intHazmatMessage' AND OBJECT_ID = OBJECT_ID(N'tblICItem'))
    BEGIN
        EXEC sp_rename 'tblICItem.intHazmatMessage', 'intHazmatTag' , 'COLUMN'
    END
END 