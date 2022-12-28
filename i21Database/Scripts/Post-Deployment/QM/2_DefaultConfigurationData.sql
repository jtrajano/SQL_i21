GO

IF  (SELECT ysnValidateLotNo FROM tblQMCompanyPreference) = NULL
	BEGIN
		UPDATE tblQMCompanyPreference
		SET ysnValidateLotNo = 1;
	END
GO
