/*
 '====================================================================================================================================='
   Stub stored procedure
  -------------------------------------------------------------------------------------------------------------------------------------						
	A stub is created in case GL module is not enabled in origin. 
	The real stored procedure is in the integration project. 
*/
CREATE PROCEDURE  [dbo].[uspGLBuildOriginAccount]
	@intUserId INT
AS
RAISERROR('Build Origin Account Procedure is not available', 16, 1);

