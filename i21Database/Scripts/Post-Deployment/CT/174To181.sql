PRINT('CT - 174To181 Started')

GO
UPDATE  CH SET CH.intWarehouseId =  CH.intINCOLocationTypeId 
FROM	tblCTContractHeader CH
JOIN	tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
WHERE   strINCOLocationType = 'Warehouse' AND CH.intINCOLocationTypeId IS NOT NULL
GO

GO
UPDATE  CH SET CH.intINCOLocationTypeId =  NULL
FROM	tblCTContractHeader CH
JOIN	tblCTContractBasis CB ON CB.intContractBasisId = CH.intContractBasisId
WHERE	strINCOLocationType = 'Warehouse' AND CH.intINCOLocationTypeId IS NOT NULL
GO

PRINT('CT - 174To181 End')

GO
PRINT('CT-2826')

UPDATE CD
SET CD.strCertifications = STUFF((
SELECT	', ' + IC.strCertificationName 
FROM	tblCTContractCertification	CF
JOIN	tblICCertification			IC	ON	IC.intCertificationId	=	CF.intCertificationId
WHERE	CF.intContractDetailId = x.intContractDetailId
FOR XML PATH(''), TYPE).value('.[1]', 'nvarchar(max)'), 1, 2, '')
FROM tblCTContractCertification AS x
JOIN tblCTContractDetail CD ON CD.intContractDetailId = x.intContractDetailId
WHERE CD.strCertifications IS NULL

PRINT('END CT-2826')
GO