
PRINT ('*****BEGIN CHECKING Move Default Terms For Vendor*****')
if not exists (select top 1 1 from tblEMEntityPreferences where strPreference = 'Move Default Terms For Vendor')
begin
	PRINT ('*****RUNNING Move Default Terms For Vendor*****')
	
	INSERT INTO tblAPVendorTerm (intEntityVendorId, intTermId)
	select intEntityVendorId, intTermsId from tblAPVendor where intTermsId is not null

	INSERT INTO tblEMEntityPreferences(strPreference,strValue)
	select 'Move Default Terms For Vendor', '1'
	

end
PRINT ('*****END CHECKING Move Default Terms For Vendor*****')