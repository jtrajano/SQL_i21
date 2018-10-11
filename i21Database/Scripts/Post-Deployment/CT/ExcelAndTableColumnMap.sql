﻿GO
TRUNCATE TABLE tblCTExcelAndTableColumnMap
GO

INSERT INTO tblCTExcelAndTableColumnMap(strTableName,strExcelColumnName,strTableCoulmnName,strRefTable,strRefTableIdCol,strRefCoulumnToCmpr,strJoinType, strSpecialJoin)
SELECT 'tblCTContractHeader', 'Type' AS strExcelColumnName, 'intContractTypeId'AS strTableCoulmnName, 'tblCTContractType'AS strRefTable, 'intContractTypeId'AS strRefTableIdCol, 'strContractType'AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Entity' AS strExcelColumnName, 'intEntityId'AS strTableCoulmnName, 'tblEMEntity'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName'AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, 
'LEFT JOIN tblEMEntity Entity ON EX.[Entity] = Entity.[strName] COLLATE Latin1_General_CI_AS 
AND Entity.intEntityId IN(SELECT intEntityId FROM tblEMEntityType WHERE strType = CASE WHEN ContractType.intContractTypeId = 1 THEN ''Vendor'' ELSE ''Customer'' END)' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Commodity' AS strExcelColumnName, 'intCommodityId'AS strTableCoulmnName, 'tblICCommodity'AS strRefTable, 'intCommodityId'AS strRefTableIdCol, 'strCommodityCode'AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'UOM' AS strExcelColumnName, 'intCommodityUOMId'AS strTableCoulmnName, 'tblICCommodityUnitMeasure'AS strRefTable, 'intCommodityUnitMeasureId'AS strRefTableIdCol, 'strUnitMeasure'AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, 
'LEFT JOIN tblICCommodityUnitMeasure CommodityUOM ON CommodityUOM.intCommodityId = Commodity.intCommodityId AND
(SELECT intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitMeasure = EX.[UOM]  COLLATE Latin1_General_CI_AS) = CommodityUOM.[intUnitMeasureId]' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Pricing Type' AS strExcelColumnName, 'intPricingTypeId'AS strTableCoulmnName, 'tblCTPricingType'AS strRefTable, 'intPricingTypeId'AS strRefTableIdCol, 'strPricingType'AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Terms' AS strExcelColumnName, 'intTermId'AS strTableCoulmnName, 'tblSMTerm'AS strRefTable, 'intTermID'AS strRefTableIdCol, 'strTerm'AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Salesperson' AS strExcelColumnName, 'intSalespersonId'AS strTableCoulmnName, 'tblEMEntity'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName'AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, 
'LEFT JOIN tblEMEntity Salesperson ON EX.[Salesperson] = Salesperson.[strName] COLLATE Latin1_General_CI_AS
 AND Salesperson.intEntityId IN(SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Salesperson'')' AS strSpecialJoin UNION ALL

SELECT 'tblCTContractHeader', 'Contact' AS strExcelColumnName, 'intEntityContactId'AS strTableCoulmnName, 'vyuCTEntityToContact'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN vyuCTEntityToContact EntityContact ON EntityContact.[intEntityId] = Entity.[intEntityId]
AND EntityContact.strName = EX.[Contact]  COLLATE Latin1_General_CI_AS' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Counter Party' AS strExcelColumnName, 'intCounterPartyId'AS strTableCoulmnName, 'tblEMEntity'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblEMEntity CounterParty ON EX.[Counter Party] = CounterParty.[strName] COLLATE Latin1_General_CI_AS
 AND CounterParty.intEntityId IN(SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Customer'')' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Producer' AS strExcelColumnName, 'intProducerId'AS strTableCoulmnName, 'tblEMEntity'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblEMEntity Producer ON EX.[Producer] = Producer.[strName] COLLATE Latin1_General_CI_AS
 AND Producer.intEntityId IN(SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Producer'')' AS strSpecialJoin UNION ALL

