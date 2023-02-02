GO
IF NOT EXISTS(SELECT TOP 1 1 from [tblEMEntityPreferences] where strPreference = 'Transfer mapping from IC to ST' and strValue = '1')
BEGIN
	exec('UPDATE a
			SET a.strRegisterFuelId1 = d.strPassportFuelId1,
				a.strRegisterFuelId2 = d.strPassportFuelId2
			FROM dbo.tblSTPumpItem a
			INNER JOIN tblSTStore b
			ON a.intStoreId = b.intStoreId
			INNER JOIN tblICItemUOM c
			ON a.intItemUOMId = c.intItemUOMId
			INNER JOIN tblICItemLocation d
			ON c.intItemId = d.intItemId AND b.intCompanyLocationId = d.intLocationId')
	EXEC(
		'INSERT INTO tblEMEntityPreferences ( strPreference, strValue)
			VALUES (''Transfer mapping from IC to ST'',''1'') ')
END 