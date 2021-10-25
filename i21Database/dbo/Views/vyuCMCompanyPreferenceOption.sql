CREATE VIEW vyuCMCompanyPreferenceOption
AS
SELECT A.*,
strBTFromFXGLAccountId =  B.strAccountId,
strBTToFXGLAccountId = C.strAccountId,
strBTForwardAccountId = D.strAccountId,
strBTForwardAccrualAccountId = E.strAccountId,
strBTBankFeesAccountId = F.strAccountId,
strBTInTransitAccountId = G.strAccountId
FROM tblCMCompanyPreferenceOption A
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTFromFXGLAccountId
)B
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTToFXGLAccountId
)C
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTForwardAccountId
)D
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTForwardAccrualAccountId
)E
OUTER APPLY(
    SELECT strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTFeesAccountId
)F
OUTER APPLY(
    SELECT strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTInTransitAccountId
)G