SELECT 'tblCTContractHeader', 'Book' AS strExcelColumnName, 'intBookId'AS strTableCoulmnName, 'tblCTBook'AS strRefTable, 'intBookId'AS strRefTableIdCol, 'strBook'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Sub Book' AS strExcelColumnName, 'intSubBookId'AS strTableCoulmnName, 'tblCTSubBook'AS strRefTable, 'intSubBookId'AS strRefTableIdCol, 'strSubBook'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblCTSubBook SubBook ON LTRIM(RTRIM(EX.[Sub Book])) = SubBook.[strSubBook] COLLATE Latin1_General_CI_AS 
AND Book.intBookId = SubBook.intBookId' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Quantity' AS strExcelColumnName, 'dblQuantity'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Contract Date' AS strExcelColumnName, 'dtmContractDate'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Entity Contract' AS strExcelColumnName, 'strCustomerContract'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Customer Contract' AS strExcelColumnName, 'strCPContract'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Provisional' AS strExcelColumnName, 'ysnProvisional'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Load' AS strExcelColumnName, 'ysnLoad'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Number Of Loads' AS strExcelColumnName, 'intNoOfLoad'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Qty Per Load' AS strExcelColumnName, 'dblQuantityPerLoad'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Load UOM' AS strExcelColumnName, 'intLoadUOMId'AS strTableCoulmnName, 'tblICCommodityUnitMeasure'AS strRefTable, 'intCommodityUnitMeasureId'AS strRefTableIdCol, 'strUnitMeasure'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblICCommodityUnitMeasure LoadUOM ON LoadUOM.intCommodityId = Commodity.intCommodityId AND
(SELECT intUnitMeasureId FROM tblICUnitMeasure WHERE strUnitMeasure = EX.[Load UOM]  COLLATE Latin1_General_CI_AS) = LoadUOM.[intUnitMeasureId]' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Position' AS strExcelColumnName, 'intPositionId'AS strTableCoulmnName, 'tblCTPosition'AS strRefTable, 'intPositionId'AS strRefTableIdCol, 'strPosition'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'INCO Ship Term' AS strExcelColumnName, 'intContractBasisId'AS strTableCoulmnName, 'tblCTContractBasis'AS strRefTable, 'intContractBasisId'AS strRefTableIdCol, 'strContractBasis'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Port City' AS strExcelColumnName, 'intINCOLocationTypeId'AS strTableCoulmnName, 'tblSMCity'AS strRefTable, 'intCityId'AS strRefTableIdCol, 'strCity'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Warehouse' AS strExcelColumnName, 'intWarehouseId'AS strTableCoulmnName, 'tblSMCompanyLocationSubLocation'AS strRefTable, 'intCompanyLocationSubLocationId'AS strRefTableIdCol, 'strSubLocationName'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Country' AS strExcelColumnName, 'intCountryId'AS strTableCoulmnName, 'tblSMCountry'AS strRefTable, 'intCountryID'AS strRefTableIdCol, 'strCountry'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Contract Number' AS strExcelColumnName, 'strContractNumber'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Contract Text' AS strExcelColumnName, 'intContractTextId'AS strTableCoulmnName, 'tblCTContractText'AS strRefTable, 'intContractTextId'AS strRefTableIdCol, 'strTextCode'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblCTContractText ContractText ON LTRIM(RTRIM(EX.[Contract Text])) = ContractText.[strTextCode] COLLATE Latin1_General_CI_AS
AND ContractText.intContractPriceType = PricingType.intPricingTypeId AND ContractText.intContractType = ContractType.intContractTypeId' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Grades' AS strExcelColumnName, 'intGradeId'AS strTableCoulmnName, 'tblCTWeightGrade'AS strRefTable, 'intWeightGradeId'AS strRefTableIdCol, 'strWeightGradeDesc'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Weights' AS strExcelColumnName, 'intWeightId'AS strTableCoulmnName, 'tblCTWeightGrade'AS strRefTable, 'intWeightGradeId'AS strRefTableIdCol, 'strWeightGradeDesc'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Signed' AS strExcelColumnName, 'ysnSigned'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Printed' AS strExcelColumnName, 'ysnPrinted'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Insurance By' AS strExcelColumnName, 'intInsuranceById'AS strTableCoulmnName, 'tblCTInsuranceBy'AS strRefTable, 'intInsuranceById'AS strRefTableIdCol, 'strInsuranceBy'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Tolerance Percent' AS strExcelColumnName, 'dblTolerancePct'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Provisional Invoice Percent' AS strExcelColumnName, 'dblProvisionalInvoicePct'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Weight For Invoicing' AS strExcelColumnName, 'intInvoiceTypeId'AS strTableCoulmnName, 'tblCTInvoiceType'AS strRefTable, 'intInvoiceTypeId'AS strRefTableIdCol, 'strInvoiceType'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Crop Year' AS strExcelColumnName, 'intCropYearId'AS strTableCoulmnName, 'tblCTCropYear'AS strRefTable, 'intCropYearId'AS strRefTableIdCol, 'strCropYear'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblCTCropYear CropYear ON LTRIM(EX.[Crop Year]) = CropYear.[strCropYear] COLLATE Latin1_General_CI_AS
AND CropYear.intCommodityId = Commodity.intCommodityId' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Association' AS strExcelColumnName, 'intAssociationId'AS strTableCoulmnName, 'tblCTAssociation'AS strRefTable, 'intAssociationId'AS strRefTableIdCol, 'strName'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Arbitration' AS strExcelColumnName, 'intArbitrationId'AS strTableCoulmnName, 'tblSMCity'AS strRefTable, 'intCityId'AS strRefTableIdCol, 'strCity'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Claim to Producer' AS strExcelColumnName, 'ysnClaimsToProducer'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Risk To Producer' AS strExcelColumnName, 'ysnRiskToProducer'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Internal Comments' AS strExcelColumnName, 'strInternalComment'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Printable Remarks' AS strExcelColumnName, 'strPrintableRemarks'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
--There can me multiple Pricing Level with same name.
--SELECT 'tblCTContractHeader', 'Price Level' AS strExcelColumnName, 'intCompanyLocationPricingLevelId'AS strTableCoulmnName, 'tblSMCompanyLocationPricingLevel'AS strRefTable, 'intCompanyLocationPricingLevelId'AS strRefTableIdCol, 'strPricingLevelName'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Substitute Item' AS strExcelColumnName, 'ysnSubstituteItem'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Max Price' AS strExcelColumnName, 'ysnMaxPrice'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Unlimited Quantity Contract' AS strExcelColumnName, 'ysnUnlimitedQuantity'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Multiple Price Fixation' AS strExcelColumnName, 'ysnMultiplePriceFixation'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Market' AS strExcelColumnName, 'intFutureMarketId'AS strTableCoulmnName, 'tblRKFutureMarket'AS strRefTable, 'intFutureMarketId'AS strRefTableIdCol, 'strFutMarketName'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Month' AS strExcelColumnName, 'intFutureMonthId'AS strTableCoulmnName, 'tblRKFuturesMonth'AS strRefTable, 'intFutureMonthId'AS strRefTableIdCol, 'strFutureMonth'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblRKFuturesMonth FutureMonth ON LTRIM(RTRIM(EX.[Month])) = FutureMonth.[strFutureMonth] COLLATE Latin1_General_CI_AS
AND FutureMonth.intFutureMarketId = FutureMarket.intFutureMarketId' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Future Price' AS strExcelColumnName, 'dblFutures'AS strTableCoulmnName, ''AS strRefTable, 'intFutureMonthId'AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'Number Of Lots' AS strExcelColumnName, 'dblNoOfLots'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractHeader', 'intConcurrencyId' AS strExcelColumnName, 'intConcurrencyId'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin 


