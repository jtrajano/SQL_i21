IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportFreightSettlement')
	DROP PROCEDURE uspGRImportFreightSettlement
GO
CREATE PROCEDURE uspGRImportFreightSettlement 
	 @Checking BIT = 0
	,@UserId INT = 0
	,@Total INT = 0 OUTPUT
AS
BEGIN TRY
	
	IF (@Checking = 1)
	BEGIN
		
		IF EXISTS(SELECT 1 FROM tblAPBill Bill JOIN gastlmst OSTL ON LTRIM(RTRIM(OSTL.gastl_tic_no))=Bill.strVendorOrderNumber collate Latin1_General_CI_AS WHERE OSTL.gastl_pd_yn <> 'Y' AND OSTL.gastl_rec_type  =  'F')
			SELECT @Total = 0
		ELSE  
			SELECT @Total = COUNT(1) FROM gastlmst OSTL 
			WHERE    OSTL.gastl_pd_yn	  <> 'Y'
			AND		 OSTL.gastl_rec_type  =  'F'

		RETURN @Total
	END

	SET NOCOUNT ON
	DECLARE @ErrMsg NVARCHAR(MAX)

	DECLARE @intFreightVoucherKey         INT
	DECLARE @VendorId		              INT
	DECLARE @LocationId		              INT
	DECLARE @UserKey		              INT
	DECLARE @strTicketNumber              NVARCHAR(1000)
	DECLARE @IRelyAdminKey                INT
								          
	DECLARE @intCreatedBillId             INT
	DECLARE @dtmVoucherDate               DATETIME
	DECLARE @voucherDetailNonInventory AS VoucherDetailNonInventory
	

	SELECT @IRelyAdminKey =intEntityId FROM tblSMUserSecurity WHERE strUserName='IRELYADMIN'
	

	SET @dtmVoucherDate = GETDATE()

		DECLARE @tblFreightVoucher AS TABLE
		(
		    intFreightVoucherKey       INT IDENTITY(1, 1)
		   ,intVendorId			       INT
		   ,intItemId			       INT
		   ,strItemNo		           NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
		   ,intUnitOfMeasureId         INT
		   ,strTicketNumber		       NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
		   ,intCompanyLocationId       INT
		   ,dblFreightUnit			   DECIMAL(24, 10)
		   ,dblFreightRate			   DECIMAL(24, 10)
		   ,dblSettlementAmount        DECIMAL(24, 10)
		   ,dtmSettlementReceiveDate   DATETIME
		   ,strCustomerReferenceNumber NVARCHAR(1000) COLLATE Latin1_General_CI_AS NULL
		   ,strTicketComment		   NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL
		   ,strGLAccountNumber		   NVARCHAR(MAX) COLLATE Latin1_General_CI_AS NULL  
		   ,intCurrencyId			   INT
		   ,intUserId				   INT
		   ,dtmUserReceiveDate		   DATETIME
		)

	   INSERT INTO @tblFreightVoucher
	   (
	      intVendorId			      
	     ,intItemId
		 ,strItemNo
	     ,intUnitOfMeasureId			      
	     ,strTicketNumber		      
	     ,intCompanyLocationId
	     ,dblFreightUnit			  
	     ,dblFreightRate      
	     ,dblSettlementAmount       
	     ,dtmSettlementReceiveDate  
	     ,strCustomerReferenceNumber
	     ,strTicketComment		  
	     ,strGLAccountNumber
	     ,intCurrencyId				  
	     ,intUserId					  
	     ,dtmUserReceiveDate
	   )
		 SELECT 
		 intVendorId			      		  = t.intEntityId
		,intItemId			      			  = Item.intItemId
		,strItemNo							  = Item.strItemNo
		,intUnitOfMeasureId					  = UOM.intItemUOMId
		,strTicketNumber		      		  = LTRIM(RTRIM(OSTL.gastl_tic_no))
		,intCompanyLocationId      			  = CL.intCompanyLocationId
		,dblFreightUnit			  			  = OSTL.gastl_frt_un
		,dblFreightRate			  			  = OSTL.gastl_frt_rt
		,dblSettlementAmount       			  = OSTL.gastl_stl_amt
		,dtmSettlementReceiveDate  			  = dbo.fnCTConvertToDateTime(OSTL.gastl_stl_rev_dt,null)
		,strCustomerReferenceNumber			  = LTRIM(RTRIM(OSTL.gastl_cus_ref_no))
		,strTicketComment		  			  = LTRIM(RTRIM(OSTL.gastl_tic_comment))
		,strGLAccountNumber		  			  = OSTL.gastl_gl_acct_no
		,intCurrencyId				  		  = CY.intCurrencyID
		,intUserId					  		  = ISNULL(US.intEntityId,@IRelyAdminKey)--
		,dtmUserReceiveDate		    		  = dbo.fnCTConvertToDateTime(OSTL.gastl_user_rev_dt,null)
		FROM		gastlmst OSTL
		JOIN (
					SELECT * FROM 
					(
						SELECT	EY.intEntityId,EY.strName,EY.strEntityNo,ET.strType,ROW_NUMBER() OVER (PARTITION BY strEntityNo,ET.strType ORDER BY EY.intEntityId) intRowNum
						FROM	tblEMEntity EY
						JOIN	tblEMEntityType			ET	ON	ET.intEntityId	=	EY.intEntityId
						 WHERE  ET.strType ='Vendor' AND ISNULL(EY.strEntityNo,'')<>'' 
					) t  WHERE intRowNum = 1

			  )   t ON LTRIM(RTRIM(t.strEntityNo)) collate Latin1_General_CI_AS	= LTRIM(RTRIM(OSTL.gastl_cus_no))

		JOIN        tblICItem				    Item ON LTRIM(RtRIM(Item.strItemNo)) collate Latin1_General_CI_AS = LTRIM(RtRIM(OSTL.gastl_com_cd))+' Freight'
		JOIN		tblICItemUOM				UOM  ON UOM.intItemId = Item.intItemId 
		JOIN		tblICCommodity				COM  ON COM.intCommodityId = Item.intCommodityId
		JOIN		tblICCommodityUnitMeasure   CU   ON CU.intCommodityId = COM.intCommodityId AND CU.ysnStockUnit = 1 AND CU.intUnitMeasureId = UOM.intUnitMeasureId
		JOIN		tblSMCompanyLocation		CL	ON	LTRIM(RTRIM(CL.strLocationNumber)) collate Latin1_General_CI_AS  = LTRIM(RTRIM(OSTL.gastl_loc_no))
		JOIN		tblSMCurrency				CY	ON	LTRIM(RTRIM(CY.strCurrency)) collate Latin1_General_CI_AS = LTRIM(RTRIM(OSTL.gastl_currency))
		LEFT JOIN	tblEMEntity					US	ON	LTRIM(RtRIM(US.strEntityNo)) collate Latin1_General_CI_AS  = LTRIM(RtRIM(OSTL.gastl_user_id))  
		LEFT JOIN	tblEMEntityType				UST	ON	UST.intEntityId = US.intEntityId AND UST.strType ='User'
		WHERE    OSTL.gastl_pd_yn			 <> 'Y'
			AND  OSTL.gastl_rec_type		 =  'F'
			AND  OSTL.gastl_pur_sls_ind		 =  'P'
			AND  OSTL.gastl_chk_no			 IS  NULL 
	   
	   SELECT @intFreightVoucherKey = MIN(intFreightVoucherKey)
	   FROM @tblFreightVoucher
	   
	   WHILE @intFreightVoucherKey > 0
	   BEGIN
			
			SET @VendorId        =   NULL
			SET @strTicketNumber =   NULL
			SET @LocationId      =   NULL
			SET @UserKey	     =   NULL

			SELECT
			 @VendorId		   = intVendorId
			,@strTicketNumber  = strTicketNumber
			,@LocationId	   = intCompanyLocationId
			,@UserKey          = intUserId
			FROM @tblFreightVoucher  
			WHERE intFreightVoucherKey = @intFreightVoucherKey

		
			 BEGIN TRANSACTION
			 					
				DELETE FROM @voucherDetailNonInventory
				
				SET @intCreatedBillId=0
									     
				  INSERT INTO @voucherDetailNonInventory   
				   (  
					 [intAccountId]  
					,[intItemId]  
					,[strMiscDescription]  
					,[dblQtyReceived]  
					,[dblDiscount]  
					,[dblCost]  
					,[intTaxGroupId]  
					)  
				   SELECT   
					 [intAccountId]         = NULL
					,[intItemId]  			= intItemId
					,[strMiscDescription]  	= strItemNo
					,[dblQtyReceived]  		= dblFreightUnit
					,[dblDiscount]  		= 0
					,[dblCost]  			= dblFreightRate
					,[intTaxGroupId]  		= NULL
				   FROM @tblFreightVoucher  
				   WHERE intFreightVoucherKey = @intFreightVoucherKey
				   
				   EXEC [dbo].[uspAPCreateBillData]   
				   @userId				 = @UserKey  
				  ,@vendorId		     = @VendorId  
				  ,@type				 = 1  
				  ,@voucherNonInvDetails = @voucherDetailNonInventory  
				  ,@shipTo				 = @LocationId  
				  ,@vendorOrderNumber	 = @strTicketNumber
				  ,@voucherDate			 = @dtmVoucherDate  
				  ,@billId				 = @intCreatedBillId OUTPUT
				  
				  IF @intCreatedBillId >0
				  BEGIN
					 COMMIT TRANSACTION
					 --Update APDetail table with Scale Ticket 

				  END
				  ELSE
				  BEGIN
				    ROLLBACK TRANSACTION
					RAISERROR (@ErrMsg,16,1);
				  END;  	
				   
		

	   SELECT @intFreightVoucherKey = MIN(intFreightVoucherKey)
	   FROM @tblFreightVoucher WHERE intFreightVoucherKey > @intFreightVoucherKey
	   END
	   	
END TRY

BEGIN CATCH
	SET @ErrMsg = ERROR_MESSAGE()
	RAISERROR (@ErrMsg,16,1,'WITH NOWAIT')
END CATCH
GO