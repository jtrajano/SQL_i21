
PRINT ('*****BEGIN CHECKING Update password history encryption*****')
if not exists (select top 1 1 from tblEMEntityPreferences where strPreference = 'Update password history encryption')
begin
	PRINT ('*****RUNNING Update password history encryption*****')
	
	update tblEMEntityPasswordHistory set strPassword = dbo.fnAESEncryptASym(strPassword)

	INSERT INTO tblEMEntityPreferences(strPreference,strValue)
	select 'Update password history encryption', '1'
	

end
PRINT ('*****END CHECKING Update password history encryption*****')