UNION ALL

--tblCTContractDetail

SELECT 'tblCTContractDetail' AS strTableName, 'Contract Number'AS strExcelColumnName, 'intContractHeaderId'AS strTableCoulmnName, 'tblCTContractHeader'AS strRefTable, 'intContractHeaderId'AS strRefTableIdCol, 'strContractNumber' AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Sequence'AS strExcelColumnName, 'intContractSeq'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Status'AS strExcelColumnName, 'intContractStatusId'AS strTableCoulmnName, 'tblCTContractStatus'AS strRefTable, 'intContractStatusId'AS strRefTableIdCol, 'strContractStatus' AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Start Date'AS strExcelColumnName, 'dtmStartDate'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'End Date'AS strExcelColumnName, 'dtmEndDate'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'M2M Date'AS strExcelColumnName, 'dtmM2MDate'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Planned Availability'AS strExcelColumnName, 'dtmPlannedAvailabilityDate'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Event Start Date'AS strExcelColumnName, 'dtmEventStartDate'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Updated Availability'AS strExcelColumnName, 'dtmUpdatedAvailabilityDate'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Location'AS strExcelColumnName, 'intCompanyLocationId'AS strTableCoulmnName, 'tblSMCompanyLocation'AS strRefTable, 'intCompanyLocationId'AS strRefTableIdCol, 'strLocationName' AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Book'AS strExcelColumnName, 'intBookId'AS strTableCoulmnName, 'tblCTBook'AS strRefTable, 'intBookId'AS strRefTableIdCol, 'strBook' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Sub-book'AS strExcelColumnName, 'intSubBookId'AS strTableCoulmnName, 'tblCTSubBook'AS strRefTable, 'intSubBookId'AS strRefTableIdCol, 'strSubBook' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Contract Item'AS strExcelColumnName, 'intItemContractId'AS strTableCoulmnName, 'tblICItemContract'AS strRefTable, 'intItemContractId'AS strRefTableIdCol, 'strContractItemNo' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Item'AS strExcelColumnName, 'intItemId'AS strTableCoulmnName, 'tblICItem'AS strRefTable, 'intItemId'AS strRefTableIdCol, 'strItemNo' AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Item Specification'AS strExcelColumnName, 'strItemSpecification'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Purchasing Group'AS strExcelColumnName, 'intPurchasingGroupId'AS strTableCoulmnName, 'tblSMPurchasingGroup'AS strRefTable, 'intPurchasingGroupId'AS strRefTableIdCol, 'strName' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractDetail' AS strTableName, 'Farm No'AS strExcelColumnName, 'intFarmFieldId'AS strTableCoulmnName, 'tblEMEntityLocation'AS strRefTable, 'intEntityLocationId'AS strRefTableIdCol, 'strLocationName' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Grade'AS strExcelColumnName, 'strGrade'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Garden'AS strExcelColumnName, 'strGarden'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Vendor Lot ID'AS strExcelColumnName, 'strVendorLotID'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Quantity'AS strExcelColumnName, 'dblQuantity'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail', 'intConcurrencyId' AS strExcelColumnName, 'intConcurrencyId'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin  UNION ALL

