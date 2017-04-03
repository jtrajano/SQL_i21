﻿CREATE PROCEDURE [dbo].[uspSMUpdateUserPermissions]  
 @userRoleId INT
AS  
  
SET QUOTED_IDENTIFIER OFF  
SET ANSI_NULLS ON  
SET NOCOUNT ON  
SET XACT_ABORT ON  
SET ANSI_WARNINGS OFF  
  
DECLARE @userId INT  
  
BEGIN TRANSACTION  

-- Get all users in the role specified
SELECT [intEntityId] INTO #tmpUserSecurities  
FROM tblSMUserSecurity WHERE intUserRoleID = @userRoleId  

-- Clear out control permissions of all users in the role specified.
DELETE tblSMUserSecurityControlPermission 
WHERE [intEntityUserSecurityId] IN (SELECT [intEntityId] FROM #tmpUserSecurities)

-- Clear out screen permissions of all users in the role specified. 
DELETE tblSMUserSecurityScreenPermission 
WHERE [intEntityUserSecurityId] IN (SELECT [intEntityId] FROM #tmpUserSecurities)

WHILE EXISTS (SELECT TOP 1 1 FROM #tmpUserSecurities)  
BEGIN  
	SELECT TOP 1 @userId = [intEntityId] FROM #tmpUserSecurities  

	-- Cascade role control permissions to user control permissions.
	INSERT INTO tblSMUserSecurityControlPermission ([intEntityUserSecurityId], intControlId, strPermission, strLabel, strDefaultValue, ysnRequired, intConcurrencyId)
	SELECT @userId, intControlId, strPermission, strLabel,strDefaultValue, ysnRequired, 1 FROM tblSMUserRoleControlPermission WHERE intUserRoleId = @userRoleId
	
	-- Cascade role screen permissions to user control permissions.
	INSERT INTO tblSMUserSecurityScreenPermission ([intEntityUserSecurityId], intScreenId, strPermission, intConcurrencyId)
	SELECT @userId, intScreenId, strPermission, 1 FROM tblSMUserRoleScreenPermission WHERE intUserRoleId = @userRoleId
	    
	DELETE FROM #tmpUserSecurities WHERE [intEntityId] = @userId  
END  
 
COMMIT TRANSACTION