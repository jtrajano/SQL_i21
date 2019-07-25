
/*
 fnSMGetVendorRefNoPrefix is a function that returns the Vendor Ref No Prefix from the company location. 
 If value is supplied for @strVendorRefNo, it will auto-append the prefix and return it to caller. 

 Note: Table-Valued functions works better than scalar functions
 See: https://www.captechconsulting.com/blog/jennifer-kenney/performance-considerations-user-defined-functions-sql-server-2012
*/

CREATE FUNCTION [dbo].[fnSMGetVendorRefNoPrefix] (
	@intLocationId INT = NULL 
	,@strVendorRefNo NVARCHAR(50) 
)
RETURNS NVARCHAR(50)
AS 
BEGIN 

	SELECT 
		@strVendorRefNo = CAST(strVendorRefNoPrefix + ISNULL(@strVendorRefNo, '')  AS NVARCHAR(50))
	FROM 
		tblSMCompanyLocation cl
	WHERE
		cl.intCompanyLocationId = @intLocationId
		AND (cl.strVendorRefNoPrefix IS NOT NULL AND LTRIM(RTRIM(cl.strVendorRefNoPrefix)) <> '') 
		AND ISNULL(@strVendorRefNo, '') NOT LIKE strVendorRefNoPrefix + '%'
		AND LTRIM(RTRIM(ISNULL(@strVendorRefNo, ''))) <> ''

	RETURN @strVendorRefNo
END