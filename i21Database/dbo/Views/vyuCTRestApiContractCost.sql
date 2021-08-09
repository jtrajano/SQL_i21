CREATE VIEW [dbo].[vyuCTRestApiContractCost] 
AS
SELECT i.strItemNo, u.strUnitMeasure, c.strCurrency, er.strCurrencyExchangeRateType, v.strEntityNo, v.strName strEntityName, cc.*
FROM tblCTContractCost cc
LEFT JOIN tblICItem i ON i.intItemId = cc.intItemId
LEFT JOIN tblICItemUOM m ON m.intItemUOMId = cc.intItemUOMId
LEFT JOIN tblICUnitMeasure u ON u.intUnitMeasureId = m.intUnitMeasureId
LEFT JOIN tblSMCurrency c ON c.intCurrencyID = cc.intCurrencyId
LEFT JOIN tblSMCurrencyExchangeRateType er ON cc.intRateTypeId = er.intCurrencyExchangeRateTypeId
LEFT JOIN tblEMEntity v ON v.intEntityId = cc.intVendorId