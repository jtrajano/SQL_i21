if not exists(select top 1 1 from tblEntityPreferences where strPreference = 'Fix Imported Vendor ysnOrigin Data' and strValue = '1')
begin
	print 'Fix Imported Vendor ysnOrigin Data'
	IF EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblAPVendor') AND name = 'strVendorId')
		AND EXISTS(SELECT * FROM sys.columns WHERE object_id = object_id('tblAPImportedVendors') AND name = 'ysnOrigin')
	BEGIN

		EXEC('UPDATE tblAPImportedVendors set ysnOrigin = 1 where strVendorId in (select strVendorId from tblAPVendor where intPaymentMethodId = 0) and ysnOrigin = 0')

		EXEC(
		'INSERT INTO tblEntityPreferences ( strPreference, strValue)
			VALUES (''Fix Imported Vendor ysnOrigin Data'',''1'') ')
	END
	print 'End Fix Imported Vendor ysnOrigin Data'
end