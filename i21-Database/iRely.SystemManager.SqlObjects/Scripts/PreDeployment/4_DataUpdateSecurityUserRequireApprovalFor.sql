IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.TABLE_CONSTRAINTS WHERE CONSTRAINT_NAME = 'UK_tblSMUserSecurityRequireApprovalFor_Column')
BEGIN
	EXEC('ALTER TABLE tblSMUserSecurityRequireApprovalFor DROP CONSTRAINT [UK_tblSMUserSecurityRequireApprovalFor_Column]' )
END

IF EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'strRequireApprovalFor' AND TABLE_NAME = 'tblSMUserSecurityRequireApprovalFor')
BEGIN
	IF NOT EXISTS (SELECT 1 FROM INFORMATION_SCHEMA.COLUMNS WHERE COLUMN_NAME = 'intScreenId' AND TABLE_NAME = 'tblSMUserSecurityRequireApprovalFor')
	BEGIN
		EXEC('ALTER TABLE tblSMUserSecurityRequireApprovalFor ADD intScreenId INT NULL')
	END
	
	EXEC('UPDATE tblSMUserSecurityRequireApprovalFor SET intScreenId = (SELECT intScreenId FROM tblSMScreen WHERE strScreenName = strRequireApprovalFor)')
END