CREATE VIEW vyuRKCompanyPreference
AS
SELECT 
A.* ,
B.strUnitMeasure,
C.strInterfaceSystem,
D.strCurrency
FROM
tblRKCompanyPreference A
LEFT JOIN	tblICUnitMeasure B ON B.intUnitMeasureId = A.intUnitMeasureId
LEFT JOIN tblRKInterfaceSystem C ON C.intInterfaceSystemId = A.intInterfaceSystemId
LEFT JOIN tblSMCurrency D ON D.intCurrencyID = A.intCurrencyId