SELECT 'tblCTContractDetail' AS strTableName, 'Quantity UOM'AS strExcelColumnName, 'intItemUOMId'AS strTableCoulmnName, 'tblICItemUOM'AS strRefTable, 'intItemUOMId'AS strRefTableIdCol, 'strUnitMeasure' AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, 
'LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId AND ItemUOM.intUnitMeasureId IN (SELECT intUnitMeasureId FROM tblICUnitMeasure WHERE [strUnitMeasure] = LTRIM(RTRIM(EX.[Quantity UOM]))COLLATE Latin1_General_CI_AS)' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Weight UOM'AS strExcelColumnName, 'intNetWeightUOMId'AS strTableCoulmnName, 'tblICItemUOM'AS strRefTable, 'intItemUOMId'AS strRefTableIdCol, 'strUnitMeasure' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblICItemUOM NetWeightUOM ON NetWeightUOM.intItemId = Item.intItemId AND NetWeightUOM.intUnitMeasureId IN (SELECT intUnitMeasureId FROM tblICUnitMeasure WHERE [strUnitMeasure] = LTRIM(RTRIM(EX.[Weight UOM]))COLLATE Latin1_General_CI_AS)' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Basis UOM'AS strExcelColumnName, 'intBasisUOMId'AS strTableCoulmnName, 'tblICItemUOM'AS strRefTable, 'intItemUOMId'AS strRefTableIdCol, 'strUnitMeasure' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblICItemUOM BasisUOM ON BasisUOM.intItemId = Item.intItemId AND BasisUOM.intUnitMeasureId IN (SELECT intUnitMeasureId FROM tblICUnitMeasure WHERE [strUnitMeasure] = LTRIM(RTRIM(EX.[Basis UOM]))COLLATE Latin1_General_CI_AS)' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Price UOM'AS strExcelColumnName, 'intPriceItemUOMId'AS strTableCoulmnName, 'tblICItemUOM'AS strRefTable, 'intItemUOMId'AS strRefTableIdCol, 'strUnitMeasure' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblICItemUOM PriceItemUOM ON PriceItemUOM.intItemId = Item.intItemId AND PriceItemUOM.intUnitMeasureId IN (SELECT intUnitMeasureId FROM tblICUnitMeasure WHERE [strUnitMeasure] = LTRIM(RTRIM(EX.[Price UOM]))COLLATE Latin1_General_CI_AS)' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'FX price UOM'AS strExcelColumnName, 'intFXPriceUOMId'AS strTableCoulmnName, 'tblICItemUOM'AS strRefTable, 'intItemUOMId'AS strRefTableIdCol, 'strUnitMeasure' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblICItemUOM FXPriceUOM ON FXPriceUOM.intItemId = Item.intItemId AND FXPriceUOM.intUnitMeasureId IN (SELECT intUnitMeasureId FROM tblICUnitMeasure WHERE [strUnitMeasure] = LTRIM(RTRIM(EX.[FX price UOM]))COLLATE Latin1_General_CI_AS)' AS strSpecialJoin UNION ALL

