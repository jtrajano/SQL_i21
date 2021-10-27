CREATE VIEW vyuCMCompanyPreferenceOption
AS
SELECT A.*,
strBTFromFXGLAccountId =  B.strAccountId,
strBTToFXGLAccountId = C.strAccountId,
strBTBankFeesAccountId = D.strAccountId,
strBTInTransitAccountId = E.strAccountId
FROM tblCMCompanyPreferenceOption A
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTFromFXGLAccountId
)B
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTToFXGLAccountId
)C
OUTER APPLY(
    SELECT strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTFeesAccountId
)D
OUTER APPLY(
    SELECT strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTInTransitAccountId
)E
