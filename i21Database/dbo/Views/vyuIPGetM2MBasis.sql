CREATE VIEW vyuIPGetM2MBasis
AS
SELECT 
M.intM2MBasisId
,M.dtmM2MBasisDate
,M.strPricingType
,M.intConcurrencyId
,M.intM2MBasisRefId
FROM tblRKM2MBasis M
