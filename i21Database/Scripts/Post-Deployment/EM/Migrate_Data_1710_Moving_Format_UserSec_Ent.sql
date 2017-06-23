
PRINT ('*****BEGIN CHECKING Migrate Format USec Ent*****')
if not exists (select top 1 1 from tblEMEntityPreferences where strPreference = 'Migrate Format USec Ent')
begin
	PRINT ('*****RUNNING Migrate Format USec Ent*****')
	
	UPDATE B SET B.strDateFormat = A.strDateFormat,
			B.strNumberFormat = A.strNumberFormat
		FROM tblSMUserSecurity A
			JOIN tblEMEntity B
				ON A.intEntityUserSecurityId = B.intEntityId

	UPDATE tblEMEntity SET strDateFormat = 'M/d/yyyy',
		strNumberFormat = '1,234,567.89'
		WHERE intEntityId IN (select intEntityContactId from tblEMEntityToContact where ysnPortalAccess = 1)

	INSERT INTO tblEMEntityPreferences(strPreference,strValue)
	select 'Migrate Format USec Ent', '1'
	

end
PRINT ('*****END CHECKING Migrate Format USec Ent*****')