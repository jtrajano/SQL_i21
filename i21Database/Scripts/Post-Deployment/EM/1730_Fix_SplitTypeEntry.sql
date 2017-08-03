
PRINT ('*****BEGIN CHECKING Replace from Blank to Both Split Type*****')
if not exists (select top 1 1 from tblEMEntityPreferences where strPreference = 'Replace from Blank to Both Split Type')
begin
	PRINT ('*****RUNNING Replace from Blank to Both Split Type*****')
	
	UPDATE tblEMEntitySplit SET strSplitType = 'Both' where strSplitType = ''

	INSERT INTO tblEMEntityPreferences(strPreference,strValue)
	select 'Replace from Blank to Both Split Type', '1'
	

end
PRINT ('*****END CHECKING Replace from Blank to Both Split Type*****')