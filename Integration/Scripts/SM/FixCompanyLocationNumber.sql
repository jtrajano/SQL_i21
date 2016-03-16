GO
	PRINT 'Update strLocationNumbers of tblSMCompanyLocation'
	IF EXISTS(select top 1 1 from sys.procedures where name = 'uspSMSyncCompanyLocation')
	EXEC uspSMSyncCompanyLocation 1, '000'

	PRINT 'Put leading 0 to location number - aglocmst'
	UPDATE aglocmst SET agloc_loc_no = RIGHT('000' + REPLACE(agloc_loc_no, ' ', ''), 3) 
	FROM aglocmst

	PRINT 'Put leading 0 to location number - tblSMCompanyLocation'
	UPDATE tblSMCompanyLocation SET strLocationNumber = RIGHT('000' + REPLACE(strLocationNumber, ' ', ''), 3) 
	FROM tblSMCompanyLocation
GO