SELECT 'tblCTContractDetail' AS strTableName, 'Net Weight'AS strExcelColumnName, 'dblNetWeight'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Packing Description'AS strExcelColumnName, 'strPackingDescription'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Estimate Yield %'AS strExcelColumnName, 'dblYield'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Unit/Layer'AS strExcelColumnName, 'intUnitsPerLayer'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Layers/PaIIet'AS strExcelColumnName, 'intLayersPerPallet'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'No of Lots'AS strExcelColumnName, 'dblNoOfLots'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Container Type'AS strExcelColumnName, 'intContainerTypeId'AS strTableCoulmnName, 'tblLGContainerType'AS strRefTable, 'intContainerTypeId'AS strRefTableIdCol, 'strContainerType' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblLGContainerTypeCommodityQty ContainerTypeCommodityQty ON ContainerTypeCommodityQty.intCommodityId = ContractHeader.intCommodityId
LEFT JOIN tblLGContainerType ContainerType ON ContainerTypeCommodityQty.intContainerTypeId = ContainerType.intContainerTypeId AND LTRIM(RTRIM(EX.[Container Type])) = ContainerType.[strContainerType] COLLATE Latin1_General_CI_AS' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'No of Containers'AS strExcelColumnName, 'intNumberOfContainers'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractDetail' AS strTableName, 'Market Zone'AS strExcelColumnName, 'intMarketZoneId'AS strTableCoulmnName, 'tblARMarketZone'AS strRefTable, 'intMarketZoneId'AS strRefTableIdCol, 'strMarketZoneCode' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractDetail' AS strTableName, 'Discount'AS strExcelColumnName, 'intDiscountTypeId'AS strTableCoulmnName, 'tblCTDiscountType'AS strRefTable, 'intDiscountTypeId'AS strRefTableIdCol, 'strDiscountType' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractDetail' AS strTableName, 'Discount Table'AS strExcelColumnName, 'intDiscountId'AS strTableCoulmnName, 'tblGRDiscountId'AS strRefTable, 'intDiscountId'AS strRefTableIdCol, 'strDiscountId' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractDetail' AS strTableName, 'Option'AS strExcelColumnName, 'intContractOptHeaderId'AS strTableCoulmnName, 'tblCTContractOptHeader'AS strRefTable, 'intContractOptHeaderId'AS strRefTableIdCol, 'strContractOptDesc' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractDetail' AS strTableName, 'Split'AS strExcelColumnName, 'intSplitId'AS strTableCoulmnName, 'tblEMEntitySplit'AS strRefTable, 'intSplitId'AS strRefTableIdCol, 'strSplitNumber' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Fixation By'AS strExcelColumnName, 'strFixationBy'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'pricing Type'AS strExcelColumnName, 'intPricingTypeId'AS strTableCoulmnName, 'tblCTPricingType'AS strRefTable, 'intPricingTypeId'AS strRefTableIdCol, 'strPricingType' AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Futures Market'AS strExcelColumnName, 'intFutureMarketId'AS strTableCoulmnName, 'tblRKFutureMarket'AS strRefTable, 'intFutureMarketId'AS strRefTableIdCol, 'strFutMarketName' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Futures Month'AS strExcelColumnName, 'intFutureMonthId'AS strTableCoulmnName, 'tblRKFuturesMonth'AS strRefTable, 'intFutureMonthId'AS strRefTableIdCol, 'strFutureMonth' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblRKFuturesMonth FutureMonth ON FutureMarket.intFutureMarketId = FutureMonth.intFutureMarketId AND LTRIM(RTRIM(EX.[Futures Month])) = FutureMonth.[strFutureMonth] COLLATE Latin1_General_CI_AS' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Futures'AS strExcelColumnName, 'dblFutures'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Basis Currency'AS strExcelColumnName, 'intBasisCurrencyId'AS strTableCoulmnName, 'tblSMCurrency'AS strRefTable, 'intCurrencyID'AS strRefTableIdCol, 'strCurrency' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Basis'AS strExcelColumnName, 'dblBasis'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Cash price'AS strExcelColumnName, 'dblCashPrice'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Ratio'AS strExcelColumnName, 'dblRatio'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Price Currency'AS strExcelColumnName, 'intCurrencyId'AS strTableCoulmnName, 'tblSMCurrency'AS strRefTable, 'intCurrencyID'AS strRefTableIdCol, 'strCurrency' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Total Cost'AS strExcelColumnName, 'dblTotalCost'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'ERP PO Number'AS strExcelColumnName, 'strERPPONumber'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'ERP Item Number'AS strExcelColumnName, 'strERPItemNumber'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'ERP Batch Number'AS strExcelColumnName, 'strERPBatchNumber'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Invoice Currency'AS strExcelColumnName, 'intInvoiceCurrencyId'AS strTableCoulmnName, 'tblSMCurrency'AS strRefTable, 'intCurrencyID'AS strRefTableIdCol, 'strCurrency' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'FX Valid From'AS strExcelColumnName, 'dtmFXValidFrom'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'FX Valid To'AS strExcelColumnName, 'dtmFXValidTo'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Forex Rate'AS strExcelColumnName, 'dblRate'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'FX price'AS strExcelColumnName, 'dblFXPrice'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Price'AS strExcelColumnName, 'ysnUseFXPrice'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Rate Type'AS strExcelColumnName, 'intRateTypeId'AS strTableCoulmnName, 'tblSMCurrencyExchangeRateType'AS strRefTable, 'intCurrencyExchangeRateTypeId'AS strRefTableIdCol, 'strCurrencyExchangeRateType' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'FX Remarks'AS strExcelColumnName, 'strFXRemarks'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Freight Terms'AS strExcelColumnName, 'intFreightTermId'AS strTableCoulmnName, 'tblSMFreightTerms'AS strRefTable, 'intFreightTermId'AS strRefTableIdCol, 'strFreightTerm' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL

