CREATE VIEW [dbo].[vyuICRebuildHistory]
AS

SELECT 
	intBackupId = BackupLog.intBackupId,
	strUserName = UserSecurity.strUserName,
	dtmDate = BackupLog.dtmDate,
	strOperation = BackupLog.strOperation,
	strRemarks = BackupLog.strRemarks,
	intCompanyId = BackupLog.intCompanyId,
	ysnRebuilding = BackupLog.ysnRebuilding,
	dtmStart = BackupLog.dtmStart,
	dtmEnd = BackupLog.dtmEnd,
	strItemNo = BackupLog.strItemNo,
	strCategoryCode = BackupLog.strCategoryCode,
	strStatus = CASE
		WHEN BackupLog.ysnFailed = 1
		THEN 'Failed'
		ELSE 'Success'
	END
FROM
	tblICBackup BackupLog
INNER JOIN
	tblSMUserSecurity UserSecurity
	ON
		BackupLog.intUserId = UserSecurity.intEntityId