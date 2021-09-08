CREATE PROCEDURE dbo.uspApiSchemaTransformCommodityContract (
      @guiApiUniqueId UNIQUEIDENTIFIER
    , @guiLogId UNIQUEIDENTIFIER
)
AS
-- Validate
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Contract Number'
    , strValue = sc.strContractNumber
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sc.intRowNumber
    , strMessage = 'The contract number ' + ISNULL(sc.strContractNumber, '') + ' already exists.'
FROM tblApiSchemaCommodityContract sc
JOIN tblCTContractHeader h ON h.strContractNumber = sc.strContractNumber
WHERE sc.guiApiUniqueId = @guiApiUniqueId

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT NEWID()
    , guiApiImportLogId = @guiLogId 
    , strField = 'Entity No'
    , strValue = sc.strEntityNo
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sc.intRowNumber
    , strMessage = 'The entity no. or entity name ' + ISNULL(sc.strEntityNo, '') + ' does not exist.'
FROM tblApiSchemaCommodityContract sc
OUTER APPLY (
  SELECT TOP 1 * 
  FROM vyuApiEntity xe
  WHERE (xe.strEntityNo = sc.strEntityNo OR xe.strName = sc.strEntityNo)
    AND xe.strType = CASE sc.strContractType WHEN 'Purchase' THEN 'Vendor' ELSE 'Customer' END
) e
WHERE sc.guiApiUniqueId = @guiApiUniqueId
  AND e.intEntityId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT NEWID()
    , guiApiImportLogId = @guiLogId 
    , strField = 'Commodity'
    , strValue = sc.strCommodity
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sc.intRowNumber
    , strMessage = 'The commodity ' + ISNULL(sc.strCommodity, '') + ' does not exist.'
FROM tblApiSchemaCommodityContract sc
OUTER APPLY (
  SELECT TOP 1 * 
  FROM tblICCommodity xc
  WHERE xc.strCommodityCode = sc.strCommodity OR xc.strDescription = sc.strCommodity
) c
WHERE sc.guiApiUniqueId = @guiApiUniqueId
  AND c.intCommodityId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Location Name'
    , strValue = sc.strLocationName
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sc.intRowNumber
    , strMessage = 'The location ' + ISNULL(sc.strLocationName, '') + ' does not exist.'
FROM tblApiSchemaCommodityContract sc
OUTER APPLY (
  SELECT TOP 1 * 
  FROM tblSMCompanyLocation le 
  WHERE le.strLocationName = sc.strLocationName OR le.strLocationNumber = sc.strLocationName
) l
WHERE sc.guiApiUniqueId = @guiApiUniqueId
    AND l.intCompanyLocationId IS NULL

  
INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Pricing Type'
    , strValue = sc.strPricingType
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sc.intRowNumber
    , strMessage = 'The pricing type ' + ISNULL(sc.strPricingType, '') + ' does not exist.'
FROM tblApiSchemaCommodityContract sc
OUTER APPLY (
  SELECT TOP 1 * 
  FROM tblCTPricingType ptt
  WHERE ptt.strPricingType = sc.strPricingType
    AND ptt.intPricingTypeId != 6
) pt
WHERE sc.guiApiUniqueId = @guiApiUniqueId
    AND pt.intPricingTypeId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Salesperson'
    , strValue = sc.strSalesperson
    , strLogLevel = 'Error'
    , strStatus = 'Failed'
    , intRowNo = sc.intRowNumber
    , strMessage = 'The salesperson ' + ISNULL(sc.strSalesperson, '') + ' does not exist.'
FROM tblApiSchemaCommodityContract sc
OUTER APPLY(
  SELECT TOP 1 *
  FROM vyuApiEntity se 
  WHERE (se.strEntityNo = sc.strSalesperson OR se.strName = sc.strSalesperson)
    AND se.strType = 'Salesperson'
) e
WHERE sc.guiApiUniqueId = @guiApiUniqueId
    AND e.intEntityId IS NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Freight Term'
    , strValue = sc.strFreightTerm
    , strLogLevel = 'Warning'
    , strStatus = 'Ignored'
    , intRowNo = sc.intRowNumber
    , strMessage = 'The freight term ' + ISNULL(sc.strFreightTerm, '') + ' does not exist.'
