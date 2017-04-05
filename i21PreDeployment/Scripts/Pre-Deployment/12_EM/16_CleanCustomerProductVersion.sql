
declare @build_m int
set @build_m = 0

if EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblSMBuildNumber' and [COLUMN_NAME] = 'strVersionNo')
BEGIN

	exec sp_executesql N'select @build_m = intVersionID from tblSMBuildNumber where strVersionNo like ''%16.1%'' '  , 
		N'@build_m int output', @build_m output;
END

if @build_m = 0

BEGIN

	PRINT 'Start Checking Customer Product Version'

	IF OBJECT_ID('FK_tblARCustomerProductVersion_tblARCustomer') IS NULL
	BEGIN
		IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomerProductVersion' and [COLUMN_NAME] = 'intCustomerId')
		 AND EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'tblARCustomer' and [COLUMN_NAME] = 'intEntityCustomerId')
		BEGIN
			PRINT 'CLEAN CUSTOMER PRODUCT VERSION'
			EXEC('DELETE tblARCustomerProductVersion where intCustomerId not in (select intEntityCustomerId from tblARCustomer)')
		END

	
	END

	PRINT 'End Checking Customer Product Version'

END
GO