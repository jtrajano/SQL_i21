/*
 '====================================================================================================================================='
   Stub stored procedure
  -------------------------------------------------------------------------------------------------------------------------------------						
	A stub is created in case GL module is not enabled in origin. 
	The real stored procedure is in the integration project. 
*/

CREATE PROCEDURE  [dbo].[uspGLImportOriginCOA]
	@ysnStructure	BIT = 0,
	@ysnPrimary		BIT = 0,
	@ysnSegment		BIT = 0,
	@ysnUnit		BIT = 0,
	@ysnOverride	BIT = 0,
	@ysnBuild		BIT = 0,
	@result			NVARCHAR(500) = '' OUTPUT
AS
