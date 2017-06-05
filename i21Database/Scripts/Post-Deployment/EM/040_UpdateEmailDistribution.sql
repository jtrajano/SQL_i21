
PRINT ('*****BEGIN Update Email Distribution for AR EFT*****')
--if not exists (select top 1 1 from tblEMEntityPreferences where strPreference = 'Update Email Distribution for AR EFT')
--begin
	PRINT ('*****RUNNING Update Email Distribution for AR EFT*****')
	
	IF EXISTS(SELECT TOP 1 1 FROM tblEMEntity where strEmailDistributionOption like '%AR EFT%')
	BEGIN
		UPDATE tblEMEntity SET strEmailDistributionOption = REPLACE(strEmailDistributionOption, 'AR EFT', 'AR Remittance') 
			WHERE strEmailDistributionOption like '%AR EFT%'
	END

	INSERT INTO tblEMEntityPreferences(strPreference,strValue)
	select 'Update Email Distribution for AR EFT', '1'
	

--end
PRINT ('*****END Update Email Distribution for AR EFT*****')