SELECT 'tblCTContractDetail' AS strTableName, 'Ship Via'AS strExcelColumnName, 'intShipViaId'AS strTableCoulmnName, 'tblEMEntity'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblEMEntity ShipVia ON EX.[Producer] = ShipVia.[strName] COLLATE Latin1_General_CI_AS
 AND ShipVia.intEntityId IN(SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Ship Via'')' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Producer'AS strExcelColumnName, 'intProducerId'AS strTableCoulmnName, 'tblEMEntity'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblEMEntity Producer ON EX.[Producer] = Producer.[strName] COLLATE Latin1_General_CI_AS
 AND Producer.intEntityId IN(SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Producer'')' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractDetail' AS strTableName, 'Bill To'AS strExcelColumnName, 'intBillTo'AS strTableCoulmnName, 'tblEMEntity'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Shipping Line'AS strExcelColumnName, 'intShippingLineId'AS strTableCoulmnName, 'tblEMEntity'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblEMEntity ShippingLine ON EX.[Producer] = ShippingLine.[strName] COLLATE Latin1_General_CI_AS
 AND ShippingLine.intEntityId IN(SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Shipping Line'')' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractDetail' AS strTableName, 'Farm Invoice NO'AS strExcelColumnName, 'strInvoiceNo'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, 
--'LEFT JOIN tblEMEntity InvoiceNo ON EX.[Producer] = InvoiceNo.[strName] COLLATE Latin1_General_CI_AS
-- AND InvoiceNo.intEntityId IN(SELECT intEntityId FROM tblEMEntityType WHERE strType = ''ChangeItTo'')' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractDetail' AS strTableName, 'Shipper'AS strExcelColumnName, 'intShipperId'AS strTableCoulmnName, 'tblEMEntity'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL

SELECT 'tblCTContractDetail' AS strTableName, 'Claims to Producer'AS strExcelColumnName, 'ysnClaimsToProducer'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Fronting'AS strExcelColumnName, 'ysnRiskToProducer'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Invoice'AS strExcelColumnName, 'ysnInvoice'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Provisional invoice'AS strExcelColumnName, 'ysnProvisionalInvoice'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Back to Back'AS strExcelColumnName, 'ysnBackToBack'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Byuer/Seller Name'AS strExcelColumnName, 'strBuyerSeller'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL

SELECT 'tblCTContractDetail' AS strTableName, 'FOB Basis'AS strExcelColumnName, 'strFobBasis'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Rail Remarks'AS strExcelColumnName, 'strRailRemark'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Loading Point Type'AS strExcelColumnName, 'strLoadingPointType'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Loading Point'AS strExcelColumnName, 'intLoadingPortId'AS strTableCoulmnName, 'tblSMCity'AS strRefTable, 'intCityId'AS strRefTableIdCol, 'strCity' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Destination Point Type'AS strExcelColumnName, 'strDestinationPointType'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Destination Point'AS strExcelColumnName, 'intDestinationPortId'AS strTableCoulmnName, 'tblSMCity'AS strRefTable, 'intCityId'AS strRefTableIdCol, 'strCity' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Destination City'AS strExcelColumnName, 'intDestinationCityId'AS strTableCoulmnName, 'tblSMCity'AS strRefTable, 'intCityId'AS strRefTableIdCol, 'strCity' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Shipping Terms'AS strExcelColumnName, 'strShippingTerm'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL

