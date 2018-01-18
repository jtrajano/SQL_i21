﻿CREATE VIEW vyuRKCompanyPreference
AS
SELECT 
 A.* ,
 B.strUnitMeasure,
 C.strInterfaceSystem,
 D.strCurrency
,GL1.strAccountId strUnrealizedGainOnBasisId
,GL2.strAccountId strUnrealizedGainOnFuturesId
,GL3.strAccountId strUnrealizedGainOnCashId
,GL4.strAccountId strUnrealizedLossOnBasisId
,GL5.strAccountId strUnrealizedLossOnFuturesId
,GL6.strAccountId strUnrealizedLossOnCashId
,GL7.strAccountId strUnrealizedGainOnInventoryBasisIOSId
,GL8.strAccountId strUnrealizedGainOnInventoryFuturesIOSId
,GL9.strAccountId strUnrealizedGainOnInventoryCashIOSId
,GL10.strAccountId strUnrealizedLossOnInventoryBasisIOSId
,GL11.strAccountId strUnrealizedLossOnInventoryFuturesIOSId
,GL12.strAccountId strUnrealizedLossOnInventoryCashIOSId
,GL13.strAccountId strUnrealizedGainOnInventoryIntransitIOSId
,GL14.strAccountId strUnrealizedLossOnInventoryIntransitIOSId
FROM
tblRKCompanyPreference A
LEFT JOIN	tblICUnitMeasure B ON B.intUnitMeasureId = A.intUnitMeasureId
LEFT JOIN tblRKInterfaceSystem C ON C.intInterfaceSystemId = A.intInterfaceSystemId
LEFT JOIN tblSMCurrency D ON D.intCurrencyID = A.intCurrencyId
LEFT JOIN tblGLAccount GL1 ON GL1.intAccountId = A.intUnrealizedGainOnBasisId
LEFT JOIN tblGLAccount GL2 ON GL2.intAccountId = A.intUnrealizedGainOnFuturesId
LEFT JOIN tblGLAccount GL3 ON GL3.intAccountId = A.intUnrealizedGainOnCashId
LEFT JOIN tblGLAccount GL4 ON GL4.intAccountId = A.intUnrealizedLossOnBasisId
LEFT JOIN tblGLAccount GL5 ON GL5.intAccountId = A.intUnrealizedLossOnFuturesId
LEFT JOIN tblGLAccount GL6 ON GL6.intAccountId = A.intUnrealizedLossOnCashId
LEFT JOIN tblGLAccount GL7 ON GL7.intAccountId = A.intUnrealizedGainOnInventoryBasisIOSId
LEFT JOIN tblGLAccount GL8 ON GL8.intAccountId = A.intUnrealizedGainOnInventoryFuturesIOSId
LEFT JOIN tblGLAccount GL9 ON GL9.intAccountId = A.intUnrealizedGainOnInventoryCashIOSId
LEFT JOIN tblGLAccount GL10 ON GL10.intAccountId = A.intUnrealizedLossOnInventoryBasisIOSId
LEFT JOIN tblGLAccount GL11 ON GL11.intAccountId = A.intUnrealizedLossOnInventoryFuturesIOSId
LEFT JOIN tblGLAccount GL12 ON GL12.intAccountId = A.intUnrealizedLossOnInventoryCashIOSId
LEFT JOIN tblGLAccount GL13 ON GL13.intAccountId = A.intUnrealizedGainOnInventoryIntransitIOSId
LEFT JOIN tblGLAccount GL14 ON GL14.intAccountId = A.intUnrealizedLossOnInventoryIntransitIOSId
