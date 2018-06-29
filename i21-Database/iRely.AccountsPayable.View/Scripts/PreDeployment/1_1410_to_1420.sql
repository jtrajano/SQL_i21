GO

IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblAPVendor]') AND type in (N'U')) 
BEGIN
	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDefaultLocationId' AND OBJECT_ID = OBJECT_ID(N'tblAPVendor')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intEntityLocationId' AND OBJECT_ID = OBJECT_ID(N'tblAPVendor'))
    BEGIN
        EXEC sp_rename 'tblAPVendor.intEntityLocationId', 'intDefaultLocationId' , 'COLUMN'
    END

	IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intDefaultContactId' AND OBJECT_ID = OBJECT_ID(N'tblAPVendor')) AND EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME  = N'intEntityContactId' AND OBJECT_ID = OBJECT_ID(N'tblAPVendor'))
    BEGIN
        EXEC sp_rename 'tblAPVendor.intEntityContactId', 'intDefaultContactId' , 'COLUMN'
    END
END

GO