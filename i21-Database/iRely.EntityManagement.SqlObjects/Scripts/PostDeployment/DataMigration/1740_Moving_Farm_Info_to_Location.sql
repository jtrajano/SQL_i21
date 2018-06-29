
PRINT '*** Start 1740 Farm to Location Migration***'
IF NOT EXISTS(SELECT TOP 1 1 FROM [tblEMEntityPreferences] WHERE strPreference = '1740 Farm to Location Migration')
BEGIN
	PRINT '*** EXECUTE ***'

	
	INSERT INTO tblEMEntityLocation(
		intEntityId,
		strLocationType,
		strLocationName,
		strFarmFieldNumber,
		strFarmFieldDescription,
		strFarmFSANumber,
		strFarmSplitNumber,
		strFarmSplitType
	)
	SELECT 
		a.intEntityId,	
		'Farm',
		substring(strFarmNumber + '-' + strFieldNumber + '-' + (select strLocationName from tblEMEntityLocation b where a.intEntityId = b.intEntityId and b.ysnDefaultLocation = 1), 1, 50), 	
		strFieldNumber, 
		strFieldDescription,
		strFSANumber,
		strSplitNumber,
		strSplitType
	FROM tblEMEntityFarm a
	
	INSERT INTO [tblEMEntityPreferences] ( strPreference, strValue)
	VALUES('1740 Farm to Location Migration', 1)
END
PRINT '*** End 1740 Farm to Location Migration***'
