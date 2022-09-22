CREATE VIEW [dbo].[vyuGLSearchLedgerAccount]
AS
SELECT
	L.intLedgerId
	,L.strLedgerName
	,L.ysnAllowAnyAccount
	,L.ysnRequireInGLAccount
	,intAccountId = LA.intAccountId
	,ysnRequireSubledger = LA.ysnRequireSubledger
	,L.intConcurrencyId
FROM tblGLLedger L
LEFT JOIN tblGLLedgerAccount LA
	ON LA.intLedgerId = L.intLedgerId
