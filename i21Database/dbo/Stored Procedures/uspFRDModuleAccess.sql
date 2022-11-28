
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
 DECLARE @intControlId INT          
 DECLARE @strPermission NVARCHAR(120) --COLLATE Latin1_General_CI_AS        
 DECLARE @intHasAccess INT  = 0             
        
 SET @intCnt  = (        
  SELECT COUNT(0) FROM tblSMUserSecurityCompanyLocationRolePermission WHERE intEntityId = @intEntityId and intCompanyLocationId = @intCompanyLocationId        
 )    
 SET @intControlId = (SELECT TOP 1 intControlId FROM tblSMControl WHERE strControlName LIKE '%Close Year%' AND intScreenId = (SELECT TOP 1 intScreenId FROM tblSMScreen WHERE strScreenName LIKE '%Fiscal%' AND strNamespace = 'GeneralLedger.view.FiscalYear'))    
         
 IF @intCnt = 0        
  BEGIN         
   SET @strPermission = (SELECT strPermission FROM tblSMUserRoleControlPermission WHERE intControlId = @intControlId AND intUserRoleId = @intUserRoleId)  
   IF @strPermission = 'Editable'  
    BEGIN   
     SET @intHasAccess = 1   
    END   
  END        
 ELSE        
  BEGIN         
   SET @intCompanyUserRole = (SELECT ISNULL(intUserRoleId,0) FROM tblSMUserSecurityCompanyLocationRolePermission WHERE intEntityId = @intEntityId and intCompanyLocationId = @intCompanyLocationId )    
   SET @strPermission = (SELECT strPermission FROM tblSMUserRoleControlPermission WHERE intControlId = @intControlId AND intUserRoleId = @intCompanyUserRole)  
   IF @strPermission = 'Editable'  
    BEGIN   
     SET @intHasAccess = 1   
    END   
  END        
------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------   
  
--RETURN            
SET @hasAccess = @intHasAccess        
END  
  