/* 
   Applying Referential Constraints to Account ID fields 
   Clean-up any Account IDs that does not exist in GL Account
*/

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intLiabilityAccount' AND object_id = object_id(N'tblPRCompanyPreference')) 
EXEC ('UPDATE tblPRCompanyPreference SET intLiabilityAccount = NULL WHERE intLiabilityAccount NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intExpenseAccount' AND object_id = object_id(N'tblPRCompanyPreference')) 
EXEC ('UPDATE tblPRCompanyPreference SET intExpenseAccount = NULL WHERE intExpenseAccount NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intEarningAccountId' AND object_id = object_id(N'tblPRCompanyPreference')) 
EXEC ('UPDATE tblPRCompanyPreference SET intEarningAccountId = NULL WHERE intEarningAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intDeductionAccountId' AND object_id = object_id(N'tblPRCompanyPreference')) 
EXEC ('UPDATE tblPRCompanyPreference SET intDeductionAccountId = NULL WHERE intDeductionAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPREmployeeDeduction')) 
EXEC ('UPDATE tblPREmployeeDeduction SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intExpenseAccountId' AND object_id = object_id(N'tblPREmployeeDeduction')) 
EXEC ('UPDATE tblPREmployeeDeduction SET intExpenseAccountId = NULL WHERE intExpenseAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPREmployeeEarning')) 
EXEC ('UPDATE tblPREmployeeEarning SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPREmployeeEarningDistribution')) 
EXEC ('UPDATE tblPREmployeeEarningDistribution SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPREmployeeTax')) 
EXEC ('UPDATE tblPREmployeeTax SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intExpenseAccountId' AND object_id = object_id(N'tblPREmployeeTax')) 
EXEC ('UPDATE tblPREmployeeTax SET intExpenseAccountId = NULL WHERE intExpenseAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPRPaycheckDeduction')) 
EXEC ('UPDATE tblPRPaycheckDeduction SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intExpenseAccountId' AND object_id = object_id(N'tblPRPaycheckDeduction')) 
EXEC ('UPDATE tblPRPaycheckDeduction SET intExpenseAccountId = NULL WHERE intExpenseAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPRPaycheckEarning')) 
EXEC ('UPDATE tblPRPaycheckEarning SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPRPaycheckTax')) 
EXEC ('UPDATE tblPRPaycheckTax SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intExpenseAccountId' AND object_id = object_id(N'tblPRPaycheckTax')) 
EXEC ('UPDATE tblPRPaycheckTax SET intExpenseAccountId = NULL WHERE intExpenseAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPRTemplateDeduction')) 
EXEC ('UPDATE tblPRTemplateDeduction SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intExpenseAccountId' AND object_id = object_id(N'tblPRTemplateDeduction')) 
EXEC ('UPDATE tblPRTemplateDeduction SET intExpenseAccountId = NULL WHERE intExpenseAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPRTemplateEarning')) 
EXEC ('UPDATE tblPRTemplateEarning SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPRTemplateEarningDistribution')) 
EXEC ('UPDATE tblPRTemplateEarningDistribution SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPRTemplateTax')) 
EXEC ('UPDATE tblPRTemplateTax SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intExpenseAccountId' AND object_id = object_id(N'tblPRTemplateTax')) 
EXEC ('UPDATE tblPRTemplateTax SET intExpenseAccountId = NULL WHERE intExpenseAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPRTypeDeduction')) 
EXEC ('UPDATE tblPRTypeDeduction SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intExpenseAccountId' AND object_id = object_id(N'tblPRTypeDeduction')) 
EXEC ('UPDATE tblPRTypeDeduction SET intExpenseAccountId = NULL WHERE intExpenseAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPRTypeEarning')) 
EXEC ('UPDATE tblPRTypeEarning SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPRTypeTax')) 
EXEC ('UPDATE tblPRTypeTax SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intExpenseAccountId' AND object_id = object_id(N'tblPRTypeTax')) 
EXEC ('UPDATE tblPRTypeTax SET intExpenseAccountId = NULL WHERE intExpenseAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')

IF EXISTS (SELECT TOP 1 1 FROM sys.columns WHERE name = N'intAccountId' AND object_id = object_id(N'tblPRWorkersCompensation')) 
EXEC ('UPDATE tblPRWorkersCompensation SET intAccountId = NULL WHERE intAccountId NOT IN (SELECT intAccountId FROM tblGLAccount)')