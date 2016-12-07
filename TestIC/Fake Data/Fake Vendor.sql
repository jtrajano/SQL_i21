CREATE PROCEDURE [testIC].[Fake Vendor]
AS
BEGIN	
	-- Create mock data for the vendor table
	EXEC tSQLt.FakeTable 'dbo.tblAPVendor';	

	INSERT INTO tblAPVendor (
		intEntityVendorId		
	)
	SELECT intEntityVendorId = 1
END