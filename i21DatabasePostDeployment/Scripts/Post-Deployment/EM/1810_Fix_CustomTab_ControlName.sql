GO
	PRINT N'START UPDATE CUSTOMTAB DETAIL'

	BEGIN
		UPDATE tblSMCustomTabDetail
		SET strControlName = REPLACE(strControlName,'#','Number'),
			strFieldName = REPLACE(strFieldName,'#','Number')
	END

	PRINT N'END UPDATE CUSTOMTAB DETAIL'

GO
