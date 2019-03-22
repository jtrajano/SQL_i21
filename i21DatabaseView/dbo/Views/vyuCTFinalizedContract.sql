CREATE VIEW [dbo].[vyuCTFinalizedContract]
 AS
 SELECT
 intContractHeaderId						= PD.intContractHeaderId
,intContractTypeId							= PH.intContractTypeId
,intContractDetailId						= PD.intContractDetailId
,strPONumber								= PH.strContractNumber+ '-' + LTRIM(PD.intContractSeq)
,strSalesEntity								= Entity.strEntityName
,strSONumber								= SH.strContractNumber+ '-' + LTRIM(SD.intContractSeq)
,dblPOQuantity								= ISNULL(PD.dblQuantity,0)
,strPOUOM									= UnitMeasure.strUnitMeasure
,strInvoiceNumber							= Invoice.strInvoiceNumber
,dtmInvoiceDate								= CONVERT(DATETIME, CONVERT(VARCHAR, Invoice.dtmPostDate, 101), 101)
,dblContractAdjustQuantity					= NULL
,strContractAdjustUOM						= NULL

FROM tblCTContractDetail	PD
JOIN tblCTContractHeader	PH			     ON  PH.intContractHeaderId				   = PD.intContractHeaderId 
											AND  PD.intContractStatusId				   = 5 --Contract Seq(Status = Complete)
											AND  PH.intContractTypeId				   = 1 --Contract (Type = Purchase)
JOIN tblICItemUOM		    ItemUOM		     ON  ItemUOM.intItemUOMId				   = PD.intItemUOMId
JOIN tblICUnitMeasure	    UnitMeasure	     ON	 UnitMeasure.intUnitMeasureId		   = ItemUOM.intUnitMeasureId
JOIN tblLGAllocationDetail  AllocationDetail ON  AllocationDetail.intPContractDetailId = PD.intContractDetailId
JOIN tblCTContractDetail	SD				 ON  SD.intContractDetailId				   = AllocationDetail.intSContractDetailId
JOIN tblCTContractHeader	SH				 ON  SH.intContractHeaderId				   = SD.intContractHeaderId
JOIN vyuCTEntity			Entity			 ON  Entity.intEntityId					   = SH.intEntityId AND Entity.strEntityType = 'Customer'
JOIN tblLGLoadDetail		LoadDetail		 ON  LoadDetail.intAllocationDetailId	   = AllocationDetail.intAllocationDetailId
JOIN tblARInvoiceDetail		InvoiceDetail	 ON  InvoiceDetail.intLoadDetailId		   = LoadDetail.intLoadDetailId
JOIN tblARInvoice			Invoice			 ON  Invoice.intInvoiceId				   = InvoiceDetail.intInvoiceId 