FROM tblApiSchemaCommodityContract sc
OUTER APPLY(
  SELECT TOP 1 *
  FROM tblSMFreightTerms se 
  WHERE (se.strFreightTerm = sc.strFreightTerm OR se.strDescription = sc.strFreightTerm)
) e
WHERE sc.guiApiUniqueId = @guiApiUniqueId
  AND e.intFreightTermId IS NULL
  AND NULLIF(sc.strFreightTerm, '') IS NOT NULL

INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
SELECT
      NEWID()
    , guiApiImportLogId = @guiLogId
    , strField = 'Term'
    , strValue = sc.strPaymentTerms
    , strLogLevel = 'Warning'
    , strStatus = 'Ignored'
    , intRowNo = sc.intRowNumber
    , strMessage = 'The payment term ' + ISNULL(sc.strPaymentTerms, '') + ' does not exist.'
FROM tblApiSchemaCommodityContract sc
OUTER APPLY(
  SELECT TOP 1 *
  FROM tblSMTerm se 
  WHERE (se.strTermCode = sc.strPaymentTerms OR se.strTerm = sc.strPaymentTerms)
) e
WHERE sc.guiApiUniqueId = @guiApiUniqueId
  AND e.intTermID IS NULL
  AND NULLIF(sc.strPaymentTerms, '') IS NOT NULL

-- Transform

/*
   Commodity contract is a master-detail type of record so we need to group the header fields. 
   These fields will be used as the key to reference the details to the correct contract header.
*/
DECLARE @inti21UserId INT = 1
DECLARE @dtmNullDate DATETIME = NULL --@dtmNullDate
-- Insert contract headers
INSERT INTO tblCTContractHeader (
      guiApiUniqueId
    , intContractTypeId
    , strContractNumber
    , dtmContractDate
    , dblQuantity
    , intEntityId
    , intSalespersonId
    , intCommodityId
    , intCommodityUOMId
    , intPricingTypeId
    , intTermId
    , intFreightTermId
    , dtmCreated
    , intConcurrencyId
    , ysnSigned
    , ysnPrinted)
SELECT DISTINCT
    @guiApiUniqueId
  , CASE sc.strContractType WHEN 'Purchase' THEN 1 ELSE 2 END
  , sc.strContractNumber
  , sc.dtmContractDate
  , 0
  , e.intEntityId
  , sp.intEntityId
  , c.intCommodityId
  , cu.intCommodityUnitMeasureId
  , pt.intPricingTypeId
  , tr.intTermID
  , ft.intFreightTermId
  , GETUTCDATE()
  , 1
  , 0
  , 0
FROM tblApiSchemaCommodityContract sc
CROSS APPLY (
  SELECT TOP 1 *
  FROM vyuApiEntity xe 
  WHERE xe.strName = sc.strEntityNo 
    AND xe.strType = CASE sc.strContractType WHEN 'Purchase' THEN 'Vendor' ELSE 'Customer' END
) e
LEFT JOIN tblSMFreightTerms ft ON ft.strFreightTerm = sc.strFreightTerm
OUTER APPLY(
  SELECT TOP 1 *
  FROM tblSMTerm se 
  WHERE (se.strTermCode = sc.strPaymentTerms OR se.strTerm = sc.strPaymentTerms)
) tr
CROSS APPLY (
  SELECT TOP 1 *
  FROM vyuApiEntity spe 
  WHERE spe.strName = sc.strSalesperson AND spe.strType = 'Salesperson'
) sp
JOIN tblICCommodity c ON c.strCommodityCode = sc.strCommodity
JOIN tblCTPricingType pt ON pt.strPricingType = sc.strPricingType
  AND pt.intPricingTypeId != 6
CROSS APPLY (
  SELECT TOP 1 intCommodityUnitMeasureId
  FROM tblICCommodityUnitMeasure CU
  JOIN tblICUnitMeasure UM ON UM.intUnitMeasureId = CU.intUnitMeasureId
  WHERE intCommodityId = c.intCommodityId
  AND CU.ysnDefault = 1
) cu
WHERE sc.guiApiUniqueId = @guiApiUniqueId
  AND NOT EXISTS(SELECT 1 FROM tblCTContractHeader h WHERE h.strContractNumber = sc.strContractNumber)
