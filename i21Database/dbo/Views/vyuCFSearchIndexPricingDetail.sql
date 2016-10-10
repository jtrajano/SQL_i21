CREATE VIEW dbo.[vyuCFSearchIndexPricingDetail]
AS
SELECT cfIPH.intIndexPricingBySiteGroupHeaderId, cfIPH.dtmDate, cfSG.intSiteGroupId, cfSG.strSiteGroup, cfSG.strDescription AS strSiteGroupDescription, cfSG.strType AS strSiteGroupType, cfPI.intPriceIndexId, cfPI.strPriceIndex, cfPI.strDescription AS strIndexDescription, 
             cfIPD.intIndexPricingBySiteGroupId, cfIPD.intTime, cfIPD.dblIndexPrice, icItem.intItemId, icItem.strItemNo, icItem.strShortName, icItem.strType AS strItemType, icItem.strDescription AS strItemDescription
FROM   dbo.tblCFIndexPricingBySiteGroupHeader AS cfIPH LEFT OUTER JOIN
             dbo.tblCFSiteGroup AS cfSG ON cfIPH.intSiteGroupId = cfSG.intSiteGroupId LEFT OUTER JOIN
             dbo.tblCFPriceIndex AS cfPI ON cfIPH.intPriceIndexId = cfPI.intPriceIndexId LEFT OUTER JOIN
             dbo.tblCFIndexPricingBySiteGroup AS cfIPD ON cfIPH.intIndexPricingBySiteGroupHeaderId = cfIPD.intIndexPricingBySiteGroupHeaderId LEFT OUTER JOIN
             dbo.tblICItem AS icItem ON cfIPD.intARItemID = icItem.intItemId
