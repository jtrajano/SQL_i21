CREATE VIEW vyuRKGetOtherChargeItemNotMapping
AS
select c.intM2MConfigurationId,c.intContractBasisId,c.intItemId,strItemNo,strContractBasis,0 as intConcurrencyId from tblRKM2MConfiguration  c
JOIN tblICItem i on i.intItemId=c.intItemId
JOIN tblCTContractBasis ct on ct.intContractBasisId=c.intContractBasisId


