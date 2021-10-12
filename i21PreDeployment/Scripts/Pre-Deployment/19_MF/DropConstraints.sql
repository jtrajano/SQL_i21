IF OBJECT_ID('dbo.[AK_tblQMSampleLabel_strSampleLabelName]', 'UQ') IS NOT NULL 
BEGIN
	ALTER TABLE tblQMSampleLabel DROP CONSTRAINT [AK_tblQMSampleLabel_strSampleLabelName]
END
GO