GROUP BY 
    sc.strContractNumber
  , sc.strContractType
  , sc.dtmContractDate
  , sc.strCommodity
  , sc.strPricingType
  , pt.intPricingTypeId
  , sc.strSalesperson
  , ISNULL(sc.intPosition, 0)
  , ISNULL(sc.intCropYear, 0)
  , sc.strEntityNo
  , e.intEntityId
  , sp.intEntityId
  , c.intCommodityId
  , cu.intCommodityUnitMeasureId
  , tr.intTermID
  , ft.intFreightTermId

 -- Validate details
  INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
  SELECT
        NEWID()
      , guiApiImportLogId = @guiLogId
      , strField = 'Item No'
      , strValue = sc.strItem
      , strLogLevel = 'Error'
      , strStatus = 'Failed'
      , intRowNo = sc.intRowNumber
      , strMessage = 'The item with an Item No. ' + ISNULL(sc.strItem, '') + ' does not exist.'
  FROM tblApiSchemaCommodityContract sc
  LEFT JOIN tblICItem i ON i.strItemNo = sc.strItem
  CROSS APPLY (
    SELECT TOP 1 intCompanyLocationId
    FROM tblSMCompanyLocation
    WHERE strLocationName = sc.strLocationName OR strLocationNumber = sc.strLocationName
  ) l
  LEFT JOIN vyuCTInventoryItemBundle ib ON ib.intItemId = i.intItemId
    AND ib.intCommodityId = i.intCommodityId
    AND ib.intBundleId IS NULL
    AND ib.intLocationId = l.intCompanyLocationId
  WHERE sc.guiApiUniqueId = @guiApiUniqueId
    AND ib.intItemId IS NULL

  INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strAction, strStatus, intRowNo, strMessage)
  SELECT
        NEWID()
      , guiApiImportLogId = @guiLogId
      , strField = 'Item No'
      , strValue = sc.strItem
      , strLogLevel = 'Error'
      , strAction = 'Skipped'
      , strStatus = 'Failed'
      , intRowNo = sc.intRowNumber
      , strMessage = 'The item with an Item No. ' + ISNULL(sc.strItem, '') + ' has been discontinued.'
  FROM tblApiSchemaCommodityContract sc
  LEFT JOIN tblICItem i ON i.strItemNo = sc.strItem
  CROSS APPLY (
    SELECT TOP 1 intCompanyLocationId
    FROM tblSMCompanyLocation
    WHERE strLocationName = sc.strLocationName OR strLocationNumber = sc.strLocationName
  ) l
  LEFT JOIN vyuCTInventoryItemBundle ib ON ib.intItemId = i.intItemId
    AND ib.intCommodityId = i.intCommodityId
    AND ib.intBundleId IS NULL
    AND ib.intLocationId = l.intCompanyLocationId
  WHERE sc.guiApiUniqueId = @guiApiUniqueId
    AND ib.strStatus = 'Discontinued'

  -- INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
  -- SELECT
  --       NEWID()
  --     , guiApiImportLogId = @guiLogId
  --     , strField = 'Start Date'
  --     , strValue = sc.dtmStartDate
  --     , strLogLevel = 'Error'
  --     , strStatus = 'Failed'
  --     , intRowNo = sc.intRowNumber
  --     , strMessage = 'The Start Date for contract sequence ' + CAST(sc.intSequence AS NVARCHAR(50)) + ' was not specified.'
  -- FROM tblApiSchemaCommodityContract sc
  -- WHERE sc.guiApiUniqueId = @guiApiUniqueId
  --   AND sc.dtmStartDate IS NULL

  INSERT INTO tblApiImportLogDetail (guiApiImportLogDetailId, guiApiImportLogId, strField, strValue, strLogLevel, strStatus, intRowNo, strMessage)
  SELECT
        NEWID()
      , guiApiImportLogId = @guiLogId
      , strField = 'Quantity UOM'
      , strValue = sc.strQuantityUOM
      , strLogLevel = 'Error'
      , strStatus = 'Failed'
      , intRowNo = sc.intRowNumber
      , strMessage = 'Cannot find the item UOM ' + ISNULL(sc.strQuantityUOM, '') + '.'
  FROM tblApiSchemaCommodityContract sc
  JOIN tblICItem i ON i.strItemNo = sc.strItem
  OUTER APPLY (
    SELECT uum.intItemUOMId, um.intUnitMeasureId
    FROM tblICUnitMeasure um
    JOIN tblICItemUOM uum ON uum.intUnitMeasureId = um.intUnitMeasureId
      AND uum.intItemId = i.intItemId
    WHERE um.strUnitMeasure = sc.strQuantityUOM
  ) iu
  WHERE sc.guiApiUniqueId = @guiApiUniqueId
    AND iu.intItemUOMId IS NULL

