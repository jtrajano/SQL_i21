PRINT '*** Update Vendor Account Number***'
IF EXISTS(SELECT TOP 1 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE [TABLE_NAME] = 'ssvndmst') 
AND NOT EXISTS (SELECT TOP 1 1 FROM tblEntityPreferences WHERE strPreference = 'Update Vendor Account Number' AND strValue = '1')
BEGIN
	PRINT '***  Updating Vendor Account Number***'

	update tblAPVendor 
		set strVendorAccountNum=left(rtrim(convert (Varchar(50),ssvnd_our_cus_no)),50) 
			from tblAPVendor 
				inner join ssvndmst 
					on strVendorPayToId=ssvnd_vnd_no collate Latin1_General_CI_AS
			where (strVendorAccountNum is null or rtrim(strVendorAccountNum)='')
				and ssvnd_our_cus_no is not null


	INSERT INTO tblEntityPreferences ( strPreference, strValue)
	VALUES('Update Vendor Account Number' , '1' )
END
PRINT '*** End Update Vendor Account Number***'