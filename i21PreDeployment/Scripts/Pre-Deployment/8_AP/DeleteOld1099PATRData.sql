IF(EXISTS(SELECT 1 FROM sys.objects WHERE name = 'tblAP1099PATRCategory'))
BEGIN
	IF EXISTS(SELECT 1 FROM tblAP1099PATRCategory WHERE strCategory = 'Nonpatrnage Distributions')
	BEGIN
		DROP TABLE tblAP1099PATRCategory
	END
END