-- Insert contract details
DECLARE @intContractHeaderId INT
DECLARE @strContractNumber NVARCHAR(100)
DECLARE @intContractTypeId INT
DECLARE @dtmContractDate DATETIME
DECLARE @intCommodityId INT
DECLARE @intSalespersonId INT
DECLARE @intPositionId INT
DECLARE @intCropYearId INT
DECLARE @intEntityId INT
DECLARE @strCommodityCode NVARCHAR(100)
DECLARE @strCommodityName NVARCHAR(100)
DECLARE @strEntityNo NVARCHAR(100)
DECLARE @strEntityName NVARCHAR(100)
DECLARE @strSalespersonNo NVARCHAR(100)
DECLARE @strSalespersonName NVARCHAR(100)
DECLARE @intPricingtypeId INT
DECLARE @intTermId INT
DECLARE @intFreightTermId INT

DECLARE cur CURSOR LOCAL FAST_FORWARD
FOR
SELECT 
    h.intContractHeaderId
  , h.strContractNumber
  , h.intContractTypeId
  , h.dtmContractDate
  , h.intCommodityId
  , h.intSalespersonId
  , ISNULL(h.intPositionId, 0) intPositionId
  , ISNULL(h.intCropYearId, 0) intCropYearId
  , ISNULL(h.intTermId, 0) intTermId
  , ISNULL(h.intFreightTermId, 0) intFreightTermId
  , h.intEntityId
  , c.strCommodityCode
  , c.strDescription
  , xe.strEntityNo
  , xe.strName
  , spe.strEntityNo
  , spe.strName
  , h.intPricingTypeId
FROM tblCTContractHeader h
JOIN tblICCommodity c ON c.intCommodityId = h.intCommodityId
JOIN vyuApiEntity xe ON xe.intEntityId = h.intEntityId
  AND xe.strType = CASE h.intContractTypeId WHEN 1 THEN 'Vendor' ELSE 'Customer' END
JOIN vyuApiEntity spe ON spe.intEntityId = h.intSalespersonId AND spe.strType = 'Salesperson'
WHERE h.guiApiUniqueId = @guiApiUniqueId
GROUP BY 
    h.strContractNumber
  , h.intContractTypeId
  , h.dtmContractDate
  , h.intCommodityId
  , h.intSalespersonId
  , h.intPricingTypeId
  , ISNULL(h.intPositionId, 0)
  , ISNULL(h.intCropYearId, 0)
  , ISNULL(h.intTermId, 0)
  , ISNULL(h.intFreightTermId, 0)
  , h.intEntityId
  , h.intContractHeaderId
  , c.strCommodityCode
  , c.strDescription
  , xe.strEntityNo
  , xe.strName
  , spe.strEntityNo
  , spe.strName

OPEN cur

FETCH NEXT FROM cur INTO
    @intContractHeaderId
  , @strContractNumber
  , @intContractTypeId
  , @dtmContractDate
  , @intCommodityId
  , @intSalespersonId
  , @intPositionId
  , @intCropYearId
  , @intTermId
  , @intFreightTermId
  , @intEntityId
  , @strCommodityCode
  , @strCommodityName
  , @strEntityNo
  , @strEntityName
  , @strSalespersonNo
  , @strSalespersonName
  , @intPricingtypeId

