if exists (select * from sys.procedures where object_id = object_id('testIC.Fake Vendor'))
	drop procedure [testIC].[Fake Vendor];
GO
CREATE PROCEDURE [testIC].[Fake Vendor]
AS
BEGIN	
	-- Create mock data for the vendor table
	EXEC tSQLt.FakeTable 'dbo.tblAPVendor';	

	INSERT INTO tblAPVendor (
		intEntityVendorId		
	)
	SELECT 1
END