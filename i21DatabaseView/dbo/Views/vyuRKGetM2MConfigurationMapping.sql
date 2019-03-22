CREATE VIEW vyuRKGetM2MConfigurationMapping
AS
select c.intM2MConfigurationId,i.intItemId,i.strItemNo,b.intContractBasisId,b.strContractBasis, c.intConcurrencyId,strAdjustmentType from tblRKM2MConfiguration c
join tblICItem i on c.intItemId=i.intItemId
join tblCTContractBasis b on b.intContractBasisId=c.intContractBasisId