CREATE PROCEDURE [dbo].[uspAPUndoBackupAPIVCMST]
AS

SET QUOTED_IDENTIFIER OFF
SET ANSI_NULLS ON
SET NOCOUNT ON
SET XACT_ABORT ON
SET ANSI_WARNINGS OFF

DELETE A
FROM tblAPapivcmst A
INNER JOIN tmp_apivcmstImport B ON A.intId = B.intBackupId

DELETE A
FROM tblAPaphglmst A
INNER JOIN tmp_apivcmstImport B 
	ON B.apivc_ivc_no = A.aphgl_ivc_no
	AND B.apivc_vnd_no = A.aphgl_vnd_no