IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[tblICCategoryLocation]') AND type in (N'U')) 
BEGIN 
    IF NOT EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'strCashRegisterDepartment' AND OBJECT_ID = OBJECT_ID(N'tblICCategoryLocation')) 
    BEGIN
		EXEC('ALTER TABLE tblICCategoryLocation ADD strCashRegisterDepartment NVARCHAR(50) COLLATE Latin1_General_CI_AS NULL')
    END
    IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'strCashRegisterDepartment' AND OBJECT_ID = OBJECT_ID(N'tblICCategoryLocation')) 
    BEGIN
		IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE NAME = N'intRegisterDepartmentId' AND OBJECT_ID = OBJECT_ID(N'tblICCategoryLocation'))
		BEGIN
			EXEC('UPDATE tblICCategoryLocation SET strCashRegisterDepartment = CAST(intRegisterDepartmentId AS NVARCHAR)')

			EXEC('
				ALTER TABLE tblICCategoryLocation
				DROP COLUMN intRegisterDepartmentId
			')
		END
    END
	IF EXISTS (SELECT TOP 1 1 FROM sys.objects WHERE object_id = OBJECT_ID(N'[dbo].[vyuICCategoryLocation]') AND type in (N'U')) 
	BEGIN
		EXEC('DROP VIEW vyuICCategoryLocation')

		EXEC('
			CREATE VIEW [dbo].[vyuICCategoryLocation]
			AS 

			SELECT	
				categoryLocation.* 
				,companyLocation.strLocationName
				,companyLocation.intCompanyLocationId
				,strProductCodeId = defaultProductCode.strRegProdCode
				,strFamilyId = defaultFamily.strSubcategoryId
				,strClassId = defaultClass.strSubcategoryId
				,strGeneralItemNo = Item.strItemNo
			FROM	
				tblICCategoryLocation categoryLocation
				LEFT JOIN tblSMCompanyLocation companyLocation
					ON categoryLocation.intLocationId = companyLocation.intCompanyLocationId
				LEFT JOIN tblSTSubcategoryRegProd defaultProductCode
					ON categoryLocation.intProductCodeId = defaultProductCode.intRegProdId
				LEFT JOIN tblSTSubcategory defaultFamily
					ON categoryLocation.intFamilyId = defaultFamily.intSubcategoryId
				LEFT JOIN tblSTSubcategory defaultClass
					ON categoryLocation.intClassId = defaultClass.intSubcategoryId
				LEFT JOIN tblICItem Item ON Item.intItemId = categoryLocation.intGeneralItemId
		')
	END
END