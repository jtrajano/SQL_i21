PRINT 'Start Updating Other Taxation Point to None'

IF ISNULL(OBJECT_ID(N'tblSMFreightTerms'),'') <>''
	BEGIN
		UPDATE tblSMFreightTerms SET strFobPoint = 'None' WHERE strFobPoint = 'Other'
	END

PRINT 'End Updating Other Taxation Point to None'