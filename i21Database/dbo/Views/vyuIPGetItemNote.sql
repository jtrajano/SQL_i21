CREATE VIEW [dbo].[vyuIPGetItemNote]
AS
SELECT ItemNote.intItemId
	,L.strLocationName
	,ItemNote.[strCommentType]
	,ItemNote.[strComments]
	,ItemNote.[intSort]
	,ItemNote.intConcurrencyId
	,ItemNote.dtmDateCreated
	,ItemNote.dtmDateModified
	,US.strUserName AS strCreatedBy
	,US1.strUserName AS strModifiedBy
FROM tblICItemNote ItemNote
LEFT JOIN tblICItemLocation IL on IL.intItemLocationId =ItemNote.intItemLocationId
Left JOIN tblSMCompanyLocation L on L.intCompanyLocationId=IL.intLocationId
LEFT JOIN tblSMUserSecurity US ON US.intEntityId = ItemNote.intCreatedByUserId
LEFT JOIN tblSMUserSecurity US1 ON US1.intEntityId = ItemNote.intModifiedByUserId
