CREATE PROCEDURE [dbo].[uspSMRefreshUserRoleMenus]  
AS  
BEGIN  
 -- Update User Role and User Security Menus  
 DECLARE @currentRow INT  
 DECLARE @totalRows INT  
 DECLARE @intNewPerformanceLogId INT = NULL,  
   @strRequestId NVARCHAR(200) = NEWID()  
  
 EXEC dbo.uspSMLogPerformanceRuntime @strModuleName = 'System Manager'
           , @strScreenName   = NULL  
           , @strProcedureName       = 'uspSMRefreshUserRoleMenus'  
           , @strRequestId   = @strRequestId  
           , @ysnStart          = 1  
           , @intUserId             = NULL  
           , @intPerformanceLogId    = NULL  
           , @intNewPerformanceLogId = @intNewPerformanceLogId OUT  
  
 SET @currentRow = 1  
 SELECT @totalRows = Count(*) FROM [tblSMUserRole] WHERE (strRoleType IN ('Administrator', 'User'))  
  
 WHILE (@currentRow <= @totalRows)  
 BEGIN  
  
 Declare @roleId INT  
 SELECT @roleId = intUserRoleID FROM (    
  SELECT ROW_NUMBER() OVER(ORDER BY intUserRoleID ASC) AS 'ROWID', *  
  FROM [tblSMUserRole] WHERE (strRoleType IN ('Administrator', 'User'))  
 ) a  
 WHERE ROWID = @currentRow  
  
 PRINT N'Executing uspSMUpdateUserRoleMenus'  
 Exec uspSMUpdateUserRoleMenus @roleId, 1, 0  
  
 SET @currentRow = @currentRow + 1  
 END  
  
 EXEC dbo.uspSMLogPerformanceRuntime @strModuleName = 'System Manager'
           , @strScreenName   = NULL  
           , @strProcedureName       = 'uspSMRefreshUserRoleMenus'  
           , @strRequestId   = @strRequestId  
           , @ysnStart          = 0  
           , @intUserId             = NULL  
           , @intPerformanceLogId    = @intNewPerformanceLogId  
END  
