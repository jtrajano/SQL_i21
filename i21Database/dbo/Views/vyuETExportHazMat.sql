CREATE VIEW [dbo].[vyuETExportHazMat]    
AS    
SELECT intTagId epa_group, strMessage msg1, msg2 ='' 
FROM tblICTag
WHERE strType = 'Hazmat Message'