CREATE VIEW vyuCMCompanyPreferenceOption
AS
SELECT A.*,
strBTForwardFromFXGLAccountId =  B.strAccountId,
strBTForwardToFXGLAccountId = C.strAccountId,
strBTSwapFromFXGLAccountId =  D.strAccountId,
strBTSwapToFXGLAccountId = E.strAccountId,
strBTBankFeesAccountId = F.strAccountId,
strBTInTransitAccountId = G.strAccountId,
strBTForexDiffAccountId = H.strAccountId
FROM tblCMCompanyPreferenceOption A
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTForwardFromFXGLAccountId
)B
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTForwardToFXGLAccountId
)C
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTSwapFromFXGLAccountId
)D
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTSwapToFXGLAccountId
)E
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTBankFeesAccountId
)F
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTInTransitAccountId
)G
OUTER APPLY(
    SELECT TOP 1 strAccountId FROM tblGLAccount WHERE intAccountId = A.intBTForexDiffAccountId
)H
