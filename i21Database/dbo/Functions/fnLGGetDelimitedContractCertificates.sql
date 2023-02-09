CREATE FUNCTION [dbo].[fnLGGetDelimitedContractCertificates](
    @intContractDetailId INT
)
RETURNS TABLE AS RETURN

SELECT strCertificates = STUFF((
    SELECT ',' + C.strCertificationName
    FROM tblCTContractCertification CC
    INNER JOIN tblICCertification C ON C.intCertificationId = CC.intCertificationId
    WHERE CC.intContractDetailId = @intContractDetailId
    AND C.strCertificationName IS NOT NULL
    FOR XML PATH('')
), 1, 1, '')

GO