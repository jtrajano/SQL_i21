CREATE VIEW [dbo].vyuSMDefaultValues
AS 
SELECT 
DV.*,
strModule = M.strModule,
strScreen = S.strScreenName
FROM tblSMDefaultValues AS DV
LEFT JOIN tblSMModule AS M ON M.intModuleId = DV.intModuleId
LEFT JOIN tblSMScreen AS S ON S.intScreenId = DV.intScreenId