CREATE PROCEDURE [dbo].[uspCTImportItemContractFromStaging]
AS
BEGIN

	SET QUOTED_IDENTIFIER OFF
	SET ANSI_NULLS ON
	SET NOCOUNT ON
	SET XACT_ABORT ON
	SET ANSI_WARNINGS OFF
	
	DECLARE @itemContractRecordNum NVARCHAR(50)
	DECLARE @ItemContractItems AS TABLE 
	(
		[intStagingItemId]					[int] NOT NULL,
		[intConcurrencyId]					[int] NOT NULL,

		[intContractPlanId]					[int] NULL,
		[intContractTypeId]					[int] NOT NULL,
		[strContractCategoryId]				[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
		[intEntityId]						[int] NOT NULL,
		[intCurrencyId]						[int] NOT NULL,

		[intCompanyLocationId]				[int] NULL, 
		[dtmContractDate]					[datetime] NULL,
		[dtmExpirationDate]					[datetime] NULL,
		[strEntryContract]					[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
		[strCPContract]						[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,

		[intFreightTermId]					[int] NULL,	
		[intCountryId]						[int] NULL, 
		[intTermId]							[int] NULL,
		--[ysnPrepaid]						[bit] NULL,   

		[strContractNumber]					[nvarchar](50) COLLATE Latin1_General_CI_AS NOT NULL,
		[intSalespersonId]					[int] NOT NULL,
		[intContractTextId]					[int] NULL,
		[ysnSigned]							[bit] NOT NULL DEFAULT ((0)),
		[dtmSigned]							[datetime] NULL,
		[ysnPrinted]						[bit] NOT NULL DEFAULT ((0)),

		[intOpportunityId]					[int] NULL,
		[intLineOfBusinessId]				[int] NULL,
		[dtmDueDate]						[datetime] NULL
	)

	INSERT INTO @ItemContractItems(
		 intStagingItemId
		,intConcurrencyId
		,intContractPlanId
		,intContractTypeId
		,intFreightTermId
		,intCountryId
		,intTermId
		,intEntityId
		,intCurrencyId
		,intCompanyLocationId	
		,intSalespersonId
		,intContractTextId
		,intOpportunityId
		,intLineOfBusinessId
		,strContractNumber
		,strEntryContract
		,strCPContract
		,strContractCategoryId			
		,ysnSigned
		--,ysnPrepaid	
		,ysnPrinted
		,dtmContractDate
		,dtmExpirationDate
		,dtmSigned	
		,dtmDueDate)
	SELECT 
		 intStagingItemId
		,1
		,intContractPlanId
		,intContractTypeId
		,intFreightTermId
		,intCountryId
		,intTermId
		,intEntityId
		,intCurrencyId
		,intCompanyLocationId	
		,intSalespersonId
		,intContractTextId
		,intOpportunityId
		,intLineOfBusinessId
		,''
		,strEntryContract
		,strCPContract
		,strContractCategoryId			
		,ysnSigned
		--,ysnPrepaid	
		,ysnPrinted
		,dtmContractDate
		,dtmExpirationDate
		,dtmSigned	
		,dtmDueDate
	FROM tblCTStagingItemContract

WHILE EXISTS(SELECT 1 FROM @ItemContractItems)
BEGIN

	DECLARE @intStagingItemId INT
	DECLARE @intItemHeaderId INT
	DECLARE @IncrementValue INT = 0

	SELECT TOP 1 @intStagingItemId = intStagingItemId FROM @ItemContractItems ORDER BY intStagingItemId	
	EXEC uspSMGetStartingNumber 144, @itemContractRecordNum OUT

	INSERT INTO tblCTItemContractHeader(
		 intContractPlanId
		,intContractTypeId
		,intFreightTermId
		,intCountryId
		,intTermId
		,intEntityId
		,intCurrencyId
		,intCompanyLocationId	
		,intSalespersonId
		,intContractTextId
		,intOpportunityId
		,intLineOfBusinessId
		,intConcurrencyId
		,strContractNumber
		,strEntryContract
		,strCPContract
		,strContractCategoryId			
		,ysnSigned
		--,ysnPrepaid	
		,ysnPrinted
		,dtmContractDate
		,dtmExpirationDate
		,dtmSigned	
		,dtmDueDate)
	SELECT
		 intContractPlanId
		,intContractTypeId
		,intFreightTermId
		,intCountryId
		,intTermId
		,intEntityId
		,intCurrencyId
		,intCompanyLocationId	
		,intSalespersonId
		,intContractTextId
		,intOpportunityId
		,intLineOfBusinessId
		,intConcurrencyId
		,@itemContractRecordNum
		,strEntryContract
		,strCPContract
		,strContractCategoryId			
		,ysnSigned
		--,ysnPrepaid	
		,ysnPrinted
		,dtmContractDate
		,dtmExpirationDate
		,dtmSigned	
		,dtmDueDate
	FROM @ItemContractItems
	WHERE intStagingItemId = @intStagingItemId

	SET @intItemHeaderId = (SELECT MAX(intItemContractHeaderId) FROM tblCTItemContractHeader WHERE strContractNumber =  @itemContractRecordNum)	

	INSERT INTO tblCTItemContractDetail(
		 intItemContractHeaderId
		,intItemId
		,strItemDescription
		,dtmDeliveryDate
		,dtmLastDeliveryDate
		,dblContracted
		,dblScheduled
		,dblAvailable
		,dblApplied
		,dblBalance
		,dblTax
		,dblPrice
		,dblTotal
		,intContractStatusId
		,intItemUOMId
		,intTaxGroupId
	)
	SELECT 		 
		 @intItemHeaderId
		,intItemId
		,strItemDescription
		,dtmDeliveryDate
		,dtmLastDeliveryDate
		,dblContracted
		,dblScheduled
		,dblAvailable
		,dblApplied
		,dblBalance
		,dblTax
		,dblPrice
		,dblTotal
		,intContractStatusId
		,intItemUOMId
		,intTaxGroupId
	FROM tblCTStagingItemContractDetail
	WHERE intStagingItemId = @intStagingItemId

	UPDATE tblCTItemContractDetail SET intLineNo = ISNULL(intLineNo,0) + @IncrementValue, @IncrementValue = @IncrementValue + 1 WHERE intItemContractHeaderId = @intItemHeaderId

	DELETE @ItemContractItems WHERE intStagingItemId = @intStagingItemId

END

    DELETE FROM tblCTStagingItemContract
    DELETE FROM tblCTStagingItemContractDetail
    
END