CREATE VIEW [dbo].[vyuQMApprovedQualityOrders]
AS
SELECT 
    -- Batch fields
    B.intBatchId
    ,B.strBatchId
    ,B.intSalesYear
    ,B.intSales
    ,CT.strCatalogueType
    ,B.strTeaGardenChopInvoiceNumber
    ,B.strVendorLotNumber
    ,B.intBrokerId
    ,[strBroker] = EB.strName
    ,B.strLeafGrade
    ,B.intGardenMarkId
    ,GM.strGardenMark
    ,B.strSustainability
    ,B.ysnTeaOrganic
    -- Sample fields
    ,CL.intCompanyLocationId
    ,CL.strLocationName
    ,SL.intStorageLocationId
    ,[strStorageLocation] = SL.strName
    ,I.intItemId
    ,I.intCommodityId
    ,I.strItemNo
    ,I.strDescription
    ,[dblQty] = B.dblTotalQuantity
    ,[intQtyItemUOMId] = QIUOM.intItemUOMId
    ,[intQtyUnitMeasureId] = QUM.intUnitMeasureId
    ,[strQtyUnitMeasure] = QUM.strSymbol
    ,[dblGrossWeight] = WQTY.dblWeight
    ,[dblTareWeight] = CAST(0 AS DECIMAL(18, 6))
    ,[dblNetWeight] = WQTY.dblWeight
    ,[intWeightItemUOMId] = WIUOM.intItemUOMId
    ,[strWeightUnitMeasure] = WUM.strSymbol
    ,[dblWeightPerUnit] = ISNULL(dbo.fnLGGetItemUnitConversion(I.intItemId, QIUOM.intItemUOMId, WUM.intUnitMeasureId), 0)
    ,[strManufacturingLeafType] = LEAF_TYPE.strDescription

    ,CH.intContractHeaderId
    ,CD.intContractDetailId
    ,CH.strContractNumber
    ,CD.intContractSeq
    ,[intVendorEntityId] = CASE WHEN CD.intContractDetailId IS NULL THEN SV.intEntityId ELSE V.intEntityId END
    ,[strVendorName] = CASE WHEN CD.intContractDetailId IS NULL THEN SV.strEntityName ELSE V.strEntityName END
    ,[intVendorLocationId] = CASE WHEN CD.intContractDetailId IS NULL THEN SV.intDefaultLocationId ELSE V.intDefaultLocationId END
    ,[strVendorLocation] = CASE WHEN CD.intContractDetailId IS NULL THEN SV.strDefaultLocation ELSE V.strDefaultLocation END
    ,[strEntityContract] = CH.strCustomerContract
    ,[strVendorRef] = CASE WHEN CD.intContractDetailId IS NULL THEN S.strAdditionalSupplierReference ELSE CH.strCustomerContract END
    ,[strPricingStatus] =   CASE
                                WHEN CD.intContractDetailId IS NULL THEN 'Fully Priced'
                                WHEN CD.intPricingStatus = 0 THEN 'Unpriced'
                                WHEN CD.intPricingStatus = 1 THEN 'Partially Priced'
                                WHEN CD.intPricingStatus = 2 THEN 'Fully Priced'
                            END COLLATE Latin1_General_CI_AS
    ,[dblCashPrice] = CASE WHEN CD.intContractDetailId IS NULL THEN S.dblB1Price ELSE CD.dblCashPrice END
    ,[intCurrencyId] = CASE WHEN CD.intContractDetailId IS NULL THEN DFC.intDefaultCurrencyId ELSE CD.intCurrencyId END
    ,[strCurrency] = CASE WHEN CD.intContractDetailId IS NULL THEN DFC.strDefaultCurrency ELSE CUR.strCurrency END
    ,[intPriceItemUOMId] = CASE WHEN CD.intContractDetailId IS NULL THEN SPIUOM.intItemUOMId ELSE CD.intPriceItemUOMId END
    ,[strPriceUnitMeasure] = CASE WHEN CD.intContractDetailId IS NULL THEN SPUOM.strUnitMeasure ELSE PUOM.strUnitMeasure END
    ,CD.dblTotalCost
    ,[intForexRateTypeId] = RT.intCurrencyExchangeRateTypeId
    ,[strForexRateType] = RT.strCurrencyExchangeRateType
    ,[dblRate] = CASE WHEN CD.intContractDetailId IS NULL THEN 1 ELSE CD.dblRate END
    ,[dblFXAmount] = CD.dblRate * CD.dblTotalCost
    ,[intFXCurrencyId] = FC.intCurrencyID
    ,[strFXCurrency] = FC.strCurrency
    ,MZ.intMarketZoneId
    ,MZ.strMarketZoneCode
