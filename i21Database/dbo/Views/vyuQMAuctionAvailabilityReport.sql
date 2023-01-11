CREATE VIEW [dbo].[vyuQMAuctionAvailabilityReport]
AS
SELECT
    S.strSaleNumber
    ,[strTeaType] = CT.strCatalogueType
    ,I.intItemId
    ,I.strItemNo
    ,EB.intEntityId
    ,[strBrokerName] = EB.strName
    ,[dblQty] = SUM(ISNULL(S.dblRepresentingQty, 0))
FROM tblQMSample S
INNER JOIN vyuEMSearchEntityBroker EB ON EB.intEntityId = S.intBrokerId
INNER JOIN tblQMCatalogueType CT ON CT.intCatalogueTypeId = S.intCatalogueTypeId
INNER JOIN tblICItem I ON I.intItemId = S.intItemId
INNER JOIN tblARMarketZone MZ ON MZ.intMarketZoneId = S.intMarketZoneId
LEFT JOIN tblMFBatch B ON B.intSampleId = S.intSampleId
WHERE B.intBatchId IS NULL
AND (S.strSaleNumber IS NOT NULL AND S.strSaleNumber <> '')
AND MZ.strMarketZoneCode = 'AUC' --Auction only
AND I.strItemNo <>'Catalogue Item'
GROUP BY
    S.strSaleNumber
    ,CT.strCatalogueType
    ,I.intItemId
    ,I.strItemNo
    ,EB.intEntityId
    ,EB.strName

GO

