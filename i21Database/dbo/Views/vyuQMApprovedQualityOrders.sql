CREATE VIEW [dbo].[vyuQMApprovedQualityOrders]
AS
SELECT
    -- Batch fields
    B.intBatchId
    ,B.strBatchId
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
    ,I.strItemNo
    ,I.strDescription
    ,[dblQty] = S.dblRepresentingQty
    ,[strQtyUnitMeasure] = QUM.strSymbol
    ,S.dblGrossWeight
    ,S.dblTareWeight
    ,S.dblNetWeight
    ,[strWeightUnitMeasure] = WUM.strSymbol

    -- Contract fields for non-auction
    ,CH.intContractHeaderId
    ,CD.intContractDetailId
    ,CH.strContractNumber
    ,CD.intContractSeq
    ,[strVendorLocation] = VL.strLocationName
    ,[strVendorRef] = CH.strCustomerContract
    ,[strPricingStatus] =   CASE intPricingStatus
                                WHEN 0 THEN 'Unpriced'
                                WHEN 1 THEN 'Partially Priced'
                                WHEN 2 THEN 'Fully Priced'
                            END COLLATE Latin1_General_CI_AS
    ,CD.dblCashPrice
    ,CD.intCurrencyId
    ,CUR.strCurrency
    ,CD.intPriceItemUOMId
    ,[strPriceUnitMeasure] = PUOM.strSymbol
    ,CD.dblTotalCost
    ,[strForexRateType] = RT.strCurrencyExchangeRateType
    ,CD.dblRate
    ,[dblFXAmount] = CD.dblRate * CD.dblTotalCost
    ,[strFXCurrency] = FC.strCurrency
FROM tblMFBatch B
INNER JOIN tblQMSample S ON S.intSampleId = B.intSampleId -- Auction or Non-Auction Sample
LEFT JOIN vyuEMSearchEntityBroker EB ON EB.intEntityId = B.intBrokerId
LEFT JOIN tblQMGardenMark GM ON GM.intGardenMarkId = B.intGardenMarkId
LEFT JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = S.intLocationId
LEFT JOIN tblICStorageLocation SL ON SL.intStorageLocationId = S.intStorageLocationId
LEFT JOIN tblICItem I ON I.intItemId = S.intItemId
LEFT JOIN tblICUnitMeasure QUM ON QUM.intUnitMeasureId = S.intRepresentingUOMId
LEFT JOIN tblICUnitMeasure WUM ON WUM.intUnitMeasureId = S.intSampleUOMId
-- Contract side tables
LEFT JOIN tblCTContractDetail CD ON CD.intContractDetailId = S.intContractDetailId
LEFT JOIN tblCTContractHeader CH ON CH.intContractHeaderId = CD.intContractHeaderId
LEFT JOIN tblEMEntity V ON V.intEntityId = CH.intEntityId
LEFT JOIN tblEMEntityLocation VL ON VL.intEntityId = V.intEntityId AND VL.intEntityLocationId= CH.intEntitySelectedLocationId
LEFT JOIN tblSMCurrency CUR ON CUR.intCurrencyID = CD.intCurrencyId
LEFT JOIN tblICItemUOM PIUOM ON PIUOM.intItemUOMId = CD.intPriceItemUOMId
LEFT JOIN tblICUnitMeasure PUOM ON PUOM.intUnitMeasureId = PIUOM.intUnitMeasureId
LEFT JOIN tblSMCurrencyExchangeRateType RT ON RT.intCurrencyExchangeRateTypeId = CD.intRateTypeId
LEFT JOIN tblSMCurrency FC ON FC.intCurrencyID = CD.intInvoiceCurrencyId AND CD.ysnUseFXPrice = 1

GO