SELECT 'tblCTContractDetail' AS strTableName, 'Vessel'AS strExcelColumnName, 'strVessel'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL

SELECT 'tblCTContractDetail' AS strTableName, 'Storage Location'AS strExcelColumnName, 'intSubLocationId'AS strTableCoulmnName, 'tblSMCompanyLocationSubLocation'AS strRefTable, 'intCompanyLocationSubLocationId'AS strRefTableIdCol, 'strSubLocationName' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Storage Unit'AS strExcelColumnName, 'intStorageLocationId'AS strTableCoulmnName, 'tblICStorageLocation'AS strRefTable, 'intStorageLocationId'AS strRefTableIdCol, 'strName' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDetail' AS strTableName, 'Print Remarks'AS strExcelColumnName, 'strRemark'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin

UNION ALL

--tblCTContractCost

SELECT 'tblCTContractCost' AS strTableName, 'Sequence'AS strExcelColumnName, 'intContractDetailId'AS strTableCoulmnName, 'tblCTContractDetail'AS strRefTable, 'intContractDetailId'AS strRefTableIdCol, 'intContractSeq' AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, 
'LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractSeq = EX.[Sequence] AND 
ContractDetail.intContractHeaderId = (SELECT intContractHeaderId FROM tblCTContractHeader WHERE [strContractNumber] = LTRIM(RTRIM(EX.[Contract Number])) COLLATE Latin1_General_CI_AS)' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCost' AS strTableName, 'Other Charges'AS strExcelColumnName, 'intItemId'AS strTableCoulmnName, 'tblICItem'AS strRefTable, 'intItemId'AS strRefTableIdCol, 'strItemNo' AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCost' AS strTableName, 'Vendor'AS strExcelColumnName, 'intVendorId'AS strTableCoulmnName, 'tblEMEntity'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblEMEntity Vendor ON EX.[Vendor] = Vendor.[strName] COLLATE Latin1_General_CI_AS
 AND Vendor.intEntityId IN(SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Vendor'')' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCost' AS strTableName, 'Cost Method'AS strExcelColumnName, 'strCostMethod'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCost' AS strTableName, 'Currency'AS strExcelColumnName, 'intCurrencyId'AS strTableCoulmnName, 'tblSMCurrency'AS strRefTable, 'intCurrencyID'AS strRefTableIdCol, 'strCurrency' AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCost' AS strTableName, 'Rate'AS strExcelColumnName, 'dblRate'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCost' AS strTableName, 'UOM'AS strExcelColumnName, 'intItemUOMId'AS strTableCoulmnName, 'tblICItemUOM'AS strRefTable, 'intItemUOMId'AS strRefTableIdCol, 'strUnitMeasure' AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType,
'LEFT JOIN tblICItemUOM ItemUOM ON ItemUOM.intItemId = Item.intItemId AND ItemUOM.intUnitMeasureId IN (SELECT intUnitMeasureId FROM tblICUnitMeasure WHERE [strUnitMeasure] = LTRIM(RTRIM(EX.[UOM]))COLLATE Latin1_General_CI_AS)' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractCost' AS strTableName, 'Status'AS strExcelColumnName, 'strStatus'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractCost' AS strTableName, 'Act Amount'AS strExcelColumnName, 'dblActualAmount'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractCost' AS strTableName, 'Accrual Amount'AS strExcelColumnName, 'dblAccruedAmount'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractCost' AS strTableName, '% Remaining'AS strExcelColumnName, 'dblRemainingPercent'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractCost' AS strTableName, 'Accrual Date'AS strExcelColumnName, 'dtmAccrualDate'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCost' AS strTableName, 'Accrue'AS strExcelColumnName, 'ysnAccrue'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractCost' AS strTableName, 'Cherge Entity'AS strExcelColumnName, 'ysnPrice'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
--SELECT 'tblCTContractCost' AS strTableName, 'Basis'AS strExcelColumnName, 'ysnBasis'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin  UNION ALL 
SELECT 'tblCTContractCost', 'intConcurrencyId' AS strExcelColumnName, 'intConcurrencyId'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin

UNION ALL

--tblCTContractCondition

