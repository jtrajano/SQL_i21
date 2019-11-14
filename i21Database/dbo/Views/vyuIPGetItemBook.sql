CREATE VIEW [dbo].[vyuIPGetItemBook]
AS
SELECT IB.intItemId 
	,B.strBook
	,SB.strSubBook
	,IB.intConcurrencyId
	,IB.dtmDateCreated
	,IB.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemBook IB
Left JOIN tblCTBook B on B.intBookId=IB.intBookId
Left JOIN tblCTSubBook SB on SB.intSubBookId=IB.intSubBookId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = IB.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = IB.intModifiedByUserId
