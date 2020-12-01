CREATE VIEW vyuGLConsolidateLog
AS
SELECT 
strDatabase,
strCompany,
L.* FROM tblGLConsolidateLog L 
JOIN tblGLSubsidiaryCompany C 
ON C.intSubsidiaryCompanyId = L.intSubsidiaryCompanyId 