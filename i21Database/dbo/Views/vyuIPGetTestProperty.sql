CREATE VIEW vyuIPGetTestProperty
AS
SELECT TP.intTestPropertyId
	,TP.intTestId
	,TP.intPropertyId
	,TP.intConcurrencyId
	,TP.intFormulaID
	,TP.intSequenceNo
	,TP.intCreatedUserId
	,TP.dtmCreated
	,TP.intLastModifiedUserId
	,TP.dtmLastModified
	,TP.intTestPropertyRefId
	,P.strPropertyName
FROM tblQMTestProperty TP WITH (NOLOCK)
LEFT JOIN tblQMProperty P WITH (NOLOCK) ON P.intPropertyId = TP.intPropertyId
