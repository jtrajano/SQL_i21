GO
	IF EXISTS(SELECT strScreenId FROM tblSMScreen WHERE strScreenId =  'My Company (Portal)')
	BEGIN
		DELETE FROM tblSMScreen WHERE strScreenId = 'My Company (Portal)'
	END
GO