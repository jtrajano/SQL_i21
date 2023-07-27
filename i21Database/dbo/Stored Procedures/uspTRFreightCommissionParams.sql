create procedure uspTRFreightCommissionParams  
@dtmDateFrom nvarchar(50),    
@dtmDateTo nvarchar(50),    
@dtmRealDateFrom DATETIME,    
@dtmRealDateTo DATETIME,    
@intDriverId INT,  
@intShipViaId INT,  
@strDeliveryType nvarchar(100),    
@intFreightItemId INT,    
@intSurchargeItemId INT,    
@intFreightCategoryId INT,    
@dblFreightUnitCommissionPct INT,  
@dblOtherUnitCommissionPct INT  
      
as
BEGIN

	SET QUOTED_IDENTIFIER OFF      
	SET ANSI_NULLS ON      
	SET NOCOUNT ON      
	SET XACT_ABORT ON      
	SET ANSI_WARNINGS OFF      
   

	IF OBJECT_ID(N'tempdb..#tmpCommissionFreightReport') IS NOT NULL DROP TABLE #tmpCommissionFreightReport

	select dtmFrom = @dtmDateFrom    
	,dtmTo = @dtmDateTo    
	,dtmRealDateFrom = @dtmRealDateFrom    
	,dtmRealDateTo = @dtmRealDateTo    
	,strDeliveryType = @strDeliveryType  
	,intDriverId    
	,intFreightItemId = @intFreightItemId    
	,intSurchargeItemId = @intSurchargeItemId    
	,intFreightCategoryId = @intFreightCategoryId    
	,dblFreightUnitCommissionPct = @dblFreightUnitCommissionPct    
	,dblOtherUnitCommissionPct = @dblOtherUnitCommissionPct    
	,intShipViaId = @intShipViaId  
  
	,strDriverName    
	,dtmLoadDateTime    
	,strMovement    
	,strVendor = ISNULL(strVendor, '')    
	,strSupplyPoint = ISNULL(strSupplyPoint, '')    
	,strCustomerNumber = ISNULL(strCustomerNumber, '')    
	,strCustomerName = ISNULL(strCustomerName, '')    
	,intItemId    
	,strItemNo    
	,intItemCategoryId    
	,strItemCategory    
	,strItemDescription    
	,dblUnits    
	,dblPrice    
	,intInvoiceId = ISNULL(intInvoiceId, 0)  
	,strCompanyAddress     
	,strCompanyName    
	,intLoadHeaderId    
	,intLoadDistributionHeaderId    
	,intLoadDistributionDetailId  


	INTO #tmpCommissionFreightReport  
	from vyuTRGetFreightCommissionLine cl    
    
	where ((cl.intDriverId =  @intDriverId OR @intDriverId = 0))    
	and (cl.strDeliveryType = @strDeliveryType     
	  OR @strDeliveryType = 'All'     
	  OR cl.strDeliveryType = 'Other Charge'  
	  OR (RTRIM(LTRIM(ISNULL(cl.strReceiptLink, ''))) = '' AND cl.intItemCategoryId = @intFreightCategoryId))    
	AND (cl.dtmLoadDateTime >= @dtmRealDateFrom AND cl.dtmLoadDateTime <= @dtmRealDateTo)   
	AND (cl.intShipViaId = @intShipViaId OR @intShipViaId = 0)  
	order by cl.dtmLoadDateTime, cl.strMovement desc    
    

	IF ((SELECT COUNT(*) FROM #tmpCommissionFreightReport) > 0)
	  BEGIN
		SELECT * FROM #tmpCommissionFreightReport

	  END
	ELSE
	  BEGIN
		DECLARE @smCompanyName NVARCHAR(250)
		DECLARE @smCompanyAddress NVARCHAR(250)
		DECLARE @smCompanyCity NVARCHAR(250)
		DECLARE @smCompanyState NVARCHAR(250)
		DECLARE @smCompanyZip NVARCHAR(250)
		DECLARE @smCompanyCountry NVARCHAR(250)

		SELECT TOP 1
			@smCompanyName = strCompanyName
			,@smCompanyAddress = strAddress
			,@smCompanyCity = strCity
			,@smCompanyState = strState
			,@smCompanyZip = strZip
			,@smCompanyCountry = strCountry
		FROM tblSMCompanySetup

		SELECT
			dtmFrom = @dtmDateFrom    
			,dtmTo = @dtmDateTo    
			,dtmRealDateFrom = @dtmRealDateFrom    
			,dtmRealDateTo = @dtmRealDateTo    
			,strDeliveryType = @strDeliveryType  
			,intDriverId = 0
			,intFreightItemId = @intFreightItemId    
			,intSurchargeItemId = @intSurchargeItemId    
			,intFreightCategoryId = @intFreightCategoryId    
			,dblFreightUnitCommissionPct = @dblFreightUnitCommissionPct    
			,dblOtherUnitCommissionPct = @dblOtherUnitCommissionPct    
			,intShipViaId = @intShipViaId  
		  
			,strDriverName = 'i21 No Data'
			,dtmLoadDateTime = NULL    
			,strMovement = NULL
			,strVendor = NULL   
			,strSupplyPoint = NULL   
			,strCustomerNumber = NULL 
			,strCustomerName = NULL
			,intItemId = 0    
			,strItemNo = NULL   
			,intItemCategoryId = 0    
			,strItemCategory = NULL
			,strItemDescription = NULL    
			,dblUnits = 0   
			,dblPrice = 0
			,intInvoiceId = 0  
			,strCompanyAddress = dbo.fnARFormatCustomerAddress(NULL, NULL, NULL, @smCompanyAddress, @smCompanyCity, @smCompanyState, @smCompanyZip, @smCompanyCountry, NULL, 0) COLLATE Latin1_General_CI_AS        
			,strCompanyName = @smCompanyName  
			,intLoadHeaderId = 0  
			,intLoadDistributionHeaderId = 0  
			,intLoadDistributionDetailId = 0
	  END


	DROP TABLE #tmpCommissionFreightReport
END