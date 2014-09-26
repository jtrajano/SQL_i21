GO

IF EXISTS(select top 1 1 from sys.procedures where name = 'uspARImportMarketZone')
	DROP PROCEDURE uspARImportMarketZone
GO


--IF (SELECT TOP 1 ysnUsed FROM ##tblOriginMod WHERE strPrefix = 'AG' and strDBName = db_name()) = 1
--BEGIN
	EXEC('CREATE PROCEDURE uspARImportMarketZone
	@MarketZoneCode NVARCHAR(3) = NULL,
	@Update BIT = 0,
	@Total INT = 0 OUTPUT

	AS

	--Make first a copy of gamktmst. This will use to track all market zone already imported
	IF(OBJECT_ID(''dbo.tblARTempMarketZone'') IS NULL)
		SELECT * INTO tblARTempMarketZone FROM gamktmst
	
	--================================================
	--     UPDATE/INSERT IN ORIGIN	
	--================================================
	IF(@Update = 1 AND @MarketZoneCode IS NOT NULL) 
	BEGIN
		--UPDATE IF EXIST IN THE ORIGIN
		IF(EXISTS(SELECT 1 FROM gamktmst WHERE gamkt_key = @MarketZoneCode))
		BEGIN
			UPDATE gamktmst
				SET 
				gamkt_key = SUBSTRING(MktZone.strMarketZoneCode,1,3),
				gamkt_desc = SUBSTRING(MktZone.strDescription,1,20)
			FROM tblARMarketZone MktZone
				WHERE strMarketZoneCode = @MarketZoneCode AND gamkt_key = @MarketZoneCode
		END
		--INSERT IF NOT EXIST IN THE ORIGIN
		ELSE
			INSERT INTO gamktmst(
				gamkt_key,
				gamkt_desc
			)
			SELECT 
				SUBSTRING(MktZone.strMarketZoneCode,1,3),
				SUBSTRING(strDescription,1,20)
			FROM tblARMarketZone
			WHERE strMarketZoneCode = @MarketZoneCode
		
	RETURN;
	END


	--================================================
	--     ONE TIME MARKET ZONE SYNCHRONIZATION	
	--================================================
	IF(@Update = 0 AND @MarketZoneCode IS NULL) 
	BEGIN
	
		--1 Time synchronization here
		PRINT ''1 Time Market Zones Synchronization''

		DECLARE @originMarketZoneCode	NVARCHAR(3)
		DECLARE @strMarketZoneCode		NVARCHAR (3)
		DECLARE	@strDescription			NVARCHAR (MAX)
	
		DECLARE @Counter INT = 0
	
    
		--Import only those are not yet imported
		SELECT gamkt_key INTO #tmpgamktmst 
			FROM gamktmst
		LEFT JOIN tblARMarketZone
			ON gamktmst.gamkt_key COLLATE Latin1_General_CI_AS = tblARMarketZone.strMarketZoneCode COLLATE Latin1_General_CI_AS
		WHERE tblARMarketZone.strMarketZoneCode IS NULL
		ORDER BY gamktmst.gamkt_key DESC

		WHILE (EXISTS(SELECT 1 FROM #tmpgamktmst))
		BEGIN
		
			SELECT @originMarketZoneCode = gamkt_key FROM #tmpgamktmst

			SELECT TOP 1
				@strMarketZoneCode = gamkt_key,
				@strDescription = gamkt_desc
			FROM gamktmst
			WHERE gamkt_key = @originMarketZoneCode
		
			--Insert into tblARMarketZone
			INSERT [dbo].[tblARMarketZone]
			([strMarketZoneCode],[strDescription])
			VALUES
			(@strMarketZoneCode,@strDescription)						
	
		
			IF(@@ERROR <> 0) 
			BEGIN
				PRINT @@ERROR;
				RETURN;
			END

			DELETE FROM #tmpgamktmst WHERE gamkt_key = @originMarketZoneCode
		
		
			SET @Counter += 1
		END
	
	SET @Total = @Counter
	--To delete all record on temp table to determine if there are still record to import
	DELETE FROM tblARTempMarketZone
	END

	--================================================
	--     GET TO BE IMPORTED RECORDS	
	--================================================
	IF(@Update = 1 AND @MarketZoneCode IS NULL) 
	BEGIN
		SELECT @Total = COUNT(gamkt_key) from tblARTempMarketZone
	END'
	)

--END