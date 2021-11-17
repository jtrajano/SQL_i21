﻿--UPDATES THE STATUS OF AR/AP/INVENTORY MODULE IF IT WILL BE OPEN FOR POSTING IN THE FISCAL YEAR SCREEN
GO
	 UPDATE tblGLFiscalYearPeriod SET  ysnAPOpen = 1 WHERE ysnAPOpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnAROpen = 1 WHERE ysnAROpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnINVOpen = 1 WHERE ysnINVOpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnPROpen = 1 WHERE ysnPROpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnCMOpen = 1 WHERE ysnCMOpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnCTOpen = 1 WHERE ysnCTOpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnFAOpen = 1 WHERE ysnFAOpen IS NULL
	 
	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLFiscalYear WHERE ysnCurrent = 1)
	 BEGIN
	 	DECLARE @intFiscalYearId INT
	 	SELECT TOP 1 @intFiscalYearId = intFiscalYearId from tblGLCurrentFiscalYear
		UPDATE fy SET ysnCurrent = 1 FROM tblGLFiscalYear fy JOIN tblGLCurrentFiscalYear cu on cu.intFiscalYearId =  fy.intFiscalYearId
	 END

	 IF NOT EXISTS(SELECT TOP 1 1 FROM tblGLDataFixLog WHERE strDescription= 'Update fiscal period name')
	 BEGIN
		UPDATE tblGLFiscalYearPeriod SET strPeriod = DATENAME(MONTH, dtmStartDate) + ' ' + DATENAME(YEAR, dtmStartDate)
		INSERT INTO tblGLDataFixLog(dtmDate, strDescription) VALUES(GETDATE(), 'Update fiscal period name')
	 END
GO
