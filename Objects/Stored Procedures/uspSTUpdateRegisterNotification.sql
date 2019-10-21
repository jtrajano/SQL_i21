CREATE PROCEDURE [dbo].[uspSTUpdateRegisterNotification]
	@strLocationIds AS NVARCHAR(MAX)
	, @strEntityIds AS NVARCHAR(MAX) OUTPUT
AS
BEGIN

	SET @strEntityIds = ''
-- ==================================================================================================================================================
-- 1. Pass Location Ids in comma separated format
-- 2. If there is no Location Ids, It will not filter Locations
-- 3. View table [vyuSTItemsToRegister] automatically detects all item's that is not being sent to the register 
--    based on table (Date and Store Id) Flag from [tblSTUpdateRegisterHistory]
-- 4. Requirements
--    * Item should have [Location] setup
--    * Item should have [UOM] setup
--    * Item Location setup should have [Product Code]
--    * Item should have [Item Pricing] setup
--    * Item should have [Special Item Pricing] setup
--    * Store should have same [Location] setup
--    * Store should have [Register] setup
-- ==================================================================================================================================================


-- Table to handle intEntityId
DECLARE @tblTempEntity TABLE(intId INT NOT NULL IDENTITY, intEntityId INT)

-- Table to handle filtered intEntityId
DECLARE @tblTempFilteredEntity TABLE(intId INT NOT NULL IDENTITY, intEntityId INT)




-- ######## Insert Non filtered Entity Id
-- IF has location id's
IF(@strLocationIds IS NOT NULL AND @strLocationIds <> '')
	BEGIN
		INSERT @tblTempEntity
		SELECT DISTINCT ITR.intEntityId
		FROM vyuSTItemsToRegister ITR
		WHERE (dtmDateModified BETWEEN     
		ISNULL    
		(     
			(      
				SELECT TOP (1) dtmEndingChangeDate      
				FROM dbo.tblSTUpdateRegisterHistory           
				WHERE intStoreId =       
				(       
					SELECT TOP (1) intStoreId FROM tblSTStore       
					WHERE intCompanyLocationId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strLocationIds))     
				)      
				ORDER BY intUpdateRegisterHistoryId DESC     
			),     
			(      
				SELECT TOP (1) dtmDate      
				FROM dbo.tblSMAuditLog      
				WHERE strTransactionType = 'Inventory.view.Item'      
				OR strTransactionType = 'Inventory.view.ItemLocation'      
				ORDER BY dtmDate ASC     
			)    
		)    
		AND GETUTCDATE())    
		OR 
		(
			dtmDateCreated BETWEEN     
			ISNULL    
			(     
				(      
					SELECT TOP (1) dtmEndingChangeDate      
					FROM dbo.tblSTUpdateRegisterHistory           
					WHERE intStoreId =       
					(       
						SELECT TOP (1) intStoreId FROM tblSTStore       
						WHERE intCompanyLocationId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strLocationIds))       
					)      
					ORDER BY intUpdateRegisterHistoryId DESC     
				),     
				(      
					SELECT TOP (1) dtmDate      
					FROM dbo.tblSMAuditLog      
					WHERE strTransactionType = 'Inventory.view.Item'      
					OR strTransactionType = 'Inventory.view.ItemLocation'      
					ORDER BY dtmDate ASC     
				)    
			)    
			AND GETUTCDATE()
		)
	END
ELSE
	BEGIN
		INSERT @tblTempEntity
		SELECT DISTINCT ITR.intEntityId
		FROM vyuSTItemsToRegister ITR
		WHERE (dtmDateModified BETWEEN     
		ISNULL    
		(     
			(      
				SELECT TOP (1) dtmEndingChangeDate      
				FROM dbo.tblSTUpdateRegisterHistory                 
				ORDER BY intUpdateRegisterHistoryId DESC     
			),     
			(      
				SELECT TOP (1) dtmDate      
				FROM dbo.tblSMAuditLog      
				WHERE strTransactionType = 'Inventory.view.Item'      
				OR strTransactionType = 'Inventory.view.ItemLocation'      
				ORDER BY dtmDate ASC     
			)    
		)    
		AND GETUTCDATE())    
		OR 
		(
			dtmDateCreated BETWEEN     
			ISNULL    
			(     
				(      
					SELECT TOP (1) dtmEndingChangeDate      
					FROM dbo.tblSTUpdateRegisterHistory                
					ORDER BY intUpdateRegisterHistoryId DESC     
				),     
				(      
					SELECT TOP (1) dtmDate      
					FROM dbo.tblSMAuditLog      
					WHERE strTransactionType = 'Inventory.view.Item'      
					OR strTransactionType = 'Inventory.view.ItemLocation'      
					ORDER BY dtmDate ASC     
				)    
			)    
			AND GETUTCDATE()
		)
	END






