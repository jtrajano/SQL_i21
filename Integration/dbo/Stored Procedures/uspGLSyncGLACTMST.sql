
GO
EXEC(
'ALTER PROCEDURE [dbo].[uspGLSyncGLACTMST]
@intAccountId INT
AS
BEGIN
IF NOT EXISTS (SELECT TOP 1 * FROM sys.tables where tables.name = ''glactmst'') RETURN -1
IF NOT EXISTS(SELECT TOP 1 1 FROM tblSMCompanyPreference WHERE ysnLegacyIntegration = 1) RETURN -1

UPDATE A
SET
glact_active_yn = case when isnull(C.ysnActive,0) = 1 then ''Y'' else ''N'' end ,
glact_sys_acct_yn = case when isnull(C.ysnSystem,0) = 1 then ''Y'' else ''N'' end ,
glact_desc = SUBSTRING(C.strDescription,1,30),
glact_desc_lookup = SUBSTRING(C.strDescription,1,8),
glact_uom = gluommst.A4GLIdentity
from glactmst A JOIN
tblGLCOACrossReference B on A.A4GLIdentity =  B.intLegacyReferenceId 
join vyuGLAccountDetail C on C.intAccountId = B.inti21Id
outer apply (
	select top 1 A4GLIdentity from gluommst WHERE gluom_code COLLATE Latin1_General_CI_AS = C.strUOMCode COLLATE Latin1_General_CI_AS
)gluommst
WHERE C.intAccountId = @intAccountId

UPDATE A
SET stri21Id = B.strAccountId 
FROM tblGLCOACrossReference A JOIN
tblGLAccount B on A.inti21Id = B.intAccountId
WHERE inti21Id = @intAccountId
RETURN 1
END')
GO
