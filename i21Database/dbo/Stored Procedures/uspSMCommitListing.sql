﻿CREATE PROCEDURE [dbo].[uspSMCommitListing]    
AS    
    
SET QUOTED_IDENTIFIER OFF    
SET ANSI_NULLS ON    
SET NOCOUNT ON    
SET XACT_ABORT ON    
SET ANSI_WARNINGS OFF    
    
BEGIN TRANSACTION    
   
 -- INSERT Screens  
 INSERT INTO tblSMScreen (  
  strScreenId,  
  strScreenName,  
  strModule,  
  strNamespace,  
  intConcurrencyId,  
  strGroupName,  
  ysnSearch  
 )  
 SELECT DISTINCT  
  '',  
  strScreenName,  
  strModule,  
  strNamespace,  
  intConcurrencyId,  
  strGroupName,  
  ysnSearch  
 FROM tblSMScreenStage  
 WHERE ISNULL(strChange, '') = 'Added' AND strNamespace NOT IN (SELECT strNamespace FROM tblSMScreen)  
  
 -- DELETE custom tab  
 DELETE FROM tblSMCustomTab WHERE intScreenId IN   
 (  
  SELECT intScreenId FROM tblSMScreen   
  WHERE strNamespace IN (SELECT strNamespace FROM tblSMScreenStage WHERE strChange = 'Deleted')   
  AND strNamespace <> 'ContractManagement.view.ContractAmendment'  
 )  
  
 -- DELETE Screens  
 DELETE FROM tblSMScreen   
 WHERE strNamespace IN (SELECT strNamespace FROM tblSMScreenStage WHERE strChange = 'Deleted') AND strNamespace <> 'ContractManagement.view.ContractAmendment' AND (ysnApproval = 0 OR ysnApproval IS NULL)
 --AND intScreenId NOT IN (SELECT intScreenId FROM tblSMTransaction)  
   
 -- INSERT Controls  
 INSERT INTO tblSMControl (  
  strControlId,  
  strControlName,  
  strControlType,  
  strContainer,  
  intScreenId,  
  intConcurrencyId  
 )  
 SELECT   
  DISTINCT  
  A.strControlId,  
  A.strControlName,  
  A.strControlType,  
  A.strContainer,  
  C.intScreenId,  
  A.intConcurrencyId  
 FROM tblSMControlStage A  
  INNER JOIN tblSMScreenStage B ON A.intScreenStageId = B.intScreenStageId  
  INNER JOIN tblSMScreen C ON B.strNamespace = C.strNamespace  
 WHERE ISNULL(A.strChange, '') = 'Added'  
  
 UPDATE tblSMControl  
 SET strControlName = A.strControlName,  
  strControlType = A.strControlType  
 FROM tblSMControlStage A  
  INNER JOIN tblSMScreenStage B ON A.intScreenStageId = B.intScreenStageId  
  INNER JOIN tblSMScreen C ON B.strNamespace = C.strNamespace  
  INNER JOIN tblSMControl D ON D.strControlId = A.strControlId  
 WHERE ISNULL(A.strChange, '') = 'Updated' AND B.strNamespace = C.strNamespace and D.intScreenId = C.intScreenId  
   
 -- DELETE Controls  
 -- DELETE tblSMControl   
 -- FROM tblSMControlStage A  
 -- 		INNER JOIN tblSMScreenStage B  ON A.intScreenStageId = B.intScreenStageId  
 -- 		INNER JOIN tblSMScreen C ON B.strNamespace = C.strNamespace     
 -- 		INNER JOIN tblSMControl D ON D.strControlId = A.strControlId   
 -- WHERE ISNULL(A.strChange, '') = 'Deleted'  
  
 DELETE tblSMControl   
 FROM tblSMControlStage A  
   INNER JOIN tblSMScreenStage B  ON A.intScreenStageId = B.intScreenStageId  
   INNER JOIN tblSMScreen C ON B.strNamespace = C.strNamespace     
   INNER JOIN tblSMControl D ON D.strControlId = A.strControlId   
 WHERE ISNULL(A.strChange, '') = 'Deleted'  
 AND  
 B.strNamespace = C.strNamespace and D.intScreenId = C.intScreenId  
  
 -- UPDATE MODULE  
 UPDATE tblSMScreen SET strModule = 'Ticket Management'  
 WHERE strModule = 'Grain'  
   
 -- DELETE Stage  
 DELETE FROM tblSMScreenStage  
  
 -- UPDATE Company Setup  
 UPDATE tblSMCompanySetup   
 SET ysnScreenControlListingUpdated = 1,
 ysnTooltipListingUpdated = 0
  
 UPDATE tblSMScreen SET ysnAvailable = 0 WHERE strNamespace IN   
 (   
  'SystemManager.view.UserRole',  
  'SystemManager.view.Letters',  
  'SystemManager.view.FileFieldMapping',  
  'SystemManager.view.SecurityPolicy',  
  'SystemManager.view.Signatures'  
  --'SystemManager.view.EntityUser'  
 )  
  
 --*************UPDATE tblSMScreen GroupName WHEN generating listing for contact user*************--  
 DECLARE @intScreenId INT,  
   @intMenuId INT,  
   @strMenuName NVARCHAR(50),  
   @intParentMenuId INT  
  
   SELECT sc.intScreenId,  
       mm.intMenuID,  
       mm.intParentMenuID,  
       mm.strMenuName  
         
   INTO #Temp  
   FROM tblSMScreen sc  
   INNER JOIN tblSMMasterMenu mm ON sc.strNamespace = LEFT(mm.strCommand, (CASE WHEN (CHARINDEX('?', mm.strCommand) - 1) < 0 THEN 0 ELSE (CHARINDEX('?', mm.strCommand) - 1) END))  
   INNER JOIN tblSMContactMenu cm ON mm.intMenuID = cm.intMasterMenuId   
  
   WHILE EXISTS(SELECT * FROM #Temp)  
    BEGIN  
     SELECT TOP 1   
      @intScreenId = intScreenId,  
      @intMenuId = intMenuID,  
      @strMenuName = strMenuName,  
      @intParentMenuId = intParentMenuID  
     FROM #Temp ORDER BY intMenuID  
      
       UPDATE tblSMScreen SET strGroupName = (SELECT REPLACE(strMenuName,'(Portal)','') FROM tblSMMasterMenu WHERE intMenuID = @intParentMenuId) WHERE intScreenId  = @intScreenId  
      
       DELETE FROM #Temp WHERE intMenuID = @intMenuId  
      
    END  
  
   DROP TABLE  #Temp  
  
  
COMMIT TRANSACTION
