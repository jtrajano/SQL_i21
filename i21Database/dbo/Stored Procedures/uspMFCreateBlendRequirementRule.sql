/****************************************************************
	Title: Create Blend Requirement Rule
	Description: Insert default value of business rule for Blend
	JIRA: MFG-4787 / MFG-4575
	Created By: Jonathan Valenzuela
	Date: 12/28/2022
*****************************************************************/
CREATE PROCEDURE [dbo].[uspMFCreateBlendRequirementRule]
	@intBlendRequirementId INT
AS
INSERT INTO tblMFBlendRequirementRule (intBlendRequirementId
									 , intBlendSheetRuleId
									 , strValue
									 , intSequenceNo)
SELECT @intBlendRequirementId
     , SheetRule.intBlendSheetRuleId
	 , CASE WHEN SheetRule.intBlendSheetRuleId = 7 THEN IssuedUOM.strName
			ELSE RuleValue.strValue
	   END
	 , SheetRule.intSequenceNo 
FROM tblMFBlendSheetRule AS SheetRule 
JOIN tblMFBlendSheetRuleValue AS RuleValue on SheetRule.intBlendSheetRuleId = RuleValue.intBlendSheetRuleId AND RuleValue.ysnDefault=1
OUTER APPLY (SELECT AD.strName
			 FROM tblMFBlendRequirement AS AB
			 LEFT JOIN tblMFMachine AS AC ON AB.intMachineId = AC.intMachineId
			 LEFT JOIN tblMFMachineIssuedUOMType AS AD ON AC.intIssuedUOMTypeId = AD.intIssuedUOMTypeId
			 WHERE AB.intBlendRequirementId = @intBlendRequirementId) AS IssuedUOM
ORDER BY SheetRule.intSequenceNo 