FROM tblMFBatch B
INNER JOIN tblQMSample S ON S.intSampleId = B.intSampleId -- Auction or Non-Auction Sample
LEFT JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
LEFT JOIN tblARMarketZone MZ ON MZ.intMarketZoneId = B.intMarketZoneId
LEFT JOIN vyuEMSearchEntityBroker EB ON EB.intEntityId = B.intBrokerId
LEFT JOIN tblQMGardenMark GM ON GM.intGardenMarkId = B.intGardenMarkId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = B.intLocationId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = S.intDestinationStorageLocationId
LEFT JOIN tblICItem I ON I.intItemId = B.intTealingoItemId
LEFT JOIN tblICCommodityAttribute LEAF_TYPE ON LEAF_TYPE.intCommodityAttributeId = S.intManufacturingLeafTypeId
-- Qty UOM Auction
LEFT JOIN tblICItemUOM QIUOM ON QIUOM.intUnitMeasureId = B.intItemUOMId AND QIUOM.intItemId = I.intItemId
LEFT JOIN tblICUnitMeasure QUM ON QUM.intUnitMeasureId = QIUOM.intUnitMeasureId
-- Weight UOM
LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = B.intWeightUOMId
LEFT JOIN tblICItemUOM WIUOM ON WIUOM.intUnitMeasureId = WUM.intUnitMeasureId AND WIUOM.intItemId = I.intItemId
--LEFT JOIN vyuQMGetSupplier SV ON SV.intEntityId = S.intEntityId
LEFT JOIN tblICItemUOM SPIUOM ON SPIUOM.intItemId = I.intItemId AND SPIUOM.intUnitMeasureId = S.intB1PriceUOMId
LEFT JOIN tblICUnitMeasure SPUOM ON SPUOM.intUnitMeasureId = SPIUOM.intUnitMeasureId
-- Contract side tables
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = S.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
--LEFT JOIN vyuQMGetSupplier V ON V.intEntityId = CH.intEntityId
LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = CD.intCurrencyId
LEFT JOIN tblICItemUOM PIUOM ON PIUOM.intItemUOMId = CD.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure PUOM ON PUOM.intUnitMeasureId = PIUOM.intUnitMeasureId
LEFT JOIN tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = CD.intRateTypeId
LEFT JOIN tblSMCurrency FC ON FC.intCurrencyID = CD.intInvoiceCurrencyId AND CD.ysnUseFXPrice = 1
OUTER APPLY (
    SELECT TOP 1
        CP.intDefaultCurrencyId
        ,[strDefaultCurrency] = C.strCurrency
    FROM tblSMCompanyPreference CP
    INNER JOIN tblSMCurrency C ON C.intCurrencyID = CP.intDefaultCurrencyId
) DFC
OUTER APPLY (
    SELECT [dblWeight] = dbo.fnCalculateQtyBetweenUOM(QIUOM.intItemUOMId, WIUOM.intItemUOMId, B.dblTotalQuantity)
) WQTY
OUTER Apply (Select Top 1 V1.intEntityId,V1.strEntityName,V1.intDefaultLocationId,V1.strDefaultLocation  from vyuQMGetSupplier V1 Where V1.intEntityId = CH.intEntityId) V
OUTER Apply (Select Top 1 SV1.intEntityId,SV1.strEntityName,SV1.intDefaultLocationId,SV1.strDefaultLocation  from vyuQMGetSupplier SV1 Where SV1.intEntityId = S.intEntityId) SV
LEFT JOIN (tblLGLoadDetail LD INNER JOIN tblLGLoad L ON L.intLoadId = LD.intLoadId AND ISNULL(L.ysnCancelled, 0) = 0)
    ON LD.intBatchId = B.intBatchId

WHERE LD.intLoadDetailId IS NULL

GO

