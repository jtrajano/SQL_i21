CREATE VIEW [dbo].[vyuFABookDepreciationReportWithCompany]
AS 

SELECT       
      BDR.dblCostLeft - BDR.dblDepreciationLTDLeft AS dblNetBookValueGaap  
 , BDR.dblCostRight - BDR.dblDepreciationLTDRight AS dblNetBookValueTax  
 , BDR.*      
 , strAssetId = FA.strAssetId         
    , strAssetDescription = FA.strAssetDescription      
    , strSerialNumber = FA.strSerialNumber      
    , strNotes = FA.strNotes      
    , dtmDateAcquired = FA.dtmDateAcquired      
    , dtmDateInService = FA.dtmDateInService      
    , strGroupCode = AssetGroup.strGroupCode      
    , strGroupDescription = AssetGroup.strGroupDescription      
    , strAssetAccountId = GLAsset.strAccountId      
    , strDepreciationAccountId = GLDepreciation.strAccountId           
    , strCompanyLocation = Company.strLocationName      
    , strLedgerLeft = LL.strLedgerName      
    , strLedgerRight = LR.strLedgerName      
    , strDepreciationMethodIdLeft = DML.strDepreciationMethodId      
    , strDepreciationMethodIdRight = DMR.strDepreciationMethodId      
    , strTaxJurisdiction = TaxJurisdiction.strTaxJurisdiction  
	, GL.*      
  
FROM tblFABookDepreciationReport BDR  
JOIN tblFAFixedAsset FA ON FA.intAssetId = BDR.intAssetId  
LEFT JOIN tblFADepreciationMethod DML ON DML.intDepreciationMethodId = BDR.intDepreciationMethodIdLeft  
LEFT JOIN tblFADepreciationMethod DMR ON DMR.intDepreciationMethodId = BDR.intDepreciationMethodIdRight  
LEFT JOIN tblGLLedger LL ON LL.intLedgerId = BDR.intLedgerIdLeft  
LEFT JOIN tblGLLedger LR ON LR.intLedgerId = BDR.intLedgerIdRight  
LEFT JOIN tblGLAccount GLAsset ON GLAsset.intAccountId = FA.intAssetAccountId          
LEFT JOIN tblGLAccount GLDepreciation ON GLDepreciation.intAccountId = FA.intDepreciationAccountId          
LEFT JOIN tblSMCompanyLocation Company ON Company.intCompanyLocationId = FA.intCompanyLocationId          
LEFT JOIN tblFAFixedAssetGroup AssetGroup ON AssetGroup.intAssetGroupId = FA.intAssetGroupId  
LEFT JOIN tblFAFixedAssetTaxJurisdiction TaxJurisdiction ON TaxJurisdiction.intAssetTaxJurisdictionId = FA.intAssetTaxJurisdictionId
LEFT JOIN tblGLTempCOASegment GL ON  FA.intAssetAccountId = GL.intAccountId
