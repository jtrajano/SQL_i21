CREATE PROCEDURE [dbo].[uspSMRefreshUserRoleMenus]  
AS  
BEGIN  
 -- Update User Role and User Security Menus  
 DECLARE @currentRow INT  
 DECLARE @totalRows INT  
 DECLARE @intNewPerformanceLogId INT = NULL
  
 EXEC dbo.uspSMLogPerformanceRuntime 
             @strModuleName             = 'System Manager'
           , @strScreenName             = 'Stored Procedure'  
           , @strProcedureName          = 'uspSMRefreshUserRoleMenus'  
           , @ysnStart                  = 1  
           , @intUserId                 = 1
           , @intPerformanceLogId       = NULL  
           , @strGroup                  = NULL
           , @intNewPerformanceLogId    = @intNewPerformanceLogId OUT  
  
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
  
 EXEC dbo.uspSMLogPerformanceRuntime 
             @strModuleName         = 'System Manager'
           , @strScreenName         = 'Stored Procedure'  
           , @strProcedureName      = 'uspSMRefreshUserRoleMenus'  
           , @ysnStart              = 0  
           , @intUserId             = 1
           , @strGroup               = NULL
           , @intPerformanceLogId   = @intNewPerformanceLogId  
END  
