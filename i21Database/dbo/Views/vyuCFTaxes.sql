CREATE VIEW dbo.vyuCFTaxes
AS
SELECT     tgm.intTaxGroupMasterId, tgm.strTaxGroupMaster, tgm.strDescription AS strTaxGroupMasterDescription, tg.intTaxGroupId, tg.strTaxGroup, 
                      tg.strDescription AS strTaxGroupDescription, tc.intTaxCodeId, tc.strTaxCode, tc.intTaxClassId, tc.strDescription, tc.strTaxAgency, 
                      tc.strAddress, tc.strZipCode, tc.strState, tc.strCity, tc.strCountry, tc.strCounty, tc.intSalesTaxAccountId, tc.intPurchaseTaxAccountId, tc.strTaxableByOtherTaxes, 
                      tc.ysnCheckoffTax, tc.intConcurrencyId
FROM         dbo.tblSMTaxGroupMaster AS tgm INNER JOIN
                      dbo.tblSMTaxGroupMasterGroup AS htgm ON tgm.intTaxGroupMasterId = htgm.intTaxGroupMasterId INNER JOIN
                      dbo.tblSMTaxGroupCode AS htgc ON htgm.intTaxGroupId = htgc.intTaxGroupId INNER JOIN
                      dbo.tblSMTaxGroup AS tg ON htgc.intTaxGroupId = tg.intTaxGroupId INNER JOIN
                      dbo.tblSMTaxCode AS tc ON htgc.intTaxCodeId = tc.intTaxCodeId