IF(@strLocationIds != '' AND @strLocationIds IS NOT NULL)
	BEGIN
		INSERT @tblTempFilteredEntity
		SELECT DISTINCT
			ITR.intEntityId
		FROM @tblTempEntity ITR
		JOIN tblSMUserSecurity SMUS ON SMUS.intEntityId = ITR.intEntityId
		LEFT JOIN tblSTUpdateRegisterNotification URN ON URN.intEntityId = ITR.intEntityId
		JOIN vyuSMUserRoleMenuSubRoleMVC SRole ON SMUS.intUserRoleID = SRole.intUserRoleId
		JOIN vyuSMUserRoleMenuLocationMVC MRole ON ITR.intEntityId = MRole.intEntityId
		WHERE (URN.ysnClick IS NULL OR URN.ysnClick = 1)
		AND SRole.strMenuName = 'Update Register' AND SRole.strModuleName = 'Store' AND SRole.ysnVisible = 1
		AND MRole.strMenuName = 'Update Register' AND MRole.strModuleName = 'Store' AND MRole.ysnVisible = 1
		AND SMUS.intCompanyLocationId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strLocationIds))
	END
ELSE
	BEGIN

		INSERT @tblTempFilteredEntity
		SELECT DISTINCT
			ITR.intEntityId
		FROM @tblTempEntity ITR
		JOIN tblSMUserSecurity SMUS ON SMUS.intEntityId = ITR.intEntityId
		LEFT JOIN tblSTUpdateRegisterNotification URN ON URN.intEntityId = ITR.intEntityId
		JOIN vyuSMUserRoleMenuSubRoleMVC SRole ON SMUS.intUserRoleID = SRole.intUserRoleId
		JOIN vyuSMUserRoleMenuLocationMVC MRole ON ITR.intEntityId = MRole.intEntityId
		WHERE (URN.ysnClick IS NULL OR URN.ysnClick = 1)
		AND SRole.strMenuName = 'Update Register' AND SRole.strModuleName = 'Store' AND SRole.ysnVisible = 1
		AND MRole.strMenuName = 'Update Register' AND MRole.strModuleName = 'Store' AND MRole.ysnVisible = 1
		AND SMUS.intCompanyLocationId IN (SELECT intCompanyLocationId FROM tblSTStore WHERE intCompanyLocationId IS NOT NULL AND intRegisterId IS NOT NULL)
	END


IF EXISTS(SELECT * FROM @tblTempFilteredEntity)
	BEGIN
		-- ==============================================================================================
		-- Return intEntity Id's in comma separated format
		SET @strEntityIds = ''
		SELECT @strEntityIds = @strEntityIds + COALESCE(CAST(EM.intEntityId AS NVARCHAR(20)) + ',','')
		FROM @tblTempFilteredEntity EM
			   --JOIN tblSMUserSecurity SMUS ON SMUS.intEntityId = EM.intEntityId
			   --JOIN tblEMEntityType ET ON ET.intEntityId = EM.intEntityId
			   --WHERE SMUS.intCompanyLocationId IN (SELECT [intID] FROM [dbo].[fnGetRowsFromDelimitedValues](@strLocationIds))
			   --AND ET.strType IN ('User', 'Employee')
		SET @strEntityIds = left(@strEntityIds, len(@strEntityIds)-1)
		-- ==============================================================================================

		DECLARE @Id INT
		DECLARE @intEntityId INT

		WHILE EXISTS(SELECT * FROM @tblTempFilteredEntity)
			BEGIN

				SELECT TOP 1 @Id = intId, @intEntityId = intEntityId From @tblTempFilteredEntity

				IF EXISTS(SELECT intEntityId FROM tblSTUpdateRegisterNotification WHERE intEntityId = @intEntityId)
					BEGIN
						UPDATE tblSTUpdateRegisterNotification
						SET ysnClick = 0
						WHERE intEntityId = @intEntityId
						AND ysnClick = 1
					END
				ELSE
					BEGIN
						INSERT INTO tblSTUpdateRegisterNotification(intEntityId)
						VALUES(@intEntityId)
					END

				DELETE @tblTempFilteredEntity WHERE intId = @Id

			END
		END
	END