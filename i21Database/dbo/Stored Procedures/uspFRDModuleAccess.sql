CREATE PROCEDURE  [dbo].[uspFRDModuleAccess]            
 @intUserRoleId AS INT,          
 @intEntityId AS INT,          
 @intCompanyLocationId AS INT,      
 @strMenuName AS NVARCHAR(MAX),                                  
 @hasAccess AS INT OUTPUT    
AS            
          
SET QUOTED_IDENTIFIER OFF                    
SET ANSI_NULLS ON                    
SET NOCOUNT ON                    
SET XACT_ABORT ON                 
          
          
BEGIN          
 DECLARE @intCnt INT        
 DECLARE @intCompanyUserRole INT          
 DECLARE @intHasAccess INT  = 0         
    
	SET @intCnt   = (    
		SELECT COUNT(0) FROM tblSMUserSecurityCompanyLocationRolePermission WHERE intEntityId = @intEntityId and intCompanyLocationId = @intCompanyLocationId    
	)     
	IF @intCompanyUserRole = 0    
		BEGIN     
			SET @intHasAccess = (SELECT ISNULL(ysnVisible,0) FROM tblSMUserRoleMenu WHERE intUserRoleId = @intUserRoleId AND intMenuId = (select TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = @strMenuName))    
		END    
	ELSE    
		BEGIN     
			SET @intCompanyUserRole = (SELECT ISNULL(intUserRoleId,0) FROM tblSMUserSecurityCompanyLocationRolePermission WHERE intEntityId = @intEntityId and intCompanyLocationId = @intCompanyLocationId )
			SET @intHasAccess = (SELECT ISNULL(ysnVisible,0) FROM tblSMUserRoleMenu WHERE intUserRoleId = @intCompanyUserRole AND intMenuId = (select TOP 1 intMenuID FROM tblSMMasterMenu WHERE strMenuName = @strMenuName))    
		END    
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------    
--RETURN        
 SET @hasAccess = @intHasAccess    
END