CREATE PROCEDURE [dbo].[uspCFGetItemTaxes]    
@CFTaxGroupMasterId    INT    
AS    
  
SELECT TC.*,TCR.*  ,TGM.[intTaxGroupMasterId],TGTM.[intTaxGroupId]  ,TGC.[intTaxCodeId]  
   FROM tblSMTaxCode TC   
    INNER JOIN tblSMTaxGroupCode TGC ON TC.[intTaxCodeId] = TGC.[intTaxCodeId]   
    INNER JOIN tblSMTaxGroup TG ON TGC.[intTaxGroupId] = TG.[intTaxGroupId]  
    INNER JOIN tblSMTaxGroupMasterGroup TGTM ON TG.[intTaxGroupId] = TGTM.[intTaxGroupId]  
    INNER JOIN tblSMTaxGroupMaster TGM ON TGTM.[intTaxGroupMasterId] = TGM.[intTaxGroupMasterId]  
    INNER JOIN tblSMTaxCodeRate TCR ON TC.[intTaxCodeId] = TCR.[intTaxCodeId]
   WHERE   
    TGM.[intTaxGroupMasterId] = @CFTaxGroupMasterId