SELECT 'tblCTContractCondition', 'Contract Number' AS strExcelColumnName, 'intContractHeaderId'AS strTableCoulmnName, 'tblCTContractHeader'AS strRefTable, 'intContractHeaderId'AS strRefTableIdCol, 'strContractNumber'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCondition', 'Condition' AS strExcelColumnName, 'intConditionId'AS strTableCoulmnName, 'tblCTCondition'AS strRefTable, 'intConditionId'AS strRefTableIdCol, 'strConditionName'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCondition', 'intConcurrencyId' AS strExcelColumnName, 'intConcurrencyId'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin


UNION ALL

--tblCTContractDocument

SELECT 'tblCTContractDocument', 'Contract Number' AS strExcelColumnName, 'intContractHeaderId'AS strTableCoulmnName, 'tblCTContractHeader'AS strRefTable, 'intContractHeaderId'AS strRefTableIdCol, 'strContractNumber'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDocument', 'Document Name' AS strExcelColumnName, 'intDocumentId'AS strTableCoulmnName, 'tblICDocument'AS strRefTable, 'intDocumentId'AS strRefTableIdCol, 'strDocumentName'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractDocument', 'intConcurrencyId' AS strExcelColumnName, 'intConcurrencyId'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin

UNION ALL

--tblCTContractCertification

SELECT 'tblCTContractCertification' AS strTableName, 'Sequence'AS strExcelColumnName, 'intContractDetailId'AS strTableCoulmnName, 'tblCTContractDetail'AS strRefTable, 'intContractDetailId'AS strRefTableIdCol, 'intContractSeq' AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, 
'LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractSeq = EX.[Sequence] AND 
ContractDetail.intContractHeaderId = (SELECT intContractHeaderId FROM tblCTContractHeader WHERE [strContractNumber] = LTRIM(RTRIM(EX.[Contract Number])) COLLATE Latin1_General_CI_AS)' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCertification', 'Certificates' AS strExcelColumnName, 'intCertificationId'AS strTableCoulmnName, 'tblICCertification'AS strRefTable, 'intCertificationId'AS strRefTableIdCol, 'strCertificationName'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCertification', 'Producer' AS strExcelColumnName, 'intProducerId'AS strTableCoulmnName, 'tblEMEntity'AS strRefTable, 'intEntityId'AS strRefTableIdCol, 'strName'AS strRefCoulumnToCmpr, 'LEFT JOIN' AS strJoinType, 
'LEFT JOIN tblEMEntity Producer ON EX.[Producer] = Producer.[strName] COLLATE Latin1_General_CI_AS
 AND Producer.intEntityId IN(SELECT intEntityId FROM tblEMEntityType WHERE strType = ''Producer'')' AS strSpecialJoin UNION ALL
 SELECT 'tblCTContractCertification' AS strTableName, 'Certification Id'AS strExcelColumnName, 'strCertificationId'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCertification' AS strTableName, 'Tracking Number'AS strExcelColumnName, 'strTrackingNumber'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCertification' AS strTableName, 'Quantity'AS strExcelColumnName, 'dblQuantity'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTContractCertification', 'intConcurrencyId' AS strExcelColumnName, 'intConcurrencyId'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin

UNION ALL

--tblCTBagMark

SELECT 'tblCTBagMark' AS strTableName, 'Sequence'AS strExcelColumnName, 'intContractDetailId'AS strTableCoulmnName, 'tblCTContractDetail'AS strRefTable, 'intContractDetailId'AS strRefTableIdCol, 'intContractSeq' AS strRefCoulumnToCmpr, 'JOIN' AS strJoinType, 
'LEFT JOIN tblCTContractDetail ContractDetail ON ContractDetail.intContractSeq = EX.[Sequence] AND 
ContractDetail.intContractHeaderId = (SELECT intContractHeaderId FROM tblCTContractHeader WHERE [strContractNumber] = LTRIM(RTRIM(EX.[Contract Number])) COLLATE Latin1_General_CI_AS)' AS strSpecialJoin UNION ALL
SELECT 'tblCTBagMark' AS strTableName, 'Bag Mark'AS strExcelColumnName, 'strBagMark'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTBagMark' AS strTableName, 'Default'AS strExcelColumnName, 'ysnDefault'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, '' AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin UNION ALL
SELECT 'tblCTBagMark', 'intConcurrencyId' AS strExcelColumnName, 'intConcurrencyId'AS strTableCoulmnName, ''AS strRefTable, ''AS strRefTableIdCol, ''AS strRefCoulumnToCmpr, '' AS strJoinType, '' AS strSpecialJoin
