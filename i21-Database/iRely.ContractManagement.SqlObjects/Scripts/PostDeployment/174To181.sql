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