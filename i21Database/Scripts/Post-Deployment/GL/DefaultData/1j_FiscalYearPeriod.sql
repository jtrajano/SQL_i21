﻿--UPDATES THE STATUS OF AR/AP/INVENTORY MODULE IF IT WILL BE OPEN FOR POSTING IN THE FISCAL YEAR SCREEN
GO
	 UPDATE tblGLFiscalYearPeriod SET  ysnAPOpen = 1 WHERE ysnAPOpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnAROpen = 1 WHERE ysnAROpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnINVOpen = 1 WHERE ysnINVOpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnPROpen = 1 WHERE ysnPROpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnCMOpen = 1 WHERE ysnCMOpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnCTOpen = 1 WHERE ysnCTOpen IS NULL
	 UPDATE tblGLFiscalYearPeriod SET  ysnFAOpen = 1 WHERE ysnFAOpen IS NULL
GO
