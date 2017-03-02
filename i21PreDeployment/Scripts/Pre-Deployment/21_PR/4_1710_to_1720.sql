/* 
   Dropping tblPRTimecard.dtmDateIn and tblPRTimecard.dtmDateOut 
   Transfers the Date part of dtmDateIn and dtmDateOut to dtmTimeIn and dtmTimeOut
*/
IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE object_id = OBJECT_ID(N'tblPRTimecard') AND name IN (N'dtmDateIn', N'dtmDateOut'))
BEGIN

--Fix Date part of dtmTimeIn
EXEC('UPDATE tblPRTimecard
		SET dtmTimeIn = STUFF(CONVERT(VARCHAR(50),dtmTimeIn,126) ,1, 10, CONVERT(DATE,dtmDateIn))
		WHERE CONVERT(DATE,dtmTimeIn) = ''2008-01-01''')

--Fix Date part of dtmTimeOut
EXEC('UPDATE tblPRTimecard
		SET dtmTimeOut = STUFF(CONVERT(VARCHAR(50),dtmTimeOut,126) ,1, 10, CONVERT(DATE,dtmDateOut))
		WHERE CONVERT(DATE,dtmTimeOut) = ''2008-01-01''')

END