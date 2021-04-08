CREATE VIEW [dbo].[vyuCTApiContractText]
AS
SELECT 
	t.intContractTextId, 
	t.strTextCode,
	ct.strContractType,
	t.strTextDescription, 
	t.strText, 
	t.strAmendmentText,
	t.ysnActive
FROM tblCTContractText t
LEFT JOIN tblCTContractType ct ON ct.intContractTypeId = t.intContractType