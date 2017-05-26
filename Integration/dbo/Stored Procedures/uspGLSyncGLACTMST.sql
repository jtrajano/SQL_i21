
GO
IF EXISTS(select top 1 1 from sys.procedures where name = 'uspGLSyncGLACTMST')
	DROP PROCEDURE uspGLSyncGLACTMST
GO
EXEC(
'CREATE procedure uspGLSyncGLACTMST
@ysnActive BIT,
@ysnSystem BIT,
@intAccountId INT,
@strAccountId NVARCHAR(20),
@strDescription NVARCHAR(30),
@strDescriptionLookup NVARCHAR(8),
@strUnit NVARCHAR(20)
AS
BEGIN
IF NOT EXISTS (SELECT TOP 1 * FROM sys.tables where tables.name = ''glactmst'') RETURN -1
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1) RETURN -1

DECLARE @LegacyReferenceId INT = NULL
SELECT TOP 1 @LegacyReferenceId = intLegacyReferenceId FROM tblGLCOACrossReference WHERE inti21Id = @intAccountId

IF @LegacyReferenceId IS NULL RETURN -1

UPDATE glactmst
SET 
glact_active_yn = case when @ysnActive = 1 then ''Y'' else ''N'' end , 
glact_sys_acct_yn = case when @ysnSystem = 1 then ''Y'' else ''N'' end , 
glact_desc = @strDescription,
glact_desc_lookup = @strDescriptionLookup, glact_uom = gluommst.A4GLIdentity
from glactmst 
outer apply (
	select top 1 A4GLIdentity from gluommst WHERE gluom_code = @strUnit
)gluommst
WHERE glactmst.A4GLIdentity = @LegacyReferenceId

UPDATE tblGLCOACrossReference
SET stri21Id = @strAccountId WHERE inti21Id = @intAccountId

RETURN 1
END')
GO
