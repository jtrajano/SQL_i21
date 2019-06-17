﻿CREATE FUNCTION [dbo].[fnSTRebateDepartment](@strStoreIdList NVARCHAR(500))
RETURNS @TempTableDepartments TABLE 
(
	ysnSuccess BIT
	, strStatusMessage NVARCHAR(200)
	, intStoreId INT NULL
	, intRegisterDepartmentId INT NULL
	, intCategoryId INT NULL
	, strCategoryCode NVARCHAR(30) NULL
	, strCategoryDescription NVARCHAR(150) NULL
)
AS 
BEGIN
	
	IF EXISTS(SELECT TOP 1 1 FROM tblSTStoreRebates WHERE intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList)))
		BEGIN
			INSERT INTO @TempTableDepartments 
			(
				ysnSuccess
				, strStatusMessage
				, intStoreId
				, intRegisterDepartmentId
				, intCategoryId
				, strCategoryCode
				, strCategoryDescription
			)
			SELECT 
				strStatus							= 1
				, strMessage						= NULL
				, intStoreId						= Rebates.intStoreId
				, intRegisterDepartmentId			= CatLoc.intRegisterDepartmentId
				, intCategoryId						= Category.intCategoryId
				, strCategoryCode					= Category.strCategoryCode
				, strCategoryDescription			= Category.strDescription
			FROM tblSTStoreRebates Rebates
			INNER JOIN tblICCategory Category
				ON Rebates.intCategoryId = Category.intCategoryId
			INNER JOIN tblICCategoryLocation CatLoc
				ON Category.intCategoryId = CatLoc.intCategoryId
			WHERE Rebates.intStoreId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strStoreIdList))

			RETURN

		END
	ELSE
		BEGIN
			INSERT INTO @TempTableDepartments 
			(
				ysnSuccess
				, strStatusMessage
				, intStoreId
				, intRegisterDepartmentId
				, intCategoryId
				, strCategoryCode
				, strCategoryDescription
			)
			VALUES 
			(
				0
				, 'Store does not have setup for Tobacco Department'
				, NULL
				, NULL
				, NULL
				, NULL
				, NULL
			)

			RETURN

		END




	-- OLD Code for tagField Rebate setup
	----// Get Department Id from Store
	--DECLARE @strDepartments AS NVARCHAR(MAX)
	--SELECT @strDepartments = strDepartment 
	--FROM tblSTStore
	--WHERE intStoreId = @intStoreId

	--IF(@strDepartments = '')
	--BEGIN
	--	INSERT INTO @TempTableDepartments (strStatus, strDepartment)
	--	VALUES ('ERROR', 'Store does not have setup for Tobacco Department')
	--	RETURN
	--RETURN
	--END

	----// Insert to tempTable
	--INSERT @TempTableDepartments
	--SELECT 'Success' AS strStatus
	--		, strCategoryCode 
	--FROM tblICCategory 
	--WHERE intCategoryId IN (SELECT Item FROM dbo.fnSTSeparateStringToColumns(@strDepartments,','))

	--IF NOT EXISTS (SELECT * FROM @TempTableDepartments)
	--BEGIN
	--	INSERT INTO @TempTableDepartments (strStatus, strDepartment)
	--	VALUES ('ERROR', 'Tobacco department does not exist')
	--	RETURN
	--END

RETURN
END