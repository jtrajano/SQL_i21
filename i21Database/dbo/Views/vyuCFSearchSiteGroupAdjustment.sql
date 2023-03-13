CREATE VIEW dbo.vyuCFSearchSiteGroupAdjustment  
AS  
SELECT    
  tblCFSiteGroupPriceAdjustmentHeader.intSiteGroupId  
 ,tblCFSiteGroupPriceAdjustmentHeader.dtmEffectiveDate  
 ,tblCFSiteGroupPriceAdjustmentHeader.intSiteGroupPriceAdjustmentHeaderId  
 ,tblCFSiteGroupPriceAdjustmentHeader.intConcurrencyId  
 ,tblCFSiteGroupPriceAdjustment.dblRate  
 ,tblCFSiteGroupPriceAdjustment.dtmEndEffectiveDate  
 ,tblCFSiteGroupPriceAdjustment.dtmStartEffectiveDate  
 ,tblCFSiteGroupPriceAdjustment.intARItemId    
 ,tblCFSiteGroupPriceAdjustment.intPriceGroupId  
 ,tblCFSiteGroupPriceAdjustment.intSiteGroupPriceAdjustmentId  
 ,tblICItem.intItemId  
 ,tblICItem.strItemNo  
 ,strItemDescription = tblICItem.strDescription  
 ,strSiteGroupDescription = tblCFSiteGroup.strDescription  
 ,tblCFSiteGroup.strSiteGroup  
 ,tblCFSiteGroup.strType  
 ,tblCFPriceRuleGroup.intPriceRuleGroupId  
 ,strPriceRuleGroup = tblCFPriceRuleGroup.strPriceGroup  
 ,strPriceRuleGroupDescription = tblCFPriceRuleGroup.strPriceGroupDescription  
FROM tblCFSiteGroupPriceAdjustmentHeader  
LEFT JOIN tblCFSiteGroupPriceAdjustment  
ON tblCFSiteGroupPriceAdjustmentHeader.intSiteGroupPriceAdjustmentHeaderId = tblCFSiteGroupPriceAdjustment.intSiteGroupPriceAdjustmentHeaderId  
LEFT JOIN tblICItem  
ON tblCFSiteGroupPriceAdjustment.intARItemId = tblICItem.intItemId  
LEFT JOIN tblCFSiteGroup  
ON tblCFSiteGroupPriceAdjustmentHeader.intSiteGroupId = tblCFSiteGroup.intSiteGroupId  
LEFT JOIN tblCFPriceRuleGroup  
ON tblCFSiteGroupPriceAdjustment.intPriceGroupId = tblCFPriceRuleGroup.intPriceRuleGroupId  
 GO