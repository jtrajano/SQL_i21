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

IF NOT EXISTS(SELECT TOP 1 1 from [tblEMEntityPreferences] where strPreference = 'Transfer mapping from IC to ST 2' and strValue = '1')
BEGIN
	EXEC('INSERT INTO	tblSTStoreDepartments (intStoreId, intCategoryId, strRegisterCode, intConcurrencyId)
			SELECT			b.intStoreId,
							a.intCategoryId,
							a.strCashRegisterDepartment,
							1 as intConcurrencyId
			FROM			tblICCategoryLocation a
			INNER JOIN		tblSTStore b
			ON				a.intLocationId = b.intCompanyLocationId
			WHERE			b.ysnConsignmentStore = 1 AND a.strCashRegisterDepartment IS NOT NULL AND a.strCashRegisterDepartment != ''''')

	EXEC('UPDATE tblSTStore SET strDepartmentOrCategory = ''D'', strCategoriesOrSubcategories = ''C''')
	EXEC('INSERT INTO tblEMEntityPreferences ( strPreference, strValue) VALUES (''Transfer mapping from IC to ST 2'',''1'') ')
END 

IF NOT EXISTS(SELECT TOP 1 1 from [tblEMEntityPreferences] where strPreference = 'Transfer mapping from IC to ST 3' and strValue = '1')
BEGIN
	EXEC('INSERT INTO	tblSTStoreDepartments (intStoreId, intCategoryId, strRegisterCode, intConcurrencyId)
			SELECT			b.intStoreId,
							a.intCategoryId,
							a.strCashRegisterDepartment,
							1 as intConcurrencyId
			FROM			tblICCategoryLocation a
			INNER JOIN		tblSTStore b
			ON				a.intLocationId = b.intCompanyLocationId
			WHERE		    b.ysnConsignmentStore = 0')

	EXEC('UPDATE tblSTStore SET strDepartmentOrCategory = ''D'', strCategoriesOrSubcategories = ''C''')
	EXEC('INSERT INTO tblEMEntityPreferences ( strPreference, strValue) VALUES (''Transfer mapping from IC to ST 3'',''1'') ')
END