WHILE @@FETCH_STATUS = 0
BEGIN
  INSERT INTO tblCTContractDetail (
      intContractHeaderId
    , intConcurrencyId
    , intItemId
    , intCompanyLocationId
    , intContractSeq
    , intContractStatusId
    , dblQuantity
    , dblBalance
    , dblFutures
    , dblCashPrice
    , dblTotalCost
    , intFutureMarketId
    , intItemUOMId
    , intPriceItemUOMId
    , intCurrencyId
    , dtmStartDate
    , dtmEndDate
    , dtmM2MDate
    , strRemark
    , intPricingTypeId
    , dtmCreated
    , intUnitMeasureId
  )
  SELECT 
      intContractHeaderId = @intContractHeaderId
    , intConcurrencyId = 1
    , intItemId = i.intItemId
    , intCompanyLocationId = l.intCompanyLocationId
    , intContractSeq = sc.intSequence
    , intContractStatusId = ISNULL(st.intContractStatusId, 1)
    , dblQuantity = ISNULL(sc.dblQuantity, 0)
    , dblBalance = (ISNULL(sc.dblQuantity, 0))
    , dblFutures = (ISNULL(sc.dblFutures, 0))
    , dblCashPrice = (ISNULL(sc.dblCashPrice, 0))
    , dblTotalCost = (ISNULL(sc.dblCashPrice, 0) * ISNULL(sc.dblQuantity, 0))
    , intFutureMarketId = fm.intFutureMarketId
    , intItemUOMId = iu.intItemUOMId
    , intPriceItemUOMId = pu.intItemUOMId
    , intCurrencyId = c.intCurrencyID
    , dtmStartDate = ISNULL(sc.dtmStartDate, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))
    , dtmEndDate = ISNULL(sc.dtmEndDate, DATEADD(DAY, 30, ISNULL(sc.dtmStartDate, DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE()), 0))))
    , dtmM2MDate = sc.dtmM2MDate
    , strRemark = sc.strRemark
    -- , intPricingTypeId = CASE WHEN fm.intFutureMarketId IS NOT NULL AND sc.dblCashPrice IS NOT NULL THEN 1
    --     WHEN fm.intFutureMarketId IS NOT NULL AND sc.dblCashPrice IS NULL AND sc.dblFutures IS NOT NULL THEN 3
    --     WHEN fm.intFutureMarketId IS NOT NULL AND sc.dblCashPrice IS NULL AND sc.dblBasis IS NOT NULL THEN 2
    --     WHEN fm.intFutureMarketId IS NULL AND sc.dblCashPrice IS NOT NULL THEN 6
    --     ELSE 4 END
    , intPricingTypeId = h.intPricingTypeId
    , GETUTCDATE()
    , iu.intUnitMeasureId
  FROM tblApiSchemaCommodityContract sc
    JOIN tblCTContractHeader h ON h.intContractHeaderId = @intContractHeaderId
    JOIN tblICItem i ON i.strItemNo = sc.strItem
    JOIN tblICCommodity co ON co.intCommodityId = @intCommodityId
    LEFT JOIN tblCTPricingType pt ON pt.strPricingType = sc.strPricingType
      AND pt.intPricingTypeId != 6
    LEFT JOIN tblSMCurrency c ON c.strCurrency = sc.strCurrency
    CROSS APPLY (
      SELECT TOP 1 intCompanyLocationId
      FROM tblSMCompanyLocation
      WHERE strLocationName = sc.strLocationName OR strLocationNumber = sc.strLocationName
    ) l
    JOIN vyuCTInventoryItemBundle ib ON ib.intItemId = i.intItemId
      AND ib.intCommodityId = i.intCommodityId
      AND ib.intBundleId IS NULL
      AND ib.intLocationId = l.intCompanyLocationId
      AND ib.strStatus != 'Discontinued'
    OUTER APPLY (
      SELECT uum.intItemUOMId, um.intUnitMeasureId
      FROM tblICUnitMeasure um
      JOIN tblICItemUOM uum ON uum.intUnitMeasureId = um.intUnitMeasureId
        AND uum.intItemId = i.intItemId
      WHERE um.strUnitMeasure = sc.strQuantityUOM
    ) iu
    OUTER APPLY (
      SELECT puum.intItemUOMId
      FROM tblICUnitMeasure pum
      JOIN tblICItemUOM puum ON puum.intUnitMeasureId = pum.intUnitMeasureId
        AND puum.intItemId = i.intItemId
      WHERE pum.strUnitMeasure = sc.strPriceUOM
    ) pu
    OUTER APPLY (
      SELECT TOP 1 * 
      FROM tblRKFutureMarket 
      WHERE strFutMarketName = sc.strMarketName
    ) fm
    JOIN vyuApiEntity e ON e.intEntityId = @intEntityId
      AND e.strType = CASE @intContractTypeId WHEN 1 THEN 'Vendor' ELSE 'Customer' END
    JOIN vyuApiEntity sp ON sp.intEntityId = @intSalespersonId
      AND sp.strType = 'Salesperson'
    LEFT JOIN tblCTContractStatus st ON st.strContractStatus = sc.strContractStatus
    JOIN tblICCommodityUnitMeasure cu ON cu.intCommodityId = co.intCommodityId
      AND cu.intUnitMeasureId = iu.intUnitMeasureId
  WHERE sc.guiApiUniqueId = @guiApiUniqueId
    AND sc.strContractNumber = @strContractNumber
  GROUP BY
      h.strContractNumber
    , h.intCommodityId
    , h.intEntityId
    , h.intSalespersonId
    , h.dtmContractDate
    , h.intContractTypeId
    , h.intPricingTypeId
    , ISNULL(h.intPositionId, 0)
    , ISNULL(h.intCropYearId, 0)
    , ISNULL(h.intTermId, 0)
    , ISNULL(h.intFreightTermId, 0)
    , i.intItemId
    , l.intCompanyLocationId
    , sc.intSequence
    , iu.intItemUOMId
    , iu.intUnitMeasureId
    , pu.intItemUOMId
    , c.intCurrencyID
    , sc.dtmStartDate
    , sc.dtmEndDate
    , sc.dtmM2MDate
    , sc.strRemark
    , st.intContractStatusId
    , fm.intFutureMarketId
    , cu.intUnitMeasureId
    , sc.dblQuantity
    , sc.dblFutures
    , sc.dblCashPrice
    , sc.dblBasis

  UPDATE tblCTContractHeader
  SET dblQuantity = (SELECT ISNULL(SUM(ISNULL(dblQuantity, 0)), 0) FROM tblCTContractDetail WHERE intContractHeaderId = @intContractHeaderId)
  WHERE intContractHeaderId = @intContractHeaderId

  EXEC uspCTCreateDetailHistory	@intContractHeaderId = @intContractHeaderId, 
    @intContractDetailId = NULL,
    @strSource = 'Contract',
    @strProcess = 'Create Contract',
    @intUserId = @inti21UserId

  FETCH NEXT FROM cur INTO
      @intContractHeaderId
    , @strContractNumber
    , @intContractTypeId
    , @dtmContractDate
    , @intCommodityId
    , @intSalespersonId
    , @intPositionId
    , @intCropYearId
    , @intTermId
    , @intFreightTermId
    , @intEntityId
    , @strCommodityCode
    , @strCommodityName
    , @strEntityNo
    , @strEntityName
    , @strSalespersonNo
    , @strSalespersonName
    , @intPricingtypeId
END

CLOSE cur
DEALLOCATE cur

-- Finalize
DECLARE @TotalImported INT = (SELECT COUNT(*) FROM tblCTContractHeader WHERE guiApiUniqueId = @guiApiUniqueId) 

UPDATE i
SET
    i.intTotalRowsImported = @TotalImported
  , i.strResult = CASE @TotalImported WHEN 0 THEN 'Failed' ELSE 'Success' END
  , i.strMessage = CASE @TotalImported WHEN 0 THEN 'There were no records imported.' ELSE NULL END
FROM tblApiImportLog i
WHERE i.guiApiImportLogId = @guiLogId

