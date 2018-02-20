IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportDiscountTable')
	DROP PROCEDURE uspGRImportDiscountTable
GO
CREATE PROCEDURE uspGRImportDiscountTable 
	 @Checking BIT = 0
	,@UserId INT = 0
	,@Total INT = 0 OUTPUT
AS
BEGIN
	--================================================
	--     IMPORT GRAIN Discount Schedule
	--================================================
	IF (@Checking = 1)
	BEGIN
			
		IF EXISTS(SELECT 1 FROM tblGRDiscountId)
			SELECT @Total = 0
		ELSE  
			SELECT @Total = 1

		RETURN @Total
	END

	BEGIN		
		 
			DECLARE @DiscountId INT

			INSERT INTO tblGRDiscountId
			(
				  intCurrencyId
				 ,strDiscountId
				 ,strDiscountDescription
				 ,ysnDiscountIdActive
				 ,intConcurrencyId
			 )
			SELECT DISTINCT
				  intCurrencyId          = Cur.intCurrencyID
				 ,strDiscountId			 = LTRIM(RTRIM(gadsc_disc_schd_no)) 
				 ,strDiscountDescription = LTRIM(RTRIM(gadsc_disc_schd_no))
				 ,ysnDiscountIdActive    = 1
				 ,intConcurrencyId		 = 1
			FROM gadscmst OdisSch  
			JOIN tblSMCurrency Cur ON Cur.strCurrency = LTRIM(RTRIM(OdisSch.gadsc_currency)) COLLATE Latin1_General_CS_AS

			SET @DiscountId = SCOPE_IDENTITY()

			INSERT INTO tblGRDiscountLocationUse
			(
			   intDiscountId
			  ,intCompanyLocationId
			  ,ysnDiscountLocationActive
			  ,intConcurrencyId 
			)
			SELECT DISTINCT
				 intDiscountId				= @DiscountId
				,intCompanyLocationId		= intCompanyLocationId
				,ysnDiscountLocationActive  = 1
				,intConcurrencyId			= 1
				FROM dbo.gadscmst a 
				JOIN tblSMCompanyLocation b ON b.strLocationNumber=a.gadsc_loc_no COLLATE  Latin1_General_CS_AS 
			
				INSERT INTO tblGRDiscountCrossReference
				(
				      intDiscountId
					 ,intDiscountScheduleId
					 ,intConcurrencyId
				)
				SELECT DISTINCT
					 intDiscountId          = @DiscountId
					,intDiscountScheduleId  = intDiscountScheduleId
					,intConcurrencyId		= 1	
			     FROM tblGRDiscountSchedule
    END

END
GO