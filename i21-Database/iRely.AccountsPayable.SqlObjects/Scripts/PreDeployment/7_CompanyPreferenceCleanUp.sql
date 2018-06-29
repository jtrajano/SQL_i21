
IF EXISTS(SELECT NULL FROM sys.columns WHERE name = 'intAccountId' AND object_id = OBJECT_ID('tblGLAccount'))
BEGIN

	IF EXISTS(SELECT NULL FROM sys.columns WHERE name = 'intARAccountId' AND object_id = OBJECT_ID('tblARCompanyPreference'))
	BEGIN
		UPDATE
			tblARCompanyPreference 
		SET
			intARAccountId =  NULL
		WHERE
			intARAccountId IS NOT NULL
			AND NOT EXISTS(SELECT NULL FROM tblGLAccount GLA WHERE GLA.intAccountId = tblARCompanyPreference.intARAccountId)
	END

	
	IF EXISTS(SELECT NULL FROM sys.columns WHERE name = 'intDiscountAccountId' AND object_id = OBJECT_ID('tblARCompanyPreference'))
	BEGIN
		UPDATE
			tblARCompanyPreference 
		SET
			intDiscountAccountId =  NULL
		WHERE
			intDiscountAccountId IS NOT NULL
			AND NOT EXISTS(SELECT NULL FROM tblGLAccount GLA WHERE GLA.intAccountId = tblARCompanyPreference.intDiscountAccountId)
	END
	
	IF EXISTS(SELECT NULL FROM sys.columns WHERE name = 'intWriteOffAccountId' AND object_id = OBJECT_ID('tblARCompanyPreference'))
	BEGIN
		UPDATE
			tblARCompanyPreference 
		SET
			intWriteOffAccountId =  NULL
		WHERE
			intWriteOffAccountId IS NOT NULL
			AND NOT EXISTS(SELECT NULL FROM tblGLAccount GLA WHERE GLA.intAccountId = tblARCompanyPreference.intWriteOffAccountId)
	END	
	
	IF EXISTS(SELECT NULL FROM sys.columns WHERE name = 'intInterestIncomeAccountId' AND object_id = OBJECT_ID('tblARCompanyPreference'))
	BEGIN
		UPDATE
			tblARCompanyPreference 
		SET
			intInterestIncomeAccountId =  NULL
		WHERE
			intInterestIncomeAccountId IS NOT NULL
			AND NOT EXISTS(SELECT NULL FROM tblGLAccount GLA WHERE GLA.intAccountId = tblARCompanyPreference.intInterestIncomeAccountId)
	END		
	
	IF EXISTS(SELECT NULL FROM sys.columns WHERE name = 'intDeferredRevenueAccountId' AND object_id = OBJECT_ID('tblARCompanyPreference'))
	BEGIN
		UPDATE
			tblARCompanyPreference 
		SET
			intDeferredRevenueAccountId =  NULL
		WHERE
			intDeferredRevenueAccountId IS NOT NULL
			AND NOT EXISTS(SELECT NULL FROM tblGLAccount GLA WHERE GLA.intAccountId = tblARCompanyPreference.intDeferredRevenueAccountId)
	END	
	
	IF EXISTS(SELECT NULL FROM sys.columns WHERE name = 'intServiceChargeAccountId' AND object_id = OBJECT_ID('tblARCompanyPreference'))
	BEGIN
		UPDATE
			tblARCompanyPreference 
		SET
			intServiceChargeAccountId =  NULL
		WHERE
			intServiceChargeAccountId IS NOT NULL
			AND NOT EXISTS(SELECT NULL FROM tblGLAccount GLA WHERE GLA.intAccountId = tblARCompanyPreference.intServiceChargeAccountId)
	END		
	
	IF EXISTS(SELECT NULL FROM sys.columns WHERE name = 'intConversionAccountId' AND object_id = OBJECT_ID('tblARCompanyPreference'))
	BEGIN
		UPDATE
			tblARCompanyPreference 
		SET
			intConversionAccountId =  NULL
		WHERE
			intConversionAccountId IS NOT NULL
			AND NOT EXISTS(SELECT NULL FROM tblGLAccount GLA WHERE GLA.intAccountId = tblARCompanyPreference.intConversionAccountId)
	END				
		
END

