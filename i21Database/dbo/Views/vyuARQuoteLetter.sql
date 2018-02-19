CREATE VIEW [dbo].[vyuARQuoteLetter]
AS 
SELECT intLetterId
	 , strName
	 , strPageBody  = CAST(blbMessage AS VARCHAR(MAX))
	 , strModuleName
	 , ysnSystemDefined
	 , blbMessage
	 , intSourceLetterId 
FROM dbo.tblSMLetter WITH (NOLOCK)