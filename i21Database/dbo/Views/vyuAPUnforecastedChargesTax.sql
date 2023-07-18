CREATE VIEW [dbo].[vyuAPUnforecastedChargesTax]
AS
  SELECT
    [intUnforecastedChargeTaxId] = ROW_NUMBER() OVER(ORDER BY intContractCostId),
    CC.intContractCostId,
		[intTaxGroupId]			=	Taxes.intTaxGroupId, 
		[intTaxCodeId]			=	Taxes.intTaxCodeId, 
		[intTaxClassId]			=	Taxes.intTaxClassId, 
		[strTaxableByOtherTaxes]=	Taxes.strTaxableByOtherTaxes, 
		[strCalculationMethod]	=	Taxes.strCalculationMethod, 
		[dblRate]				=	Taxes.dblRate, 
		[intAccountId]			=	Taxes.intTaxAccountId, 
		[dblTax]				=	ISNULL(Taxes.dblTax,0), 
		[dblAdjustedTax]		=	ISNULL(Taxes.dblAdjustedTax,0), 
		[ysnTaxAdjusted]		=	Taxes.ysnTaxAdjusted, 
		[ysnSeparateOnBill]		=	Taxes.ysnSeparateOnInvoice, 
		[ysnCheckOffTax]		=	Taxes.ysnCheckoffTax,
		[ysnTaxOnly]        = Taxes.ysnTaxOnly,
		[ysnTaxExempt]      = Taxes.ysnTaxExempt,
    Taxes.strTaxCode
  FROM tblCTContractCost CC
  INNER JOIN tblCTContractDetail CD on CD.intContractDetailId = CC.intContractDetailId
  INNER JOIN tblCTContractHeader CH on CH.intContractHeaderId = CD.intContractHeaderId
  INNER JOIN tblEMEntity EN ON EN.intEntityId = CC.intVendorId
  INNER JOIN (tblEMEntityLocation EL INNER JOIN vyuAPVendorDefault VD ON EL.intEntityLocationId = VD.intDefaultLocationId)
    ON CC.intVendorId = EL.intEntityId
  INNER JOIN tblSMCompanyLocation CL ON CL.intCompanyLocationId = CH.intCompanyLocationId
  OUTER APPLY fnGetItemTaxComputationForVendor
      (CC.intItemId
      ,CC.intVendorId
      ,CH.dtmContractDate
      ,CC.dblRate
      ,1
      ,CD.intTaxGroupId
      ,CH.intCompanyLocationId
      ,VD.intDefaultLocationId
      ,1
      ,CAST(0 AS BIT)
      ,CH.intFreightTermId
      ,CAST(0 AS BIT)
      ,CC.intItemUOMId
      ,NULL
      ,NULL
      ,NULL) Taxes
  WHERE CC.ysnUnforcasted = 1
  AND CH.intContractTypeId = 1
  AND Taxes.dblTax IS NOT NULL
