IF EXISTS (SELECT TOP 1 1 FROM sys.procedures WHERE name = 'uspGRImportDiscountSchedule')
	DROP PROCEDURE uspGRImportDiscountSchedule
GO
CREATE PROCEDURE uspGRImportDiscountSchedule 
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
		
		IF EXISTS(SELECT 1 FROM tblGRDiscountSchedule)
			SELECT @Total = 0
		ELSE  
			SELECT @Total = COUNT(1) FROM ( SELECT DISTINCT gadsc_disc_schd_no,gadsc_com_cd,gadsc_currency FROM gadscmst )t

		RETURN @Total
	END

	INSERT INTO tblGRDiscountSchedule 
	(
		 intCurrencyId
		,intCommodityId
		,strDiscountDescription
		,intConcurrencyId
	)
	SELECT DISTINCT 
		 intCurrencyId			= Cur.intCurrencyID
		,intCommodityId			= Com.intCommodityId
		,strDiscountDescription = LTRIM(RTRIM(gadsc_disc_schd_no))
		,intConcurrencyId		= 1
	FROM gadscmst OdisSch
	JOIN tblICCommodity Com ON Com.strCommodityCode = LTRIM(RTRIM(OdisSch.gadsc_com_cd)) COLLATE Latin1_General_CS_AS
	JOIN tblSMCurrency Cur ON Cur.strCurrency = LTRIM(RTRIM(OdisSch.gadsc_currency)) COLLATE Latin1_General_CS_AS
	LEFT JOIN tblGRDiscountSchedule Sch ON Sch.intCurrencyId = Cur.intCurrencyID
		AND Sch.strDiscountDescription = LTRIM(RTRIM(gadsc_disc_schd_no))
		AND Sch.intCommodityId = Com.intCommodityId
	WHERE Sch.intCurrencyId IS NULL
		AND Sch.strDiscountDescription IS NULL
		AND Sch.intCommodityId IS NULL
END
